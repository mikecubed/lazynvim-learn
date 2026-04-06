# Architecture

## Overview

lazynvim-learn is an interactive terminal-based tutorial for learning Neovim and LazyVim. It is a pure bash application that runs inside a tmux pane, spawns sandboxed Neovim instances for exercises, and verifies user actions by querying Neovim state via its RPC interface.

The user manages their own tmux session. The tutorial assumes it is running inside tmux but does not create or manage tmux sessions itself (unlike tmux-learn). This makes it suitable for remote SSH workflows where the user already has tmux running.

## Runtime Model

```
User's tmux session
├── Pane 0 (top): lazynvim-learn bash process
│   └── Reads lessons, shows UI, drives exercise loop
└── Pane 1 (bottom): Sandboxed Neovim instance
    └── NVIM_APPNAME=lazynvim-learn
    └── Listens on /tmp/lazynvim-learn-<pid>.sock
```

The tutorial splits the current tmux window vertically. The top pane runs the bash tutorial engine. The bottom pane runs Neovim with an isolated configuration. The engine communicates with Neovim over a Unix domain socket using `nvim --server`.

## Directory Structure

```
lazynvim-learn
├── lazynvim-learn             # Entry point (bash executable)
├── lib/
│   ├── engine.sh              # Lesson runner, exercise state machine
│   ├── ui.sh                  # Terminal UI primitives (ANSI escape codes)
│   ├── nvim_helpers.sh        # Neovim RPC wrapper functions
│   ├── verify.sh              # Exercise verification via nvim RPC
│   ├── progress.sh            # Flat-file progress tracking
│   └── sandbox.sh             # Neovim sandbox lifecycle (launch, kill, reset)
├── lessons/
│   ├── 01-neovim-essentials/
│   │   ├── 01-modal-editing.sh
│   │   ├── 02-motions.sh
│   │   ├── 03-text-objects.sh
│   │   ├── 04-buffers-windows.sh
│   │   └── 05-registers.sh
│   ├── 02-lazyvim-navigation/
│   │   ├── 01-lazyvim-overview.sh
│   │   ├── 02-neo-tree.sh
│   │   ├── 03-telescope.sh
│   │   ├── 04-flash-nvim.sh
│   │   └── 05-which-key.sh
│   ├── 03-editing-power/
│   │   ├── 01-lsp-basics.sh
│   │   ├── 02-completions.sh
│   │   ├── 03-formatting-linting.sh
│   │   └── 04-treesitter.sh
│   ├── 04-customization/
│   │   ├── 01-lazyvim-structure.sh
│   │   ├── 02-adding-plugins.sh
│   │   ├── 03-keymaps.sh
│   │   ├── 04-options-autocmds.sh
│   │   └── 05-lazyvim-extras.sh
│   └── 05-workflows/
│       ├── 01-lazygit.sh
│       ├── 02-terminal.sh
│       ├── 03-debugging-dap.sh
│       └── 04-putting-it-together.sh
├── configs/
│   ├── base/                  # Complete LazyVim config for the sandbox
│   │   └── lua/
│   │       ├── config/
│   │       │   ├── lazy.lua
│   │       │   ├── keymaps.lua
│   │       │   ├── options.lua
│   │       │   └── autocmds.lua
│   │       └── plugins/
│   │           └── tutorial.lua   # Companion plugin (see below)
│   └── exercise-files/        # Sample files for exercises
│       ├── sample.py
│       ├── sample.lua
│       ├── sample.js
│       └── sample.md
└── docs/
    ├── architecture.md        # This file
    ├── lessons.md             # Module and lesson outline
    ├── verification.md        # Verification API reference
    └── companion-plugin.md    # Companion plugin spec
```

## Component Responsibilities

### Entry Point (`lazynvim-learn`)

The main bash script. Responsibilities:
- Check prerequisites (bash 4.0+, nvim 0.9+, tmux, active tmux session)
- First-run setup: copy `configs/base/` to `~/.config/lazynvim-learn/` and run headless plugin sync
- Source all library files
- Drive the main menu loop (module selection, lesson selection, continue, reset)
- Module unlock logic (80% of previous module required)

