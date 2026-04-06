#!/usr/bin/env bash
# lessons/04-customization/04-options-autocmds.sh
# Module 4, Lesson 4: Options and Autocommands

lesson_info() {
    LESSON_TITLE="Options and Autocommands"
    LESSON_MODULE="04-customization"
    LESSON_DESCRIPTION="Tune editor behaviour with vim.opt and automate workflows with nvim_create_autocmd."
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Configuring Neovim with vim.opt"
    # -----------------------------------------------------------------------

    engine_teach "Neovim has hundreds of built-in options that control how it looks and
behaves. In Lua you set them through the vim.opt table, which is the modern
replacement for the old Vimscript :set command.

The syntax is simple:

  vim.opt.number         = true    -- show line numbers
  vim.opt.relativenumber = true    -- relative numbers (great for motions)
  vim.opt.tabstop        = 2       -- width of a tab character
  vim.opt.shiftwidth     = 2       -- spaces used for each indent level
  vim.opt.expandtab      = true    -- convert tabs to spaces
  vim.opt.wrap           = false   -- disable line wrapping
  vim.opt.scrolloff      = 8       -- keep 8 lines visible above/below cursor
  vim.opt.signcolumn     = 'yes'   -- always show the sign column (git, LSP)
  vim.opt.colorcolumn    = '80'    -- highlight column 80 as a ruler"

    engine_teach "LazyVim already sets most of these to sensible values. Open
lua/config/options.lua to see what it pre-configures, and add only the
settings you want to override. Less is more — every override is something
you are responsible for maintaining."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "vim.opt vs vim.o vs vim.g"
    # -----------------------------------------------------------------------

    engine_teach "Neovim exposes several option tables in Lua. Understanding the difference
helps you know which one to use:

  vim.opt   — the recommended way to set options; supports Lua operators
              for list/set options (e.g. vim.opt.path:append('**'))

  vim.o     — thin wrapper, equivalent to vim.opt but without operator
              support; vim.o.number = true works but is more limited

  vim.g     — global variables (vim.g.mapleader = ' ')
              This is how you set the leader key and plugin global vars

  vim.b     — buffer-local variables
  vim.w     — window-local variables

For options that should apply everywhere, use vim.opt. For plugin-specific
globals (like g:loaded_foobar), use vim.g."

    engine_teach "vim.opt supports Lua-style operators for options that take lists:

  vim.opt.path:append('**')         -- add ** to the path
  vim.opt.wildignore:append('*.o')  -- add *.o to wildignore
  vim.opt.shortmess:remove('I')     -- remove 'I' from shortmess
  vim.opt.formatoptions:remove('o') -- stop auto-inserting comment leader

These are much cleaner than the old Vimscript set path+=** syntax."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Setting the Leader Key"
    # -----------------------------------------------------------------------

    engine_teach "The leader key must be set *before* lazy.nvim loads (so plugins can use
it in their specs). In LazyVim this is done at the very top of lazy.lua or
init.lua:

  vim.g.mapleader      = ' '   -- Space as leader
  vim.g.maplocalleader = '\\'  -- Backslash as local leader

You will almost never change these from the LazyVim defaults. If you do, make
sure the assignment happens before any require() calls that load plugins."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "What are Autocommands?"
    # -----------------------------------------------------------------------

    engine_teach "Autocommands (autocmds) let you run Lua code in response to Neovim
events. Neovim fires events at well-defined moments — when a file is opened,
when you save, when the cursor moves, when a buffer is closed, and many more.

The Lua API for creating autocmds is:

  vim.api.nvim_create_autocmd('EventName', {
      pattern = '*.lua',      -- file pattern (optional)
      group   = group_id,     -- autocmd group (optional but recommended)
      callback = function(ev)
          -- code to run
      end,
  })

The callback receives a table ev with fields like buf (buffer number),
file (file path), and match (the pattern that triggered the event)."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Common Autocmd Events"
    # -----------------------------------------------------------------------

    engine_teach "Events you will reach for most often:

  BufReadPost    — after a file's content has been loaded into a buffer
  BufWritePre    — just before a buffer is saved to disk (great for formatting)
  BufWritePost   — after a buffer has been saved
  BufEnter       — when entering a buffer (switching to it)
  BufLeave       — when leaving a buffer

  FileType       — when a buffer's filetype is detected/set
  LspAttach      — when an LSP client attaches to a buffer

  InsertEnter    — entering Insert mode
  InsertLeave    — leaving Insert mode
  ModeChanged    — whenever the mode changes (very general)

  VimEnter       — after Neovim has fully started
  VimLeavePre    — just before Neovim exits
  ColorScheme    — after a colorscheme is loaded

  CursorHold     — cursor has not moved for 'updatetime' milliseconds
  TextChanged    — text in Normal mode has changed
  TextChangedI   — text in Insert mode has changed"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Using Autocmd Groups"
    # -----------------------------------------------------------------------

    engine_teach "Autocmds should be created inside a *group* so they can be cleared and
