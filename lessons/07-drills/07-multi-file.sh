#!/usr/bin/env bash
# lessons/07-drills/07-multi-file.sh
# Practice multi-file workflows: buffers, splits, windows, and saving

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="Multi-File Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill buffer switching, splits, window management, and multi-file saves."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_mf_fuzzy_open() {
    verify_reset
    local bufname
    bufname=$(nvim_eval "expand('%:t')")
    if [[ "$bufname" == "multi-file.py" ]]; then
        VERIFY_MESSAGE="Opened multi-file.py with fuzzy finder"
        return 0
    fi
    VERIFY_MESSAGE="Current file is '$bufname', expected 'multi-file.py'"
    VERIFY_HINT="Press <leader>ff, type multi-file, select it and press Enter"
    return 1
}

verify_mf_buffer_switch() {
    verify_reset
    local bufname
    bufname=$(nvim_eval "expand('%:t')")
    if [[ "$bufname" == "sample.py" ]]; then
        VERIFY_MESSAGE="Switched to sample.py buffer"
        return 0
    fi
    VERIFY_MESSAGE="Current file is '$bufname', expected 'sample.py'"
    VERIFY_HINT="Press <leader>, or <leader>fb to open buffer picker, select sample.py"
    return 1
}

verify_mf_vsplit() {
    verify_reset
    local count
    count=$(nvim_lua "#vim.api.nvim_tabpage_list_wins(0)")
    if [[ "$count" -ge 2 ]]; then
        VERIFY_MESSAGE="Vertical split created — $count windows open"
        return 0
    fi
    VERIFY_MESSAGE="Only $count window(s) open, expected at least 2"
    VERIFY_HINT="Type :vsplit and press Enter"
    return 1
}

verify_mf_open_in_split() {
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w) return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match('sample.js') ~= nil end)")
    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="sample.js is open in a split"
        return 0
    fi
    VERIFY_MESSAGE="sample.js is not visible in any split"
    VERIFY_HINT="In the new split, type :e sample.js or use <leader>ff to find it"
    return 1
}

verify_mf_switch_window() {
    verify_reset
    local bufname
    bufname=$(nvim_eval "expand('%:t')")
    local count
    count=$(nvim_lua "#vim.api.nvim_tabpage_list_wins(0)")
    # They must have splits and be on a different file than sample.js
    if [[ "$count" -ge 2 ]] && [[ "$bufname" != "sample.js" ]]; then
        VERIFY_MESSAGE="Switched to another window (now on '$bufname')"
        return 0
    fi
    if [[ "$count" -lt 2 ]]; then
        VERIFY_MESSAGE="Need at least 2 windows open to switch between them"
        VERIFY_HINT="Create a split first with :vsplit, then use Ctrl-w h/l to switch"
        return 1
    fi
    VERIFY_MESSAGE="Still on sample.js — switch to the other window"
    VERIFY_HINT="Press Ctrl-w h or Ctrl-w l to move to the other window"
    return 1
}

