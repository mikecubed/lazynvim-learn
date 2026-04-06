#!/usr/bin/env bash
# lessons/03-editing-power/04-treesitter.sh
# Module 3, Lesson 4: Treesitter

lesson_info() {
    LESSON_TITLE="Treesitter"
    LESSON_MODULE="03-editing-power"
    LESSON_DESCRIPTION="Understand how Treesitter drives syntax highlighting, code folding, and structural navigation in LazyVim."
    LESSON_TIME="13 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: user entered Visual mode via Treesitter incremental selection.
# We just confirm Visual mode is active — the point is that they used v +
# repeat to expand the selection node by node.
verify_visual_selection_active() {
    verify_mode "v"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is Treesitter?"
    # -----------------------------------------------------------------------

    engine_teach "Treesitter is a parser generator and incremental parsing library.
Neovim embeds it to build a real, live syntax tree of every file you edit.

Traditional editors use regular expressions to colorize code — fast, but
easily confused by nesting and edge cases. Treesitter parses the file into
an actual tree of nodes: functions, arguments, strings, operators. Because
the tree is always up to date, every feature built on top of it is precise."

    engine_teach "What Treesitter powers in LazyVim:

  Syntax highlighting   — accurate, scope-aware colors even in complex files
  Indentation           — correct auto-indent based on code structure
  Code folding          — fold whole functions or blocks, not just indent levels
  Incremental selection — expand/shrink selections along the parse tree
  Text objects          — af (around function), if (inside function), etc.
  :InspectTree          — see the raw parse tree of the current file"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Installed Parsers and :TSInstall"
    # -----------------------------------------------------------------------

    engine_teach "Each language needs its own Treesitter parser. LazyVim installs the
most common ones automatically via the ensure_installed list in the plugin
spec. You can see what is installed with:"

    engine_show_key "" ":TSInstallInfo" "List all installed and available parsers"
    engine_show_key "" ":TSInstall"     "Install a parser: :TSInstall python"
    engine_show_key "" ":TSUpdate"      "Update all installed parsers"

    engine_teach "You can also add parsers permanently in your own config:

  -- lua/plugins/treesitter.lua
  return {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = { 'rust', 'toml', 'dockerfile' },
    },
  }

LazyVim merges your list with its defaults, so you never have to repeat
the built-in ones."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Incremental Selection"
    # -----------------------------------------------------------------------

    engine_teach "One of Treesitter's most practical features is incremental selection.
Instead of counting characters or eyeballing a visual selection, you expand
the selection one parse-tree node at a time.

LazyVim's default keybindings for incremental selection:

  Start:    v then Enter       — select the smallest node at the cursor
  Expand:   Enter (in Visual)  — expand to the parent node
  Shrink:   Backspace (Visual) — shrink back to the child node

Each press of Enter moves one level up the syntax tree:
  identifier → argument → argument list → function call → statement → block"

    engine_show_key "" "v + Enter"       "Begin incremental node selection"
    engine_show_key "" "Enter"           "(Visual) Expand selection to parent node"
    engine_show_key "" "Backspace"       "(Visual) Shrink selection to child node"

    engine_teach "This is far more reliable than counting with 'viw' or counting lines
with 'Vip'. You cannot accidentally grab too much or too little — the parser
knows exactly where each construct starts and ends."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Treesitter Text Objects"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim includes nvim-treesitter-textobjects which adds structural
text objects powered by the parse tree:

  af / if   — around/inside function definition
  ac / ic   — around/inside class definition
  aa / ia   — around/inside argument in a call
  al / il   — around/inside loop body

These work with any operator: daf deletes the whole function, yic yanks
the class body, caa changes an argument in a call."

    engine_show_key "d/c/y" "af"   "Around function (definition + body)"
    engine_show_key "d/c/y" "if"   "Inside function (body only)"
    engine_show_key "d/c/y" "ac"   "Around class"
    engine_show_key "d/c/y" "ic"   "Inside class body"
    engine_show_key "d/c/y" "aa"   "Around argument (includes comma)"
    engine_show_key "d/c/y" "ia"   "Inside argument"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Inspecting the Parse Tree"
    # -----------------------------------------------------------------------

    engine_teach ":InspectTree opens a split window showing the full Treesitter parse
tree for the current buffer. It updates live as you edit.

This is invaluable when:
  • Debugging why a text object does not select what you expect
  • Writing custom Treesitter queries for your own plugin or config
  • Understanding how a language's grammar is structured

Use it as a learning tool — open sample.lua and explore the tree while
moving the cursor around. The node under the cursor is highlighted in the
tree view."

    engine_show_key "" ":InspectTree"   "Show Treesitter parse tree for current buffer"
    engine_show_key "" ":Inspect"       "Show highlight captures under cursor"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Use Incremental Selection"
    # -----------------------------------------------------------------------

    engine_teach "sample.lua contains a function called M.increment. You will use
incremental selection to expand from a single identifier outward through
the parse tree.

Steps:
  1. Place the cursor on the word 'amount' inside M.increment (line 9).
  2. Press v then Enter to start selection on that identifier.
  3. Press Enter again to expand to the expression M.counter + amount.
  4. Keep pressing Enter to keep expanding outward.

The check passes as long as Visual mode is active — so press Check while
the selection is still highlighted."

    engine_exercise "ts-incr-select" \
        "Expand a Treesitter selection with Enter" \
        "Place the cursor inside M.increment (line 9), press 'v' then Enter to select a node, then press Enter again to expand. Keep pressing Enter to grow the selection. Press Check while still in Visual mode." \
        verify_visual_selection_active \
        "Start with the cursor on any identifier. Press 'v' then Enter, then keep pressing Enter. The check only needs Visual mode to be active." \
        "file" \
        "sample.lua"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Quiz"
    # -----------------------------------------------------------------------

    engine_quiz \
        "What does Treesitter provide that regular-expression highlighting cannot?" \
        "Faster rendering speed for very large files" \
        "A precise, always-updated parse tree that reflects real code structure" \
        "Automatic spell-checking inside comments and strings" \
        2

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "Treesitter is the foundation beneath LazyVim's editing experience:

  Accurate highlighting  — colors reflect code semantics, not regex patterns
  Incremental selection  — v + Enter to expand node by node
  Structural text objects — af, if, ac, ic, aa, ia for precise edits
  :InspectTree           — explore the parse tree to understand any file
  :TSInstall <lang>      — add a parser for any supported language

You do not need to think about Treesitter most of the time — it works
invisibly. But knowing it is there helps you understand why certain
features work, and what to add to your config when they do not.

Congratulations — you have completed Module 3: Editing Power.

You are now equipped with the full professional toolkit:
  LSP for intelligence, completions for speed,
  formatters for consistency, Treesitter for precision."

    engine_pause
}
