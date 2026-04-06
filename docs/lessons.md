# Lesson Outline

## Module Progression

Modules unlock sequentially. Each module requires 80% completion of the previous module. This prevents users from jumping ahead without foundations but allows skipping individual exercises that frustrate them.

---

## Module 1: Neovim Essentials

**Target audience:** Users coming from VS Code, Sublime, nano, or other non-modal editors. Also useful as a refresher for casual vim users.

**Prerequisite knowledge:** Basic terminal usage.

### 1.1 Modal Editing

- Why modes exist (the efficiency argument)
- Normal mode: the home base
- Insert mode: entering text (`i`, `a`, `o`, `I`, `A`, `O`)
- Visual mode: selecting text (`v`, `V`, `Ctrl-v`)
- Command-line mode: running commands (`:`)
- Returning to Normal mode (`Esc`, `Ctrl-[`, `jk` in LazyVim)
- The mode indicator in the statusline

**Exercises:**
1. Switch between all four modes (verify via `nvim_get_mode`)
2. Enter insert mode, type a specific sentence, return to normal mode (verify buffer content)
3. Enter visual mode, select a line, delete it (verify line count changed)

### 1.2 Motions

- Character motions: `h`, `j`, `k`, `l`
- Word motions: `w`, `b`, `e`, `W`, `B`, `E`
- Line motions: `0`, `^`, `$`
- Paragraph motions: `{`, `}`
- File motions: `gg`, `G`, `<number>G`
- Search motions: `f`, `F`, `t`, `T`, `;`, `,`
- Screen motions: `H`, `M`, `L`, `Ctrl-u`, `Ctrl-d`

**Exercises:**
1. Navigate to a specific line number (verify cursor position)
2. Jump to a specific word using `f`/`t` (verify cursor position)
3. Move to the end of the file and back (verify cursor position)

### 1.3 Text Objects

- The operator + motion/text-object model: `{operator}{count}{motion}`
- Inner vs around: `i` vs `a`
- Word objects: `iw`, `aw`
- Quote objects: `i"`, `a"`, `i'`, `a'`
- Bracket objects: `i(`, `a(`, `i{`, `a{`, `i[`, `a[`
- Tag objects: `it`, `at`
- Paragraph objects: `ip`, `ap`
- Combining with operators: `diw`, `ci"`, `ya{`, `>ip`

**Exercises:**
1. Delete a word using `diw` (verify word removed from line)
2. Change text inside quotes using `ci"` (verify content changed)
3. Yank a paragraph using `yip` (verify register content)

### 1.4 Buffers and Windows

- Buffers: in-memory file representations
- Listed vs unlisted buffers
- Buffer commands: `:e`, `:bn`, `:bp`, `:bd`
- Windows (splits): `:split`, `:vsplit`, `Ctrl-w` commands
- Moving between windows: `Ctrl-w h/j/k/l`
- Resizing windows: `Ctrl-w +/-/</>`
- Tabs (sparingly -- LazyVim uses bufferline instead)

**Exercises:**
1. Open a second file in a new buffer (verify buffer list)
2. Create a vertical split (verify window count)
3. Navigate between splits (verify active window changed)

### 1.5 Registers and Macros

- The unnamed register `""`
- Named registers `"a` through `"z`
- The system clipboard registers `"+` and `"*`
- The yank register `"0`
- Viewing registers: `:registers`
- Recording macros: `q{register}` ... `q`
- Playing macros: `@{register}`, `@@`
- Applying macros to ranges

**Exercises:**
1. Yank a line into register `a`, paste it elsewhere (verify register content)
2. Record a macro that adds a prefix to a line, apply it to 3 lines (verify buffer content)

---

## Module 2: LazyVim Navigation

**Target audience:** Users who have basic Neovim skills and want to learn the LazyVim distribution.

**Prerequisite knowledge:** Module 1 or existing vim/neovim comfort.

### 2.1 LazyVim Overview

- What LazyVim is (a Neovim config distribution, not a fork)
- The `lazy.nvim` plugin manager
- LazyVim's default leader key: `Space`
- The `:Lazy` dashboard
- How LazyVim organizes config: `lua/config/` and `lua/plugins/`
- LazyVim Extras: optional feature bundles

**Exercises:**
1. Open the Lazy dashboard with `:Lazy` (verify Lazy UI is open)
2. Check how many plugins are installed (quiz based on Lazy output)

### 2.2 Neo-tree (File Explorer)

- Opening Neo-tree: `<leader>e` (toggle), `<leader>E` (cwd)
- Navigation: `j`/`k` to move, `Enter` to open, `-` to go up
- File operations: `a` (add), `d` (delete), `r` (rename), `c` (copy), `m` (move)
- Filtering and searching within Neo-tree
- Closing Neo-tree: `q` or `<leader>e`

**Exercises:**
1. Open Neo-tree and navigate to a specific file (verify file opened)
2. Create a new file using Neo-tree (verify file exists on disk)
3. Rename a file using Neo-tree (verify old name gone, new name exists)

