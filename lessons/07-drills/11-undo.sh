#!/usr/bin/env bash
# lessons/07-drills/11-undo.sh
# Practice undo, redo, and the built-in Undotree

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Undo Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill undo, redo, branch traversal, and the built-in Undotree."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_undo_delete_line() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if ! echo "$content" | grep -q "DELETE_THIS_LINE"; then
        VERIFY_MESSAGE="Line deleted successfully"
        return 0
    fi
    VERIFY_MESSAGE="The DELETE_THIS_LINE line is still present"
    VERIFY_HINT="Go to the DELETE_THIS_LINE line and press dd"
    return 1
}

verify_undo_restore_line() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "DELETE_THIS_LINE"; then
        VERIFY_MESSAGE="Line restored with undo"
        return 0
    fi
    VERIFY_MESSAGE="DELETE_THIS_LINE is still missing — press u to undo"
    VERIFY_HINT="Press u in Normal mode to undo the deletion"
    return 1
}

verify_undo_change_word() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q '"new_value"'; then
        VERIFY_MESSAGE="Word changed successfully"
        return 0
    fi
    VERIFY_MESSAGE="Expected REPLACE_ME line to contain 'new_value'"
    VERIFY_HINT="Go to 'old_value', press ciw, type new_value, press Esc"
    return 1
}

verify_undo_redo_change() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q '"new_value"'; then
        VERIFY_MESSAGE="Change restored with redo"
        return 0
    fi
    VERIFY_MESSAGE="'new_value' not found — press Ctrl-r to redo"
    VERIFY_HINT="Press Ctrl-r in Normal mode to redo the change"
    return 1
}

verify_undo_delete_func() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if ! echo "$content" | grep -q "def disconnect"; then
        VERIFY_MESSAGE="Function deleted"
        return 0
    fi
    VERIFY_MESSAGE="The disconnect function is still present"
    VERIFY_HINT="Go to the disconnect function and press daf to delete the whole function"
    return 1
}

verify_undo_restore_func() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "def disconnect"; then
        VERIFY_MESSAGE="Function restored with undo"
        return 0
    fi
    VERIFY_MESSAGE="The disconnect function is still missing — press u to undo"
    VERIFY_HINT="Press u in Normal mode to undo the deletion"
    return 1
}

verify_undo_change_line() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "updated text"; then
        VERIFY_MESSAGE="Line changed successfully"
        return 0
    fi
    VERIFY_MESSAGE="Expected CHANGE_THIS line to contain 'updated text'"
    VERIFY_HINT="Go to 'original text here', press ci\", type updated text, press Esc"
    return 1
}

verify_undo_multi_undo() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "original text here"; then
        VERIFY_MESSAGE="Multiple undos successful — back to original"
        return 0
    fi
    VERIFY_MESSAGE="Expected 'original text here' to be restored"
    VERIFY_HINT="Press u multiple times until the original text is back"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Undo Drill"

    engine_teach "Practice undo and redo. No explanations — just reps.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/undo.py"

    drill_show_reference 'Undo Quick Reference\n\nu       Undo last change\nCtrl-r  Redo (undo the undo)\ng-      Go to older text state\ng+      Go to newer text state\n:earlier 5m  Revert to 5 min ago\n:later 30s   Jump forward 30 sec'

    engine_exercise "undo-dd" \
        "1. Delete a line with dd" \
        "Go to the DELETE_THIS_LINE and delete it with dd. Type 'check'." \
        verify_undo_delete_line \
        "Navigate to DELETE_THIS_LINE and press dd" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-restore-dd" \
        "2. Undo the deletion with u" \
        "Press u to undo and bring the deleted line back. Type 'check'." \
        verify_undo_restore_line \
        "Press u in Normal mode" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-ciw" \
        "3. Change a word with ciw" \
        "Go to REPLACE_ME = \"old_value\". Change 'old_value' to 'new_value' using ciw. Type 'check'." \
        verify_undo_change_word \
        "Place cursor on old_value, press ciw, type new_value, press Esc" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-then-redo" \
        "4. Undo then redo with u and Ctrl-r" \
        "Press u to undo the change (old_value comes back), then Ctrl-r to redo it (new_value returns). Type 'check' when 'new_value' is showing." \
        verify_undo_redo_change \
        "Press u to undo, then Ctrl-r to redo. Check should pass with new_value visible." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-daf" \
        "5. Delete a function with daf" \
        "Go to the disconnect function and delete it entirely with daf. Type 'check'." \
        verify_undo_delete_func \
        "Go inside the disconnect function and press daf" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-restore-daf" \
        "6. Undo to restore the function" \
        "Press u to bring the disconnect function back. Type 'check'." \
        verify_undo_restore_func \
        "Press u in Normal mode" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-ci-quote" \
        "7. Change inside quotes" \
        "Go to CHANGE_THIS = \"original text here\". Change the string to 'updated text' using ci\". Type 'check'." \
        verify_undo_change_line \
        "Place cursor inside the quotes, press ci\", type updated text, press Esc" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "undo-multi-undo" \
        "8. Undo multiple changes" \
        "Press u repeatedly until 'original text here' is restored on the CHANGE_THIS line. Type 'check'." \
        verify_undo_multi_undo \
        "Press u multiple times — each press undoes one change" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Undo is your safety net — use it fearlessly."
    engine_pause
}
