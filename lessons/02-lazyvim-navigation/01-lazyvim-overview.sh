#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/01-lazyvim-overview.sh
# Module 2, Lesson 1: LazyVim Overview

lesson_info() {
    LESSON_TITLE="LazyVim Overview"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Understand what LazyVim is, how lazy.nvim manages plugins, and how the config is structured."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

verify_lazy_dashboard_open() {
    verify_reset
    # Check for the lazy.nvim UI — could be filetype "lazy" or buffer name containing "lazy"
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_wins()):any(function(w) local b=vim.api.nvim_win_get_buf(w) local ft=vim.bo[b].filetype local name=vim.api.nvim_buf_get_name(b) return ft=='lazy' or name:lower():find('lazy') ~= nil end)")
    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="The lazy.nvim dashboard is open!"
        return 0
    else
        VERIFY_MESSAGE="No window with filetype 'lazy' found"
        VERIFY_HINT="Type :Lazy (capital L) and press Enter"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is LazyVim?"
    # -----------------------------------------------------------------------

    engine_teach "Neovim is a highly extensible editor — but a fresh install is bare-bones.
You need to configure keymaps, choose plugins, wire up an LSP client, set up
completion, and more. Doing all that from scratch takes days.

LazyVim is a *Neovim distribution*: a curated set of sane defaults, pre-wired
plugins, and opinionated keymaps that gives you a polished IDE experience
without writing hundreds of lines of Lua yourself. It is not a plugin — it is
a complete, ready-to-use Neovim configuration that you can extend."

    engine_teach "LazyVim is built on top of lazy.nvim, the plugin manager written by
Folke Vanhoucke (the same author as LazyVim). lazy.nvim handles downloading,
updating, lazy-loading, and profiling every plugin in your setup."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Space Leader"
    # -----------------------------------------------------------------------

    engine_teach "In LazyVim the *leader key* is Space. Almost every feature has a
mnemonic keybinding that starts with <Space>:

  <Space>f  — Find things (files, text, buffers …)
  <Space>b  — Buffer commands
  <Space>c  — Code actions (LSP)
  <Space>g  — Git commands
  <Space>w  — Window management
  <Space>x  — Diagnostics / trouble list
  <Space>s  — Search (grep, symbols, …)

You never have to remember them all at once. LazyVim integrates which-key,
so after pressing Space you will see a pop-up menu listing every available
continuation."

    engine_show_key "Space" "" "Open which-key popup (leader prefix)"
    engine_show_key "Space" "?" "Show all available keymaps"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The lazy.nvim Plugin Manager"
    # -----------------------------------------------------------------------

    engine_teach "lazy.nvim keeps your plugins organised and up to date. You interact
with it through the :Lazy command, which opens an interactive dashboard where
you can:

  I  — Install any missing plugins
  U  — Update all installed plugins
  S  — Sync (install + update + clean in one step)
  X  — Clean plugins that are no longer required
  P  — Show the startup profile to see what is slow
  L  — Show the change log for recent updates

You can also manage individual plugins by searching in the dashboard and
pressing Enter on a plugin name."

    engine_show_key ":" "Lazy" "Open the lazy.nvim plugin manager dashboard"
    engine_show_key "Space" "l" "Open lazy.nvim (LazyVim shortcut)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Config Directory Structure"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim follows the standard Neovim config layout at
~/.config/nvim/ (or ~/.config/lazynvim-learn/ in this sandbox):

  init.lua              — entry point; bootstraps lazy.nvim
  lua/config/
    options.lua         — vim.opt.* settings
    keymaps.lua         — your personal keymaps
    autocmds.lua        — autocommands
  lua/plugins/          — YOUR plugin overrides and additions
    example.lua         — LazyVim ships a commented example here

Everything in lua/plugins/ is automatically loaded. Drop a file there to
add a plugin, override a LazyVim default, or disable something you do not need.
You never touch the LazyVim source directly — it is just a plugin."

    engine_teach "The separation is intentional:
  • LazyVim's defaults live inside the lazy.nvim plugin store (~/.local/share/…)
  • Your personal tweaks live in ~/.config/nvim/lua/plugins/
  • Updates to LazyVim never overwrite your customisations"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Extras: Opt-in Feature Packs"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim ships dozens of optional feature packs called *Extras*. Each
Extra bundles a set of related plugins pre-configured to work together. Examples:

  lazyvim.plugins.extras.lang.typescript   — TypeScript LSP + tools
  lazyvim.plugins.extras.lang.python       — Pyright + debugger + venv
  lazyvim.plugins.extras.ui.mini-animate   — smooth scroll animations
  lazyvim.plugins.extras.editor.telescope  — Telescope fuzzy finder
  lazyvim.plugins.extras.coding.copilot    — GitHub Copilot integration

To enable an Extra, add one line to lua/plugins/extras.lua:
  { import = 'lazyvim.plugins.extras.lang.python' }

You can browse all available Extras with :LazyExtras."

    engine_show_key ":" "LazyExtras" "Browse and toggle LazyVim Extras"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Open the lazy.nvim Dashboard"
    # -----------------------------------------------------------------------

    engine_teach "Let's see lazy.nvim in action. Open the plugin manager dashboard by
running the :Lazy command. You should see a list of all installed plugins.

Press 'q' inside the dashboard to close it when you are done exploring."

    engine_exercise "open-lazy-dashboard" \
        "Open the :Lazy Dashboard" \
        "Type :Lazy and press Enter to open the lazy.nvim plugin manager. The dashboard will appear in a floating window. Explore for a moment, then press 'check'." \
        verify_lazy_dashboard_open \
        "In Normal mode, type a colon then: Lazy — and press Enter." \
        "empty"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Quiz: The Leader Key"
    # -----------------------------------------------------------------------

    engine_quiz \
        "What is the leader key in LazyVim?" \
        "Backslash (\\)" \
        "Space" \
        "Comma (,)" \
        "Ctrl" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now understand the LazyVim ecosystem:

  • LazyVim is a Neovim distribution, not just a plugin
  • lazy.nvim is the plugin manager — use :Lazy to manage plugins
  • Space is the leader key; which-key shows available commands after it
  • Your config lives in lua/plugins/ — LazyVim's source is separate
  • Extras are opt-in feature packs you enable with one import line

Next up: Neo-tree — LazyVim's file explorer and project navigator."

    engine_pause
}
