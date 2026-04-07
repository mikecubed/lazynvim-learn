#!/usr/bin/env bash
# lessons/04-customization/05-lazyvim-extras.sh
# Module 4, Lesson 5: LazyVim Extras

lesson_info() {
    LESSON_TITLE="LazyVim Extras"
    LESSON_MODULE="04-customization"
    LESSON_DESCRIPTION="Browse and enable pre-packaged LazyVim Extras for languages, tools, and editor enhancements."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

verify_lazy_extras_open() {
    verify_filetype_visible "lazy"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What are LazyVim Extras?"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim ships a large library of optional feature packs called *Extras*.
Each Extra is a pre-configured bundle of plugins, LSP servers, formatters,
linters, and keymaps that work together out of the box.

Think of an Extra as a one-line recipe that turns a bare Neovim+LazyVim
setup into a fully configured development environment for a specific language
or workflow:

  lazyvim.plugins.extras.lang.python       — Pyright LSP + debugger + ruff
  lazyvim.plugins.extras.lang.typescript   — tsserver + ESLint + prettier
  lazyvim.plugins.extras.lang.rust         — rust-analyzer + crates.nvim
  lazyvim.plugins.extras.lang.go           — gopls + gofmt + delve debug
  lazyvim.plugins.extras.lang.java         — jdtls + lombok support

You opt in to exactly the languages and tools you need, and nothing else
is installed."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Extra Categories"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim organises Extras into categories. Browsing them helps you
discover features you did not know existed:

  lang.*      — language support (LSP, DAP, formatter, linter per language)
  editor.*    — editor enhancements (aerial, mini.files, overseer, …)
  ui.*        — visual improvements (mini.animate, edgy, smear-cursor, …)
  coding.*    — coding tools (copilot, codeium, luasnip, yanky, …)
  formatting.* — formatters (prettier, black, stylua, …)
  linting.*   — linters (eslint, pylint, shellcheck, …)
  dap.*       — debugger adapters (nlua, python, …)
  test.*      — test runners (neotest adapters)
  util.*      — utilities (octo, rest, …)

Each category represents a different dimension of the editor. You can mix and
match freely — enable the lang.python Extra, the editor.aerial Extra, and the
coding.copilot Extra all at once."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "How to Enable an Extra"
    # -----------------------------------------------------------------------

    engine_teach "There are two ways to enable a LazyVim Extra:

METHOD 1: The :LazyExtras UI (interactive)
  Run :LazyExtras to open an interactive browser. Use j/k to navigate, press
  x to toggle an Extra on or off, then press q and restart Neovim.
  LazyVim writes the selection to your lazyvim.json file automatically.

METHOD 2: Add an import line to lua/plugins/ (manual)
  Create or edit a file in lua/plugins/ and add an import:

  -- lua/plugins/extras.lua
  return {
    { import = 'lazyvim.plugins.extras.lang.python' },
    { import = 'lazyvim.plugins.extras.coding.copilot' },
  }

  This is equivalent to what the UI does under the hood. The manual approach
  is useful when you want the extra tracked in version control."

    engine_teach "Both methods produce the same result. The interactive UI is easier when
you are exploring; the file-based import is better for a config you keep in
git (dotfiles repository).

After enabling an Extra, run :Lazy sync to install the new plugins."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exploring :LazyExtras"
    # -----------------------------------------------------------------------

    engine_teach "The :LazyExtras browser shows you every available Extra with a short
description, and highlights which ones are currently enabled. Key controls
inside the browser:

  j / k        — move up and down
  x            — toggle the Extra under the cursor
  /            — search/filter Extras by name
  q            — close and write changes

The browser also shows which Extras have been enabled by LazyVim itself as
part of its default setup — those appear with a different indicator so you
know they are active even if you did not enable them explicitly."

    engine_show_key ":" "LazyExtras" "Open the LazyVim Extras browser"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "What an Extra Provides (Example: lang.python)"
    # -----------------------------------------------------------------------

    engine_teach "To make the concept concrete, here is what the lang.python Extra adds:

  Plugins installed:
    nvim-lspconfig      — wires up the Pyright LSP server
    nvim-dap            — Debug Adapter Protocol client
    nvim-dap-python     — Python-specific DAP adapter (uses debugpy)
    neotest             — test runner framework
    neotest-python      — Python test adapter (pytest, unittest, doctest)

  Formatters / linters configured:
    ruff                — extremely fast Python linter and formatter
    black               — alternative formatter (if ruff not preferred)

  Keymaps added (under <leader>d for debug, <leader>t for test):
    <leader>td          — run tests under cursor
    <leader>tl          — run last test
    <leader>ts          — toggle test summary
    <leader>db          — toggle breakpoint
    <leader>dc          — continue debugger

One import line. Everything wired up and ready to use."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Extras vs Manual Plugin Specs"
    # -----------------------------------------------------------------------

    engine_teach "You might wonder: why use an Extra instead of adding the plugin spec
yourself? The answer is integration effort.

When you add a plugin manually you need to:
  • Find the right combination of plugins that work together
  • Configure each one individually (LSP server name, formatter command, …)
  • Wire up the keymaps in a consistent way
  • Keep everything updated and compatible

An Extra does all of that work for you. The LazyVim maintainers test the
combinations and update them as plugins evolve.

Use Extras whenever LazyVim has one that covers your use case. Add manual
specs for plugins that LazyVim does not cover, or for highly personal
customisations of a plugin's behaviour."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Overriding What an Extra Configures"
    # -----------------------------------------------------------------------

    engine_teach "Enabling an Extra does not lock you in. Because lazy.nvim merges specs,
you can override any plugin that an Extra configures, just like any other
LazyVim default:

  -- lua/plugins/python-tweaks.lua
  return {
    {
      'mfussenegger/nvim-dap',   -- already added by lang.python Extra
      opts = {
        -- your custom DAP config here
      },
    },
  }

The Extra's spec and your spec are merged. Your opts keys win over the Extra's
defaults. You never need to fork or copy the Extra source."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise: Open :LazyExtras"
    # -----------------------------------------------------------------------

    engine_teach "Open the LazyVim Extras browser to explore what is available.

Run :LazyExtras and browse through the categories. Try pressing '/' to
filter by 'lang' and see all language Extras. Press 'q' to close when done.

The check passes while the Extras browser is open."

    engine_exercise "open-lazy-extras" \
        "Open :LazyExtras" \
        "Run :LazyExtras to open the Extras browser. Browse the available Extras, then type 'check' (you can close with 'q' afterwards)." \
        verify_lazy_extras_open \
        "In Normal mode type :LazyExtras and press Enter. The Extras browser will open." \
        "empty"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Quiz: What Do Extras Provide?"
    # -----------------------------------------------------------------------

    engine_quiz \
        "What is the correct way to enable a LazyVim Extra manually (file-based)?" \
        "Add opts = { extras = { 'lang.python' } } to lazy.lua" \
        "Create a lua/extras.lua file with enable('lang.python')" \
        "Add { import = 'lazyvim.plugins.extras.lang.python' } to a file in lua/plugins/" \
        "Run :set lazyextras+=lang.python from the command line" \
        3

    # -----------------------------------------------------------------------
    engine_section "Quiz: Extras vs Manual Specs"
    # -----------------------------------------------------------------------

    engine_quiz \
        "Can you override the configuration of a plugin installed by an Extra?" \
        "No — Extra configs are locked and cannot be changed" \
        "Yes — add a spec for the same plugin in lua/plugins/ and lazy.nvim merges them" \
        "Yes — but only by editing the Extra's source file in the lazy.nvim store" \
        "No — you must disable the Extra and configure the plugin from scratch" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim Extras are pre-packaged, opt-in feature bundles:

  • Browse all Extras with :LazyExtras
  • Enable interactively with x in the browser, or add an import line in lua/plugins/
  • Categories: lang.*, editor.*, ui.*, coding.*, formatting.*, linting.*, dap.*, test.*
  • Each Extra installs and wires up plugins, LSP servers, formatters, and keymaps
  • You can override any Extra's plugin config with your own spec in lua/plugins/
  • After enabling, run :Lazy sync to install new plugins

This is the end of the Customization module. You now have the full picture:

  Lesson 1 — Config directory layout and key files
  Lesson 2 — Plugin spec format, opts, lazy-loading, :Lazy
  Lesson 3 — Keymaps with vim.keymap.set and plugin keys fields
  Lesson 4 — Options with vim.opt and autocommands with nvim_create_autocmd
  Lesson 5 — Extras for one-line language and tool setup

With these skills you can shape LazyVim into exactly the editor you want,
without ever touching the source of the plugins themselves.

Next up: Module 5 — Workflows — putting everything together for real-world
development with LSP, Git, and debugging."

    engine_pause
}
