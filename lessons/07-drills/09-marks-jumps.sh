#!/usr/bin/env bash
# lessons/07-drills/09-marks-jumps.sh
# Practice marks, jumplist, and changelist navigation

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Marks & Jumps Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill setting marks, jumping between them, and using the jumplist."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_mk_set_mark_a() {
    verify_reset
    local mark_line
    mark_line=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'a')[1]")
    if [[ "$mark_line" -gt 0 ]]; then
        VERIFY_MESSAGE="Mark 'a' set on line $mark_line"
        return 0
    fi
    VERIFY_MESSAGE="Mark 'a' is not set"
    VERIFY_HINT="Press ma to set mark 'a' on the current line"
    return 1
}

verify_mk_jump_to_a() {
    verify_reset
    local mark_line
    mark_line=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'a')[1]")
    local cursor_line
    cursor_line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    if [[ "$mark_line" -gt 0 ]] && [[ "$cursor_line" -eq "$mark_line" ]]; then
        VERIFY_MESSAGE="Jumped to mark 'a' on line $cursor_line"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $cursor_line, mark 'a' is on line $mark_line"
    VERIFY_HINT="Press 'a (apostrophe a) to jump to mark a"
    return 1
}

verify_mk_set_second_mark() {
    verify_reset
    local mark_a
    mark_a=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'a')[1]")
    local mark_b
    mark_b=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'b')[1]")
    if [[ "$mark_a" -gt 0 ]] && [[ "$mark_b" -gt 0 ]] && [[ "$mark_a" -ne "$mark_b" ]]; then
        VERIFY_MESSAGE="Mark 'a' on line $mark_a, mark 'b' on line $mark_b"
        return 0
    fi
    if [[ "$mark_b" -le 0 ]]; then
        VERIFY_MESSAGE="Mark 'b' is not set"
        VERIFY_HINT="Move to a different line and press mb to set mark 'b'"
        return 1
    fi
    VERIFY_MESSAGE="Marks 'a' and 'b' are on the same line — use different lines"
    VERIFY_HINT="Move to a different line than mark 'a' and press mb"
    return 1
}

verify_mk_jump_back_ctrl_o() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # They should have jumped somewhere and then back. Accept if cursor is not at bottom of file
    # We'll set them up at line 1, have them jump to ~100, then Ctrl-o back
    if [[ "$line" -le 50 ]]; then
        VERIFY_MESSAGE="Jumped back to line $line with Ctrl-o"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected to jump back to an earlier position"
    VERIFY_HINT="Press Ctrl-o to go back in the jumplist"
    return 1
}

verify_mk_jump_forward_ctrl_i() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # After Ctrl-o then Ctrl-i, they should be forward again (near end of file)
    if [[ "$line" -ge 50 ]]; then
        VERIFY_MESSAGE="Jumped forward to line $line with Ctrl-i"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected to jump forward"
    VERIFY_HINT="Press Ctrl-i to go forward in the jumplist"
    return 1
}

verify_mk_changelist() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # They made a change, moved away, then g; should bring them back
    # The change was near line 25 (Task class area)
    if [[ "$line" -ge 20 ]] && [[ "$line" -le 35 ]]; then
        VERIFY_MESSAGE="Jumped to last change at line $line"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected near the last change location"
    VERIFY_HINT="Press g; to jump to the location of the last change"
    return 1
}

verify_mk_double_tick() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # After jumping to a line and pressing '', they should return to previous position
    # Accept if they're not on line 1 (where we'll send them) and not on the target line
    if [[ "$line" -ge 2 ]] && [[ "$line" -le 60 ]]; then
        VERIFY_MESSAGE="Jumped back to previous position at line $line"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line"
    VERIFY_HINT="Press '' (two apostrophes) to jump back to your previous position"
    return 1
}

