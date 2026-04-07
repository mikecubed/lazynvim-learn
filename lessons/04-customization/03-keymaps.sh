#!/usr/bin/env bash
# lessons/04-customization/03-keymaps.sh
# Module 4, Lesson 3: Keymaps

lesson_info() {
    LESSON_TITLE="Keymaps"
    LESSON_MODULE="04-customization"
    LESSON_DESCRIPTION="Add personal keybindings with vim.keymap.set and define keys in plugin specs."
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Check that <leader>wd exists (delete window — a standard LazyVim mapping).
# which-key intercepts leader maps so we search through nvim_get_keymap.
verify_leader_wd_exists() {
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_get_keymap(\"n\")):any(function(m) return m.lhs == \" wd\" end)")
    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Keymap <leader>wd exists"
        return 0
    else
        VERIFY_MESSAGE="Keymap <leader>wd not found"
        VERIFY_HINT="This mapping should exist by default in LazyVim. Try :nmap <Space>wd"
        return 1
    fi
}

# Check that jk insert-mode escape exists
verify_escape_to_normal() {
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_get_keymap(\"i\")):any(function(m) return m.lhs == \"jk\" end)")
    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Keymap jk exists in insert mode"
        return 0
    else
        VERIFY_MESSAGE="Keymap jk not found in insert mode"
        VERIFY_HINT="This mapping should exist by default in LazyVim"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "How Keymaps Work in Neovim"
    # -----------------------------------------------------------------------

    engine_teach "In Neovim every keymap maps a *left-hand side* (the key sequence you press)
to a *right-hand side* (the action that happens). Both sides can be a string
(another key sequence), a Lua function, or a Vim command.

Keymaps are *mode-specific*. The same key can do different things in Normal,
Insert, Visual, and other modes. You always specify which mode a keymap
applies to when you create it."

    engine_teach "The Lua function for creating keymaps is:

  vim.keymap.set(mode, lhs, rhs, opts)

Where:
  mode   — string or table: 'n', 'i', 'v', 'x', 'o', 'c', 't', or { 'n', 'v' }
  lhs    — the key sequence you want to press (e.g. '<leader>ff')
  rhs    — what to do (string command, key sequence, or Lua function)
  opts   — options table (desc, silent, noremap, buffer, …)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Your First Keymap"
    # -----------------------------------------------------------------------

    engine_teach "Here is a complete example — a Normal-mode map that saves the file:

  vim.keymap.set('n', '<leader>fs', '<cmd>w<cr>', {
      desc  = 'Save File',
      silent = true,
  })

Breaking it down:
  'n'           — Normal mode only
  '<leader>fs'  — Space + f + s (since Space is the leader)
  '<cmd>w<cr>'  — runs :w and presses Enter
  desc          — shown in which-key and :map output
  silent        — suppresses the command echo in the status line

The desc option is important: it is what appears in which-key when you press
Space and wait. Always add a meaningful description."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Common Mode Strings"
    # -----------------------------------------------------------------------

    engine_teach "Mode strings you will use most often:

  'n'   — Normal mode
  'i'   — Insert mode
  'v'   — Visual and Select mode
  'x'   — Visual mode only (excludes Select)
  'o'   — Operator-pending mode (e.g. after pressing 'd' or 'y')
  'c'   — Command-line mode
  't'   — Terminal mode
  ''    — All modes (equivalent to :map)
  { 'n', 'v' }  — multiple modes at once

For most personal keymaps you will use 'n'. For completion or snippet maps
you might use 'i'. Passing a table lets you share a single mapping across
multiple modes."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The opts Table"
    # -----------------------------------------------------------------------

    engine_teach "Common options you can pass in the opts table:

  desc    = 'Human-readable description'  -- shown in which-key
  silent  = true   -- suppress command echo in status line
  noremap = true   -- prevent recursive remapping (default true in keymap.set)
  buffer  = 0      -- apply to current buffer only (0 = current, or buf number)
  nowait  = true   -- do not wait for a longer key sequence
  expr    = true   -- rhs is evaluated as a Lua expression

Note: vim.keymap.set uses noremap = true by default (unlike the old :nmap
command). This means you almost never need to set it explicitly."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Where to Put Your Keymaps"
    # -----------------------------------------------------------------------

    engine_teach "You have two natural homes for keymaps in LazyVim:

  1. lua/config/keymaps.lua
     For personal keymaps that are not tied to any particular plugin.
     Examples: quick save, toggle line numbers, window navigation shortcuts.

  2. The keys field in a plugin spec (lua/plugins/)
     For keymaps that *load* or *activate* a specific plugin.
     lazy.nvim registers these keys immediately at startup so they work even
     before the plugin is loaded — pressing them for the first time triggers
     the load.

A good rule of thumb: if the keymap only makes sense when a plugin is
installed, put it in the plugin spec. Otherwise, put it in keymaps.lua."

    engine_teach "Example of keymaps in a plugin spec:

  return {
    {
      'folke/todo-comments.nvim',
      keys = {
        { ']t', function() require('todo-comments').jump_next() end,
          desc = 'Next Todo Comment' },
        { '[t', function() require('todo-comments').jump_prev() end,
          desc = 'Previous Todo Comment' },
      },
    },
  }

When you press ]t, lazy.nvim loads todo-comments.nvim on demand and then
immediately runs the jump_next() function."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Overriding and Disabling LazyVim Keymaps"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim ships with many default keymaps. You may want to override some
or remove ones that conflict with your workflow.

To override a LazyVim keymap, just call vim.keymap.set with the same lhs in
keymaps.lua. Your definition runs after LazyVim's and wins.

To disable a LazyVim keymap entirely, set its rhs to false in a plugin spec:

  return {
    {
      'folke/which-key.nvim',
      keys = {
        { '<leader>?', false },   -- remove LazyVim's 'which-key help' binding
      },
    },
  }

You can also use vim.keymap.del(mode, lhs) in keymaps.lua, but the false
trick inside the spec is cleaner because it is collocated with the plugin."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Inspecting Existing Keymaps"
    # -----------------------------------------------------------------------

    engine_teach "To see what is mapped and find conflicts, use these tools:

  :map          — show all Normal-mode maps
  :nmap         — Normal mode only
  :imap         — Insert mode only
  :vmap         — Visual mode only
  <leader>sk    — keymap picker (search by description or key)
  <leader>?     — which-key cheat sheet for the current mode

The keymap picker (<leader>sk) is the fastest way to explore
all mappings — just type a word from the description and it narrows instantly."

    engine_show_key "Space" "sk" "Search all keymaps"
    engine_show_key "Space" "?" "which-key cheat sheet"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Quiz: vim.keymap.set Syntax"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Which vim.keymap.set call correctly maps <leader>q to :quit in Normal mode?" \
        "vim.keymap.set('n', '<leader>q', ':quit<CR>', { desc = 'Quit' })" \
        "vim.keymap.set('<leader>q', 'n', ':quit<CR>', { desc = 'Quit' })" \
        "vim.keymap.set('n', '<leader>q', 'quit', { desc = 'Quit' })" \
        "vim.keymap.set({ desc = 'Quit' }, 'n', '<leader>q', ':quit<CR>')" \
        1

    # -----------------------------------------------------------------------
    engine_section "Quiz: Where Do Plugin Keymaps Go?"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Where is the best place to define a keymap that lazy-loads a plugin when pressed?" \
        "lua/config/keymaps.lua, using vim.keymap.set" \
        "The keys field inside the plugin spec in lua/plugins/" \
        "init.lua, before lazy.nvim is bootstrapped" \
        "lua/config/autocmds.lua, inside a BufReadPost autocommand" \
        2

    # -----------------------------------------------------------------------
    engine_section "Discovering Keymaps with Which-Key"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim uses which-key to show available keymaps as you type.
When you press Space (the leader key) and wait, which-key displays all
available <leader> keymaps organized by group:

  w — windows (wd = delete window, wm = maximize, ...)
  f — find/files (ff = find file, fg = live grep, ...)
  g — git (gg = lazygit, gb = blame, ...)
  c — code (cr = rename, cf = format, ...)
  s — search (search pickers)

Pressing any prefix key (like g, ], [) also triggers which-key after a
short delay, showing what follows. This is the fastest way to discover
keymaps without memorizing them."

    engine_pause

    engine_teach "Let's test your knowledge."

    engine_quiz \
        "What does <leader>wd do in LazyVim?" \
        "Delete word" \
        "Delete window" \
        "Download file" \
        "Debug watch" \
        2

    engine_quiz \
        "Which built-in key combination is equivalent to Escape for leaving Insert mode?" \
        "Ctrl-c" \
        "Ctrl-[" \
        "Ctrl-n" \
        "Ctrl-x" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now know how to work with keymaps in LazyVim:

  • vim.keymap.set(mode, lhs, rhs, opts) is the Lua keymap API
  • Always add a desc so which-key can display it
  • Personal keymaps go in lua/config/keymaps.lua
  • Plugin-triggering keymaps go in the keys field of the plugin spec
  • Override LazyVim maps by calling vim.keymap.set with the same lhs
  • Disable a map with false in a plugin spec's keys table
  • Explore all maps with <leader>sk or <leader>?

Next up: vim.opt settings and autocommands — tuning editor behaviour and
reacting to events."

    engine_pause
}
