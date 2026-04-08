#!/usr/bin/env bash
# lessons/07-drills/06-search-replace.sh
# Practice search, replace, and regex substitution

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Search & Replace Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill forward/backward search, word search, and substitution commands."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_sr_search_forward() {
    verify_reset
    local line
    line=$(nvim_eval "getline('.')")
    if echo "$line" | grep -q "fetch_data"; then
        VERIFY_MESSAGE="Found fetch_data with forward search"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is not on a line containing 'fetch_data'"
    VERIFY_HINT="Type /fetch_data and press Enter"
    return 1
}

verify_sr_search_backward() {
    verify_reset
    local line
    line=$(nvim_eval "getline('.')")
    if echo "$line" | grep -q "max_retries\|timeout_seconds\|use_cache"; then
        VERIFY_MESSAGE="Found a config variable with backward search"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is not on a configuration line"
    VERIFY_HINT="Type ?max_retries and press Enter to search backward"
    return 1
}

verify_sr_next_match() {
    verify_reset
    # After searching for old_name, n should move to the next occurrence
    local line_num
    line_num=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    local line
    line=$(nvim_eval "getline('.')")
    if echo "$line" | grep -q "old_name"; then
        VERIFY_MESSAGE="Jumped to next match with n"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is not on a line containing 'old_name'"
    VERIFY_HINT="Type /old_name Enter to search, then press n to jump to next match"
    return 1
}

verify_sr_star_search() {
    verify_reset
    # After pressing * on old_name, the search register should contain it
    local search
    search=$(nvim_eval "getreg('/')")
    if echo "$search" | grep -q "old_name"; then
        VERIFY_MESSAGE="Word under cursor search activated with *"
        return 0
    fi
    VERIFY_MESSAGE="Search register doesn't contain 'old_name'"
    VERIFY_HINT="Place cursor on 'old_name' and press * to search for word under cursor"
    return 1
}

verify_sr_substitute_line() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    # At least one old_name should be changed to new_name, but not all
    if echo "$content" | grep -q "new_name" && echo "$content" | grep -q "old_name"; then
        VERIFY_MESSAGE="Substitution on current line worked"
        return 0
    fi
    VERIFY_MESSAGE="Expected one old_name changed to new_name (single line substitute)"
    VERIFY_HINT="Go to a line with 'old_name', type :s/old_name/new_name/ and Enter"
    return 1
}

verify_sr_substitute_all() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if ! echo "$content" | grep -q "old_name"; then
        VERIFY_MESSAGE="All occurrences replaced with :%s"
        return 0
    fi
    VERIFY_MESSAGE="Some 'old_name' occurrences still remain"
    VERIFY_HINT="Type :%s/old_name/new_name/g and press Enter"
    return 1
}

verify_sr_substitute_confirm() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    local mode
    mode=$(nvim_eval "mode()")
    # Must be back in normal mode (not in confirm prompt) and have at least one change
    if [[ "$mode" == "n" ]] && echo "$content" | grep -q "new_name"; then
        VERIFY_MESSAGE="Interactive substitution completed"
        return 0
    fi
    VERIFY_MESSAGE="Expected at least one replacement via confirmation mode"
    VERIFY_HINT="Type :%s/old_name/new_name/gc and press y/n for each match, then check"
    return 1
}

verify_sr_regex_replace() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    # Check that snake_case_one etc. have been changed to camelCase or any non-snake form
    if ! echo "$content" | grep -q "snake_case_one\|snake_case_two\|snake_case_three"; then
        VERIFY_MESSAGE="Regex substitution applied to snake_case variables"
        return 0
    fi
    VERIFY_MESSAGE="The snake_case variables are still present"
    VERIFY_HINT="Try :%s/snake_case_/snakeCase/g or a regex pattern to change them"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Search & Replace Drill"

    engine_teach "Practice finding and replacing text. Speed is the goal.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/search-replace.py"

    drill_show_reference 'Search & Replace Quick Reference\n\n/pattern   Search forward\n?pattern   Search backward\nn          Next match\nN          Previous match\n*          Search word under cursor\n:s/a/b/    Replace first on line\n:%s/a/b/g  Replace all in file\n:%s/a/b/gc Replace with confirmation'

    engine_exercise "sr-search-forward" \
        "1. Search forward with /" \
        "Search for 'fetch_data' using /fetch_data and press Enter. Type 'check' when your cursor is on it." \
        verify_sr_search_forward \
        "Type /fetch_data and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-search-backward" \
        "2. Search backward with ?" \
        "From your current position, search backward for 'max_retries' using ?max_retries. Type 'check'." \
        verify_sr_search_backward \
        "Type ?max_retries and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-next-match" \
        "3. Jump to next match with n" \
        "Search for 'old_name' with /old_name, then press n to cycle through matches. Land on any line with old_name. Type 'check'." \
        verify_sr_next_match \
        "Type /old_name Enter, then press n to move through matches" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-star-search" \
        "4. Search word under cursor with *" \
        "Place your cursor on the word 'old_name' and press * to search for it. Type 'check'." \
        verify_sr_star_search \
        "Move cursor onto 'old_name', then press *" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-substitute-line" \
        "5. Replace on current line with :s" \
        "Go to a line containing 'old_name' and run :s/old_name/new_name/ to replace the first occurrence on that line. Type 'check'." \
        verify_sr_substitute_line \
        "Go to a line with old_name, type :s/old_name/new_name/ Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-substitute-all" \
        "6. Replace all in file with :%s" \
        "Replace all remaining 'old_name' with 'new_name' using :%s/old_name/new_name/g. Type 'check'." \
        verify_sr_substitute_all \
        "Type :%s/old_name/new_name/g and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Reset the file for the confirm exercise
    engine_nvim_open "drills/search-replace.py"

    engine_exercise "sr-substitute-confirm" \
        "7. Replace with confirmation :%s///gc" \
        "Run :%s/old_name/new_name/gc and choose y or n for each match. Replace at least one. Press Esc or answer all prompts, then type 'check'." \
        verify_sr_substitute_confirm \
        "Type :%s/old_name/new_name/gc Enter, press y to confirm at least one" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "sr-regex-replace" \
        "8. Regex replace snake_case" \
        "Change the three snake_case_ variables at the bottom. Use :%s/snake_case_/snakeCase/g or any regex to remove the snake_case prefix. Type 'check'." \
        verify_sr_regex_replace \
        "Type :%s/snake_case_/snakeCase/g Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Search and replace mastered."
    engine_pause
}
