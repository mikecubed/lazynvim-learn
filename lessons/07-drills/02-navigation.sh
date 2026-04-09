#!/usr/bin/env bash
# lessons/07-drills/02-navigation.sh
# Practice core navigation motions: hjkl, w/b/e, f/t, gg/G, %, H/M/L

DRILL_EXERCISE_COUNT=10

lesson_info() {
    LESSON_TITLE="Navigation Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill the essential cursor motions until they're second nature."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_nav_line20() {
    verify_cursor_line 20
}

verify_nav_line1() {
    verify_cursor_line 1
}

verify_nav_word_forward() {
    verify_reset
    local col
    col=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")
    local line
    line=$(nvim_eval "getline('.')")
    # Cursor should be on "connect" (the function name on line 12)
    if verify_cursor_on_pattern "def connect"; then
        VERIFY_MESSAGE="Cursor is on the connect function"
        return 0
    fi
    VERIFY_MESSAGE="Move to the 'connect' function on line 12"
    VERIFY_HINT="Try 12G to jump to 'def connect'"
    return 1
}

verify_nav_find_char() {
    verify_reset
    local col
    col=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")
    local line
    line=$(nvim_eval "getline('.')")
    # After f: on line 14, cursor should be on the colon in {host}:{port}
    if echo "$line" | grep -q "Connecting to" && [[ "$col" -ge 30 ]]; then
        VERIFY_MESSAGE="Found the colon character"
        return 0
    fi
    VERIFY_MESSAGE="Use f to find ':' on line 14"
    VERIFY_HINT="Go to line 14 (14G), then type f:"
    return 1
}

verify_nav_matching_bracket() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    local content
    content=$(nvim_eval "getline('.')")
    # Line 73 has return {"active": ..., "inactive": ...} — { and } on same line
    # After pressing % on { cursor lands on }, staying on line 73
    if [[ "$line" -eq 73 ]]; then
        VERIFY_MESSAGE="Jumped to matching bracket"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — use % to jump to matching bracket"
    VERIFY_HINT="Go to line 73 (73G), place cursor on { then press %"
    return 1
}

verify_nav_goto_line() {
    verify_cursor_line 35
}

verify_nav_word_back() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    local col
    col=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")
    # Should be on "class" keyword of Database (line 39)
    if [[ "$line" -eq 39 ]] && [[ "$col" -eq 0 ]]; then
        VERIFY_MESSAGE="Cursor is at the start of 'class' on line 39"
        return 0
    fi
    VERIFY_MESSAGE="Move to the start of 'class' on line 39"
    VERIFY_HINT="Go to line 39 (39G), then press 0 or use b to reach column 0"
    return 1
}

verify_nav_end_of_word() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    local col
    col=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")
    local content
    content=$(nvim_eval "getline('.')")
    # On line 41, cursor should be at end of a word in self.path = path
    if [[ "$line" -eq 41 ]] && echo "$content" | grep -q "self.path" && [[ "$col" -ge 8 ]]; then
        VERIFY_MESSAGE="Cursor is at end of a word on line 41"
        return 0
    fi
    VERIFY_MESSAGE="Use e to move to end of a word on line 41"
    VERIFY_HINT="Go to line 41 (41G), press 0, then press e to jump to end of first word"
    return 1
}

verify_nav_screen_position() {
    verify_reset
    local line top_line bot_line
    line=$(nvim_eval "line('.')")
    top_line=$(nvim_eval "line('w0')")
    bot_line=$(nvim_eval "line('w\$')")
    local mid=$(( (top_line + bot_line) / 2 ))
    local diff=$(( line - mid ))
    [[ "$diff" -lt 0 ]] && diff=$(( -diff ))

    if [[ "$diff" -le 2 ]]; then
        VERIFY_MESSAGE="Cursor is at the middle of the screen (line $line)"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected near middle (line ~$mid)"
    VERIFY_HINT="Press M (capital M) to jump to the middle of the visible screen"
    return 1
}

verify_nav_find_function() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    if verify_cursor_on_pattern "def format_report"; then
        VERIFY_MESSAGE="Cursor is on the format_report function"
        return 0
    fi
    VERIFY_MESSAGE="Navigate to the 'format_report' function"
    VERIFY_HINT="Try /format_report then Enter, or use 83G"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Navigation Drill"

    engine_teach "Pure navigation practice. Move fast, move precise.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/navigation.py"

    # Show reference (normal mode only, skipped in hard mode)
    drill_show_reference 'Navigation Quick Reference\n\ngg    Go to first line\nG     Go to last line\n20G   Go to line 20\n:35   Go to line 35\nw     Word forward\nb     Word backward\ne     End of word\nf{c}  Find char forward\n%     Match bracket\nH/M/L Top/Mid/Bot of screen'

    engine_exercise "nav-line20" \
        "1. Jump to line 20" \
        "Move your cursor to line 20. Type 'check' when you're there." \
        verify_nav_line20 \
        "Type 20G" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-first-line" \
        "2. Jump to the first line" \
        "Move to line 1 of the file. Type 'check' when you're there." \
        verify_nav_line1 \
        "Type gg" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-word-forward" \
        "3. Navigate to the connect function" \
        "Move to line 12 where 'def connect' is. Place your cursor on that line. Type 'check'." \
        verify_nav_word_forward \
        "Type 12G to jump to line 12" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-find-char" \
        "4. Find a character with f" \
        "Go to line 14 and use f: to find the colon in the format string. Type 'check'." \
        verify_nav_find_char \
        "Type 14G then f:" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-matching-bracket" \
        "5. Jump to matching bracket with %" \
        "Go to line 73, put cursor on the { in the dict, then press % to jump to matching }. Type 'check'." \
        verify_nav_matching_bracket \
        "Type 73G, find { then press %" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-goto-line" \
        "6. Go to line 35 with :line" \
        "Use :35 and Enter to jump to line 35. Type 'check'." \
        verify_nav_goto_line \
        "Type :35 then Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-word-back" \
        "7. Move to start of 'class' on line 39" \
        "Go to line 39 and use b to reach column 0 (the 'class' keyword). Type 'check'." \
        verify_nav_word_back \
        "Type 39G then press 0 or use b until at column 0" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-end-of-word" \
        "8. End-of-word motion on line 41" \
        "Go to line 41, press 0 to go to start, then use e to reach the end of a word. Type 'check'." \
        verify_nav_end_of_word \
        "Type 41G then 0 then e" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-screen-middle" \
        "9. Jump to middle of screen with M" \
        "Press M to move to the middle line of the visible screen. Type 'check'." \
        verify_nav_screen_position \
        "Press M (capital M)" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "nav-find-function" \
        "10. Navigate to format_report" \
        "Find and move to the 'def format_report' line using any method. Type 'check'." \
        verify_nav_find_function \
        "Try /format_report Enter, or 83G" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Your navigation skills are looking sharp."
    engine_pause
}
