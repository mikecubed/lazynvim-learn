#!/usr/bin/env bash
# lessons/07-drills/10-macros.sh
# Practice recording and playing macros for batch edits

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Macros Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill recording macros, replaying them, and batch transformations."
    LESSON_TIME="6 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_mac_record_simple() {
    verify_reset
    # After recording qq dw j q, the first item line should have its first word deleted
    local line
    line=$(nvim_lua "vim.api.nvim_buf_get_lines(0, 6, 7, false)[1]")
    # Original is "item_apple" — after dw it should be empty or just whitespace
    if [[ "$line" != "item_apple" ]]; then
        VERIFY_MESSAGE="Line modified — macro recorded and played"
        return 0
    fi
    VERIFY_MESSAGE="Line 7 still shows 'item_apple' — record and run the macro"
    VERIFY_HINT="On line 7: qq dw j q — this records deleting first word and moving down"
    return 1
}

verify_mac_play() {
    verify_reset
    local line8
    line8=$(nvim_lua "vim.api.nvim_buf_get_lines(0, 7, 8, false)[1]")
    if [[ "$line8" != "item_banana" ]]; then
        VERIFY_MESSAGE="Macro replayed — line modified"
        return 0
    fi
    VERIFY_MESSAGE="Line 8 still shows 'item_banana'"
    VERIFY_HINT="Press @q to replay the macro"
    return 1
}

verify_mac_repeat() {
    verify_reset
    local line9
    line9=$(nvim_lua "vim.api.nvim_buf_get_lines(0, 8, 9, false)[1]")
    if [[ "$line9" != "item_cherry" ]]; then
        VERIFY_MESSAGE="Macro repeated with @@"
        return 0
    fi
    VERIFY_MESSAGE="Line 9 still shows 'item_cherry'"
    VERIFY_HINT="Press @@ to repeat the last macro"
    return 1
}

verify_mac_count() {
    verify_reset
    # After 3@q, three more lines should be modified
    local modified=0
    local lines
    lines=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 9, 14, false), '|')")
    # Check that at least 3 of the remaining item_ lines are gone
    local remaining
    remaining=$(echo "$lines" | grep -o "item_" | wc -l)
    if [[ "$remaining" -le 2 ]]; then
        VERIFY_MESSAGE="Multiple lines transformed with counted macro"
        return 0
    fi
    VERIFY_MESSAGE="$remaining item lines still unchanged — expected most to be modified"
    VERIFY_HINT="Press 3@q to run the macro 3 times"
    return 1
}

verify_mac_comment() {
    verify_reset
    # After recording a comment macro (qq I# <Esc>jq), check function lines have # prefix
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 18, 24, false), '|')")
    if echo "$content" | grep -q "^#\|^# "; then
        VERIFY_MESSAGE="Comment macro applied — lines now start with #"
        return 0
    fi
    # Check for at least one commented line in the function area
    local commented
    commented=$(nvim_lua "
        local count = 0
        for i = 19, 24 do
            local l = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1] or ''
            if l:match('^#') then count = count + 1 end
        end
        return count
    ")
    if [[ "$commented" -ge 1 ]]; then
        VERIFY_MESSAGE="Found $commented commented line(s)"
        return 0
    fi
    VERIFY_MESSAGE="No commented lines found in the function area"
    VERIFY_HINT="Go to line 19, record: qq I# <Esc>jq — this adds # at the start and moves down"
    return 1
}

verify_mac_visual_apply() {
    verify_reset
    # After visual selection + :normal @q, multiple lines should be commented
    local commented
    commented=$(nvim_lua "
        local count = 0
        for i = 19, 33 do
            local l = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1] or ''
            if l:match('^#') then count = count + 1 end
        end
        return count
    ")
    if [[ "$commented" -ge 4 ]]; then
        VERIFY_MESSAGE="$commented lines commented via visual macro"
        return 0
    fi
    VERIFY_MESSAGE="Only $commented line(s) commented — expected at least 4"
    VERIFY_HINT="Select lines with V + motion, then type :normal @q and Enter"
    return 1
}

