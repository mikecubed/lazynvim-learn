#!/usr/bin/env bash
# lessons/03-editing-power/01-lsp-basics.sh
# Module 3, Lesson 1: LSP Basics

lesson_info() {
    LESSON_TITLE="LSP Basics"
    LESSON_MODULE="03-editing-power"
    LESSON_DESCRIPTION="Use Neovim's built-in LSP to jump to definitions, find references, rename symbols, and trigger code actions."
    LESSON_TIME="15 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: LSP is attached to the current buffer
verify_lsp_ready() {
    verify_lsp_attached
}

# Exercise 2: cursor moved away from the call-site after gd
# The engine captures EXERCISE_START_LINE just before launching.
verify_gd_jumped() {
    verify_jumped_to_line "$EXERCISE_START_LINE"
}

# Exercise 3: the symbol "add_tag" was renamed to "attach_tag"
verify_rename_add_tag() {
    verify_reset
    # Check buffer content directly — avoid luaeval quoting issues
    if verify_buffer_contains "attach_tag"; then
        if verify_buffer_not_contains "add_tag"; then
            VERIFY_MESSAGE="Symbol renamed to 'attach_tag'"
            return 0
        else
            VERIFY_MESSAGE="'add_tag' still found in buffer — make sure all occurrences were renamed"
            VERIFY_HINT="Place cursor on 'add_tag', press Space c r, type 'attach_tag', press Enter"
            return 1
        fi
    else
        VERIFY_MESSAGE="'attach_tag' not found in buffer"
        VERIFY_HINT="Place cursor on 'add_tag', press Space c r, type 'attach_tag', press Enter"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is the LSP?"
    # -----------------------------------------------------------------------

    engine_teach "LSP stands for Language Server Protocol. It is a standard interface
that lets editors talk to language-aware tools — compilers, type checkers,
linters — without knowing anything about the language themselves.

Neovim ships with a built-in LSP client. LazyVim pre-configures it via
nvim-lspconfig and mason.nvim, so when you open a Python, Lua, TypeScript,
or Go file the right language server starts automatically in the background."

    engine_teach "What does an LSP give you?

  Go to definition    — jump to where a function or class is declared
  Go to references    — list every place a symbol is used
  Hover documentation — show a docstring for the thing under the cursor
  Rename symbol       — safely rename across the entire project
  Code actions        — quick-fixes, import organizers, extract refactors
  Diagnostics         — inline errors and warnings without leaving the editor

All of this happens without leaving Neovim and without running any build step."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigation Keybindings"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim maps LSP navigation commands in Normal mode. The cursor must be
on a symbol for these to work:"

    engine_show_key "" "gd"         "Go to Definition (in the current window)"
    engine_show_key "" "gD"         "Go to Declaration"
    engine_show_key "" "gr"         "Go to References (Telescope list)"
    engine_show_key "" "gI"         "Go to Implementation"
    engine_show_key "" "gy"         "Go to Type Definition"
    engine_show_key "" "K"          "Hover documentation (press K again to enter the popup)"

    engine_teach "After jumping with gd you can come back with Ctrl-o (jump back in the
jumplist). Press Ctrl-i to jump forward again. The full jumplist is available
via :jumps."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Code Actions and Rename"
    # -----------------------------------------------------------------------

    engine_teach "The two most transformative LSP features are rename and code actions.
They operate at the semantic level — the LSP understands the code, so a
rename updates every reference in every file, not just the one the cursor
is in."

    engine_show_key "Leader" "cr"   "Rename symbol under cursor"
    engine_show_key "Leader" "ca"   "Code Actions menu (cursor or selection)"
    engine_show_key "Leader" "cA"   "Code Actions for the whole file (source actions)"

    engine_teach "When you press <leader>cr a small input box appears pre-filled with the
current name. Edit it and press Enter — the LSP rewrites all usages.

<leader>ca opens a menu of context-sensitive fixes: add a missing import,
extract a function, convert a loop to a comprehension, and so on. The items
depend entirely on the language server."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Diagnostic Navigation"
    # -----------------------------------------------------------------------

    engine_teach "Diagnostics are the errors and warnings the LSP injects into the gutter
and underlines in the buffer. LazyVim gives you quick ways to jump between
them without touching the mouse:"

    engine_show_key "" "]d"         "Jump to next diagnostic"
    engine_show_key "" "[d"         "Jump to previous diagnostic"
    engine_show_key "" "]e"         "Jump to next error (errors only)"
    engine_show_key "" "[e"         "Jump to previous error"
    engine_show_key "Leader" "cd"   "Show diagnostic for the line under cursor"
    engine_show_key "Leader" "xx"   "Open diagnostics in a Trouble.nvim list"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Wait for LSP to Attach"
    # -----------------------------------------------------------------------

    engine_teach "Open sample.py in the sandbox below. The Python LSP (pyright or
basedpyright) starts in the background — it usually takes a few seconds.
The check passes as soon as at least one LSP client is attached.

