#!/usr/bin/env bash
# lessons/04-customization/02-adding-plugins.sh
# Module 4, Lesson 2: Adding Plugins

lesson_info() {
    LESSON_TITLE="Adding Plugins"
    LESSON_MODULE="04-customization"
    LESSON_DESCRIPTION="Learn the lazy.nvim plugin spec format, opts, lazy-loading, and how to sync plugins."
    LESSON_TIME="15 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

verify_lazy_dashboard_open() {
    verify_filetype_visible "lazy"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "How lazy.nvim Knows About Plugins"
    # -----------------------------------------------------------------------

    engine_teach "Every plugin in your setup is described by a *spec* — a Lua table that
tells lazy.nvim where to find the plugin and how to configure it. Specs live
inside files in lua/plugins/. lazy.nvim scans that directory on startup and
merges all the specs it finds.

The minimal spec is just a string:

  return { 'github-user/repo-name' }

That single line is enough for lazy.nvim to install and load the plugin. Of
course you usually want more control — that is where the full spec format
comes in."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Full Spec Table"
    # -----------------------------------------------------------------------

    engine_teach "A complete plugin spec looks like this:

  return {
    {
      'stevearc/oil.nvim',          -- [1] plugin source (required)
      dependencies = {              -- plugins this one needs
        'nvim-tree/nvim-web-devicons',
      },
      opts = {                      -- passed to require('oil').setup()
        default_file_explorer = true,
        columns = { 'icon' },
      },
      lazy = false,                 -- load at startup (not lazily)
      keys = {                      -- keymaps that trigger loading
        { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
      },
      event = 'VeryLazy',           -- OR load after this event
      cmd = 'Oil',                  -- OR load when this command is run
      ft = 'oil',                   -- OR load for this filetype
    },
  }"

    engine_teach "You do not need all those fields every time. The most common ones are:

  [1]           — the plugin source string (always required)
  opts          — config table passed to setup(); avoids writing a config fn
  dependencies  — other plugins that must be loaded first
  keys          — keymaps; load the plugin only when one is pressed
  event         — load on a Neovim event (e.g. 'BufReadPost', 'VeryLazy')
  cmd           — load when this Ex command is first used
  lazy          — set to false to force eager loading at startup"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "opts vs config"
    # -----------------------------------------------------------------------

    engine_teach "There are two ways to configure a plugin after it loads:

  opts = { ... }
    The simplest approach. lazy.nvim calls require('plugin').setup(opts)
    automatically. Use this whenever a plugin supports a setup() function
    (nearly all modern Neovim plugins do).

  config = function(_, opts)
    A full Lua function called after the plugin loads. Receives the merged
    opts table as its second argument. Use this when you need more than just
    setup() — e.g. setting buffer-local options, mapping keys dynamically,
    or running setup code only when a condition is met.

In practice, opts covers 90% of cases. Use config when opts is not enough."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Lazy-loading: Why and How"
    # -----------------------------------------------------------------------

    engine_teach "lazy.nvim earned its name from *lazy-loading*: plugins are loaded only
when they are actually needed, keeping startup time fast.

The four main lazy-loading triggers are:

  keys = { ... }     Load when the user presses a mapped key
  cmd  = 'CmdName'   Load when the user runs an Ex command
  event = 'Event'    Load after a Neovim event fires
  ft = 'filetype'    Load when a buffer with that filetype is opened

If you specify none of these, lazy.nvim uses heuristics (or loads eagerly
if lazy = false).

LazyVim's built-in plugin specs already set these triggers correctly for
every bundled plugin. When you add your own plugins, choosing the right
trigger is the key to keeping startup fast."

    engine_teach "Common events used for lazy-loading:

  'VeryLazy'     — fires after the UI is ready; good for tools not needed immediately
  'BufReadPost'  — fires after a buffer's file has been read
  'BufWritePre'  — fires just before a buffer is saved
  'InsertEnter'  — fires when entering Insert mode
  'LspAttach'    — fires when an LSP client attaches to a buffer

'VeryLazy' is a lazy.nvim custom event (not a built-in Neovim event) that
is a convenient catch-all for deferred loading."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Overriding LazyVim's Default Plugin Config"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim pre-configures many plugins with its own opts. To override a
setting, add a spec with the same plugin name to lua/plugins/. lazy.nvim
*merges* specs from different sources, so you only need to specify the keys
you want to change:

  -- lua/plugins/overrides.lua
  return {
    {
      'nvim-lualine/lualine.nvim',
      opts = {
        options = { theme = 'catppuccin' },
      },
    },
  }

This changes the lualine theme without touching any of LazyVim's other
lualine settings. The merge is deep, so nested tables are combined rather
than replaced."

    engine_teach "To *disable* a plugin that LazyVim enables by default, set enabled = false:

  return {
    { 'folke/noice.nvim', enabled = false },
  }

That is all it takes. You do not need to comment out or delete any LazyVim
source code."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Installing and Syncing with :Lazy"
    # -----------------------------------------------------------------------

    engine_teach "After you add a new spec to lua/plugins/, you need to install it.
lazy.nvim provides the :Lazy command for this:

  :Lazy sync      — install missing + update existing + clean removed plugins
  :Lazy install   — install only missing plugins (no updates)
  :Lazy update    — update existing plugins
  :Lazy clean     — remove plugins no longer in your specs
  :Lazy health    — run health checks for all plugins
  :Lazy profile   — show startup-time profile

The dashboard shows each plugin's status: installed (green), not installed
(grey), with errors (red). You can also type in the dashboard to filter
by plugin name and press Enter to see its details."

    engine_show_key "Space" "l"  "Open :Lazy dashboard (LazyVim shortcut)"
    engine_show_key ":" "Lazy" "Open :Lazy dashboard"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Quiz: Plugin Spec Format"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Which field in a lazy.nvim plugin spec is automatically passed to require('plugin').setup()?" \
        "config" \
        "setup" \
        "opts" \
        "options" \
        3

    # -----------------------------------------------------------------------
    engine_section "Quiz: Lazy-loading Triggers"
    # -----------------------------------------------------------------------

    engine_quiz \
        "You want a plugin to load only when the user runs ':FormatToggle'. Which spec field do you use?" \
        "event = 'FormatToggle'" \
        "cmd = 'FormatToggle'" \
        "keys = { 'FormatToggle' }" \
        "lazy = 'FormatToggle'" \
        2

    # -----------------------------------------------------------------------
    engine_section "Exercise: Open the :Lazy Dashboard"
    # -----------------------------------------------------------------------

    engine_teach "Open the lazy.nvim plugin manager dashboard with :Lazy. Browse the
installed plugins for a moment — notice the load time column on the right.
Press 'q' inside the dashboard when you are done exploring.

The check passes while the dashboard is open (before you press 'q')."

    engine_exercise "open-lazy-dashboard" \
        "Open the :Lazy Dashboard" \
        "Run :Lazy to open the plugin manager dashboard. Explore the plugin list, then press 'check' (you can close with 'q' afterwards)." \
        verify_lazy_dashboard_open \
        "In Normal mode type :Lazy and press Enter to open the dashboard." \
        "empty"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now know how to add and configure plugins with lazy.nvim:

  • Every plugin is described by a spec table in lua/plugins/
  • opts is passed to setup(); use config for more complex setup
  • Lazy-load with keys, cmd, event, or ft to keep startup fast
  • Override LazyVim defaults by returning a spec with the same plugin name
  • Disable any plugin with enabled = false
  • :Lazy sync installs, updates, and cleans in one step

Next up: Keymaps — adding your own bindings and overriding LazyVim defaults."

    engine_pause
}