### 2.3 Telescope (Fuzzy Finder)

- The core concept: fuzzy matching across various sources
- `<leader>ff` - Find files
- `<leader>fg` / `<leader>/` - Live grep (search file contents)
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files
- `<leader>f"` - Registers
- `<leader>s` prefix: search commands (symbols, diagnostics, help, etc.)
- Telescope navigation: `Ctrl-j/k` or arrow keys, `Enter` to select, `Esc` to close

**Exercises:**
1. Find and open a file by name using `<leader>ff` (verify correct file open)
2. Search for a string across files using `<leader>/` (verify cursor on matching line)
3. Switch to a buffer using `<leader>fb` (verify active buffer changed)

### 2.4 Flash.nvim (Jump Motions)

- What Flash does: label-based jumping
- `s` in normal mode: search and jump with labels
- `S` in normal mode: Treesitter-based selection
- Flash in Telescope: `Ctrl-s` to toggle Flash in results
- Remote flash: `r` in operator-pending mode
- Comparison with traditional `/` search

**Exercises:**
1. Use `s` to jump to a specific word on screen (verify cursor position)
2. Use `S` to select a Treesitter node (verify visual selection active)

### 2.5 Which-Key and Discoverability

- What Which-Key does: shows available keybindings after pressing a prefix
- Press `<leader>` and wait -- see all Space-prefixed bindings
- Press `g` and wait -- see all g-prefixed bindings
- Press `]` or `[` and wait -- see bracket navigation
- Exploring LazyVim's keymap groups
- Using Which-Key to discover new commands

**Exercises:**
1. Use Which-Key to find the keymap for "Toggle Terminal" (quiz)
2. Use Which-Key to find the keymap for "Git Blame" (quiz)

---

## Module 3: Editing Power

**Target audience:** Users comfortable with LazyVim navigation who want to leverage its IDE features.

**Prerequisite knowledge:** Modules 1-2.

### 3.1 LSP Basics

- What LSP is and why it matters
- LazyVim's LSP setup: `mason.nvim` + `nvim-lspconfig`
- `:LspInfo` - see active language servers
- Go to definition: `gd`
- Go to references: `gr`
- Go to declaration: `gD`
- Go to implementation: `gI`
- Hover documentation: `K`
- Signature help: `Ctrl-k` in insert mode
- Rename symbol: `<leader>cr`
- Code actions: `<leader>ca`

**Exercises:**
1. Jump to a function definition using `gd` (verify cursor moved to definition line)
2. Find all references to a variable using `gr` (verify Telescope/quickfix opened)
3. Rename a symbol using `<leader>cr` (verify all occurrences changed)

### 3.2 Completions

- How nvim-cmp works
- Trigger: auto-popup or `Ctrl-Space`
- Navigation: `Ctrl-n`/`Ctrl-p` or `Tab`/`Shift-Tab`
- Accept: `Enter` or `Ctrl-y`
- Dismiss: `Ctrl-e`
- Completion sources: LSP, buffer, path, snippets
- Snippet expansion and navigation: `Tab` to jump between placeholders
- LazyVim's completion keymap summary

**Exercises:**
1. Use LSP completion to finish a function name (verify correct text inserted)
2. Use path completion to type a file path (verify path in buffer)

### 3.3 Formatting and Linting

- conform.nvim for formatting
- nvim-lint for linting
- Format on save (LazyVim default)
- Manual format: `<leader>cf`
- `:ConformInfo` - see active formatters
- Diagnostics from linters: `]d`/`[d` to navigate
- `<leader>cd` - line diagnostics float

**Exercises:**
1. Intentionally misformat code, trigger format with `<leader>cf` (verify formatting applied)
2. Navigate to the next diagnostic with `]d` (verify cursor moved to diagnostic line)

### 3.4 Treesitter

- What Treesitter is: syntax tree parsing
- Syntax highlighting: Treesitter vs regex
- Incremental selection: `Ctrl-Space` (init), `Ctrl-Space` (expand), `Backspace` (shrink)
- Treesitter text objects: function, class, parameter, etc.
- `:InspectTree` - see the syntax tree
- LazyVim's Treesitter-powered features

**Exercises:**
1. Use incremental selection to select a function body (verify selection range)
2. Use `:InspectTree` to identify the node type at cursor (quiz)

---

## Module 4: Customization

**Target audience:** Users who want to make LazyVim their own.

**Prerequisite knowledge:** Modules 1-3.

### 4.1 LazyVim File Structure

- `~/.config/nvim/lua/config/lazy.lua` - lazy.nvim bootstrap
- `~/.config/nvim/lua/config/options.lua` - vim options
- `~/.config/nvim/lua/config/keymaps.lua` - custom keymaps
- `~/.config/nvim/lua/config/autocmds.lua` - autocommands
- `~/.config/nvim/lua/plugins/*.lua` - plugin specs (merged with LazyVim defaults)
- How LazyVim's plugin specs are merged (extend, override, disable)

