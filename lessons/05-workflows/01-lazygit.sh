#!/usr/bin/env bash
# lessons/05-workflows/01-lazygit.sh
# Module 5, Lesson 1: Git Workflows with Lazygit

lesson_info() {
    LESSON_TITLE="Git Workflows with Lazygit"
    LESSON_MODULE="05-workflows"
    LESSON_DESCRIPTION="Use lazygit inside Neovim to stage, commit, push, and explore history — without leaving your editor."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

verify_lazygit_open() {
    verify_via_companion "lazygit_is_open"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Why Git Inside Neovim?"
    # -----------------------------------------------------------------------

    engine_teach "Most developers keep a terminal tab open just for git. Lazygit eliminates
that context switch. It is a full-featured terminal UI for git that LazyVim
integrates directly: one keypress opens it, another closes it, and you never
leave your editor.

Inside lazygit you can stage individual hunks, write commit messages, resolve
merge conflicts, browse history, push and pull remotes, and manage branches —
all with keyboard shortcuts that are visible on screen."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Opening Lazygit"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim maps lazygit to two convenient locations:"

    engine_show_key "Space" "gg" "Open lazygit (project root)"
    engine_show_key "Space" "gG" "Open lazygit (current file's directory)"

    engine_teach "Press <leader>gg from any buffer to open lazygit in a floating terminal
that fills most of the screen. Press 'q' inside lazygit to close it and return
to where you were."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Lazygit Layout"
    # -----------------------------------------------------------------------

    engine_teach "Lazygit divides the screen into panels:

  Top-left    — Files with changes (staged / unstaged)
  Top-middle  — Branches
  Top-right   — Commits
  Bottom      — Diff view for the selected item

Use Tab to cycle between panels and arrow keys (or j/k) to move within a panel.
The key bindings for the focused panel appear along the bottom of the screen —
you never have to memorise them all at once."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Staging and Committing"
    # -----------------------------------------------------------------------

    engine_teach "The most common workflow in the Files panel:"

    engine_show_key "" "Space" "Stage or unstage the selected file"
    engine_show_key "" "a"     "Stage or unstage ALL files at once"
    engine_show_key "" "c"     "Commit staged changes (opens a message prompt)"
    engine_show_key "" "P"     "Push to the remote branch"
    engine_show_key "" "p"     "Pull from the remote"

    engine_teach "To stage only part of a file (a hunk), select the file and press Enter to
drill into the diff view. Navigate to a hunk with j/k and press Space to stage
just that hunk. This lets you craft clean, focused commits even when a file has
unrelated changes mixed together."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Git Blame"
    # -----------------------------------------------------------------------

    engine_teach "For a lighter-weight look at blame information without opening lazygit,
LazyVim provides quick blame commands directly from Normal mode:"

    engine_show_key "Space" "gb" "Git blame — show commit info for current line"
    engine_show_key "Space" "gB" "Git blame — show full blame for entire file"
    engine_show_key "]"     "h"  "Jump to next git hunk (change)"
    engine_show_key "["     "h"  "Jump to previous git hunk"
    engine_show_key "Space" "gh" "Preview hunk diff inline"
    engine_show_key "Space" "gH" "Reset current hunk to HEAD"

    engine_teach "The gutter icons tell you at a glance which lines are added (│), changed
(~), or removed (▸) since the last commit. You can navigate between hunks with
]h and [h, making it easy to review your own work before staging."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Browsing History"
    # -----------------------------------------------------------------------

    engine_teach "Switch to the Commits panel in lazygit (Tab to the top-right) to browse
your project history:

  Enter  — expand a commit to see the changed files
  Space  — checkout a commit (detached HEAD)
  y      — copy the commit SHA to the clipboard
  r      — reword the commit message (interactive rebase)
  d      — drop the commit

For a quick git log without opening lazygit, the picker also has you covered:"

    engine_show_key "Space" "gc" "Git commits — browse log with the picker"
    engine_show_key "Space" "gs" "Git status — staged and unstaged with the picker"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Open Lazygit"
    # -----------------------------------------------------------------------

    engine_teach "Open lazygit with <leader>gg. Look around the panels, then leave it
open. The check passes as soon as lazygit is running in a buffer."

    engine_exercise "lazygit-open" \
        "Open Lazygit with <leader>gg" \
        "Press <leader>gg (Space g g) to open lazygit. Explore the layout — Files, Branches, Commits. Leave it open and type 'check'." \
        verify_lazygit_open \
        "Press Space then g then g. Lazygit should fill the screen. Leave it open before typing 'check'." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Git Blame Keybinding"
    # -----------------------------------------------------------------------

    engine_quiz "Which keybinding shows git blame information for the current line in LazyVim?" \
        "<leader>gl" \
        "<leader>gb" \
        "<leader>gB" \
        2

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now have a complete git workflow inside Neovim:

  <leader>gg   — open lazygit (full UI: stage, commit, push, history)
  <leader>gG   — open lazygit from the current directory
  <leader>gb   — inline blame for the current line
  <leader>gB   — full file blame
  ]h / [h      — jump between changed hunks
  <leader>gh   — preview a hunk inline

The key insight: everything is reachable without leaving Neovim. Context
switches kill flow — lazygit eliminates the git-specific ones.

Next up: the integrated terminal — running commands without ever opening a
separate terminal window."

    engine_pause
}
