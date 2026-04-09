# lazynvim-learn

An interactive terminal tutorial for learning Neovim and LazyVim. Practice real editing skills in a sandboxed Neovim instance with guided lessons, quizzes, and timed drills -- all from your terminal.

## Features

- **30+ guided lessons** across 5 modules covering Neovim essentials, LazyVim navigation, editing power tools, customization, and real workflows
- **Interactive exercises** with automatic verification -- the tutorial checks your work inside a live Neovim instance via RPC
- **Timed drills** (10 sessions) for building muscle memory with scoring and progress tracking
- **Quick refresher** mode for a fast 5-minute skills review
- **Sandboxed environment** -- uses its own config (`NVIM_APPNAME=lazynvim-learn`) so your existing Neovim setup is untouched
- **Progress tracking** with module unlocking (80% completion gates)

## Curriculum

| Module | Topics |
|--------|--------|
| 1. Neovim Essentials | Modal editing, motions, text objects, buffers/windows, registers |
| 2. LazyVim Navigation | Overview, Neo-tree, Telescope, Flash.nvim, Which-key |
| 3. Editing Power | LSP basics, completions, formatting/linting, Treesitter |
| 4. Customization | LazyVim structure, plugins, keymaps, options/autocmds, extras |
| 5. Workflows | Lazygit, terminal, debugging (DAP), putting it all together |
| 6. Refresher | Quick 5-minute skills review |
| 7. Drills | 10 timed practice sessions with scoring |

## Requirements

- **Bash** 4.0+
- **Neovim** 0.12.0+
- **tmux** (must be running inside a tmux session)
- **git**

## Installation

Clone the repo and run the entry point:

```bash
git clone https://github.com/mikecubed/lazynvim-learn.git
cd lazynvim-learn
./lazynvim-learn
```

On first run, the tutorial copies a LazyVim config to `~/.config/lazynvim-learn/` and syncs plugins. Your existing Neovim configuration is not affected.

### macOS note

macOS ships Bash 3.x. Install a newer version:

```bash
brew install bash
```

## Usage

```bash
# Start the tutorial
./lazynvim-learn

# Show version
./lazynvim-learn --version

# Re-copy config and re-sync plugins
./lazynvim-learn --reset-config
```

The tutorial splits your tmux window into two panes: the top pane runs the lesson engine, and the bottom pane runs a sandboxed Neovim where you practice.

## How It Works

The tutorial engine is pure Bash. It communicates with a sandboxed Neovim instance over a Unix domain socket using `nvim --server` RPC commands. Exercises are verified automatically by querying Neovim state (buffer contents, cursor position, mode, etc.) from Bash or via a small companion Lua plugin.

## Development

```bash
# Run the test suite
bash test/test_runner.sh

# Run a single lesson for testing
bash test/run-lesson.sh lessons/01-neovim-essentials/01-modal-editing.sh
```

See the `docs/` directory for architecture details, lesson authoring conventions, and the verification API.

## License

[MIT](LICENSE)
