#!/usr/bin/env bash
# lessons/07-drills/04-copy-paste.sh
# Practice yank, put, named registers, and text object yanking

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Copy & Paste Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill yank, put, registers, and text object selections."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_cp_yank_line() {
    verify_reset
    local content
    content=$(nvim_eval "getreg('\"')")
    if echo "$content" | grep -q "def square"; then
        VERIFY_MESSAGE="Line yanked to unnamed register"
        return 0
    fi
    VERIFY_MESSAGE="Unnamed register doesn't contain the square function line"
    VERIFY_HINT="Go to the 'def square' line and press yy"
    return 1
}

verify_cp_paste_below() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    local count
    count=$(echo "$content" | grep -o "def square" | wc -l)
    if [[ "$count" -ge 2 ]]; then
        VERIFY_MESSAGE="Line pasted below — duplicate found"
        return 0
    fi
    VERIFY_MESSAGE="No duplicate of the 'def square' line found"
    VERIFY_HINT="Go to the 'def square' line, yy to yank, then p to paste below"
    return 1
}

verify_cp_paste_above() {
    verify_reset
    # After yanking "def cube" and pasting above with P, there should be a duplicate
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    local count
    count=$(echo "$content" | grep -o "def cube" | wc -l)
    if [[ "$count" -ge 2 ]]; then
        VERIFY_MESSAGE="Line pasted above — duplicate found"
        return 0
    fi
    VERIFY_MESSAGE="No duplicate of the 'def cube' line found"
    VERIFY_HINT="Go to the 'def cube' line, yy to yank, move up a line, then P to paste above"
    return 1
}

verify_cp_yank_word() {
    verify_reset
    local content
    content=$(nvim_eval "getreg('\"')")
    if echo "$content" | grep -q "CLIPBOARD"; then
        VERIFY_MESSAGE="Word 'CLIPBOARD' yanked"
        return 0
    fi
    VERIFY_MESSAGE="Unnamed register doesn't contain 'CLIPBOARD'"
    VERIFY_HINT="Find 'CLIPBOARD' in the file, place cursor on it, type yiw"
    return 1
}

verify_cp_named_register_yank() {
    verify_reset
    local content
    content=$(nvim_eval "getreg('a')")
    if echo "$content" | grep -q "PI"; then
        VERIFY_MESSAGE="Line yanked to register a"
        return 0
    fi
    VERIFY_MESSAGE="Register 'a' doesn't contain the PI line"
    VERIFY_HINT="Go to the 'PI = 3.14159' line and type \"ayy"
    return 1
}

verify_cp_named_register_paste() {
    verify_reset
    # After pasting from "a register, PI line should appear somewhere after the constants
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    local count
    count=$(echo "$content" | grep -o "PI = 3.14159" | wc -l)
    if [[ "$count" -ge 2 ]]; then
        VERIFY_MESSAGE="Pasted from register a — duplicate found"
        return 0
    fi
    VERIFY_MESSAGE="No duplicate of the PI line found"
    VERIFY_HINT="Move to where you want to paste, then type \"ap"
    return 1
}

verify_cp_yank_paragraph() {
    verify_reset
    local content
    content=$(nvim_eval "getreg('\"')")
    # The report section comment paragraph
    if echo "$content" | grep -q "report format" && echo "$content" | grep -q "individual items"; then
        VERIFY_MESSAGE="Paragraph yanked to register"
        return 0
    fi
    VERIFY_MESSAGE="Unnamed register doesn't contain the report comment paragraph"
    VERIFY_HINT="Place cursor inside the report comment block (lines starting with #) and type yip"
    return 1
}

verify_cp_visual_yank_paste() {
    verify_reset
    # The process_alpha function should appear duplicated (user selects it, yanks, pastes)
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    local count
    count=$(echo "$content" | grep -o "def process_alpha" | wc -l)
    if [[ "$count" -ge 2 ]]; then
        VERIFY_MESSAGE="Function duplicated via visual yank and paste"
        return 0
    fi
    VERIFY_MESSAGE="No duplicate of process_alpha found"
    VERIFY_HINT="Go to 'def process_alpha', V, select the whole function (5j), y, move to target line, p"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Copy & Paste Drill"

    engine_teach "Master yanking and putting. Registers are your clipboard slots.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/copy-paste.py"

    # Show reference (normal mode only, skipped in hard mode)
    drill_show_reference 'Copy & Paste Quick Reference\n\nyy    Yank current line\np     Paste below\nP     Paste above\nyiw   Yank inner word\nyip   Yank inner paragraph\n\"ayy  Yank line to register a\n\"ap   Paste from register a\nV+y   Visual line yank'

    engine_exercise "cp-yank-line" \
        "1. Yank a line with yy" \
        "Go to the 'def square(n):' line and yank it with yy. Type 'check'." \
        verify_cp_yank_line \
        "Go to the 'def square' line and press yy" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-paste-below" \
        "2. Paste below with p" \
        "Stay on the 'def square' line (yank it again with yy if needed) and press p to paste below. Type 'check'." \
        verify_cp_paste_below \
        "Make sure 'def square' is yanked (yy), then press p" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-paste-above" \
        "3. Paste above with P" \
        "Go to the 'def cube(n):' line, yank it with yy, then move up and press P to paste above. Type 'check'." \
        verify_cp_paste_above \
        "Go to 'def cube' line, yy, then k then P" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-yank-word" \
        "4. Yank a word with yiw" \
        "Find the word 'CLIPBOARD' in the file and yank it with yiw. Type 'check'." \
        verify_cp_yank_word \
        "Search /CLIPBOARD, place cursor on it, type yiw" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-named-reg-yank" \
        "5. Yank to named register a" \
        "Go to the 'PI = 3.14159' line and yank it to register a with \"ayy. Type 'check'." \
        verify_cp_named_register_yank \
        "Go to the PI line, type \"ayy (quote a yy)" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-named-reg-paste" \
        "6. Paste from named register a" \
        "Move to the end of the constants section (after EULER line) and paste from register a with \"ap. Type 'check'." \
        verify_cp_named_register_paste \
        "Move below the EULER line, then type \"ap" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-yank-paragraph" \
        "7. Yank a paragraph with yip" \
        "Find the report comment block (starts with '# --- Report section ---') and place your cursor inside the paragraph of comment lines below it. Yank the paragraph with yip. Type 'check'." \
        verify_cp_yank_paragraph \
        "Go to a line like '# Reports are generated daily', then type yip" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "cp-visual-yank-paste" \
        "8. Visual select, yank, and paste" \
        "Select the entire process_alpha function (def line through return) with V + motion, yank with y, move to after process_beta, and paste with p. Type 'check'." \
        verify_cp_visual_yank_paste \
        "Go to 'def process_alpha', V, 4j, y, go past process_beta's return, p" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Registers and yanking are now in your muscle memory."
    engine_pause
}