Does NOT bootstrap into tmux. Exits with an error if not inside a tmux session, telling the user to start one.

### Engine (`lib/engine.sh`)

Direct port from tmux-learn with these changes:
- `engine_exercise` sandbox types change from tmux session/split to nvim sandbox modes
- `engine_demo` executes commands inside Neovim via RPC instead of shell eval
- New: `engine_nvim_keys` sends keystrokes to the sandbox Neovim for demonstrations

API (available to lesson files):
- `engine_section "Title"` - section header
- `engine_teach "Text..."` - typewriter-style instruction
- `engine_pause` - wait for Enter
- `engine_demo "desc" "cmd"` - show a command
- `engine_show_key "Leader" "ff" "Find files"` - keybinding display
- `engine_quiz "Question?" "A" "B" "C" 2` - quiz (last arg = correct index)
- `engine_exercise "id" "Title" "Instructions" verify_func "hint" "sandbox-type"` - interactive exercise
- `engine_nvim_keys "keys"` - send keys to sandbox Neovim (for demonstrations)
- `engine_nvim_open "file"` - open a file in sandbox Neovim

### UI (`lib/ui.sh`)

Direct port from tmux-learn. Same ANSI UI primitives. One change:
- `ui_term_width` uses `tmux display-message -p '#{pane_width}'` since we're always inside tmux

### Neovim Helpers (`lib/nvim_helpers.sh`)

Thin wrappers around `nvim --server $NVIM_SOCKET` for introspection:

```bash
NVIM_SOCKET=""  # Set by sandbox_launch

nvim_eval "expr"              # --remote-expr, returns stdout
nvim_lua "lua_expr"           # luaeval() wrapper
nvim_exec "vim_command"       # --remote-send + command mode
nvim_send_keys "keys"         # --remote-send raw keys
nvim_is_running               # check if socket responds
nvim_wait_ready               # poll until nvim is responsive
nvim_get_mode                 # returns current mode string
nvim_get_bufname              # current buffer filename
nvim_get_filetype             # current buffer filetype
nvim_get_cursor               # line,col of cursor
nvim_get_line "n"             # content of line n
nvim_get_current_line         # content of cursor line
nvim_get_register "reg"       # content of a register
nvim_get_option "opt"         # value of a vim option
nvim_get_var "var"            # value of a vim variable
```

### Verification (`lib/verify.sh`)

Exercise verification functions. Each sets `VERIFY_MESSAGE` and optionally `VERIFY_HINT`, returns 0 (pass) or 1 (fail). Uses `nvim_helpers.sh` for all Neovim state queries.

See `docs/verification.md` for the full API.

### Progress (`lib/progress.sh`)

Direct port from tmux-learn. Flat-file tracking at `~/.lazynvim-learn/progress`. Lessons identified by `module/lesson-name` keys with `complete` or `in-progress` status.

### Sandbox (`lib/sandbox.sh`)

Manages the sandboxed Neovim instance lifecycle:

```bash
NVIM_APPNAME="lazynvim-learn"
NVIM_SOCKET="/tmp/lazynvim-learn-$$.sock"
SANDBOX_PANE=""

sandbox_launch [file]         # Split tmux pane, launch nvim with --listen
sandbox_kill                  # Kill the nvim pane
sandbox_reset [file]          # Kill and relaunch
sandbox_open_file "path"      # Open a file in the running sandbox
sandbox_setup_exercise "dir"  # Copy exercise files to a temp dir, open in nvim
sandbox_is_alive              # Check if sandbox pane and nvim process exist
```

The sandbox uses `NVIM_APPNAME=lazynvim-learn` which makes Neovim use `~/.config/lazynvim-learn/` as its config directory, completely isolated from the user's real Neovim config.

### Companion Plugin (`configs/base/lua/plugins/tutorial.lua`)

