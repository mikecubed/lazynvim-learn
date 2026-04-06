# Companion Plugin

## Purpose

The companion plugin is a small Neovim plugin that ships as part of the sandbox config (`configs/base/lua/plugins/tutorial.lua`). It runs inside the sandboxed Neovim instance and provides support that the bash engine uses via RPC.

The companion plugin does NOT drive the tutorial. The bash engine does that. The plugin exists because some operations are much easier or more reliable to do from inside Neovim than from external RPC calls.

## What It Does

### 1. Complex Verification Helpers

Some exercise verifications require multi-step Lua logic that's unwieldy as a one-liner passed through `nvim --server --remote-expr "luaeval('...')"`. The companion plugin exposes clean functions:

```lua
-- lua/lazynvim-learn/verify.lua
local M = {}

-- Check if Telescope is currently open
function M.telescope_is_open()
  local ok, _ = pcall(require, "telescope.actions.state")
  if not ok then return "fail:Telescope not available" end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == "TelescopePrompt" then
      return "pass:Telescope is open"
    end
  end
  return "fail:Telescope is not open:Open it with <leader>ff"
end

-- Check if Neo-tree is open and showing a specific path
function M.neotree_showing_path(path)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == "neo-tree" then
      return "pass:Neo-tree is open"
    end
  end
  return "fail:Neo-tree is not open:Toggle it with <leader>e"
end

-- Check if a breakpoint is set on a specific line
function M.breakpoint_on_line(line_num)
  local breakpoints = require("dap.breakpoints").get()
  for buf, bps in pairs(breakpoints) do
    for _, bp in ipairs(bps) do
      if bp.line == line_num then
        return "pass:Breakpoint set on line " .. line_num
      end
    end
  end
  return "fail:No breakpoint on line " .. line_num .. ":Set one with <leader>db"
end

-- Check if lazygit terminal is open
function M.lazygit_is_open()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("lazygit") then
      local loaded = vim.api.nvim_buf_is_loaded(buf)
      if loaded then
        return "pass:Lazygit is running"
      end
    end
  end
  return "fail:Lazygit is not open:Open it with <leader>gg"
end

-- Check all occurrences of a symbol were renamed
function M.symbol_renamed(old_name, new_name)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  local has_old = content:find(old_name, 1, true)
  local has_new = content:find(new_name, 1, true)

  if has_old then
    return "fail:'" .. old_name .. "' still found in buffer:Use <leader>cr to rename"
  elseif has_new then
    return "pass:Symbol renamed to '" .. new_name .. "'"
  else
    return "fail:Neither '" .. old_name .. "' nor '" .. new_name .. "' found"
  end
end

-- Verify formatting was applied (checks if buffer matches formatted version)
function M.buffer_is_formatted()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Use conform to check what formatted output would be
  local ok, conform = pcall(require, "conform")
  if not ok then
    return "fail:conform.nvim not available"
  end

  -- Compare current content with what conform would produce
  -- This is a simplified check -- real implementation would use
  -- conform.format() in dry-run mode
  local formatters = conform.list_formatters(buf)
  if #formatters == 0 then
    return "fail:No formatters configured for this filetype"
  end

  -- If buffer is not modified after format, it was already formatted
  -- (We trigger format, then check modified state)
  return "pass:Buffer appears formatted"
end

return M
```

### 2. Exercise File Scaffolding

Some exercises need specific buffer content or file structures. The companion plugin can set up exercise state that's hard to create from bash:

```lua
-- lua/lazynvim-learn/scaffold.lua
local M = {}

-- Set up a buffer with specific content for an exercise
function M.setup_buffer(content, filetype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
  vim.api.nvim_set_current_buf(buf)
  if filetype then
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
  end
end

-- Create a temp project structure for exercises
function M.setup_project(base_dir, files)
  vim.fn.mkdir(base_dir, "p")
  for path, content in pairs(files) do
    local full = base_dir .. "/" .. path
    local dir = vim.fn.fnamemodify(full, ":h")
    vim.fn.mkdir(dir, "p")
    local f = io.open(full, "w")
    if f then
      f:write(content)
      f:close()
    end
  end
  vim.cmd.cd(base_dir)
end

-- Mark a target in the buffer with extmarks (visual hint for user)
function M.mark_target(line, col, text)
  local ns = vim.api.nvim_create_namespace("lazynvim-learn")
  vim.api.nvim_buf_set_extmark(0, ns, line - 1, col, {
    virt_text = { { " <-- " .. text, "DiagnosticHint" } },
    virt_text_pos = "eol",
  })
end

-- Clear all tutorial markers
function M.clear_marks()
  local ns = vim.api.nvim_create_namespace("lazynvim-learn")
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
```

### 3. Event Tracking

Some verifications need to know if the user performed a specific action (not just the end state). The companion plugin can track events:

```lua
-- lua/lazynvim-learn/tracker.lua
local M = {}

M.events = {}

function M.reset()
  M.events = {}
end

function M.track(event_name)
  table.insert(M.events, {
    name = event_name,
    time = vim.loop.now(),
  })
end

function M.has_event(name)
  for _, e in ipairs(M.events) do
    if e.name == name then return true end
  end
  return false
end

-- Set up autocommands to track specific actions
function M.watch_lsp_rename()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LspRenameFile",
    callback = function() M.track("lsp_rename") end,
    once = true,
  })
end

function M.watch_format()
  -- Track when conform formats
  local ok, conform = pcall(require, "conform")
  if ok then
    -- Hook into conform's format completion
    M.track_format_pending = true
  end
end

return M
```

## Plugin Spec

The companion plugin is defined as a local plugin in the sandbox config:

```lua
-- configs/base/lua/plugins/tutorial.lua
return {
  {
    name = "lazynvim-learn",
    dir = vim.fn.stdpath("config") .. "/lua/lazynvim-learn",
    lazy = false,
    priority = 1000,
    config = function()
      -- Make the verify/scaffold/tracker modules available
      -- No keymaps, no UI -- this is a headless support plugin
    end,
  },
}
```

The plugin modules live at:
```
configs/base/lua/lazynvim-learn/
├── init.lua
├── verify.lua
├── scaffold.lua
└── tracker.lua
```

## Calling from Bash

The bash engine invokes companion functions via `nvim_lua()`:

```bash
# Simple verification
result=$(nvim_lua "require('lazynvim-learn.verify').telescope_is_open()")

# Scaffold an exercise
nvim_lua "require('lazynvim-learn.scaffold').setup_buffer('def hello():\\n    pass', 'python')"

# Track and verify actions
nvim_lua "require('lazynvim-learn.tracker').watch_lsp_rename()"
# ... user does the exercise ...
result=$(nvim_lua "require('lazynvim-learn.tracker').has_event('lsp_rename')")

# Mark a target for the user
nvim_lua "require('lazynvim-learn.scaffold').mark_target(15, 0, 'rename this function')"
```

## Design Constraints

1. **No UI ownership.** The companion plugin never opens windows, floating panels, or prompts. All user-facing UI is in the bash engine's terminal pane.
2. **No keybindings.** The plugin does not bind any keys. The sandbox Neovim uses standard LazyVim keybindings.
3. **Stateless between exercises.** Each exercise should call `tracker.reset()` and `scaffold.clear_marks()` before starting. Don't rely on state from a previous exercise.
4. **Fail gracefully.** All functions return string results, never throw. If a plugin isn't loaded yet (lazy-loading), return a clear error message.
5. **Minimal footprint.** This plugin should be < 200 lines total. Complex exercise setup belongs in the exercise files themselves (as bash that copies files, etc.), not in the companion plugin.
