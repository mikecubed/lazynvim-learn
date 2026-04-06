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
  local ok, dap_bps = pcall(require, "dap.breakpoints")
  if not ok then return "fail:nvim-dap not available" end

  local breakpoints = dap_bps.get()
  for _, bps in pairs(breakpoints) do
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
      if vim.api.nvim_buf_is_loaded(buf) then
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

-- Verify formatting was applied
function M.buffer_is_formatted()
  local buf = vim.api.nvim_get_current_buf()
  local ok, conform = pcall(require, "conform")
  if not ok then
    return "fail:conform.nvim not available"
  end

  local formatters = conform.list_formatters(buf)
  if #formatters == 0 then
    return "fail:No formatters configured for this filetype"
  end

  return "pass:Buffer appears formatted"
end

return M
