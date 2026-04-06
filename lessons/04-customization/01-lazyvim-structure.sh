#!/usr/bin/env bash
# lessons/04-customization/01-lazyvim-structure.sh
# Module 4, Lesson 1: LazyVim Config Structure

lesson_info() {
    LESSON_TITLE="LazyVim Config Structure"
    LESSON_MODULE="04-customization"
    LESSON_DESCRIPTION="Understand the config directory layout and the purpose of each key file."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

verify_options_file_open() {
    verify_file_open "options.lua"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Your Config is Just Lua"
    # -----------------------------------------------------------------------

    engine_teach "One of the things that makes Neovim stand out is that your entire
configuration is written in Lua — a real programming language. No arcane
vimscript, no INI files. If you can write a conditional or a loop in Lua, you
can configure Neovim.

LazyVim gives you a well-organized directory structure so you always know
where to put things. Once you understand the layout, customising your editor
becomes straightforward."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Config Directory"
    # -----------------------------------------------------------------------

    engine_teach "Your Neovim config lives at:

  ~/.config/nvim/

In this tutorial the sandbox uses:

  ~/.config/lazynvim-learn/

Everything inside follows the same structure, so the skills transfer directly.
The root of the config directory contains one file that bootstraps everything:"

    engine_teach "  init.lua

This is the entry point. In a LazyVim setup it typically contains only a few
lines — it bootstraps lazy.nvim (the plugin manager) and hands control over
to LazyVim. You rarely need to edit it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "lua/config/ — Your Personal Settings"
    # -----------------------------------------------------------------------

    engine_teach "Inside lua/config/ you will find four files that LazyVim loads
automatically during startup:

  lua/config/
    options.lua   — vim.opt.* settings (tab width, line numbers, wrap, …)
    keymaps.lua   — your personal keybindings (vim.keymap.set)
    autocmds.lua  — autocommands (things that run on events like BufWrite)
    lazy.lua      — lazy.nvim bootstrap and configuration

LazyVim loads all four files for you. You do not need to require() them
yourself — just put your code in the right file and it will take effect."

    engine_show_key "Space" "fc" "Open config directory (Find Config)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "options.lua — Changing Editor Behaviour"
    # -----------------------------------------------------------------------

    engine_teach "options.lua is where you tune how the editor behaves. LazyVim already
sets sensible defaults, so this file is for overriding things you want
different. For example:

  vim.opt.relativenumber = false   -- turn off relative line numbers
  vim.opt.tabstop = 4              -- 4-space tabs instead of 2
  vim.opt.wrap = true              -- enable line wrapping
  vim.opt.scrolloff = 10           -- keep 10 lines visible above/below cursor
  vim.opt.colorcolumn = '80'       -- show a ruler at column 80

The vim.opt table is the Lua interface to Neovim's option system. Almost
every :set command you have seen in Vimscript has a direct vim.opt equivalent."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "keymaps.lua — Personal Keybindings"
    # -----------------------------------------------------------------------

    engine_teach "keymaps.lua is where you add your own keybindings using vim.keymap.set.
LazyVim's built-in mappings are defined elsewhere (inside the LazyVim plugin),
so this file is purely additive — you are adding on top, not replacing.

A typical entry looks like:

  vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float,
      { desc = 'Line Diagnostics' })

The first argument is the mode ('n' = normal, 'i' = insert, 'v' = visual),
the second is the key sequence, the third is the action, and the fourth is
an options table. The desc field is what appears in which-key."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "lua/plugins/ — Plugin Overrides and Additions"
    # -----------------------------------------------------------------------

    engine_teach "lua/plugins/ is where your customisation really lives. Every .lua file
in this directory is automatically loaded by lazy.nvim. You can have as many
files as you like — one per plugin, one per topic, or one giant file. The
name does not matter; only the content does.

Each file returns a Lua table (or table of tables) describing plugins:

  -- lua/plugins/colorscheme.lua
  return {
    { 'folke/tokyonight.nvim', opts = { style = 'moon' } },
  }

LazyVim merges your specs with its own, so you can override any of its
defaults by returning a spec with the same plugin name."

    engine_teach "LazyVim ships an example file at lua/plugins/example.lua. It contains
commented-out snippets showing common customisation patterns. Reading through
it is one of the best ways to learn the spec format."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "configs/base/ in This Tutorial"
    # -----------------------------------------------------------------------

    engine_teach "In this tutorial the 'config' sandbox type opens a read-only view of
the LazyVim config that ships with lazynvim-learn. The files are real Lua
files — you can explore them to see how the companion plugin and sandbox
configuration work.

The sandbox Neovim instance is separate from your real Neovim config. Nothing
you do inside the exercises will affect ~/.config/nvim/."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise: Open options.lua"
    # -----------------------------------------------------------------------

    engine_teach "Navigate to the config directory and open options.lua. You can use:

  :e lua/config/options.lua    — relative path from the config root
  <leader>ff                   — find files, then type 'options'

The check passes when options.lua is the active buffer."

    engine_exercise "open-options-lua" \
        "Open options.lua" \
        "Open the file lua/config/options.lua in the sandbox. Use :e lua/config/options.lua or <leader>ff and search for 'options'. Press 'check' when the file is open." \
        verify_options_file_open \
        "Try :e lua/config/options.lua or press Space ff and type 'options', then Enter." \
        "config"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Quiz: Config File Purposes"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Which file should you edit to change vim.opt settings (like tab width or line numbers)?" \
        "init.lua" \
        "lua/config/options.lua" \
        "lua/plugins/example.lua" \
        "lua/config/keymaps.lua" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "The LazyVim config directory at a glance:

  init.lua                — bootstrap; rarely touched
  lua/config/options.lua  — vim.opt.* settings
  lua/config/keymaps.lua  — your personal vim.keymap.set calls
  lua/config/autocmds.lua — event-driven automation
  lua/config/lazy.lua     — lazy.nvim bootstrap config
  lua/plugins/            — plugin specs; every .lua here is auto-loaded

Keep your personal tweaks in lua/config/ and your plugin work in lua/plugins/.
That boundary keeps things easy to understand and maintain.

Next up: Adding and configuring plugins with the lazy.nvim spec format."

    engine_pause
}
