#!/usr/bin/env bash
# lessons/05-workflows/02-terminal.sh
# Module 5, Lesson 2: The Integrated Terminal

lesson_info() {
    LESSON_TITLE="The Integrated Terminal"
    LESSON_MODULE="05-workflows"
    LESSON_DESCRIPTION="Open floating and persistent terminals inside Neovim, run commands, and return to editing without losing context."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

# Pass when any window is showing a terminal-mode buffer.
# LazyVim uses snacks.nvim terminal; filetype is "snacks_terminal" for managed terminals.
# Fallback: check for any buffer in terminal mode (filetype "terminal" or
# the buffer name starting with "term://").
verify_terminal_open() {
    verify_reset

    # Check for any terminal-like buffer: snacks_terminal, toggleterm, terminal,
    # or any buffer whose name starts with "term://"
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_bufs()):any(function(b) if not vim.api.nvim_buf_is_loaded(b) then return false end local ft = vim.bo[b].filetype local name = vim.api.nvim_buf_get_name(b) return ft == \"snacks_terminal\" or ft == \"toggleterm\" or ft == \"terminal\" or name:match(\"^term://\") ~= nil end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Terminal is open"
        return 0
    fi

    VERIFY_MESSAGE="No terminal buffer found"
    VERIFY_HINT="Press <leader>ft to open a floating terminal or Ctrl-/ for a quick toggle."
    return 1
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Terminals Inside Neovim"
    # -----------------------------------------------------------------------

    engine_teach "Neovim has a built-in terminal emulator. LazyVim enhances it with the
snacks.nvim terminal, which gives you floating terminals, split terminals, and
persistent sessions — all managed with keyboard shortcuts.

The benefit: you can run a build command, check output, and jump straight back
to the failing line in the editor, all without switching applications."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Opening a Terminal"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim provides several ways to open a terminal:"

    engine_show_key "Space" "ft" "Open a floating terminal (current directory)"
    engine_show_key "Space" "fT" "Open a floating terminal (project root)"
    engine_show_key "Ctrl"  "/"  "Toggle a terminal split (quick access)"
    engine_show_key "Ctrl"  "_"  "Same as Ctrl-/ (alternative binding)"

    engine_teach "<leader>ft opens a terminal in a floating window that hovers over your
editing area. It is ideal for quick commands. Press the same key combination
again (or press Escape twice) to hide it without killing the shell — your
session is preserved and the command continues running.

<C-/> opens a terminal in a horizontal split at the bottom of the screen.
This is useful when you want to see the editor and the output at the same time."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Terminal Mode"
    # -----------------------------------------------------------------------

    engine_teach "When a terminal buffer is focused, Neovim enters Terminal mode. In this
mode, every keypress is forwarded directly to the shell — your Normal mode
shortcuts do not work.

You will know you are in terminal mode because the mode indicator shows TERMINAL
and the cursor changes style."

    engine_show_key "Esc Esc" "" "Leave terminal mode — return to Normal mode"
    engine_show_key "Ctrl"  "\\\\n" "Alternative: leave terminal mode"

    engine_teach "Once you are back in Normal mode inside the terminal buffer, you can use
all the usual Neovim motions to scroll through output, yank text, or search
with /. Press 'i' or 'a' to re-enter terminal mode when you want to type more
commands."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigating Between Terminal and Editor"
    # -----------------------------------------------------------------------

    engine_teach "The standard window navigation keys work once you have left terminal mode:"

    engine_show_key "Ctrl" "h" "Move to the window on the left"
    engine_show_key "Ctrl" "j" "Move to the window below"
    engine_show_key "Ctrl" "k" "Move to the window above"
    engine_show_key "Ctrl" "l" "Move to the window on the right"

    engine_teach "Tip: if you press <C-/> to open a bottom split terminal and then press
<C-/> again, the terminal is hidden but the shell stays alive. Next time you
open it the history and the working directory are exactly as you left them.

For longer-running processes (test suites, dev servers, compilers) this means
you can check on them without interrupting them."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Multiple Terminal Instances"
    # -----------------------------------------------------------------------

    engine_teach "Snacks terminal supports numbered instances. You can have several
shells open simultaneously and switch between them:"

    engine_show_key "1 Space" "ft" "Open or focus terminal #1"
    engine_show_key "2 Space" "ft" "Open or focus terminal #2"

    engine_teach "Prefix any terminal command with a count to address a specific instance.
A common pattern: terminal 1 for a dev server, terminal 2 for running tests,
terminal 3 for git commands — each persistent and addressable."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Open a Terminal"
    # -----------------------------------------------------------------------

    engine_teach "Open a terminal using <leader>ft or <C-/>. You do not need to run any
commands — just open it. The check passes when a terminal buffer is visible."

    engine_exercise "terminal-open" \
        "Open an integrated terminal" \
        "Press <leader>ft (Space f t) or Ctrl-/ to open a terminal. Leave it visible and type 'check'." \
        verify_terminal_open \
        "Press Space then f then t. A floating terminal window should appear. Leave it open before typing 'check'." \
        "empty"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Escaping Terminal Mode"
    # -----------------------------------------------------------------------

    engine_quiz "You have typed a command in the terminal and now want to scroll through the output in Normal mode. What do you press to leave terminal mode?" \
        "Ctrl-c" \
        "Escape" \
        "Escape Escape (press Escape twice)" \
        3

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You can now stay inside Neovim for everything:

  <leader>ft   — floating terminal (current directory)
  <leader>fT   — floating terminal (project root)
  <C-/>        — toggle bottom-split terminal
  Esc Esc      — leave terminal mode, enter Normal mode
  Ctrl-h/j/k/l — navigate back to editor windows

The key habit: use Esc Esc to leave terminal mode before trying to navigate
away. If you press Ctrl-h while still in terminal mode the keystroke goes to
the shell, not to Neovim.

Next up: the Debug Adapter Protocol — setting breakpoints and stepping through
code without leaving the editor."

    engine_pause
}