**Exercises:**
1. Open the LazyVim options file (verify correct file open)
2. Identify which file to edit to add a new keymap (quiz)

### 4.2 Adding Plugins

- Plugin spec format for lazy.nvim
- Adding a new plugin: create a file in `lua/plugins/`
- Basic spec: `return { "author/plugin-name" }`
- With config: `opts = {}`, `config = function()`, `keys = {}`
- Lazy-loading: `event`, `cmd`, `ft`, `keys` triggers
- Dependencies: `dependencies = {}`
- `:Lazy sync` after adding

**Exercises:**
1. View the current plugin list with `:Lazy` (verify Lazy UI open)
2. Quiz: what does the `keys` field in a plugin spec do?

### 4.3 Keymaps

- LazyVim's keymap conventions
- Adding keymaps in `lua/config/keymaps.lua`
- `vim.keymap.set(mode, lhs, rhs, opts)`
- Plugin-specific keymaps in plugin specs via `keys = {}`
- The `<leader>` key namespace
- Overriding LazyVim defaults
- Deleting a LazyVim default keymap

**Exercises:**
1. Find what `<leader>gg` does (quiz -- answer: lazygit)
2. Identify the keymap for toggling line numbers (quiz)

### 4.4 Options and Autocommands

- Setting vim options: `vim.opt.xxx = value`
- Common options: `number`, `relativenumber`, `tabstop`, `shiftwidth`, `wrap`, `scrolloff`
- What autocommands are: event-driven hooks
- `vim.api.nvim_create_autocmd(event, opts)`
- Common events: `BufEnter`, `BufWritePre`, `FileType`, `VimEnter`
- LazyVim's default autocommands and how to override

**Exercises:**
1. Check the current value of `scrolloff` (verify via `:set scrolloff?`)
2. Quiz: which event fires when you open a file?

### 4.5 LazyVim Extras

- What Extras are: curated feature bundles
- Browsing extras: `:LazyExtras`
- Language extras: `lang.python`, `lang.typescript`, `lang.rust`, etc.
- Editor extras: `editor.flash`, `editor.mini-files`, etc.
- Formatting extras: `formatting.prettier`, `formatting.black`, etc.
- Enabling an Extra: add to `lazy.lua` imports
- How Extras modify the plugin set

**Exercises:**
1. Open the Extras browser with `:LazyExtras` (verify UI open)
2. Quiz: what does a language Extra typically include?

---

## Module 5: Workflows

**Target audience:** Users ready to build real workflows with LazyVim.

**Prerequisite knowledge:** Modules 1-4.

### 5.1 Lazygit Integration

- What lazygit is
- Opening lazygit: `<leader>gg`
- Basic lazygit workflow: stage, commit, push
- Viewing diffs
- Blame: `<leader>gb` (git blame)
- Git hunk navigation: `]h`/`[h`
- Gitsigns features: stage hunk, reset hunk, preview hunk

**Exercises:**
1. Open lazygit with `<leader>gg` (verify terminal opened with lazygit)
2. Stage and commit a file change (verify git log shows new commit)

### 5.2 Terminal

- LazyVim's terminal integration
- Toggle terminal: `<leader>ft` (floating) or `<leader>fT` (root)
- Terminal mode: `Ctrl-/` to toggle, `Esc Esc` to exit terminal mode
- Sending commands to terminal
- Running code from the editor

**Exercises:**
1. Open a floating terminal with `<leader>ft` (verify terminal buffer exists)
2. Run a command in the terminal (verify terminal content)

### 5.3 Debugging with DAP

- What DAP is (Debug Adapter Protocol)
- LazyVim's debugging Extra: `dap.core`
- Setting breakpoints: `<leader>db`
- Starting debugger: `<leader>dc` (continue)
- Step controls: `<leader>ds` (step over), `<leader>di` (step into), `<leader>do` (step out)
- DAP UI: `<leader>du`
- Inspecting variables

**Exercises:**
1. Set a breakpoint on a specific line (verify breakpoint via DAP API)
2. Quiz: what is the difference between step over and step into?

### 5.4 Putting It Together

- Building a development workflow
- Session management with persistence plugins
- Working with multiple projects
- Remote development tips (Neovim over SSH)
- Recommended Extras for different languages
- Where to go next: LazyVim docs, Neovim docs, community resources
- Congratulations and completion trophy

**Exercises:**
1. Final challenge: open a project, find a function, rename it, format the file, commit the change (multi-step verification)

---

## Lesson Conventions

1. Every lesson starts with `engine_section` for its first topic
2. Use `engine_teach` for instruction text (auto-wraps and typewriter effect)
3. Use `engine_show_key` for keybinding displays
4. Use `engine_demo` for command demonstrations
5. Use `engine_pause` between sections so users can absorb content
6. Exercises go at the end of related sections, not all at the end
7. Each exercise must have a verification function and a hint
8. Cleanup any exercise state before the next exercise or lesson end
9. Quiz questions test understanding, not memorization
10. Estimated time per lesson: 5-10 minutes