verify_mac_compound() {
    verify_reset
    # Check that at least one config line has been transformed
    # Original: "name = ..." -> should become "config['name'] = ..."
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 40, 49, false), '|')")
    if echo "$content" | grep -q "config\["; then
        VERIFY_MESSAGE="Compound macro applied — config pattern found"
        return 0
    fi
    VERIFY_MESSAGE="No config['key'] pattern found in the config section"
    VERIFY_HINT="On a config line, record: qq Iconfig['<Esc>ea']<Esc>jq"
    return 1
}

verify_mac_batch() {
    verify_reset
    # Check that multiple config lines were transformed
    local transformed
    transformed=$(nvim_lua "
        local count = 0
        for i = 41, 48 do
            local l = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1] or ''
            if l:match(\"config%[\") then count = count + 1 end
        end
        return count
    ")
    if [[ "$transformed" -ge 5 ]]; then
        VERIFY_MESSAGE="$transformed config lines transformed — batch edit complete"
        return 0
    fi
    VERIFY_MESSAGE="Only $transformed line(s) transformed — expected at least 5"
    VERIFY_HINT="Use a counted macro (e.g. 7@q) or visual select + :normal @q"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Macros Drill"

    engine_teach "Master macro recording for powerful batch edits.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/macros.py"

    drill_show_reference 'Macros Quick Reference\n\nqq         Start recording to register q\nq          Stop recording\n@q         Play macro q\n@@         Repeat last macro\n5@q        Play macro 5 times\nV + :normal @q  Apply macro to selected lines\nI          Insert at line start\nA          Append at line end\n<Esc>      Return to normal mode'

    # Exercise 1: Record a simple macro
    engine_nvim_keys "7G0"

    engine_exercise "mac-record" \
        "1. Record a macro to delete a word" \
        "Cursor is on line 7 ('item_apple'). Record a macro: qq dw j q (record into q: delete word, move down, stop). Type 'check'." \
        verify_mac_record_simple \
        "Press qq to start recording, dw to delete word, j to move down, q to stop" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 2: Play macro
    engine_exercise "mac-play" \
        "2. Play the macro with @q" \
        "Your cursor should be on the next item line. Press @q to replay the macro. Type 'check'." \
        verify_mac_play \
        "Press @q to replay the macro in register q" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 3: Repeat with @@
    engine_exercise "mac-repeat" \
        "3. Repeat with @@" \
        "Press @@ to repeat the last played macro. Type 'check'." \
        verify_mac_repeat \
        "Press @@ (at-at) to repeat" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 4: Counted macro
    engine_exercise "mac-count" \
        "4. Run macro N times" \
        "Press 3@q to run the macro 3 more times on the remaining items. Type 'check'." \
        verify_mac_count \
        "Press 3@q to run the macro 3 times" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 5: Record a commenting macro
    engine_nvim_keys "19G0"
    sleep 0.5

    engine_exercise "mac-comment" \
        "5. Record a macro to comment lines" \
        "Cursor is on line 19 (def connect). Record: qq I# <Esc>jq — this inserts # at the start and moves down. Type 'check'." \
        verify_mac_comment \
        "Press qq, then I# <Esc>j, then q to stop recording" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 6: Visual macro apply
    engine_exercise "mac-visual" \
        "6. Apply macro to visual selection" \
        "Select several function lines below with V and motion (e.g. V 10j), then type :normal @q and press Enter to apply the comment macro to all selected lines. Type 'check'." \
        verify_mac_visual_apply \
        "V to start visual line, select lines, then :normal @q Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 7: Compound macro for config transformation
    # Go to the config section
    engine_nvim_keys "41G0"
    sleep 0.5

    engine_exercise "mac-compound" \
        "7. Record a compound macro" \
        "Cursor is on line 41 ('name = \"app\"'). Record a macro to transform it to config['name'] = \"app\": qq Iconfig['<Esc>ea']<Esc>jq. Type 'check'." \
        verify_mac_compound \
        "qq Iconfig['<Esc>ea']<Esc>jq — inserts config[' at start, '] after key name" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 8: Batch transform remaining config lines
    engine_exercise "mac-batch" \
        "8. Batch-transform with macros" \
        "Apply the config transformation macro to the remaining config lines using a counted macro (e.g. 7@q) or visual selection + :normal @q. Type 'check' when at least 5 lines are transformed." \
        verify_mac_batch \
        "Try 7@q or select the lines with V, then :normal @q" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Macros turn repetitive edits into one-keystroke operations."
    engine_pause
}