verify_mk_combined() {
    verify_reset
    local mark_a
    mark_a=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'a')[1]")
    local mark_b
    mark_b=$(nvim_lua "vim.api.nvim_buf_get_mark(0, 'b')[1]")
    local cursor_line
    cursor_line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # They should have set both marks and navigated to mark a
    if [[ "$mark_a" -gt 0 ]] && [[ "$mark_b" -gt 0 ]] && [[ "$cursor_line" -eq "$mark_a" ]]; then
        VERIFY_MESSAGE="Marks set and navigated to mark 'a' at line $cursor_line"
        return 0
    fi
    if [[ "$mark_a" -le 0 ]]; then
        VERIFY_MESSAGE="Mark 'a' not set"
        VERIFY_HINT="Set mark 'a' with ma on one function, mark 'b' with mb on another, then jump to 'a' with 'a"
        return 1
    fi
    if [[ "$mark_b" -le 0 ]]; then
        VERIFY_MESSAGE="Mark 'b' not set"
        VERIFY_HINT="Set mark 'b' with mb on a different function"
        return 1
    fi
    VERIFY_MESSAGE="Cursor is on line $cursor_line, mark 'a' is on line $mark_a — jump to mark 'a'"
    VERIFY_HINT="Press 'a to jump to mark a"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Marks & Jumps Drill"

    engine_teach "Practice setting marks and jumping around the file efficiently.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/marks-jumps.py"

    drill_show_reference 'Marks & Jumps Quick Reference\n\nma        Set mark a\n'"'"'a        Jump to mark a line\n`a        Jump to mark a exact position\nmb        Set mark b\n'"'"'b        Jump to mark b\nCtrl-o    Jump back in jumplist\nCtrl-i    Jump forward in jumplist\ng;        Previous change location\ng,        Next change location\n'"'"''"'"'        Jump to last jump position\n:marks    Show all marks'

    # Exercise 1: Set mark a
    engine_nvim_keys "22G"

    engine_exercise "mk-set-mark" \
        "1. Set a mark with ma" \
        "Your cursor is on line 22. Press ma to set mark 'a' here. Type 'check'." \
        verify_mk_set_mark_a \
        "Press ma to set mark 'a'" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 2: Jump to mark a
    engine_nvim_keys "80G"

    engine_exercise "mk-jump-to-a" \
        "2. Jump to mark a" \
        "You've been moved to line 80. Jump back to mark 'a' with 'a (apostrophe a). Type 'check'." \
        verify_mk_jump_to_a \
        "Press 'a (apostrophe then a)" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 3: Set a second mark
    engine_exercise "mk-second-mark" \
        "3. Set mark b on a different line" \
        "Move to a different function (e.g. line 48 or 65) and press mb to set mark 'b'. Type 'check'." \
        verify_mk_set_second_mark \
        "Go to another line (e.g. 48G) and press mb" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 4: Ctrl-o jumplist back
    engine_nvim_keys "1G"
    sleep 0.5
    engine_nvim_keys "100G"
    sleep 0.5

    engine_exercise "mk-ctrl-o" \
        "4. Jump back with Ctrl-o" \
        "You've been moved to the end of the file. Press Ctrl-o to jump back in the jumplist. Type 'check' when you're in the upper half of the file." \
        verify_mk_jump_back_ctrl_o \
        "Press Ctrl-o to go back in the jumplist" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 5: Ctrl-i jumplist forward
    engine_exercise "mk-ctrl-i" \
        "5. Jump forward with Ctrl-i" \
        "Now press Ctrl-i to jump forward in the jumplist (back toward the end). Type 'check' when you're past line 50." \
        verify_mk_jump_forward_ctrl_i \
        "Press Ctrl-i to go forward in the jumplist" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 6: Changelist with g;
    # Make a change first, then move away
    engine_nvim_keys "25Go    # modified line<Esc>"
    sleep 0.5
    engine_nvim_keys "80G"
    sleep 0.5

    engine_exercise "mk-changelist" \
        "6. Jump to last change with g;" \
        "A change was made near line 25. You're now on line 80. Press g; to jump to the last change location. Type 'check'." \
        verify_mk_changelist \
        "Press g; to jump to the last change location" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 7: Double apostrophe to jump back
    engine_nvim_keys "10G"
    sleep 0.5
    engine_nvim_keys "60G"
    sleep 0.5

    engine_exercise "mk-double-tick" \
        "7. Jump to previous position with ''" \
        "You jumped from line 10 to line 60. Press '' (two apostrophes) to jump back to line 10. Type 'check'." \
        verify_mk_double_tick \
        "Press '' (apostrophe apostrophe) to jump to your previous position" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 8: Combined marks navigation
    # Clear marks first by resetting
    engine_nvim_keys ":delmarks ab<CR>"
    sleep 0.5

    engine_exercise "mk-combined" \
        "8. Combined: set marks and navigate" \
        "Set mark 'a' on any function definition (e.g. 'def main'), set mark 'b' on a different function, then jump to mark 'a'. Type 'check' when on mark 'a'." \
        verify_mk_combined \
        "ma on one function, go to another, mb, then 'a to jump back" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Marks and jumps let you fly around code."
    engine_pause
}
