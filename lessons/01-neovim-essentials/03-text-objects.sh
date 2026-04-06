#!/usr/bin/env bash
# lessons/01-neovim-essentials/03-text-objects.sh
# Lesson: Text Objects — the operator + motion model

lesson_info() {
    LESSON_TITLE="Text Objects"
    LESSON_MODULE="01-neovim-essentials"
    LESSON_DESCRIPTION="Master Neovim's operator + text-object model to edit precisely without moving first"
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: delete a word under cursor with diw
# The word "TODO" appears in sample.py; user should delete it.
verify_diw_word() {
    verify_buffer_not_contains "TODO"
}

# Exercise 2: change text inside double-quotes with ci"
# sample.py has STATUS_OPEN = "open" — user replaces "open" with "active"
verify_ci_quotes() {
    verify_buffer_contains "active"
}

# Exercise 3: yank a paragraph with yip
# Checks the unnamed register is non-empty (any content will do).
verify_yip_paragraph() {
    verify_register_not_empty '"'
}

# ---------------------------------------------------------------------------

lesson_run() {
    # ------------------------------------------------------------------
    engine_section "The Operator + Motion Model"
    # ------------------------------------------------------------------

    engine_teach "Neovim editing commands follow a grammar: OPERATOR + MOTION (or TEXT OBJECT).

An OPERATOR says *what* to do:
  d  — delete
  c  — change (delete and enter Insert mode)
  y  — yank (copy)
  >  — indent
  =  — auto-format

A MOTION says *where* to act:
  w  — to the next word
  \$  — to the end of line
  gg — to the top of the file

Combine them: dw deletes to the next word, y\$ yanks to end of line."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Text Objects: More Precise Than Motions"
    # ------------------------------------------------------------------

    engine_teach "Text OBJECTS describe a region of text, not a direction to travel.
They only make sense after an operator (you can't just press iw in Normal mode).

The two flavours:
  i  — INNER  (the content, not the surrounding delimiters)
  a  — AROUND (includes the surrounding delimiters / whitespace)

Examples:
  diw  — delete inner word      (just the word, not surrounding spaces)
  daw  — delete around word     (word + the trailing space)
  ci\"  — change inner \"...\"     (replace text between the quotes)
  ca\"  — change around \"...\"    (replace the quotes too)
  yip  — yank inner paragraph   (the whole paragraph block)
  yap  — yank around paragraph  (paragraph + surrounding blank lines)"

    engine_pause

    # ------------------------------------------------------------------
    engine_section "The Full Text Object Zoo"
    # ------------------------------------------------------------------

    engine_teach "Every object works with both i (inner) and a (around):"
    printf '\n'

    engine_show_key "d/c/y" "iw / aw"  "word"
    engine_show_key "d/c/y" "iW / aW"  "WORD (space-delimited token)"
    engine_show_key "d/c/y" "is / as"  "sentence"
    engine_show_key "d/c/y" "ip / ap"  "paragraph (blank-line delimited)"
    engine_show_key "d/c/y" 'i" / a"'  "double-quoted string"
    engine_show_key "d/c/y" "i' / a'"  "single-quoted string"
    engine_show_key "d/c/y" "i\` / a\`" "backtick string"
    engine_show_key "d/c/y" "i( / a("  "parentheses  (also: ib)"
    engine_show_key "d/c/y" "i[ / a["  "square brackets"
    engine_show_key "d/c/y" "i{ / a{"  "curly braces  (also: iB)"
    engine_show_key "d/c/y" "i< / a<"  "angle brackets"
    engine_show_key "d/c/y" "it / at"  "HTML/XML tag"
    printf '\n'

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Practical Tip: Cursor Placement"
    # ------------------------------------------------------------------

    engine_teach "You do NOT need to move the cursor to the start of a word or quote.
As long as the cursor is ANYWHERE inside the object, the operator applies
to the whole thing.

  'hello world'
   ^--- cursor here, then ci' replaces the whole string — cursor
        does not need to be at the h."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Exercise 1: Delete Inner Word (diw)"
    # ------------------------------------------------------------------

    engine_teach "The file sample.py contains the comment:

  # TODO: add logging support

Position your cursor anywhere on the word TODO, then type:

  diw

This deletes the word without touching the surrounding #, :, or spaces."

    engine_exercise \
        "ex-diw" \
        "Delete the word TODO with diw" \
        "Open sample.py. Place the cursor on the word 'TODO' (line 5). Type 'diw' to delete just that word. Type 'check' when done." \
        verify_diw_word \
        "Navigate to line 5, put the cursor on 'TODO', then press d, i, w in Normal mode." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Exercise 2: Change Inside Quotes (ci\")"
    # ------------------------------------------------------------------

    engine_teach "sample.py defines:

  STATUS_OPEN = \"open\"

Place the cursor anywhere between the double quotes (or even on them)
and type:

  ci\"

Neovim deletes the text inside the quotes and drops you into Insert mode.
Type the word  active  and press Escape."

    engine_exercise \
        "ex-ciquote" \
        'Change "open" to "active" with ci"' \
        'In sample.py, find the line: STATUS_OPEN = "open"  (line 6). Place cursor inside or on the quotes. Type ci" (c, i, then the double-quote key), type "active", then press Escape. Type "check" when done.' \
        verify_ci_quotes \
        'Position cursor on the word "open" or the surrounding quotes, then type: c i " — this deletes the content inside the quotes and enters Insert mode.' \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Exercise 3: Yank a Paragraph (yip)"
    # ------------------------------------------------------------------

    engine_teach "sample.py contains several paragraph-sized chunks of code separated
by blank lines — for example the TodoItem class methods.

Place the cursor anywhere inside one of those blocks, then type:

  yip

This yanks the entire paragraph into the unnamed register (\").
You can then paste it elsewhere with  p  or  P."

    engine_exercise \
        "ex-yip" \
        "Yank a paragraph with yip" \
        "In sample.py, place the cursor inside any paragraph (e.g., inside the 'def complete' method block around line 17). Type 'yip' to yank the paragraph. Type 'check' when done." \
        verify_yip_paragraph \
        "Put the cursor inside a block of code surrounded by blank lines and press y, i, p. The bottom status bar should show a line count like '3 lines yanked'." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Lesson Complete"
    # ------------------------------------------------------------------

    engine_teach "You now know Neovim's most powerful editing primitive: the operator +
text-object grammar.

Key take-aways:
  • i = inner (no delimiters), a = around (includes delimiters)
  • Cursor just needs to be *inside* the object — exact position irrelevant
  • Combine any operator (d, c, y, >, =) with any object (iw, i\", ip, …)
  • This works in Visual mode too: select with viw, then operator

Next lesson: Buffers and Windows — managing multiple files at once."

    engine_pause
}
