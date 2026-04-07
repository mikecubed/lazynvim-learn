#!/usr/bin/env bash
# lessons/06-refresher/01-quick-refresher.sh
# A fast-paced refresher covering key skills from all modules.
# Uses a single sandbox session throughout. No teaching — just exercises.

lesson_info() {
    LESSON_TITLE="Quick Refresher"
    LESSON_MODULE="06-refresher"
    LESSON_DESCRIPTION="A 5-minute drill covering the key skills from the entire tutorial."
    LESSON_TIME="5 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_refresher_mode() {
    verify_mode "n"
}

verify_refresher_typed_text() {
    verify_reset
    if verify_buffer_contains "refresher complete"; then
        VERIFY_MESSAGE="Text found in buffer"
        return 0
    fi
    VERIFY_MESSAGE="Type 'refresher complete' in the buffer"
    VERIFY_HINT="Press i, type 'refresher complete', press Escape"
    return 1
}

verify_refresher_line_15() {
    verify_cursor_line 15
}

verify_refresher_deleted_word() {
    verify_reset
    if verify_buffer_not_contains "UNUSED_CONSTANT"; then
        VERIFY_MESSAGE="Word deleted"
        return 0
    fi
    VERIFY_MESSAGE="'UNUSED_CONSTANT' is still in the buffer"
    VERIFY_HINT="Place cursor on UNUSED_CONSTANT and type diw"
    return 1
}

verify_refresher_split() {
    verify_window_count 2 "ge"
}

verify_refresher_file_open() {
    verify_file_open "sample.md"
}

verify_refresher_explorer() {
    verify_reset
    { verify_filetype_visible "snacks_explorer" \
        || verify_filetype_visible "snacks_picker_list" \
        || verify_filetype_visible "snacks_layout_box" \
        || verify_filetype_visible "neo-tree"; } && {
        VERIFY_MESSAGE="File explorer is open"
        return 0
    }
    VERIFY_MESSAGE="File explorer is not open"
    VERIFY_HINT="Press Space then e"
    return 1
}

verify_refresher_formatted() {
    verify_via_companion "buffer_is_formatted"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    engine_section "Quick Refresher"

    engine_teach "No explanations — just exercises. One sandbox, eight tasks.
Complete as many as you can. Type 'skip' to move on if you get stuck."

    # Launch sandbox once with sample.py — reuse for all exercises
    engine_exercise "r-insert-text" \
        "1. Enter Insert mode and type text" \
        "Press i, type 'refresher complete', press Escape. Type 'check' when in Normal mode." \
        verify_refresher_typed_text \
        "i → type the text → Escape" \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-jump-line" \
        "2. Jump to line 15" \
        "Navigate to line 15. Type 'check' when your cursor is on line 15." \
        verify_refresher_line_15 \
        "Type 15G" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-delete-word" \
        "3. Delete a word with diw" \
        "Find UNUSED_CONSTANT in the file and delete it with diw. Type 'check' when done." \
        verify_refresher_deleted_word \
        "Navigate to UNUSED_CONSTANT (try /UNUSED then diw)" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-split" \
        "4. Create a split" \
        "Create a vertical split with :vsplit. Type 'check' when you have 2+ windows." \
        verify_refresher_split \
        "Type :vsplit and press Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-find-file" \
        "5. Open sample.md with the fuzzy finder" \
        "Use <leader>ff to find and open sample.md. Type 'check' when it is the active buffer." \
        verify_refresher_file_open \
        "Space f f → type 'md' → Enter" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-explorer" \
        "6. Open the file explorer" \
        "Press <leader>e to toggle the file explorer. Type 'check' while it is visible." \
        verify_refresher_explorer \
        "Press Space then e" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_exercise "r-format" \
        "7. Format a buffer" \
        "Open sample.py (<leader>ff), then format it with <leader>cf. Type 'check' when done." \
        verify_refresher_formatted \
        "Space f f → sample.py → Enter, then Space c f" \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_quiz "8. What does <leader>gg open?" \
        "Git diff" \
        "Lazygit" \
        "Go to definition" \
        "Global search" \
        2

    engine_teach "All done. Nice work keeping those skills sharp."

    engine_pause
}
