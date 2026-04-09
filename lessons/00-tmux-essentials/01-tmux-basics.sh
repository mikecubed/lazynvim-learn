#!/usr/bin/env bash
# lessons/00-tmux-essentials/01-tmux-basics.sh
# Module 0, Lesson 1: tmux Basics for This Tutorial
#
# This is an OPTIONAL lesson that does not block Module 1.
# It provides just enough tmux knowledge to use lazynvim-learn comfortably.

lesson_info() {
    LESSON_TITLE="tmux Basics for This Tutorial"
    LESSON_MODULE="00-tmux-essentials"
    LESSON_DESCRIPTION="A quick orientation to tmux — just enough to use this tutorial comfortably."
    LESSON_TIME="5 minutes"
}

# No exercises — this is an informational lesson only.

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "Why tmux?"
    # -----------------------------------------------------------------------

    engine_teach "This tutorial runs inside tmux — a terminal multiplexer that lets you
split your terminal into multiple panes and windows. You are using tmux
right now.

During exercises, the tutorial splits your tmux window into two panes:

  LEFT pane   — the lesson engine (where you are reading this)
  RIGHT pane  — a sandboxed Neovim instance (where you practice)

You will click between these panes to do exercises, then click back here
to type 'check'. That is the core workflow for every lesson."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Prefix Key"
    # -----------------------------------------------------------------------

    engine_teach "tmux uses a prefix key to distinguish its commands from normal typing.
The default prefix is Ctrl-b. You press Ctrl-b first, release it, then
press the next key.

You do NOT need to memorize tmux commands for this tutorial. But knowing
the prefix exists helps if you accidentally trigger something."

    engine_show_key "Ctrl-b" "?"       "Show all tmux keybindings (press q to exit)"
    engine_show_key "Ctrl-b" "d"       "Detach from tmux (you can reattach later)"

    engine_teach "If you ever detach accidentally, reattach with:
  tmux attach"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Panes: Splitting and Switching"
    # -----------------------------------------------------------------------

    engine_teach "The tutorial automatically creates pane splits for exercises. But if
you need to manage panes yourself, here are the essentials:"

    engine_show_key "Ctrl-b" "%"       "Split the window vertically (side by side)"
    engine_show_key "Ctrl-b" "\""      "Split the window horizontally (top/bottom)"
    engine_show_key "Ctrl-b" "arrow"   "Move focus to an adjacent pane"
    engine_show_key "" "click"         "Click a pane to focus it (if mouse mode is on)"

    engine_teach "In this tutorial, clicking is the easiest way to switch between the
lesson pane and the Neovim pane. tmux mouse mode is usually enabled by
default in modern configurations."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Scrolling in tmux"
    # -----------------------------------------------------------------------

    engine_teach "If you need to scroll back through lesson output, tmux has a copy mode:

  Ctrl-b [     — enter copy/scroll mode
  q            — exit copy mode
  Up/Down      — scroll line by line
  Page Up/Down — scroll by page

You can also scroll with the mouse wheel if mouse mode is enabled.

Note: this scrolls the tmux pane history, not Neovim. Inside Neovim,
scrolling works differently (Ctrl-u / Ctrl-d or the mouse wheel)."

    engine_show_key "Ctrl-b" "["       "Enter copy/scroll mode"
    engine_show_key "" "q"             "Exit copy/scroll mode"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Windows and Sessions"
    # -----------------------------------------------------------------------

    engine_teach "tmux organizes your work into sessions, windows, and panes:

  Session  — a collection of windows (like a workspace)
  Window   — a full-screen tab within a session
  Pane     — a split within a window

This tutorial runs in your current session and window. It creates pane
splits for Neovim exercises and cleans them up when each lesson ends.

You do not need to create sessions or windows for this tutorial."

    engine_show_key "Ctrl-b" "c"       "Create a new window"
    engine_show_key "Ctrl-b" "n"       "Next window"
    engine_show_key "Ctrl-b" "p"       "Previous window"
    engine_show_key "Ctrl-b" "w"       "List all windows (interactive picker)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Learn More"
    # -----------------------------------------------------------------------

    engine_teach "This was just enough tmux to use this tutorial. If you want to go
deeper, check out tmux-learn — a companion tutorial that teaches tmux
the same way this tutorial teaches Neovim:

  https://github.com/mikecubed/tmux-learn

tmux-learn has 21 interactive lessons covering sessions, windows, panes,
customization, scripting, and advanced workflows.

You do NOT need to complete tmux-learn before continuing here. The
Neovim lessons start in Module 1 and only require basic pane switching
(clicking between panes), which you already know how to do."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "The essentials for this tutorial:

  Click            — switch between the lesson pane and Neovim pane
  Ctrl-b [         — scroll back through lesson output (q to exit)
  Ctrl-b d         — detach from tmux (tmux attach to come back)
  Ctrl-b ?         — show all tmux keybindings

That is all you need. Head to Module 1 to start learning Neovim!"

    engine_pause
}
