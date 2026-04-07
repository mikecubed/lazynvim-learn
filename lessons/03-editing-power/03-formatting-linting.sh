#!/usr/bin/env bash
# lessons/03-editing-power/03-formatting-linting.sh
# Module 3, Lesson 3: Formatting and Linting

lesson_info() {
    LESSON_TITLE="Formatting and Linting"
    LESSON_MODULE="03-editing-power"
    LESSON_DESCRIPTION="Format code automatically with conform.nvim and navigate diagnostics from nvim-lint and the LSP."
    LESSON_TIME="13 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: buffer has been run through a formatter
verify_buffer_formatted() {
    verify_via_companion "buffer_is_formatted"
}

# Exercise 2: cursor has moved to a different line after ]d
verify_jumped_to_diagnostic() {
    verify_jumped_to_line "$EXERCISE_START_LINE"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Two Different Tools: Formatters vs Linters"
    # -----------------------------------------------------------------------

    engine_teach "Formatting and linting sound similar but serve different purposes:

FORMATTER — rewrites the source code to comply with a style guide.
  It changes whitespace, indentation, line length, and quoting.
  It never changes the meaning of your code — only its appearance.
  Examples: Black (Python), Prettier (JS/TS), stylua (Lua).

LINTER — analyzes code for potential bugs, type errors, or style violations
  and reports them as diagnostics (errors/warnings/hints).
  It does NOT modify the file — it just tells you what is wrong.
  Examples: flake8/ruff (Python), eslint (JS/TS), selene (Lua).

LazyVim handles both via two plugins: conform.nvim for formatting and
nvim-lint for linting. Both plug into the same diagnostic system that the
LSP uses, so they show up in the same gutter icons and the same ]d/[d navigation."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Formatting with conform.nvim"
    # -----------------------------------------------------------------------

    engine_teach "conform.nvim runs external formatters and writes the result back into
the buffer without touching your cursor position or undo history.

LazyVim pre-configures a sensible set of formatters per filetype. You can
override or add formatters in  lua/plugins/formatting.lua."

    engine_show_key "Leader" "cf"   "Format the current buffer (or selection in Visual mode)"

    engine_teach "LazyVim also enables *format-on-save* by default for most filetypes.
That means every time you press :w (or use the auto-save plugin) the
formatter runs automatically. You can toggle this per-buffer:

  <leader>uf   — toggle auto-format for this buffer
  <leader>uF   — toggle auto-format globally

The status bar shows a small icon when auto-format is disabled."

    engine_show_key "Leader" "uf"   "Toggle format-on-save for this buffer"
    engine_show_key "Leader" "uF"   "Toggle format-on-save globally"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigating Diagnostics"
    # -----------------------------------------------------------------------

    engine_teach "Diagnostics appear as colored underlines in the buffer and icons in the
sign column on the left. They come from three sources that all merge together:

  • The LSP (type errors, undefined variables, …)
  • nvim-lint (style violations, security issues, …)
  • External tools you add yourself

Regardless of source, navigation is the same:"

    engine_show_key "" "]d"         "Jump to next diagnostic (any severity)"
    engine_show_key "" "[d"         "Jump to previous diagnostic"
    engine_show_key "" "]e"         "Jump to next error"
    engine_show_key "" "[e"         "Jump to previous error"
    engine_show_key "" "]w"         "Jump to next warning"
    engine_show_key "" "[w"         "Jump to previous warning"
    engine_show_key "Leader" "cd"   "Show full diagnostic message in a floating window"

    engine_teach "Pressing <leader>cd is especially useful for long error messages that
do not fit in the virtual text shown at the end of the line."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Trouble.nvim: Diagnostics as a List"
    # -----------------------------------------------------------------------

    engine_teach "When a file has many diagnostics, jumping one by one gets tedious.
Trouble.nvim gives you a full-screen panel listing every issue:

  <leader>xx   — toggle Trouble panel (buffer diagnostics)
  <leader>xX   — toggle Trouble (workspace diagnostics)
  <leader>xL   — toggle the Location List
  <leader>xQ   — toggle the Quickfix List

Inside Trouble you can press Enter to jump to any item, 'o' to open it
in a split, and 'q' to close the panel. It updates live as LSP or lint
results change."

    engine_show_key "Leader" "xx"   "Toggle Trouble diagnostics panel"
    engine_show_key "Leader" "xX"   "Toggle workspace-wide diagnostics"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Format the Buffer with <leader>cf"
    # -----------------------------------------------------------------------

    engine_teach "sample.py has a few deliberate style inconsistencies:

  • The add_tag method (line 21) has a missing space: add_tag(self,tag: str)
  • There are trailing spaces on some lines

Run the formatter to clean them all up at once:
  1. Press <leader>cf (Space, c, f).
  2. The buffer is rewritten in place.
  3. type 'check'."

    engine_exercise "fmt-conform" \
        "Format sample.py with <leader>cf" \
        "Press <leader>cf (Space c f) to run the formatter on the buffer. The check passes when conform.nvim confirms a formatter ran." \
        verify_buffer_formatted \
        "Press Space then c then f in Normal mode. Make sure the buffer is a Python file so a formatter is available." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Navigate to a Diagnostic with ]d"
    # -----------------------------------------------------------------------

    engine_teach "The sandbox buffer may have diagnostics from the LSP or linter. You
will use ]d to jump to the next one.

  1. Press gg to go to the top of the file.
  2. Press ]d to jump to the next diagnostic.

The check passes when the cursor has moved from line 1 to a different line."

    # Position cursor at the top so ]d has to move it.
    engine_nvim_keys "gg"

    EXERCISE_START_LINE=1

    engine_exercise "diag-jump" \
        "Jump to next diagnostic with ]d" \
        "Press gg to reach the top of the file, then press ]d to jump to the next diagnostic. The check passes when the cursor has moved from line 1." \
        verify_jumped_to_diagnostic \
        "Make sure you are at the top (gg), then press ] then d. If there are no diagnostics, save the file (:w) and wait a moment for the LSP to run." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "Your formatting and linting workflow:

  <leader>cf   — format the current buffer on demand
  <leader>uf   — toggle format-on-save (on by default)
  ]d / [d      — jump between diagnostics
  ]e / [e      — jump between errors only
  <leader>cd   — read the full diagnostic message
  <leader>xx   — view all diagnostics in a Trouble panel

Between format-on-save, LSP diagnostics, and a linter, you get continuous
feedback about your code without running a separate build step.

Next up: Treesitter — the syntax engine that makes all of this possible."

    engine_pause
}
