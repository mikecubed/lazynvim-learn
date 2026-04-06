#!/usr/bin/env bash
# lessons/01-neovim-essentials/01-modal-editing.sh
# Module 1, Lesson 1: Modal Editing

lesson_info() {
    LESSON_TITLE="Modal Editing"
    LESSON_MODULE="01-neovim-essentials"
    LESSON_DESCRIPTION="Learn Neovim's modal editing paradigm and how to switch between modes."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_normal_mode() {
    verify_mode "n"
}

verify_insert_mode() {
    verify_mode "i"
}

verify_visual_mode() {
    verify_mode "v"
}

verify_hello_neovim_in_normal() {
    verify_reset
    local mode_ok=0
    local buf_ok=0

    verify_mode "n" && mode_ok=1
    verify_buffer_contains "Hello Neovim" && buf_ok=1

    if [[ $mode_ok -eq 0 ]]; then
        VERIFY_MESSAGE="You need to be in Normal mode. Press Escape to leave Insert mode."
        VERIFY_HINT="After typing, press Escape to return to Normal mode."
        return 1
    fi

    if [[ $buf_ok -eq 0 ]]; then
        VERIFY_MESSAGE="Buffer doesn't contain 'Hello Neovim'. Enter Insert mode with 'i' and type it."
        VERIFY_HINT="Press 'i' to enter Insert mode, type 'Hello Neovim', then press Escape."
        return 1
    fi

    VERIFY_MESSAGE="'Hello Neovim' is in the buffer and you're in Normal mode."
    return 0
}

verify_line_deleted() {
    verify_reset
    # The sandbox starts with an empty buffer (1 line). After adding lines and
    # deleting one the count should still be less than or equal to the original.
    # We check that the line count is at most 1 (the buffer was modified and a
    # line removed). The exercise scaffolds the buffer with 3 lines so we
    # verify it now has at most 2.
    local actual
    actual=$(nvim_lua "vim.api.nvim_buf_line_count(0)")

    if [[ "$actual" -le 2 ]]; then
        VERIFY_MESSAGE="Line deleted. Buffer now has $actual line(s)."
        return 0
    else
        VERIFY_MESSAGE="Buffer still has $actual lines. Select a line in Visual mode and press 'd'."
        VERIFY_HINT="Press 'V' to select the whole line, then press 'd' to delete it."
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is Modal Editing?"
    # -----------------------------------------------------------------------

    engine_teach "Most editors work in a single mode: every key you press either types a
character or triggers a shortcut with a modifier like Ctrl or Alt. Neovim works
differently. It has distinct *modes*, each designed for a specific task."

    engine_teach "This might feel strange at first, but it is the source of Neovim's power.
In Normal mode your entire keyboard becomes a command palette — no modifier keys
required. Want to delete a word? Type 'dw'. Want to copy three lines? Type '3yy'.
Once it clicks, you will never want to go back."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Four Main Modes"
    # -----------------------------------------------------------------------

    engine_teach "Neovim has four modes you will use constantly:"

    engine_teach "NORMAL MODE — Your home base. This is where you navigate, delete, copy,
and issue commands. Neovim always starts here. You can always get back to Normal
mode by pressing Escape."

    engine_show_key "Escape" "" "Return to Normal mode from anywhere"
    engine_show_key "Ctrl" "[" "Alternative: also returns to Normal mode"

    engine_teach "INSERT MODE — Where you type text. It works like a conventional editor.
Press 'i' to enter Insert mode before the cursor, 'a' to enter after the cursor,
or 'o' to open a new line below."

    engine_show_key "" "i" "Enter Insert mode before cursor"
    engine_show_key "" "a" "Enter Insert mode after cursor"
    engine_show_key "" "o" "Open new line below and enter Insert mode"
    engine_show_key "" "I" "Enter Insert mode at start of line"
    engine_show_key "" "A" "Enter Insert mode at end of line"
    engine_show_key "" "O" "Open new line above and enter Insert mode"

    engine_pause

    engine_teach "VISUAL MODE — For selecting text. Once you have a selection, operators
like 'd' (delete), 'y' (yank/copy), or '>' (indent) act on it."

    engine_show_key "" "v" "Character-wise Visual mode"
    engine_show_key "" "V" "Line-wise Visual mode (select whole lines)"
    engine_show_key "Ctrl" "v" "Block-wise Visual mode (column selection)"

    engine_teach "COMMAND-LINE MODE — Runs Ex commands. You reach it by pressing ':' from
Normal mode. Here you can save files (':w'), quit (':q'), run substitutions
(':%s/old/new/g'), and much more."

    engine_show_key "" ":" "Enter Command-line mode"
    engine_show_key "" "/" "Search forward (also enters a command-line)"
    engine_show_key "" "?" "Search backward"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Mode Indicator"
    # -----------------------------------------------------------------------

    engine_teach "Look at the bottom-left of the Neovim pane below. LazyVim shows a colored
status indicator that tells you the current mode:

  NORMAL  — you are in Normal mode (usually blue)
  INSERT  — you are in Insert mode (usually green)
  VISUAL  — you are in Visual mode (usually orange/purple)
  V-LINE  — you are in line-wise Visual mode
  V-BLOCK — you are in block-wise Visual mode
  COMMAND — you are typing a command

Keeping an eye on this indicator is the fastest way to get oriented when
something unexpected happens."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "LazyVim's jk Escape"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim adds a convenient shortcut: typing 'jk' quickly while in Insert
mode returns you to Normal mode. This keeps your hands near the home row and
avoids reaching for Escape. You can use either 'jk' or Escape — both work."

    engine_show_key "" "jk" "Exit Insert mode (LazyVim shortcut)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercises"
    # -----------------------------------------------------------------------

    # Exercise 1: Reach Insert mode and come back
    engine_teach "Time to practice! The Neovim pane below is ready. Work through each
exercise and press Check when you're done."

    engine_exercise "enter-insert-mode" \
        "Enter and Leave Insert Mode" \
        "Press 'i' to enter Insert mode, then press Escape (or 'jk') to return to Normal mode. The check passes when Neovim is in Normal mode." \
        verify_normal_mode \
        "Press 'i' to enter Insert mode, then Escape to return to Normal mode." \
        "empty"

    # Exercise 2: Type text in Insert mode and return to Normal
    engine_nvim_keys "ggdG"

    engine_exercise "type-hello-neovim" \
        "Type 'Hello Neovim'" \
        "Press 'i' to enter Insert mode, type exactly 'Hello Neovim', then press Escape to return to Normal mode." \
        verify_hello_neovim_in_normal \
        "Press 'i', type 'Hello Neovim' (capital H and N), then press Escape." \
        "empty"

    # Exercise 3: Visual line select and delete
    engine_teach "For the next exercise the sandbox has three lines of text. You will select
one line with Visual mode and delete it."

    engine_nvim_keys "ggdG"
    engine_nvim_keys "iLine one<CR>Line two<CR>Line three<Esc>"

    engine_exercise "visual-delete-line" \
        "Select and Delete a Line" \
        "Use 'V' (capital V) to select the current line in Visual mode, then press 'd' to delete it. The buffer should have fewer than 3 lines when you're done." \
        verify_line_deleted \
        "Move to any line, press 'V' to select it, then press 'd' to delete it." \
        "empty"

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now know the foundation of Neovim:

  Normal mode  — navigate and edit (press Escape to get here)
  Insert mode  — type text (press i, a, o, I, A, or O to enter)
  Visual mode  — select text (press v, V, or Ctrl-v to enter)
  Command-line — run commands (press : to enter)

The mode indicator in the status bar always tells you where you are. When in
doubt, press Escape to return to Normal mode and start fresh.

Next up: Motions — how to move around a file at the speed of thought."

    engine_pause
}
