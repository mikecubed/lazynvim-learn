#!/usr/bin/env bash
# lessons/05-workflows/03-debugging-dap.sh
# Module 5, Lesson 3: Debugging with DAP

lesson_info() {
    LESSON_TITLE="Debugging with DAP"
    LESSON_MODULE="05-workflows"
    LESSON_DESCRIPTION="Set breakpoints, inspect variables, and step through code using the Debug Adapter Protocol — all inside Neovim."
    LESSON_TIME="15 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

# The exercise asks the user to set a breakpoint on line 17 of sample.py.
# Line 17 is the body of the `complete()` method: "self.status = STATUS_DONE"
verify_breakpoint_on_line_17() {
    verify_via_companion "breakpoint_on_line" "17"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is the Debug Adapter Protocol?"
    # -----------------------------------------------------------------------

    engine_teach "Debugging traditionally means leaving the editor, running a tool in a
separate window, and stitching the output back into your mental model of the
code. The Debug Adapter Protocol (DAP) eliminates that by providing a standard
interface that allows Neovim to talk directly to language debuggers.

nvim-dap, nvim-dap-ui, and language adapters are available as a LazyVim Extra.
Once enabled and configured, you set breakpoints and inspect state without
ever leaving your buffer.

Note: DAP requires the dap LazyVim Extra and a language-specific adapter
(e.g. debugpy for Python). This lesson covers the keybindings and workflow —
exercises are quizzes since DAP setup varies by language."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The DAP Keymap Prefix: <leader>d"
    # -----------------------------------------------------------------------

    engine_teach "All DAP commands live under the <leader>d prefix. Press <leader>d and
pause — which-key will show the full menu. The most important ones:"

    engine_show_key "Space" "db" "Toggle breakpoint on the current line"
    engine_show_key "Space" "dB" "Set a conditional breakpoint (with expression)"
    engine_show_key "Space" "dc" "Continue (run until next breakpoint)"
    engine_show_key "Space" "dC" "Run to cursor (temporary breakpoint here)"
    engine_show_key "Space" "di" "Step into the function under the cursor"
    engine_show_key "Space" "do" "Step over the current line"
    engine_show_key "Space" "dO" "Step out of the current function"
    engine_show_key "Space" "du" "Toggle the DAP UI panel"
    engine_show_key "Space" "dE" "Evaluate an expression in the current scope"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Setting Breakpoints"
    # -----------------------------------------------------------------------

    engine_teach "Move the cursor to any line and press <leader>db to toggle a breakpoint.
A red dot (or similar sign) appears in the gutter to confirm the breakpoint is
set. Press the same key again to remove it.

Breakpoints are persistent within a session — they survive buffer switches and
are tracked per file. You can set as many as you like before starting a debug
session."

    engine_show_key "Space" "db" "Toggle breakpoint — gutter icon appears when set"

    engine_teach "For conditional breakpoints (<leader>dB), Neovim prompts you for an
expression in the current language. The debugger will only pause when that
expression evaluates to true — useful for breaking inside a loop only when a
specific condition is met."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Starting a Debug Session"
    # -----------------------------------------------------------------------

    engine_teach "<leader>dc (Continue) starts the debugger if no session is running, or
resumes execution to the next breakpoint if one is already active.

Most language adapters are auto-detected from the filetype. For Python,
nvim-dap-python launches debugpy on the current file. For Node.js, the adapter
connects to a running process or launches one.

If the adapter is not auto-configured, you can define launch configurations in
a .vscode/launch.json file at the project root — DAP reads this standard format."

    engine_show_key "Space" "dc" "Start / Continue the debug session"
    engine_show_key "Space" "dq" "Quit / terminate the debug session"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The DAP UI"
    # -----------------------------------------------------------------------

    engine_teach "Press <leader>du to toggle the nvim-dap-ui panel. It opens a set of
floating or split windows showing:

  Scopes    — local variables, arguments, and their current values
  Watches   — expressions you are monitoring continuously
  Breakpoints — list of all breakpoints with conditions
  Stacks    — the call stack at the current pause point
  Console   — debugger output and REPL for evaluating expressions

You can hover over any variable in your source buffer and press <leader>dE
to evaluate it in the current scope — the result appears inline."

    engine_show_key "Space" "du" "Toggle DAP UI panels"
    engine_show_key "Space" "dE" "Evaluate expression under cursor"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Step Controls"
    # -----------------------------------------------------------------------

    engine_teach "Once paused at a breakpoint, you control execution line by line:"

    engine_show_key "Space" "do" "Step over — execute current line, stop at next"
    engine_show_key "Space" "di" "Step into — follow a function call inside"
    engine_show_key "Space" "dO" "Step out  — finish current function, return to caller"
    engine_show_key "Space" "dc" "Continue  — run until next breakpoint or end"
    engine_show_key "Space" "dC" "Run to cursor — stop at the line under the cursor"

    engine_teach "The current execution line is highlighted in the source buffer so you can
always see exactly where the program is paused. Variable values in the Scopes
panel update with each step."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercises"
    # -----------------------------------------------------------------------

    # Check if DAP is available in the sandbox
    local dap_available=0
    if sandbox_is_alive 2>/dev/null; then
        local dap_check
        dap_check=$(nvim_lua "tostring(pcall(require, \"dap\"))")
        [[ "$dap_check" == "true" ]] && dap_available=1
    fi

    if [[ $dap_available -eq 1 ]]; then
        engine_teach "DAP is available in this sandbox. Let's try setting a breakpoint."

        engine_nvim_open "sample.py"

        engine_exercise "dap-set-breakpoint" \
            "Set a breakpoint on line 17 of sample.py" \
            "Navigate to line 17 (try '17G') and press <leader>db to toggle a breakpoint. A gutter marker should appear. Type 'check' when done." \
            verify_breakpoint_on_line_17 \
            "Press '17G' to jump to line 17, then press Space d b to set a breakpoint." \
            "file" \
            "sample.py"

        [[ $_ENGINE_QUIT -eq 1 ]] && return
    else
        engine_teach "DAP is not available in this session (plugins may still be installing).
To enable debugging in your own Neovim config:

  1. Run :LazyExtras and enable 'dap.core'
  2. Run :MasonInstall debugpy  (for Python debugging)
  3. Restart Neovim

Try running ./lazynvim-learn --reset-config to reinstall the
sandbox, then come back to this lesson. Skipping the hands-on
exercise for now."

        engine_pause
    fi

    engine_quiz "Which keybinding sets a breakpoint on the current line?" \
        "<leader>dc" \
        "<leader>db" \
        "<leader>dB" \
        "<leader>du" \
        2

    engine_quiz "You are paused at a breakpoint and want to execute the current line without following any function calls it makes. Which key do you use?" \
        "<leader>di (step into)" \
        "<leader>do (step over)" \
        "<leader>dO (step out)" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now have a working mental model of debugging inside Neovim:

  <leader>db   — toggle breakpoint on the current line
  <leader>dB   — conditional breakpoint
  <leader>dc   — start session / continue to next breakpoint
  <leader>do   — step over
  <leader>di   — step into
  <leader>dO   — step out
  <leader>dC   — run to cursor
  <leader>du   — toggle DAP UI (scopes, watches, stacks)
  <leader>dE   — evaluate expression in current scope

The workflow: set breakpoints with <leader>db, start with <leader>dc, then
use step controls to trace through the logic. The UI panels keep variable
state visible at all times.

Next up: the capstone lesson — putting everything together in one multi-step
challenge."

    engine_pause
}