recreated without duplication. This is especially important if your config
file is sourced more than once (e.g. during reload).

  local group = vim.api.nvim_create_augroup('MyAutocmds', { clear = true })

  vim.api.nvim_create_autocmd('BufWritePre', {
      group   = group,
      pattern = '*.lua',
      callback = function()
          vim.lsp.buf.format({ async = false })
      end,
  })

The clear = true option removes any previously registered autocmds in the
group, preventing duplicates on reload. Always use groups in your config."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Practical Autocmd Examples"
    # -----------------------------------------------------------------------

    engine_teach "A few autocmds that are genuinely useful in everyday editing:

1. Highlight yanked text for 300ms:

  vim.api.nvim_create_autocmd('TextYankPost', {
      group    = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
      callback = function()
          vim.highlight.on_yank({ timeout = 300 })
      end,
  })

2. Strip trailing whitespace on save:

  vim.api.nvim_create_autocmd('BufWritePre', {
      group    = vim.api.nvim_create_augroup('TrimWhitespace', { clear = true }),
      pattern  = '*',
      callback = function()
          vim.cmd([[%s/\\s\\+$//e]])
      end,
  })

3. Set local options for specific filetypes:

  vim.api.nvim_create_autocmd('FileType', {
      group    = vim.api.nvim_create_augroup('MarkdownSettings', { clear = true }),
      pattern  = 'markdown',
      callback = function()
          vim.opt_local.wrap       = true
          vim.opt_local.linebreak  = true
          vim.opt_local.spell      = true
      end,
  })

Note vim.opt_local — it applies the option to the current buffer only."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Where LazyVim's Autocmds Live"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim itself registers a number of autocmds that enhance the editing
experience — things like auto-resizing splits when the terminal is resized,
restoring cursor position on file open, and toggling relative numbers based
on mode.

You can see them in your lua/config/autocmds.lua (which by default is almost
empty and ready for your additions) and inside the LazyVim source (accessible
via :Lazy and opening the lazynvim plugin entry).

If a LazyVim autocmd bothers you, you can clear it by name:

  vim.api.nvim_clear_autocmds({ group = 'lazyvim_group_name' })

But it is usually better to read the LazyVim source first to understand why
the autocmd is there before removing it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Quiz: Setting an Option in Lua"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Which Lua line correctly enables relative line numbers in Neovim?" \
        "vim.set.relativenumber = true" \
        "set relativenumber = true" \
        "vim.opt.relativenumber = true" \
        "vim.options['relativenumber'] = true" \
        3

    # -----------------------------------------------------------------------
    engine_section "Quiz: Autocmd Events"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Which event fires just BEFORE a buffer is written to disk (ideal for auto-formatting)?" \
        "BufWritePost" \
        "BufReadPost" \
        "BufWritePre" \
        "FileType" \
        3

    # -----------------------------------------------------------------------
    engine_section "Quiz: Autocmd Groups"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Why should you pass { clear = true } when creating an autocmd group?" \
        "It speeds up autocmd execution by clearing old caches" \
        "It prevents duplicate autocmds if the config file is reloaded" \
        "It clears the screen before the autocmd runs" \
        "It is required for the group to work at all" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now know how to fine-tune Neovim's behaviour at two levels:

  vim.opt            — set global options (tabstop, wrap, number, …)
  vim.opt_local      — set buffer or window-local options
  vim.g              — set global variables (leader key, plugin flags)
  nvim_create_autocmd — run code when events fire (FileType, BufWritePre, …)
  nvim_create_augroup — group autocmds to avoid duplication on reload

Put your option overrides in lua/config/options.lua and your autocommands in
lua/config/autocmds.lua. LazyVim loads both automatically.

Next up: LazyVim Extras — enabling pre-packaged language and editor feature
packs with a single import."

    engine_pause
}