verify_mf_resize() {
    verify_reset
    local widths
    widths=$(nvim_lua "
        local ws = vim.api.nvim_tabpage_list_wins(0)
        local widths = {}
        for _, w in ipairs(ws) do
            table.insert(widths, vim.api.nvim_win_get_width(w))
        end
        return table.concat(widths, ',')
    ")
    # If windows have different widths, resize happened (default vsplit is ~equal)
    local w1 w2
    w1=$(echo "$widths" | cut -d',' -f1)
    w2=$(echo "$widths" | cut -d',' -f2)
    if [[ -n "$w1" ]] && [[ -n "$w2" ]]; then
        local diff=$(( w1 > w2 ? w1 - w2 : w2 - w1 ))
        if [[ "$diff" -ge 5 ]]; then
            VERIFY_MESSAGE="Windows resized — widths differ by $diff columns"
            return 0
        fi
    fi
    VERIFY_MESSAGE="Windows are still roughly equal width"
    VERIFY_HINT="Press Ctrl-w > (or 10 Ctrl-w >) to make current window wider, or Ctrl-w < to make it narrower"
    return 1
}

verify_mf_close_split() {
    verify_reset
    local count
    count=$(nvim_lua "#vim.api.nvim_tabpage_list_wins(0)")
    if [[ "$count" -eq 1 ]]; then
        VERIFY_MESSAGE="Split closed — back to single window"
        return 0
    fi
    VERIFY_MESSAGE="Still $count windows open, expected 1"
    VERIFY_HINT="Type :close or press Ctrl-w c to close the current split"
    return 1
}

verify_mf_wall() {
    verify_reset
    # Check that no buffers are modified (all saved)
    local modified_count
    modified_count=$(nvim_lua "
        local count = 0
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_get_option_value('modified', {buf=b}) then
                count = count + 1
            end
        end
        return count
    ")
    if [[ "$modified_count" -eq 0 ]]; then
        VERIFY_MESSAGE="All buffers saved"
        return 0
    fi
    VERIFY_MESSAGE="$modified_count buffer(s) still have unsaved changes"
    VERIFY_HINT="Type :wall and press Enter to save all buffers"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Multi-File Drill"

    engine_teach "Practice working across multiple files. Splits, buffers, saves.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "sample.py"

    drill_show_reference 'Multi-File Quick Reference\n\n<leader>ff  Find files (fuzzy)\n<leader>,   Switch buffer\n<leader>fb  Buffer picker\n:vsplit     Vertical split\n:e file     Open file\nCtrl-w h/l  Switch window left/right\nCtrl-w >/<  Resize window\n:close      Close split\nCtrl-w c    Close split\n:wall       Save all buffers'

    engine_exercise "mf-fuzzy-open" \
        "1. Open a file with fuzzy finder" \
        "Press <leader>ff to open the file finder. Type 'multi-file' to filter and select drills/multi-file.py. Type 'check'." \
        verify_mf_fuzzy_open \
        "Press <leader>ff, type multi-file, select it, press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-buffer-switch" \
        "2. Switch buffers" \
        "Switch back to sample.py using <leader>, (buffer switcher) or <leader>fb. Type 'check'." \
        verify_mf_buffer_switch \
        "Press <leader>, or <leader>fb, then select sample.py" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-vsplit" \
        "3. Create a vertical split" \
        "Type :vsplit and press Enter to split the window vertically. Type 'check'." \
        verify_mf_vsplit \
        "Type :vsplit and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-open-in-split" \
        "4. Open a file in the split" \
        "In the new split pane, open sample.js with :e sample.js or <leader>ff. Type 'check'." \
        verify_mf_open_in_split \
        "Type :e sample.js Enter, or use <leader>ff and search for sample.js" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-switch-window" \
        "5. Switch between windows" \
        "Press Ctrl-w h or Ctrl-w l to move to the other split window. Type 'check' when you're on a different file." \
        verify_mf_switch_window \
        "Press Ctrl-w h or Ctrl-w l to jump to the other window" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-resize" \
        "6. Resize a window" \
        "Make the current window wider with Ctrl-w > (repeat or prefix with a count like 10 Ctrl-w >). Type 'check' when widths differ noticeably." \
        verify_mf_resize \
        "Press 10 Ctrl-w > to make the window 10 columns wider" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "mf-close-split" \
        "7. Close a split" \
        "Close the current split with :close or Ctrl-w c. Type 'check' when only one window remains." \
        verify_mf_close_split \
        "Type :close Enter or press Ctrl-w c" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Make a small change so :wall has something to save
    engine_nvim_keys "Go# saved<Esc>"

    engine_exercise "mf-wall" \
        "8. Save all buffers with :wall" \
        "Type :wall to save all open buffers at once. Type 'check'." \
        verify_mf_wall \
        "Type :wall and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. Multi-file workflows are essential for real projects."
    engine_pause
}
