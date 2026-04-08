#!/usr/bin/env bash
# lessons/07-drills/08-lsp-refactoring.sh
# Practice LSP features: go to definition, references, rename, diagnostics, code actions

DRILL_EXERCISE_COUNT=8

lesson_info() {
    LESSON_TITLE="LSP & Refactoring Drill"
    LESSON_MODULE="07-drills"
    LESSON_DESCRIPTION="Drill LSP navigation, rename, diagnostics, and code actions."
    LESSON_TIME="7 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_lsp_goto_definition() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # calculate_total is defined on LineItem at line 22 and Invoice at line 37
    # After gd from a call site, cursor should land on one of the definitions
    if verify_cursor_on_pattern "def calculate_total"; then
        VERIFY_MESSAGE="Jumped to definition of calculate_total"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected to be on a 'def calculate_total' line"
    VERIFY_HINT="Place cursor on 'calculate_total' (e.g. line 36) and press gd"
    return 1
}

verify_lsp_references() {
    verify_reset
    # After gr, a picker/quickfix window should open. Check if there are multiple windows
    # or if the picker filetype is visible
    local win_count
    win_count=$(nvim_lua "#vim.api.nvim_tabpage_list_wins(0)")
    local ft
    ft=$(nvim_eval "&filetype")
    # Telescope or fzf picker, or quickfix
    if [[ "$win_count" -ge 2 ]] || [[ "$ft" == "TelescopePrompt" ]] || [[ "$ft" == "qf" ]]; then
        VERIFY_MESSAGE="References picker opened"
        return 0
    fi
    # Also check if cursor moved to a reference (user may have already selected one)
    if verify_cursor_on_pattern "calculate_total"; then
        VERIFY_MESSAGE="Navigated to a reference of calculate_total"
        return 0
    fi
    VERIFY_MESSAGE="References picker not detected"
    VERIFY_HINT="Place cursor on 'calculate_total' and press gr to find references"
    return 1
}

verify_lsp_rename() {
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "compute_total"; then
        VERIFY_MESSAGE="Symbol renamed to compute_total"
        return 0
    fi
    VERIFY_MESSAGE="Buffer still contains 'calculate_total' — rename not applied"
    VERIFY_HINT="Place cursor on 'calculate_total', press <leader>cr, type 'compute_total', press Enter"
    return 1
}

verify_lsp_next_diagnostic() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # The type error is on line 80: print_invoice_header(42) passes int instead of str
    if [[ "$line" -ge 78 ]] && [[ "$line" -le 82 ]]; then
        VERIFY_MESSAGE="Jumped to diagnostic near line $line"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — expected near the diagnostic (line ~80)"
    VERIFY_HINT="Press ]d to jump to the next diagnostic"
    return 1
}

verify_lsp_code_action() {
    verify_reset
    # After a code action, check if something changed. Hard to verify precisely,
    # so we check the buffer was modified or cursor is still near the diagnostic
    local modified
    modified=$(nvim_eval "&modified")
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    if [[ "$modified" == "1" ]]; then
        VERIFY_MESSAGE="Code action applied — buffer modified"
        return 0
    fi
    # If they already saved or the action didn't modify, accept if near diagnostic
    if [[ "$line" -ge 78 ]] && [[ "$line" -le 82 ]]; then
        VERIFY_MESSAGE="Cursor is at the diagnostic location"
        VERIFY_HINT="Press <leader>ca, then select an action from the menu"
        return 1
    fi
    VERIFY_MESSAGE="No code action detected"
    VERIFY_HINT="Go to the diagnostic (]d), then press <leader>ca and select a fix"
    return 1
}

verify_lsp_format() {
    verify_reset
    local modified
    modified=$(nvim_eval "&modified")
    # After formatting, buffer may or may not change depending on current state
    # Check the buffer is well-formed (at minimum, file is still valid)
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")
    if echo "$content" | grep -q "class Invoice"; then
        VERIFY_MESSAGE="Buffer formatted successfully"
        return 0
    fi
    VERIFY_MESSAGE="Buffer may not have been formatted correctly"
    VERIFY_HINT="Press <leader>cf to format the buffer"
    return 1
}

