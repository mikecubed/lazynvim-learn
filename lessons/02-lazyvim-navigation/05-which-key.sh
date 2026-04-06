#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/05-which-key.sh
# Module 2, Lesson 5: Which-key — Discovering Keybindings

lesson_info() {
    LESSON_TITLE="Which-key — Discovering Keybindings"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Use which-key's popup menus to explore and memorise LazyVim's keybinding groups without opening any documentation."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# No custom verifiers — this lesson uses quizzes only.
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "The Discovery Problem"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim ships with hundreds of keybindings spread across dozens of plugins.
No one memorises them from a README. Instead, LazyVim includes which-key.nvim,
a plugin that intercepts any prefix key and, after a short pause, pops up a
floating window listing every valid continuation.

The mental shift: you do not need to remember the full keymap. You only need
to remember the prefix — then wait and read."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The <leader> Prefix"
    # -----------------------------------------------------------------------

    engine_teach "In LazyVim, <leader> is the Space bar. Almost every plugin command lives
under <leader>. Try pressing Space in Normal mode and waiting one second — a
categorised menu appears showing every available group."

    engine_show_key "<leader>" ""    "Wait ~1 s to open the which-key root menu"
    engine_show_key "<leader>" "f"   "File operations group"
    engine_show_key "<leader>" "b"   "Buffer group"
    engine_show_key "<leader>" "c"   "Code / LSP group"
    engine_show_key "<leader>" "g"   "Git group"
    engine_show_key "<leader>" "s"   "Search group"
    engine_show_key "<leader>" "u"   "UI toggles group"
    engine_show_key "<leader>" "w"   "Window management group"
    engine_show_key "<leader>" "x"   "Diagnostics / trouble group"

    engine_teach "Each letter opens a second level. For example, press Space then 'f' and
which-key shows every file command: find files, find recent, find in buffer,
etc. You navigate the tree level by level, or just type the full sequence
once you have it memorised."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The 'g' Prefix"
    # -----------------------------------------------------------------------

    engine_teach "The 'g' key in Normal mode is a standard Neovim prefix for secondary
goto-style commands. Press 'g' and wait to see the full list:"

    engine_show_key "g" "d"   "Go to definition"
    engine_show_key "g" "r"   "Go to references (LSP)"
    engine_show_key "g" "I"   "Go to implementation"
    engine_show_key "g" "y"   "Go to type definition"
    engine_show_key "g" "D"   "Go to declaration"
    engine_show_key "g" "g"   "Go to first line of file"
    engine_show_key "g" "h"   "Hover documentation"
    engine_show_key "g" "s"   "Flash (remote jump) — from flash.nvim"

    engine_teach "Most of these only do something meaningful when an LSP is attached, but
which-key will still list them so you know they exist."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The ']' and '[' Navigation Prefixes"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim uses ']' and '[' as paired 'next' and 'previous' navigation
prefixes across many different object types. Press ']' and wait:"

    engine_show_key "]" "d"   "Next diagnostic"
    engine_show_key "]" "e"   "Next error"
    engine_show_key "]" "w"   "Next warning"
    engine_show_key "]" "b"   "Next buffer in buffer list"
    engine_show_key "]" "q"   "Next quickfix entry"
    engine_show_key "]" "t"   "Next todo comment"
    engine_show_key "[" "d"   "Previous diagnostic"
    engine_show_key "[" "b"   "Previous buffer"
    engine_show_key "[" "q"   "Previous quickfix entry"

    engine_teach "The symmetry makes these easy to internalise: ']' always goes forward,
'[' always goes back, and the letter is the same for both directions.
You do not need to memorise each pair — after a few uses they become natural."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Practical Tips"
    # -----------------------------------------------------------------------

    engine_teach "Three habits that make which-key work for you:

1. PAUSE intentionally. If you forget the second key, stop and wait. which-key
   will appear within a second and remind you. There is no cost to pausing.

2. EXPLORE groups you have not used. Press <leader>u (UI toggles) or <leader>x
   (diagnostics) occasionally and read what is there. You will discover
   commands you did not know existed.

3. USE the search. Inside a which-key popup, type '/' to filter by keyword.
   Searching 'term' will surface <leader>ft (toggle terminal) immediately."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Quizzes"
    # -----------------------------------------------------------------------

    engine_teach "Two short quizzes to check you can navigate the which-key hierarchy.
Use the Neovim pane to try the keymaps if you are unsure — press Space and
follow the menus."

    # Quiz 1: Toggle Terminal
    engine_quiz \
        "Which LazyVim keymap opens (or toggles) a floating terminal?" \
        "<leader>ft" \
        "<leader>tt" \
        "<leader>ot" \
        1

    # Quiz 2: Git Blame
    engine_quiz \
        "Which LazyVim keymap shows the git blame for the current line?" \
        "<leader>gL" \
        "<leader>gb" \
        "<leader>gl" \
        2

    # -----------------------------------------------------------------------
    engine_section "Key Takeaways"
    # -----------------------------------------------------------------------

    engine_teach "which-key turns LazyVim's large keymap from a liability into an asset:

  Space        — root menu, all <leader> commands at a glance
  g + pause    — all goto / LSP navigation commands
  ] + pause    — all 'next' navigation commands
  [ + pause    — all 'previous' navigation commands
  z + pause    — fold, spell, and view commands

You now have two full modules under your belt. Module 3 covers the LSP features
(code completion, diagnostics, go-to-definition) that make Neovim a proper IDE."

    engine_pause
}
