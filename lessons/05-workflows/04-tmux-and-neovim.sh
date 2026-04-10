#!/usr/bin/env bash
# lessons/05-workflows/04-tmux-and-neovim.sh
# Module 5, Lesson 4: tmux and Neovim Together

lesson_info() {
    LESSON_TITLE="tmux and Neovim Together"
    LESSON_MODULE="05-workflows"
    LESSON_DESCRIPTION="Combine tmux panes with Neovim splits for a powerful terminal-based development workflow."
    LESSON_TIME="10 minutes"
}

# No exercises — this is a conceptual/workflow lesson.

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Two Tools, One Workflow"
    # -----------------------------------------------------------------------

    engine_teach "You have been using tmux throughout this entire tutorial — it is what
creates the split between this lesson pane and the Neovim pane. But tmux
and Neovim are separate tools that overlap in some areas:

  tmux    — splits your terminal into panes, manages sessions and windows
  Neovim  — splits its editor into windows, has a built-in terminal

Both can create split views. Both can run terminal commands. So when
should you use which?"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "When to Use Neovim Splits"
    # -----------------------------------------------------------------------

    engine_teach "Use Neovim splits when you are working with files and code:

  Comparing two files side by side     — :vsplit other_file.py
  Viewing a definition while editing   — gd opens in a split
  Running a quick command              — <leader>ft for a floating terminal
  Browsing diagnostics alongside code  — <leader>xx opens Trouble

Neovim splits share the same LSP context, registers, and undo history.
Everything is connected — yank from one split, paste in another. The LSP
understands all open buffers together."

    engine_show_key "Ctrl-w" "v"            "Vertical split (side by side)"
    engine_show_key "Ctrl-w" "s"            "Horizontal split (top/bottom)"
    engine_show_key "Ctrl-w" "h/j/k/l"     "Move between Neovim splits"
    engine_show_key "Ctrl-w" "q"            "Close the current split"
    engine_show_key "Leader" "ft"           "Floating terminal (inside Neovim)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "When to Use tmux Panes"
    # -----------------------------------------------------------------------

    engine_teach "Use tmux panes when you need things to persist independently of Neovim:

  Long-running processes   — dev servers, watchers, build logs
  Multiple projects        — different tmux windows for different repos
  Pair programming         — share a tmux session with a colleague
  Session persistence      — detach and reattach without losing state

tmux panes survive even if Neovim exits. If your dev server is running
in a tmux pane, closing Neovim does not kill it. If your SSH connection
drops, tmux keeps everything running — just reattach."

    engine_show_key "Ctrl-b" "%"            "Split tmux vertically"
    engine_show_key "Ctrl-b" "\""           "Split tmux horizontally"
    engine_show_key "Ctrl-b" "arrow"        "Move between tmux panes"
    engine_show_key "Ctrl-b" "z"            "Zoom a pane to full screen (toggle)"
    engine_show_key "Ctrl-b" "d"            "Detach from tmux session"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "A Typical Development Layout"
    # -----------------------------------------------------------------------

    engine_teach "A common setup for daily development:

  tmux window 1 — 'editor'
    Left pane (80%):   Neovim with your project open
    Right pane (20%):  A shell for git commands, running tests, etc.

  tmux window 2 — 'server'
    Full pane:         Dev server / docker compose / build watcher

  tmux window 3 — 'misc'
    Full pane:         Database shell, logs, or other tools

Switch between tmux windows with Ctrl-b n (next) or Ctrl-b w (picker).
Inside the editor window, use Neovim splits for multi-file editing.

This separation keeps concerns clean:
  Neovim handles code.  tmux handles infrastructure."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "LazyVim Terminal vs tmux"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim includes terminal integration via <leader>ft (floating) and
<leader>fT (in a split). These open a terminal inside Neovim.

When to use LazyVim's terminal:
  Quick one-off commands — run a test, check git status, install a package
  You want the output visible alongside your code
  You want to copy output directly into a buffer

When to use a tmux pane instead:
  Long-running processes that should outlive your Neovim session
  Commands that produce a lot of scrollback (build logs, server output)
  When you want to zoom in with Ctrl-b z without affecting Neovim

There is no wrong answer — use whatever feels natural. Many developers
use LazyVim's terminal for quick commands and tmux panes for persistent
processes."

    engine_show_key "Leader" "ft"           "LazyVim floating terminal"
    engine_show_key "Leader" "fT"           "LazyVim terminal in a split"
    engine_show_key "Ctrl-b" "z"            "Zoom current tmux pane (toggle)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Learn More About tmux"
    # -----------------------------------------------------------------------

    engine_teach "This lesson covered how tmux and Neovim complement each other. If you
want to go deeper into tmux itself — sessions, scripted layouts, plugins,
pair programming — check out the companion tutorial:

  https://github.com/mikecubed/tmux-learn

tmux-learn has 21 interactive lessons with the same exercise-based format
as this tutorial."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "The tmux + Neovim workflow:

  Neovim splits  — for code: comparing files, viewing definitions, editing
  tmux panes     — for infrastructure: servers, logs, persistent shells
  <leader>ft     — for quick terminal commands inside Neovim
  Ctrl-b z       — zoom a tmux pane when you need more space
  Ctrl-b w       — switch between tmux windows (editor, server, misc)

Together, tmux and Neovim give you a complete terminal-based IDE that
persists across SSH sessions and never needs a mouse.

Next up: the capstone — putting everything together in one fluid workflow."

    engine_pause
}
