#!/usr/bin/env bash
# lessons/07-drills/05-operators.sh
# Practice operators, text objects, surround, and dot repeat

DRILL_EXERCISE_COUNT=10

lesson_info() {
    LESSON_TITLE="Operators Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill d/c operators, text objects, surround, and dot repeat."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_op_delete_line() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if ! echo "$content" | grep -q "def remove_me"; then
        VERIFY_MESSAGE="Line deleted successfully"
        return 0
    fi
    VERIFY_MESSAGE="The 'def remove_me' line is still present"
    VERIFY_HINT="Go to the 'def remove_me' line and press dd"
    return 1
}

verify_op_ciw() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "def greet_user" && echo "$content" | grep -q '"Hi, World!"'; then
        VERIFY_MESSAGE="Word changed inside quotes with ciw"
        return 0
    fi
    VERIFY_MESSAGE="Expected 'Hello' changed to 'Hi' in the message string"
    VERIFY_HINT="Go to 'Hello' in message = \"Hello, World!\", press ciw, type Hi, press Esc"
    return 1
}

verify_op_ci_quote() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q '"Goodbye, World!"'; then
        VERIFY_MESSAGE="Changed inside quotes with ci\""
        return 0
    fi
    VERIFY_MESSAGE="Expected message string changed to 'Goodbye, World!'"
    VERIFY_HINT="Go to the message = \"...\" line, press ci\", type Goodbye, World!, press Esc"
    return 1
}

verify_op_da_paren() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    # The old_config line should no longer have the dict content in parens
    # Actually checking if the parenthesized args in calculate_total's sum() are removed
    # Let's check that sum(items) had its parens+content deleted
    if echo "$content" | grep -q 'total = sum$\|total = sum[^(]'; then
        VERIFY_MESSAGE="Deleted around parentheses with da("
        return 0
    fi
    # Alternative: check the line no longer has (items)
    local line
    line=$(nvim_lua "for i,l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match('total = sum') then return l end end")
    if [[ -n "$line" ]] && ! echo "$line" | grep -q "(items)"; then
        VERIFY_MESSAGE="Deleted around parentheses with da("
        return 0
    fi
    VERIFY_MESSAGE="The (items) part after sum is still present"
    VERIFY_HINT="Go to 'total = sum(items)', place cursor on or inside the parens, press da("
    return 1
}

verify_op_indent() {
    verify_reset
    # Check that the INDENT_ME and INDENT_ALSO lines have extra indentation
    local line1 line2
    line1=$(nvim_lua "for i,l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match('INDENT_ME') then return l end end")
    line2=$(nvim_lua "for i,l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match('INDENT_ALSO') then return l end end")
    if [[ "$line1" =~ ^[[:space:]] ]] && [[ "$line2" =~ ^[[:space:]] ]]; then
        VERIFY_MESSAGE="Two lines indented successfully"
        return 0
    fi
    VERIFY_MESSAGE="The INDENT_ME / INDENT_ALSO lines are not indented"
    VERIFY_HINT="Go to the INDENT_ME line and press >j to indent two lines"
    return 1
}

verify_op_delete_to_end() {
    verify_reset
    # Check that the line starting with old_config now has no dict content
    local line
    line=$(nvim_lua "for i,l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do if l:match('old_config') then return l end end")
    if [[ -n "$line" ]] && ! echo "$line" | grep -q "{"; then
        VERIFY_MESSAGE="Deleted to end of line with D"
        return 0
    fi
    VERIFY_MESSAGE="The old_config line still has content after the variable name"
    VERIFY_HINT="Go to 'old_config = {', place cursor on '=', press D"
    return 1
}

verify_op_change_to_end() {
    verify_reset
    # Check that one of the return lines in format_name has been changed
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q 'return full$\|return full[^.]'; then
        VERIFY_MESSAGE="Changed to end of line with C"
        return 0
    fi
    # Check that .strip() is gone from the return line in format_name
    local line
    line=$(nvim_lua "
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_func = false
        for i, l in ipairs(lines) do
            if l:match('def format_name') then in_func = true end
            if in_func and l:match('return') then return l end
        end
    ")
    if [[ -n "$line" ]] && ! echo "$line" | grep -q "strip()"; then
        VERIFY_MESSAGE="Changed to end of line with C"
        return 0
    fi
    VERIFY_MESSAGE="Expected the return line in format_name to be changed"
    VERIFY_HINT="Go to 'return full.strip()', place cursor on '.strip()', press C, type new text, press Esc"
    return 1
}

verify_op_surround_add() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q '"hello"\|"world"'; then
        VERIFY_MESSAGE="Surround added with quotes"
        return 0
    fi
    VERIFY_MESSAGE="Expected hello or world to be wrapped in quotes"
    VERIFY_HINT="Go to 'hello' on the word_to_surround line, type gsaiw\" to add quotes"
    return 1
}