If you see a warning icon in the status bar spinning, LSP is still starting.
Wait for it to settle, then press Check."

    engine_exercise "lsp-attach" \
        "Confirm LSP is attached to sample.py" \
        "Open sample.py and wait for the LSP to start. Press Check when the status bar is no longer showing a loading spinner." \
        verify_lsp_ready \
        "The LSP may still be indexing. Wait 5-10 seconds and try again." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Jump to Definition with gd"
    # -----------------------------------------------------------------------

    engine_teach "sample.py defines the class TodoItem and uses it in several places.
In the TodoList.add() method (around line 36) the code constructs a
TodoItem instance.

Steps:
  1. Move the cursor to the word 'TodoItem' on that line.
  2. Press gd.

Neovim will jump up to the class definition. The check passes when the
cursor has moved away from the call-site line."

    # Capture the current cursor line so verify_gd_jumped can compare.
    EXERCISE_START_LINE=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")

    engine_exercise "lsp-gd" \
        "Jump to definition with gd" \
        "Place the cursor on 'TodoItem' in the TodoList.add() method (around line 36). Press gd. The check passes when the cursor has jumped to the class definition." \
        verify_gd_jumped \
        "Move cursor onto 'TodoItem', then press g then d in Normal mode. Use Ctrl-o to come back if needed." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 3: Rename a Symbol with <leader>cr"
    # -----------------------------------------------------------------------

    engine_teach "sample.py has a method called add_tag on the TodoItem class. You will
rename it to attach_tag using the LSP rename feature.

Steps:
  1. Navigate to the method definition: def add_tag (line 21).
  2. Place the cursor on the word add_tag.
  3. Press <leader>cr (Space, c, r).
  4. In the rename input, clear the field and type:  attach_tag
  5. Press Enter.

The LSP will update the definition and every call site in one step.
The check passes when 'add_tag' no longer appears in the buffer."

    engine_exercise "lsp-rename" \
        "Rename add_tag to attach_tag with <leader>cr" \
        "Place the cursor on 'add_tag' (line 21). Press <leader>cr (Space c r), clear the prompt, type 'attach_tag', and press Enter. Press Check when done." \
        verify_rename_add_tag \
        "Move cursor to 'add_tag', press Space then c then r, type the new name 'attach_tag', then press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now have the core LSP workflow:

  gd            — go to definition (Ctrl-o to come back)
  gD            — go to declaration
  gr            — see all references in a Telescope list
  K             — read the documentation for a symbol
  <leader>cr    — rename across the whole project
  <leader>ca    — code actions (fixes, refactors, imports)
  ]d / [d       — navigate between diagnostics

The LSP turns Neovim into an IDE-grade editor. As long as a language server
exists for your language, you get all of this for free.

Next up: nvim-cmp completions — intelligent suggestions as you type."

    engine_pause
}
