#!/usr/bin/env bash
# lessons/01-neovim-essentials/05-registers.sh
# Lesson 1.5 — Registers and Macros

lesson_info() {
    LESSON_TITLE="Registers and Macros"
    LESSON_MODULE="01-neovim-essentials"
    LESSON_DESCRIPTION="Master Neovim's register system and macro recording."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Verification helpers
# ---------------------------------------------------------------------------

_verify_register_a_has_item() {
    # Register "a" must contain the line "- item 1: save file"
    verify_register_contains "a" "item 1"
}

_verify_items_transformed() {
    # All three list lines must have been rewritten from "- item N:" to "* ITEM N:"
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\")")

    local ok=1
    echo "$content" | grep -q '\* ITEM 1' || ok=0
    echo "$content" | grep -q '\* ITEM 2' || ok=0
    echo "$content" | grep -q '\* ITEM 3' || ok=0

    # Also make sure the old format is gone
    if echo "$content" | grep -q '^\- item [123]'; then
        ok=0
    fi

    if [[ $ok -eq 1 ]]; then
        VERIFY_MESSAGE="All three items have been transformed"
        return 0
    else
        VERIFY_MESSAGE="Not all three items are transformed yet"
        VERIFY_HINT="Record the macro on line 1 with qa, then replay it with @a on lines 2 and 3"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# lesson_run
# ---------------------------------------------------------------------------

lesson_run() {
    # ------------------------------------------------------------------
    # Section 1: The register system
    # ------------------------------------------------------------------
    engine_section "Neovim's Register System"

    engine_teach "Every time you yank, delete, or change text in Neovim, the text lands in a register — a named clipboard slot. Understanding registers gives you precise control over what you paste."

    engine_teach "The most important registers to know:"

    engine_show_key '""'  ""   "Unnamed register — default destination for y, d, c, x"
    engine_show_key '"0'  ""   "Yank register — always holds the last yanked text (not deleted)"
    engine_show_key '"a-z' ""  "Named registers — you choose when to use them"
    engine_show_key '"+'  ""   "System clipboard (requires clipboard support)"
    engine_show_key '"*'  ""   "Primary selection (Linux/X11 middle-click)"

    printf '\n'
    engine_teach "Named registers are perfect when you need to copy several different things at once without overwriting each other."

    engine_pause

    # ------------------------------------------------------------------
    # Section 2: Yanking into a named register
    # ------------------------------------------------------------------
    engine_section "Yanking Into a Named Register"

    engine_teach "To target a specific register, prefix your operator with a double-quote and the register letter. The pattern is:"
    engine_show_key '"a' "yy"  "Yank current line into register a"
    engine_show_key '"a' "yw"  "Yank word into register a"
    engine_show_key '"a' "y\$"  "Yank to end of line into register a"

    printf '\n'
    engine_teach "To paste from a named register:"
    engine_show_key '"a' "p"   "Paste register a after cursor"
    engine_show_key '"a' "P"   "Paste register a before cursor"

    printf '\n'
    engine_teach "To inspect all register contents at any time, run :registers (or :reg for short). Neovim shows each register and a preview of what it holds."
    engine_show_key ":"  "reg"  "List all registers and their contents"

    engine_pause

    # ------------------------------------------------------------------
    # Exercise 1: Yank into register a
    # ------------------------------------------------------------------
    engine_exercise \
        "yank-register-a" \
        "Yank a Line Into Register a" \
        'The file registers.md is open in the sandbox. Find the line that reads "- item 1: save file" and yank the whole line into register a using: \"ayy

Then type :reg a to confirm the register holds that line.

When you are ready, type check.' \
        _verify_register_a_has_item \
        'Position the cursor on the "- item 1: save file" line, then type "ayy to yank the line into register a.' \
        "file" \
        "${LAZYNVIM_LEARN_ROOT}/configs/exercise-files/registers.md"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    # Section 3: Viewing registers
    # ------------------------------------------------------------------
    engine_section "Viewing Registers"

    engine_teach ":registers shows a table of every active register. You will see the type (characterwise, linewise, blockwise) next to each entry. This is handy for debugging unexpected pastes."

    engine_teach "A few special read-only registers worth knowing:"
    engine_show_key '".'  ""  "Last inserted text"
    engine_show_key '"%'  ""  "Current filename"
    engine_show_key '":'  ""  "Last Ex command"
    engine_show_key '"/'  ""  "Last search pattern"

    engine_pause

    # ------------------------------------------------------------------
    # Section 4: Macros
    # ------------------------------------------------------------------
    engine_section "Recording Macros"

    engine_teach "A macro is just a sequence of keystrokes recorded into a register. Because macros live in normal registers, everything you already know about registers applies to them too."

    engine_teach "Recording a macro:"
    engine_show_key "q"  "a"   "Start recording into register a (q again to stop)"
    engine_show_key "q"  ""    "Stop recording"

    printf '\n'
    engine_teach "Playing a macro:"
    engine_show_key "@"  "a"   "Replay macro stored in register a"
    engine_show_key "@@" ""    "Replay the most recently used macro"
    engine_show_key "3"  "@a"  "Replay macro a three times"

    printf '\n'
    engine_teach "Macros capture every keystroke — motions, operators, insert-mode text, Ex commands — so they can automate almost any repetitive edit."

    engine_pause

    # ------------------------------------------------------------------
    # Section 5: Practical macro tips
    # ------------------------------------------------------------------
    engine_section "Practical Macro Tips"

    engine_teach "A few habits that make macros reliable:"

    engine_teach "1. Start with a motion that positions the cursor predictably. Using 0 (jump to column 1) at the start of a macro makes it safe to replay on any line."

    engine_teach "2. End the macro so the cursor lands on the next target. If your macro edits one line and ends with j (move down), repeating it with @a will chain through a list automatically."

    engine_teach "3. Test the macro on one line before running it on many. Use u to undo, fix the recording, and try again."

    engine_teach "4. To apply a macro to a visual range, select the lines with V then type :normal @a — Neovim will run the macro on every selected line."

    engine_pause

    # ------------------------------------------------------------------
    # Exercise 2: Record and apply a macro
    # ------------------------------------------------------------------
    engine_exercise \
        "macro-transform" \
        "Transform Lines With a Macro" \
        'The file registers.md has three lines that look like:
  - item 1: save file
  - item 2: quit editor
  - item 3: undo change

Your goal: transform all three lines so they read:
  * ITEM 1: save file
  * ITEM 2: quit editor
  * ITEM 3: undo change

Suggested approach:
  1. Move to the "- item 1" line
  2. Type qa to start recording into register a
  3. Edit the line: change "- item" to "* ITEM" (try 0 then cw* ITEM<Esc>)
  4. Press j to move to the next line
  5. Press q to stop recording
  6. Press @a twice (or 2@a) to replay on the remaining two lines

Type check when all three lines are transformed.' \
        _verify_items_transformed \
        'Record with qa, use 0 to go to column 1, then cw to change "- item" to "* ITEM", press j, then q to stop. Replay with 2@a.' \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    # Quiz
    # ------------------------------------------------------------------
    engine_section "Quick Check"

    engine_quiz \
        'What register always holds the most recently yanked text (even after a delete)?' \
        '"" (the unnamed register)' \
        '"0 (the yank register)' \
        '"+ (the clipboard register)' \
        '"/ (the search register)' \
        2

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    engine_quiz \
        'Which key sequence starts recording a macro into register b?' \
        '@b' \
        'qb' \
        '"by' \
        'mb' \
        2

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    # Wrap-up
    # ------------------------------------------------------------------
    engine_section "Lesson Complete"

    engine_teach "You now have two powerful tools for repetitive editing: named registers that let you juggle multiple clipboard slots, and macros that can replay any sequence of edits on demand."

    engine_teach "The more you use macros, the more natural it becomes to design your edits so they are easy to replay. That habit — thinking in repeatable actions — is one of the hallmarks of efficient Neovim editing."

    engine_pause
}