verify_op_dot_repeat() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    # Both hello and world should now be quoted
    if echo "$content" | grep -q '"hello"' && echo "$content" | grep -q '"world"'; then
        VERIFY_MESSAGE="Dot repeat applied — both words are quoted"
        return 0
    fi
    VERIFY_MESSAGE="Expected both hello and world to be wrapped in quotes"
    VERIFY_HINT="After surrounding hello with quotes, go to world and press . to repeat"
    return 1
}

verify_op_delete_func() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if ! echo "$content" | grep -q "def remove_me\|This entire function"; then
        VERIFY_MESSAGE="Function body deleted"
        return 0
    fi
    VERIFY_MESSAGE="The remove_me function is still present in the buffer"
    VERIFY_HINT="Go inside the remove_me function body and press dip, or select lines with V and d"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Operators Drill"

    engine_teach "Practice operators and text objects. No explanations — just reps.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/operators.py"

    drill_show_reference 'Operators Quick Reference\n\ndd    Delete line\nciw   Change inner word\nci"   Change inside quotes\nda(   Delete around parens\n>j    Indent 2 lines\nD     Delete to end of line\nC     Change to end of line\ngsaiw" Surround word with "\n.     Repeat last change\ndip   Delete inner paragraph'

    engine_exercise "op-delete-line" \
        "1. Delete a line with dd" \
        "Go to the 'def remove_me(x):' line and delete it with dd. Type 'check'." \
        verify_op_delete_line \
        "Navigate to 'def remove_me' and press dd" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-ciw" \
        "2. Change inner word with ciw" \
        "In the greet_user function, change 'Hello' to 'Hi' using ciw. Go to the word 'Hello' and type ciw then Hi then Esc. Type 'check'." \
        verify_op_ciw \
        "Place cursor on 'Hello' in message = \"Hello, World!\", press ciw, type Hi, Esc" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-ci-quote" \
        "3. Change inside quotes with ci\"" \
        "Now change the entire message string to 'Goodbye, World!' using ci\". Place cursor inside the quotes and type ci\" then the new text. Type 'check'." \
        verify_op_ci_quote \
        "Place cursor inside the quotes on the message line, press ci\", type Goodbye, World!, Esc" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-da-paren" \
        "4. Delete around parentheses with da(" \
        "In calculate_total, delete '(items)' from the sum() call using da(. Place cursor on or inside the parens and type da(. Type 'check'." \
        verify_op_da_paren \
        "Go to 'sum(items)', place cursor on 'items' or a paren, press da(" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-indent" \
        "5. Indent two lines with >j" \
        "Find the lines INDENT_ME and INDENT_ALSO (near the bottom). Go to INDENT_ME and press >j to indent both lines. Type 'check'." \
        verify_op_indent \
        "Go to the INDENT_ME line and press >j" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-delete-to-end" \
        "6. Delete to end of line with D" \
        "Go to the 'old_config = {\"host\": ...}' line. Place cursor on the '=' sign and press D to delete from there to end of line. Type 'check'." \
        verify_op_delete_to_end \
        "Go to old_config line, place cursor on '=', press D" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-change-to-end" \
        "7. Change to end of line with C" \
        "In format_name, go to 'return full.strip()'. Place cursor on the '.' before strip and press C to change the rest. Type 'full' then Esc. Type 'check'." \
        verify_op_change_to_end \
        "Go to 'return full.strip()', cursor on '.', press C, type full, Esc" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-surround-add" \
        "8. Add surrounding quotes with gsa" \
        "Find 'word_to_surround = hello'. Place cursor on 'hello' and type gsaiw\" to surround the word with double quotes. Type 'check'." \
        verify_op_surround_add \
        "Go to hello, type gsaiw\"" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-dot-repeat" \
        "9. Repeat last change with ." \
        "Now go to the next line where 'another_word = world' and press . to repeat the surround on 'world'. Type 'check'." \
        verify_op_dot_repeat \
        "Go to 'world' on the next line and press ." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "op-delete-func" \
        "10. Delete a function body" \
        "Delete the entire remove_me function (if any remains) or any multi-line block using dip or V + motion + d. All traces of remove_me should be gone. Type 'check'." \
        verify_op_delete_func \
        "Go inside the remove_me function, press dip to delete the paragraph, or use Vjjd" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Operators and text objects are powerful — keep practicing."
    engine_pause
}
