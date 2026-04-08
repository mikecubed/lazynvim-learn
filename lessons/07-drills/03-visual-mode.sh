#!/usr/bin/env bash
# lessons/07-drills/03-visual-mode.sh
# Practice visual selection: v, V, Ctrl-v, select+action, gv, block insert

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Visual Mode Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill visual selections — character, line, and block modes."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_vis_delete_line() {
    verify_reset
    if verify_buffer_not_contains "DEPRECATED_ITEMS"; then
        VERIFY_MESSAGE="Line deleted successfully"
        return 0
    fi
    VERIFY_MESSAGE="The DEPRECATED_ITEMS line is still in the buffer"
    VERIFY_HINT="Go to the DEPRECATED_ITEMS line, press V then d"
    return 1
}

verify_vis_select_word() {
    verify_reset
    # After viw + deletion of the word "broken_handler", it should be gone
    if verify_buffer_not_contains "broken_handler"; then
        VERIFY_MESSAGE="Word deleted with visual select"
        return 0
    fi
    VERIFY_MESSAGE="'broken_handler' is still in the buffer"
    VERIFY_HINT="Place cursor on 'broken_handler', type viw to select it, then d to delete"
    return 1
}

verify_vis_multiline() {
    verify_reset
    # The grocery_list items (apples through elderberries) should be gone
    if verify_buffer_not_contains "apples" && verify_buffer_not_contains "elderberries"; then
        VERIFY_MESSAGE="Multiple lines deleted"
        return 0
    fi
    VERIFY_MESSAGE="The grocery list items are still in the buffer"
    VERIFY_HINT="Go to the 'apples' line, press V, then j four times, then d"
    return 1
}

verify_vis_yank() {
    verify_reset
    # The unnamed register should contain hardware_list items
    local content
    content=$(nvim_eval "getreg('\"')")
    if echo "$content" | grep -q "screws"; then
        VERIFY_MESSAGE="Selection yanked to register"
        return 0
    fi
    VERIFY_MESSAGE="Register doesn't contain the hardware list"
    VERIFY_HINT="Go to the 'screws' line, V then 3j then y to yank 4 lines"
    return 1
}

verify_vis_block_select() {
    verify_reset
    # After block-selecting and deleting the "ITEM: " prefix from the comment block,
    # the lines should no longer start with "#   ITEM: "
    if verify_buffer_not_contains "#   ITEM: "; then
        VERIFY_MESSAGE="Column deleted with block select"
        return 0
    fi
    VERIFY_MESSAGE="The 'ITEM: ' prefix is still in the comment block"
    VERIFY_HINT="Go to first ITEM line, Ctrl-v, select down 4 lines, select 'ITEM: ' with e or l, then d"
    return 1
}

verify_vis_delete_function() {
    verify_reset
    if verify_buffer_not_contains "unused_function" && verify_buffer_not_contains "DELETE_THIS_FUNCTION"; then
        VERIFY_MESSAGE="Function block deleted"
        return 0
    fi
    VERIFY_MESSAGE="The unused_function is still in the buffer"
    VERIFY_HINT="Go to DELETE_THIS_FUNCTION line, V, select down through the function, then d"
    return 1
}

verify_vis_reselect() {
    verify_reset
    # After gv and then deletion, the previously selected text should be gone
    # We check that format_table's comment "col1     col2     col3" is gone
    if verify_buffer_not_contains "col1     col2     col3"; then
        VERIFY_MESSAGE="Reselected and deleted with gv"
        return 0
    fi
    VERIFY_MESSAGE="The comment line is still in the buffer"
    VERIFY_HINT="First select the line with V, press Esc, then gv to reselect, then d"
    return 1
}

verify_vis_block_insert() {
    verify_reset
    # After block insert, the hardware_list items should have "# " prepended
    # (or the grocery list if those were deleted — check hardware lines)
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q '# .*"screws"'; then
        VERIFY_MESSAGE="Block insert completed"
        return 0
    fi
    VERIFY_MESSAGE="The hardware list items don't have '# ' prefix"
    VERIFY_HINT="Go to 'screws' line, Ctrl-v, select down 3 lines, press I, type '# ', press Escape"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Visual Mode Drill"

    engine_teach "Select, act, repeat. Visual mode mastery in 8 exercises.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/visual-mode.py"

    # Show reference (normal mode only, skipped in hard mode)
    drill_show_reference 'Visual Mode Quick Reference\n\nv     Character visual\nV     Line visual\nCtrl-v  Block visual\nd     Delete selection\ny     Yank selection\ngv    Reselect last\nviw   Select inner word\nI     Block insert (in Ctrl-v)\nEsc   Exit visual / apply block insert'

    engine_exercise "vis-delete-line" \
        "1. Delete a line with V + d" \
        "Find the DEPRECATED_ITEMS line and delete it using V then d. Type 'check' when done." \
        verify_vis_delete_line \
        "Navigate to the DEPRECATED_ITEMS line, press V then d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-select-word" \
        "2. Select and delete a word with viw" \
        "Find 'broken_handler' in the list and delete it with viw then d. Type 'check'." \
        verify_vis_select_word \
        "Place cursor on 'broken_handler', type viw then d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-multiline" \
        "3. Select and delete multiple lines" \
        "Delete all grocery_list items (apples through elderberries) using V + motion + d. Type 'check'." \
        verify_vis_multiline \
        "Go to 'apples' line, press V, press j four times to extend, then d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-yank" \
        "4. Yank a visual selection" \
        "Select all 4 hardware_list items (screws through washers) with V + motion, then yank with y. Type 'check'." \
        verify_vis_yank \
        "Go to 'screws' line, V, 3j, then y" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-block-select" \
        "5. Block select and delete a column" \
        "Find the comment block with 'ITEM: ' prefixes. Use Ctrl-v to block select 'ITEM: ' across all 5 lines, then d. Type 'check'." \
        verify_vis_block_select \
        "Go to first ITEM line, place cursor on I of ITEM, Ctrl-v, 4j, then use e and l to cover 'ITEM: ', then d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-delete-function" \
        "6. Delete an entire function block" \
        "Delete the DELETE_THIS_FUNCTION line and the unused_function below it (both the flag and the function). Use V + motion + d. Type 'check'." \
        verify_vis_delete_function \
        "Go to the DELETE_THIS_FUNCTION line, V, select down through the return statement, then d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-reselect" \
        "7. Reselect with gv and delete" \
        "Find the comment '#     col1     col2     col3' inside format_table. Select it with V, press Esc, then gv to reselect, then d to delete. Type 'check'." \
        verify_vis_reselect \
        "Go to the col1/col2/col3 comment, V, Esc, gv, d" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "vis-block-insert" \
        "8. Block insert with Ctrl-v + I" \
        "Comment out the 4 hardware_list items by block inserting '# ' at the start. Use Ctrl-v, select 4 lines, press I, type '# ', press Escape. Type 'check'." \
        verify_vis_block_insert \
        "Go to 'screws' line col 4, Ctrl-v, 3j, I, type '# ', Escape" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Visual mode is a powerful editing multiplier."
    engine_pause
}
