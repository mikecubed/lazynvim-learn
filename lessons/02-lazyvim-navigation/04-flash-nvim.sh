#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/04-flash-nvim.sh
# Module 2, Lesson 4: Flash.nvim — Label-based Jumping

# The "file" sandbox type opens sample.py (70 lines of Python with classes
# and functions — good Treesitter node coverage).

lesson_info() {
    LESSON_TITLE="Flash.nvim — Label-based Jumping"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Jump anywhere on screen in two keystrokes with flash.nvim labels, and select Treesitter nodes with S."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: user used s{chars} to jump to a line containing "priority"
# sample.py has "priority" on lines 11, 12, 27, 35, 36, 42, 69.
verify_on_priority_line() {
    verify_reset
    local line
    line=$(nvim_eval "getline('.')")

    if echo "$line" | grep -q "priority"; then
        VERIFY_MESSAGE="Cursor is on a line containing 'priority'."
        return 0
    else
        VERIFY_MESSAGE="Current line does not contain 'priority'. Use 's' to jump there."
        VERIFY_HINT="Press 's', type 'pr', wait for flash labels to appear, then press the highlighted label key next to the word 'priority'."
        return 1
    fi
}

# Exercise 2: user pressed S to enter Treesitter-node visual selection
verify_treesitter_visual() {
    verify_reset
    local mode
    mode=$(nvim_eval "mode()")

    # Flash S lands in visual mode (v) or linewise visual (V) depending on node
    if [[ "$mode" == "v" || "$mode" == "V" ]]; then
        VERIFY_MESSAGE="Treesitter node selected in Visual mode."
        return 0
    else
        VERIFY_MESSAGE="Not in Visual mode (current mode: '$mode'). Use 'S' to select a Treesitter node."
        VERIFY_HINT="Make sure you are in Normal mode first (press Escape), then press capital 'S', wait for labels, and press the label key next to a code block."
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is Flash.nvim?"
    # -----------------------------------------------------------------------

    engine_teach "flash.nvim is a LazyVim built-in that replaces slow searching with instant
labeled jumping. Instead of pressing '/' and scanning for text, you press 's',
type one or two characters, and flash overlays every matching position on screen
with a one-letter label. Press that label and your cursor teleports there.

No counting, no repeated ';', no mouse — just two or three keystrokes to land
anywhere visible."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The 's' Jump"
    # -----------------------------------------------------------------------

    engine_teach "The core workflow:"

    engine_show_key "" "s"        "Start a flash jump (Normal, Visual, or Operator-pending mode)"
    engine_show_key "" "{chars}"  "Type one or two characters to search — matches highlight instantly"
    engine_show_key "" "{label}"  "Press the highlighted label letter to jump to that match"
    engine_show_key "" "<Esc>"    "Cancel the flash jump without moving"

    engine_teach "Flash matches are case-insensitive by default. As you type more characters
the label set narrows, so typing two characters ('pr') is usually enough to
pinpoint a unique word ('priority', 'print', etc.).

The labels are placed at the start of each match, using unused letters so they
never obscure the target text."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Remote Flash"
    # -----------------------------------------------------------------------

    engine_teach "Flash also has a 'remote' mode — useful in Operator-pending context:"

    engine_show_key "" "r"       "Remote flash: jump-then-operate, cursor returns after the operation"
    engine_show_key "y" "r{chars}{label}"  "Example: yank text at a remote location without moving permanently"

    engine_teach "Remote flash lets you operate on text anywhere on screen without permanently
moving your cursor. After the operation, the cursor returns to where it started.
This pairs naturally with operators: 'yr' yanks from a remote position; 'dr'
deletes remotely."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Treesitter Node Selection with 'S'"
    # -----------------------------------------------------------------------

    engine_teach "Capital 'S' activates Flash's Treesitter mode. Instead of jumping to a
character match, flash highlights entire syntax nodes — functions, classes,
arguments, blocks — and lets you select one."

    engine_show_key "" "S"       "Flash Treesitter: label every visible syntax node"
    engine_show_key "" "{label}" "Press a label to jump into that node in Visual mode"

    engine_teach "Treesitter mode is powerful for quickly selecting a whole function body,
a conditional block, or an argument list. Once you land in Visual mode you
can press an operator (d, c, y) or extend the selection with 'o' and 'O'.

It also composes with Operator-pending mode: 'dS' + label deletes the
selected node outright."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Flash in Telescope"
    # -----------------------------------------------------------------------

    engine_teach "Flash integrates with Telescope fuzzy finders. While a Telescope picker is
open, press Ctrl-s to enable flash labels on visible results, then press a
label to jump directly to that result."

    engine_show_key "Ctrl" "s"   "Flash labels inside an active Telescope picker"

    engine_teach "This means you can open a file picker (<leader>ff), narrow results with a
few characters, then press Ctrl-s and a label instead of pressing the arrow
keys or Enter. It turns the picker into a two-keystroke teleporter."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercises"
    # -----------------------------------------------------------------------

    engine_teach "The Neovim pane has sample.py open — a 70-line Python file with classes,
methods, and several occurrences of the word 'priority'. Work through the
two exercises below."

    # Exercise 1: s-jump to a line containing "priority"
    engine_exercise "flash-s-jump" \
        "Flash-jump to 'priority'" \
        "Press 's', type 'pr', wait for flash labels to appear, then press the label shown next to any occurrence of 'priority' to land on that line." \
        verify_on_priority_line \
        "Press 's', type the letters 'pr' (for 'priority'), then press the label letter flashed next to the target word." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # Exercise 2: S Treesitter selection — any visible node lands in visual mode
    engine_teach "For the next exercise you will use capital 'S' to select a Treesitter node.
Make sure you are in Normal mode (press Escape if unsure), then press 'S'.
Flash will label every syntax node it can see. Press any label key — the node
will be selected in Visual mode."

    engine_exercise "flash-treesitter" \
        "Select a Treesitter Node with S" \
        "Press capital 'S' (Shift+s) to start Treesitter flash. Press any label to select that node. You should end up in Visual mode with a code node highlighted." \
        verify_treesitter_visual \
        "Press Escape first to ensure Normal mode, then press capital 'S'. Press any visible label letter — you should see a block highlighted in Visual mode." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "Flash.nvim key commands:

  s{chars}{label}  — jump anywhere on screen in ~3 keystrokes
  S{label}         — select a Treesitter syntax node in Visual mode
  r{chars}{label}  — remote flash (operate without moving cursor permanently)
  Ctrl-s           — flash labels inside an active Telescope picker

Flash replaces the old '/' search-and-count workflow for in-screen navigation.
Once it becomes muscle memory, you will rarely need to scroll or press arrow
keys to reach a visible target.

Next up: Which-key — discovering every keybinding by just waiting."

    engine_pause
}
