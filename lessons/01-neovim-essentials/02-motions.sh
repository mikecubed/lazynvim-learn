#!/usr/bin/env bash
# lessons/01-neovim-essentials/02-motions.sh
# Module 1, Lesson 2: Motions

# The "file" sandbox type opens configs/exercise-files/sample.md (52 lines).
# Cursor-line verifications below are based on that file's content.

lesson_info() {
    LESSON_TITLE="Motions"
    LESSON_MODULE="01-neovim-essentials"
    LESSON_DESCRIPTION="Navigate a file at the speed of thought using Neovim motions."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# Shared helper: return the path to sample.md in the sandbox dir
# ---------------------------------------------------------------------------
_sample_file() {
    echo "${LAZYNVIM_LEARN_ROOT}/configs/exercise-files/sample.md"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

# Exercise 1: navigate to line 29 (the lua code block opening line)
verify_on_line_29() {
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")

    if [[ "$actual" -eq 29 ]]; then
        VERIFY_MESSAGE="Cursor is on line 29."
        return 0
    else
        VERIFY_MESSAGE="Cursor is on line $actual — aim for line 29."
        VERIFY_HINT="Type '29G' or ':29<Enter>' to jump directly to line 29."
        return 1
    fi
}

# Exercise 2: cursor on the word 'faster' (line 10, col 20 — 0-based)
# Line 10: "Word motions are faster: `w` jumps forward one word, `b` jumps back."
# 'f' + 'f' from the start of the line lands on the first 'f' in 'faster' (col 16)
verify_on_word_faster() {
    verify_reset
    local line col
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    col=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")

    # Accept cursor anywhere on line 10 between 'f' of 'faster' (col 16) and
    # last char of 'faster' (col 21) — 0-based.
    if [[ "$line" -eq 10 && "$col" -ge 16 && "$col" -le 21 ]]; then
        VERIFY_MESSAGE="Cursor is on the word 'faster' on line 10."
        return 0
    else
        VERIFY_MESSAGE="Cursor is at line $line, column $col. Navigate to the word 'faster' on line 10."
        VERIFY_HINT="Go to line 10 with '10G', then press 'ff' to jump to the first 'f' in 'faster'."
        return 1
    fi
}

# Exercise 3a: cursor at the last line of the file (line 52)
verify_at_end_of_file() {
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    local total
    total=$(nvim_lua "vim.api.nvim_buf_line_count(0)")

    if [[ "$actual" -eq "$total" ]]; then
        VERIFY_MESSAGE="Cursor is at the last line ($total)."
        return 0
    else
        VERIFY_MESSAGE="Cursor is on line $actual — move to the last line (line $total)."
        VERIFY_HINT="Press 'G' (capital G) to jump to the end of the file."
        return 1
    fi
}

# Exercise 3b: cursor at the first line of the file (line 1)
verify_at_top_of_file() {
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")

    if [[ "$actual" -eq 1 ]]; then
        VERIFY_MESSAGE="Cursor is back at line 1."
        return 0
    else
        VERIFY_MESSAGE="Cursor is on line $actual — move to line 1."
        VERIFY_HINT="Press 'gg' (lowercase gg) to jump to the top of the file."
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Why Motions Matter"
    # -----------------------------------------------------------------------

    engine_teach "In most editors you reach for the mouse or arrow keys to move around. In
Neovim you have a whole language of motions — each a short key sequence that
moves the cursor with surgical precision. The more motions you know, the less
time you spend traveling and the more time you spend editing."

    engine_teach "Motions also combine with operators. 'dw' means 'delete (d) one word (w)'.
'c3j' means 'change (c) the next three lines down (3j)'. You will explore
operators in later lessons. For now, focus on moving."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Character Motions"
    # -----------------------------------------------------------------------

    engine_teach "The most basic motions move one character or one line at a time. You may
know these from the old-school hjkl mnemonic:"

    engine_show_key "" "h" "Move left one character"
    engine_show_key "" "j" "Move down one line"
    engine_show_key "" "k" "Move up one line"
    engine_show_key "" "l" "Move right one character"

    engine_teach "These work without leaving Normal mode. That is the point — your hands stay
on the home row. The arrow keys also work, but professional Neovim users prefer
hjkl because it keeps fingers in position.

You can prefix any motion with a count: '5j' moves down 5 lines, '3l' moves
right 3 characters."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Word Motions"
    # -----------------------------------------------------------------------

    engine_teach "Word motions jump by whole words, which is usually faster than character
motions:"

    engine_show_key "" "w" "Jump forward to the start of the next word"
    engine_show_key "" "b" "Jump backward to the start of the current/previous word"
    engine_show_key "" "e" "Jump forward to the end of the current/next word"
    engine_show_key "" "W" "Jump forward one WORD (space-delimited)"
    engine_show_key "" "B" "Jump backward one WORD (space-delimited)"
    engine_show_key "" "E" "Jump forward to end of WORD"

    engine_teach "Lowercase versions ('w', 'b', 'e') treat punctuation as word boundaries.
Uppercase versions ('W', 'B', 'E') treat anything separated by whitespace as a
single WORD. Use whichever fits the text you are navigating."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Line Motions"
    # -----------------------------------------------------------------------

    engine_teach "These motions keep you on the current line:"

    engine_show_key "" "0" "Jump to the very start of the line (column 0)"
    engine_show_key "" "^" "Jump to the first non-whitespace character"
    engine_show_key "" "$" "Jump to the end of the line"
    engine_show_key "" "g_" "Jump to the last non-whitespace character"

    engine_teach "In practice, '0' and '$' are the most used. LazyVim users often remap
'H' and 'L' to '^' and '$' for convenience — but the default bindings always
work."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "File Motions"
    # -----------------------------------------------------------------------

    engine_teach "To jump across the entire file:"

    engine_show_key "" "gg" "Jump to the first line of the file"
    engine_show_key "" "G" "Jump to the last line of the file"
    engine_show_key "" "{N}G" "Jump to line N (e.g. '29G' goes to line 29)"
    engine_show_key "" ":{N}" "Also jumps to line N via Command-line mode"

    engine_teach "'{N}G' is the fastest way to reach a known line number. If you see a
compiler error on line 47, type '47G' and you are there instantly."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Paragraph and Screen Motions"
    # -----------------------------------------------------------------------

    engine_teach "Paragraph motions jump between blank-line-separated blocks of text:"

    engine_show_key "" "{" "Jump to the start of the previous paragraph"
    engine_show_key "" "}" "Jump to the start of the next paragraph"

    engine_teach "Screen motions scroll the view while moving the cursor:"

    engine_show_key "Ctrl" "u" "Scroll up half a screen"
    engine_show_key "Ctrl" "d" "Scroll down half a screen"
    engine_show_key "Ctrl" "b" "Scroll up a full screen"
    engine_show_key "Ctrl" "f" "Scroll down a full screen"
    engine_show_key "" "H" "Move cursor to the top of the visible screen"
    engine_show_key "" "M" "Move cursor to the middle of the visible screen"
    engine_show_key "" "L" "Move cursor to the bottom of the visible screen"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Find Motions (f, F, t, T)"
    # -----------------------------------------------------------------------

    engine_teach "Find motions jump to a specific character on the current line:"

    engine_show_key "" "f{char}" "Jump forward to the next occurrence of {char} on this line"
    engine_show_key "" "F{char}" "Jump backward to the previous occurrence of {char}"
    engine_show_key "" "t{char}" "Jump forward, stopping one character before {char}"
    engine_show_key "" "T{char}" "Jump backward, stopping one character after {char}"
    engine_show_key "" ";" "Repeat the last f/F/t/T motion forward"
    engine_show_key "" "," "Repeat the last f/F/t/T motion backward"

    engine_teach "For example, on a line reading 'The quick brown fox', pressing 'ff' jumps
the cursor to the first 'f' in 'fox'. Press ';' to jump to the next 'f', or ','
to go back. These are especially powerful for quick edits within a line."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercises"
    # -----------------------------------------------------------------------

    engine_teach "The Neovim pane has sample.md open — a short reference file with
52 lines. Work through each exercise using what you just learned."

    # Exercise 1: jump to a specific line number
    engine_exercise "jump-to-line" \
        "Jump to Line 29" \
        "Navigate to line 29 in the file. Use '29G' for a direct jump, or ':29<Enter>' from Command-line mode." \
        verify_on_line_29 \
        "Type '29G' (twenty-nine, then capital G) to jump directly to line 29." \
        "file" \
        "sample.md"

    # Exercise 2: use f motion to reach a specific word
    engine_teach "For the next exercise you will use the 'f' find motion. First go to line
10 with '10G', then use 'ff' to jump the cursor onto the 'f' in 'faster'."

    engine_exercise "find-motion" \
        "Jump to 'faster' with f" \
        "Go to line 10 (press '10G'), then press 'ff' to jump to the word 'faster' on that line." \
        verify_on_word_faster \
        "Press '10G' to reach line 10, then 'ff' to jump to the first 'f' in 'faster'." \
        "current"

    # Exercise 3a: go to end of file
    engine_exercise "end-of-file" \
        "Jump to the End of the File" \
        "Press 'G' (capital G) to jump to the very last line of the file." \
        verify_at_end_of_file \
        "Press capital 'G' to jump to the last line." \
        "current"

    # Exercise 3b: return to top
    engine_exercise "top-of-file" \
        "Jump Back to the Top" \
        "Press 'gg' (lowercase g twice) to jump back to line 1." \
        verify_at_top_of_file \
        "Press 'g' then 'g' (two lowercase g presses) to return to the top." \
        "current"

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now have a full toolkit of motions:

  hjkl      — character-by-character movement
  w / b / e — word-by-word movement
  0 / ^ / $ — line start and end
  { / }     — paragraph jumps
  Ctrl-u/d  — half-screen scrolls
  H / M / L — jump within the visible screen
  f{c} / t{c} — jump to a character on the current line
  gg / G    — top and bottom of file
  {N}G      — jump to line N

These combine with counts ('3w', '5j') and with operators ('d3w', 'c$') to make
editing incredibly fast. Repetition builds muscle memory — keep using them
instead of arrow keys.

Next up: Text Objects — how to act on meaningful chunks of code and prose."

    engine_pause
}