verify_lsp_jump_back() {
    verify_reset
    local line
    line=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")
    # After gd then Ctrl-o, they should be back near where they started
    # We set them up at line 36, so accept anywhere near there
    # Accept any line that is NOT a definition line (20 or 34)
    if verify_cursor_on_pattern "def calculate_total\|def compute_total"; then
        VERIFY_MESSAGE="Still on the definition — press Ctrl-o to jump back"
        VERIFY_HINT="Press Ctrl-o to go back in the jumplist"
        return 1
    fi
    if [[ "$line" -ge 33 ]] && [[ "$line" -le 40 ]]; then
        VERIFY_MESSAGE="Jumped back to the call site at line $line"
        return 0
    fi
    # Accept anywhere that's not the definition
    if [[ "$line" -ne 20 ]] && [[ "$line" -ne 34 ]]; then
        VERIFY_MESSAGE="Jumped back to line $line"
        return 0
    fi
    VERIFY_MESSAGE="Cursor is on line $line — use Ctrl-o to jump back"
    VERIFY_HINT="Press Ctrl-o to go back in the jumplist"
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "LSP & Refactoring Drill"

    engine_teach "Practice using LSP features for navigation and refactoring.
Requires pyright for Python LSP. Allow a few seconds for LSP to start.
Type 'skip' to move on if you get stuck."

    # Set up sandbox with exercise files
    sandbox_setup_exercise "dir" 2>/dev/null || true
    engine_nvim_open "drills/lsp-refactoring.py"

    # Give pyright time to start
    sleep 3

    drill_show_reference 'LSP Quick Reference\n\ngd          Go to definition\ngr          Find references\n<leader>cr  Rename symbol\n]d          Next diagnostic\n[d          Prev diagnostic\n<leader>ca  Code action\n<leader>cf  Format buffer\nK           Hover info\nCtrl-o      Jump back'

    engine_exercise "lsp-goto-def" \
        "1. Go to definition" \
        "Place cursor on 'calculate_total' in the Invoice.calculate_total method body (line 36, on 'item.calculate_total()') and press gd to jump to its definition. Type 'check'." \
        verify_lsp_goto_definition \
        "Go to line 36, place cursor on calculate_total, press gd" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "lsp-references" \
        "2. Find references" \
        "Place cursor on 'calculate_total' and press gr to see all references. A picker will open. Type 'check' (press Escape first if the picker is still open)." \
        verify_lsp_references \
        "Place cursor on calculate_total, press gr" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "lsp-rename" \
        "3. Rename a symbol" \
        "Place cursor on 'calculate_total' and press <leader>cr to rename it to 'compute_total'. All references update at once. Type 'check'." \
        verify_lsp_rename \
        "Cursor on calculate_total, <leader>cr, type compute_total, Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "lsp-next-diag" \
        "4. Jump to next diagnostic" \
        "Press ]d to jump to the next diagnostic (there's a type error around line 80). Type 'check'." \
        verify_lsp_next_diagnostic \
        "Press ]d to jump to the next diagnostic" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "lsp-code-action" \
        "5. Apply a code action" \
        "With cursor on the diagnostic, press <leader>ca to see available code actions. Select one to apply. Type 'check'." \
        verify_lsp_code_action \
        "Press <leader>ca and select an action from the menu" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "lsp-format" \
        "6. Format the buffer" \
        "Press <leader>cf to format the entire buffer using the LSP formatter. Type 'check'." \
        verify_lsp_format \
        "Press <leader>cf" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_quiz "What does K show when pressed over a symbol?" \
        "The symbol's definition" \
        "Hover documentation for the symbol" \
        "A list of keybindings" \
        2

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Set up for jump back: go to a call site, then gd, then Ctrl-o
    engine_nvim_keys "36G"
    sleep 1

    engine_exercise "lsp-jump-back" \
        "8. Navigate back with Ctrl-o" \
        "First press gd to jump to a definition, then press Ctrl-o to jump back to where you were. Type 'check' when you're back." \
        verify_lsp_jump_back \
        "Press gd to jump to definition, then Ctrl-o to jump back" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    drill_hide_reference
    engine_teach "All done. LSP is your most powerful code navigation tool."
    engine_pause
}
