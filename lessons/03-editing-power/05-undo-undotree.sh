#!/usr/bin/env bash
# lessons/03-editing-power/05-undo-undotree.sh
# Module 3, Lesson 5: Undo & Undotree

lesson_info() {
    LESSON_TITLE="Undo & Undotree"
    LESSON_MODULE="03-editing-power"
    LESSON_DESCRIPTION="Master undo, redo, and Neovim's built-in undo tree visualizer to edit fearlessly."
    LESSON_TIME="10 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: user deleted the "complete" method (line containing "def complete")
verify_method_deleted() {
    verify_reset
    if verify_buffer_not_contains "def complete"; then
        VERIFY_MESSAGE="The 'complete' method has been deleted"
        return 0
    else
        VERIFY_MESSAGE="The 'complete' method is still in the buffer"
        VERIFY_HINT="Place cursor on 'def complete' and press 'dd' to delete the line, or use 'daf' to delete the whole method."
        return 1
    fi
}

# Exercise 2: user undid the delete — "def complete" is back
verify_method_restored() {
    verify_reset
    if verify_buffer_contains "def complete"; then
        VERIFY_MESSAGE="The 'complete' method has been restored"
        return 0
    else
        VERIFY_MESSAGE="The 'complete' method is not in the buffer — keep pressing u to undo"
        VERIFY_HINT="Press u in Normal mode to undo. Press multiple times if needed."
        return 1
    fi
}

# Exercise 3: :Undotree window is visible
verify_undotree_open() {
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_wins()):any(function(w) local buf = vim.api.nvim_win_get_buf(w); return vim.bo[buf].filetype == \"nvim-undotree\" end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Undotree window is open"
        return 0
    else
        VERIFY_MESSAGE="No Undotree window found"
        VERIFY_HINT="Type :Undotree in Normal mode and press Enter."
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Undo and Redo Basics"
    # -----------------------------------------------------------------------

    engine_teach "Every change you make in Neovim is recorded in an undo history. This
means you can always get back to a previous state — no matter how many
edits you have made.

The basic commands are simple:"

    engine_show_key "" "u"          "Undo the last change"
    engine_show_key "Ctrl" "r"     "Redo (undo the undo)"

    engine_teach "Each press of u steps one change backward. Each press of Ctrl-r steps
one change forward. You can undo all the way back to when the file was
opened, and redo all the way forward to your most recent edit.

This is the safety net that lets you experiment freely — delete a
paragraph, try a refactor, rearrange code. If the result is wrong,
u brings it right back."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Undo Tree"
    # -----------------------------------------------------------------------

    engine_teach "Most editors have a linear undo history: undo, undo, undo, redo, redo.
If you undo and then make a new edit, the redo history is lost forever.

Neovim is different. It keeps an undo TREE. When you undo and then make
a different change, both branches are preserved. You never lose work.

Example:
  1. Type 'hello'      →  state A
  2. Type 'world'      →  state B
  3. Undo              →  back to A
  4. Type 'neovim'     →  state C (a new branch)

In most editors, state B is gone. In Neovim, state B still exists in
the undo tree — you just need a way to see it and navigate to it."

    engine_teach "Neovim has time-based undo commands that let you jump to how the file
looked at a specific point in time, regardless of which branch you are on:

  :earlier 5m   — revert to 5 minutes ago
  :later 30s    — jump forward 30 seconds
  :earlier 3    — go back 3 changes

These are useful even without the tree visualizer."

    engine_show_key "" ":earlier 5m"   "Revert to file state 5 minutes ago"
    engine_show_key "" ":later 30s"    "Jump forward 30 seconds"
    engine_show_key "" "g-"            "Go to older text state (follows branches)"
    engine_show_key "" "g+"            "Go to newer text state (follows branches)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Delete a Method"
    # -----------------------------------------------------------------------

    engine_teach "sample.py is open in the Neovim pane. The TodoItem class has a method
called 'complete' (around line 19).

Delete the entire 'complete' method — you can use 'dd' to delete line
by line, or 'daf' to delete the whole function at once.

The check passes when 'def complete' is no longer in the buffer."

    engine_exercise "undo-delete-method" \
        "Delete the 'complete' method" \
        "Navigate to the 'complete' method (around line 19). Delete it using 'dd' or 'daf'. type 'check' when done." \
        verify_method_deleted \
        "Move to 'def complete' with /def complete<Enter>, then press 'daf' to delete the whole function." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Undo the Delete"
    # -----------------------------------------------------------------------

    engine_teach "The method is gone — but not really. Press u to undo and bring it back.

If you used 'daf' the whole method comes back in one undo. If you used
'dd' multiple times you may need to press u several times.

The check passes when 'def complete' appears in the buffer again."

    engine_exercise "undo-restore-method" \
        "Undo to restore the 'complete' method" \
        "Press u (in Normal mode) to undo until the 'complete' method reappears. type 'check' when done." \
        verify_method_restored \
        "Press u in Normal mode. If it does not come back, press u more times." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "The Built-in Undotree Visualizer"
    # -----------------------------------------------------------------------

    engine_teach "Neovim 0.12 ships with a built-in undo tree visualizer. It shows every
branch of your undo history as an interactive tree — no plugin needed.

It ships as an optional package, so you load it once with:
  :packadd nvim.undotree

Then open it with :Undotree. A side panel appears showing the tree
structure. You can navigate the tree to jump between branches and see
exactly what changed at each point.

In older Neovim versions this required a third-party plugin (undotree or
mundo). Now it is built in."

    engine_show_key "" ":packadd nvim.undotree"  "Load the built-in undotree package"
    engine_show_key "" ":Undotree"               "Open the undo tree visualizer"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 3: Open the Undotree"
    # -----------------------------------------------------------------------

    engine_teach "Open the Undotree visualizer to see the undo history for this buffer.
After the edits and undos you just performed, the tree should have at
least a couple of entries.

First load the package:  :packadd nvim.undotree
Then open the tree:      :Undotree

The check passes when the Undotree window is visible."

    engine_exercise "undo-open-undotree" \
        "Open the Undotree visualizer" \
        "Type :packadd nvim.undotree then :Undotree in Normal mode and press Enter. type 'check' when the tree panel is visible." \
        verify_undotree_open \
        "In Normal mode, type :packadd nvim.undotree<Enter> first, then :Undotree<Enter>." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Quiz"
    # -----------------------------------------------------------------------

    engine_quiz \
        "You undo three changes, then type new text. What happens to the undone changes?" \
        "They are lost — redo history is cleared when you make a new edit" \
        "They are saved in a separate file you can load later" \
        "They are preserved in the undo tree — both branches coexist" \
        3

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now have the complete undo toolkit:

  u             — undo the last change
  Ctrl-r        — redo (undo the undo)
  g- / g+       — traverse older/newer states across branches
  :earlier 5m   — revert to how the file looked 5 minutes ago
  :Undotree     — visualize and navigate the full undo tree

Neovim's undo tree means you never lose work. Every edit path you have
ever taken is preserved and reachable. This is the safety net that lets
you edit fearlessly.

Congratulations — you have completed Module 3: Editing Power.

You are now equipped with the full professional toolkit:
  LSP for intelligence, completions for speed,
  formatters for consistency, Treesitter for precision,
  and undo for fearlessness."

    engine_pause
}