A small Neovim plugin that ships with the sandbox config. It does NOT drive the tutorial -- the bash engine does that. It provides:

1. **RPC query helpers** - Lua functions the bash engine can call via `nvim_lua()` for complex verifications that are easier to express in Lua than chained `--remote-expr` calls
2. **Exercise scaffolding** - Sets up buffers, creates sample content, configures exercise-specific state
3. **Visual indicators** - Optional extmarks/virtual text showing exercise targets in the buffer

See `docs/companion-plugin.md` for details.

### Lesson Files (`lessons/<module>/<nn>-<topic>.sh`)

Each lesson is a bash script defining two functions:

```bash
lesson_info() {
    LESSON_TITLE="Finding Files with Telescope"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Use Telescope to fuzzy-find and open files."
    LESSON_TIME="8 minutes"
    LESSON_PREREQUISITES="02-lazyvim-navigation/01-lazyvim-overview"
}

lesson_run() {
    engine_section "What is Telescope?"
    engine_teach "Telescope is a fuzzy finder..."

    engine_exercise \
        "telescope-1" \
        "Find a File" \
        "Use <leader>ff to find and open sample.py" \
        verify_telescope_exercise \
        "Press Space then ff to open Telescope, type 'sample.py', press Enter" \
        "file"

    engine_teach "Great work! Telescope is one of the most-used tools in LazyVim."
}

verify_telescope_exercise() {
    verify_file_open "sample.py"
}
```

## Sandbox Types for Exercises

The `engine_exercise` sixth argument specifies what sandbox state to set up:

| Type | Behavior |
|------|----------|
| `"file"` | Launch sandbox with a specific exercise file open |
| `"dir"` | Launch sandbox in a temp directory with exercise files |
| `"empty"` | Launch sandbox with an empty buffer |
| `"config"` | Launch sandbox pointed at the config directory for config-editing exercises |
| `"current"` | Use the already-running sandbox as-is (no reset) |
| `"none"` | No sandbox needed (quiz-only or teach-only exercise) |

## Data Flow

```
Lesson file
  │
  ├── engine_teach/section/pause → ui.sh → ANSI to terminal (top pane)
  │
  ├── engine_exercise
  │     ├── sandbox.sh → tmux split-window → nvim --listen (bottom pane)
  │     ├── User works in Neovim
  │     ├── User types "check" in top pane
  │     ├── verify_func() → nvim_helpers.sh → nvim --server query
  │     ├── Result displayed via ui.sh
  │     └── Loop until pass/skip/quit
  │
  └── progress.sh → ~/.lazynvim-learn/progress
```

## Prerequisites

- bash 4.0+
- Neovim 0.9+ (for `NVIM_APPNAME` support, `--listen`, RPC stability)
- tmux (any reasonably recent version, for pane splitting)
- git (for LazyVim plugin installation on first run)
- Internet connection (first run only, for plugin download)

## First-Run Bootstrap

On first launch, if `~/.config/lazynvim-learn/` does not exist:

1. Copy `configs/base/` to `~/.config/lazynvim-learn/`
2. Display a "Setting up..." message
3. Run `NVIM_APPNAME=lazynvim-learn nvim --headless "+Lazy! sync" +qa`
4. Wait for exit, verify `lazy-lock.json` exists
5. Report success or error

Subsequent launches skip this step. A `--reset-config` flag forces re-setup.

## Key Differences from tmux-learn

| Aspect | tmux-learn | lazynvim-learn |
|--------|-----------|----------------|
| Subject | tmux | Neovim + LazyVim |
| Runtime | Inside tmux it creates | Inside user's existing tmux |
| Sandbox | tmux sessions | Neovim with NVIM_APPNAME isolation |
| Verification | tmux CLI state queries | Neovim RPC (nvim --server) |
| Bootstrap | Auto-creates tmux session | Requires existing tmux session |
| First-run setup | None | Plugin installation (~30s) |
| Companion plugin | None | Small Lua plugin in sandbox config |
