#!/usr/bin/env bash
# lessons/01-neovim-essentials/04-buffers-windows.sh
# Lesson: Buffers and Windows — managing multiple files at once

lesson_info() {
    LESSON_TITLE="Buffers and Windows"
    LESSON_MODULE="01-neovim-essentials"
    LESSON_DESCRIPTION="Understand the buffer/window distinction and navigate multiple files with splits"
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: open sample.lua in a second buffer
verify_second_buffer() {
    verify_file_in_buffers "sample.lua"
}

# Exercise 2: create a vertical split (at least 2 windows)
verify_vsplit_created() {
    verify_window_count 2 "ge"
}

# Exercise 3: navigate to a split showing sample.md
verify_navigate_to_split() {
    verify_split_has_file "sample.md"
}

# ---------------------------------------------------------------------------

lesson_run() {
    # ------------------------------------------------------------------
    engine_section "Buffers vs Windows vs Tabs"
    # ------------------------------------------------------------------

    engine_teach "Three concepts — easy to confuse, important to separate:

BUFFER  — an in-memory copy of a file (or unnamed scratch space).
          Buffers persist even when you can't see them.
          Think of a buffer as a loaded document.

WINDOW  — a viewport that displays ONE buffer.
          You can have many windows showing the same buffer, or
          different windows showing different buffers.
          Think of a window as a panel on your screen.

TAB     — a layout of windows.  Tabs in Neovim are NOT like browser
          tabs (one file per tab).  Each tab is its own tiling
          arrangement.  Most users stick to one tab."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Working With Buffers"
    # ------------------------------------------------------------------

    engine_teach "Useful buffer commands (type them in Normal mode after pressing :):"
    printf '\n'

    engine_show_key ":" "e {file}"   "open (edit) a file into the current window"
    engine_show_key ":" "bn"         "go to next buffer (:bnext)"
    engine_show_key ":" "bp"         "go to previous buffer (:bprevious)"
    engine_show_key ":" "b {name}"   "jump to a buffer by name or number"
    engine_show_key ":" "bd"         "close (delete) the current buffer"
    engine_show_key ":" "ls"         "list all open buffers"
    printf '\n'

    engine_teach "LazyVim shortcut — use the buffer line at the top of the screen.
The <leader>b prefix has extra buffer commands.  For quick switching,
Shift-H and Shift-L (in LazyVim defaults) jump to the previous/next
buffer in the tab bar."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Splits: Multiple Windows at Once"
    # ------------------------------------------------------------------

    engine_teach "Splits let you view two (or more) files — or different parts of the
same file — at the same time."
    printf '\n'

    engine_show_key ":" "split   (or :sp)"   "horizontal split — same file"
    engine_show_key ":" "vsplit  (or :vs)"   "vertical split   — same file"
    engine_show_key ":" "sp {file}"           "horizontal split — open a different file"
    engine_show_key ":" "vs {file}"           "vertical split   — open a different file"
    printf '\n'

    engine_teach "Ctrl-w is the window prefix.  After pressing Ctrl-w, tap a direction:"
    printf '\n'

    engine_show_key "Ctrl-w" "h"  "move focus to the window on the LEFT"
    engine_show_key "Ctrl-w" "l"  "move focus to the window on the RIGHT"
    engine_show_key "Ctrl-w" "j"  "move focus to the window BELOW"
    engine_show_key "Ctrl-w" "k"  "move focus to the window ABOVE"
    engine_show_key "Ctrl-w" "w"  "cycle through windows"
    engine_show_key "Ctrl-w" "q"  "close the current window (not the buffer)"
    engine_show_key "Ctrl-w" "="  "equalise window sizes"
    printf '\n'

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Resizing Windows"
    # ------------------------------------------------------------------

    engine_teach "You can resize splits from Normal mode:"
    printf '\n'

    engine_show_key "Ctrl-w" ">"   "widen current window by 1 column"
    engine_show_key "Ctrl-w" "<"   "narrow current window by 1 column"
    engine_show_key "Ctrl-w" "+"   "increase window height by 1 row"
    engine_show_key "Ctrl-w" "-"   "decrease window height by 1 row"
    printf '\n'

    engine_teach "LazyVim also maps  <leader>w  to a +window prefix with additional
helpers, and you can drag split dividers with the mouse if mouse=a is set."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Exercise 1: Open a Second Buffer"
    # ------------------------------------------------------------------

    engine_teach "The sandbox has several sample files: sample.py, sample.lua, sample.md, sample.js.

Right now sample.py is open.  Open sample.lua into Neovim without
closing sample.py by running:

  :e sample.lua

After this, :ls will show two buffers.  You can switch back to
sample.py with :bp."

    engine_exercise \
        "ex-open-buffer" \
        "Open sample.lua as a second buffer" \
        "Type :e sample.lua and press Enter to open the file. Both sample.py and sample.lua should now be in the buffer list. Type 'check' when done." \
        verify_second_buffer \
        "In Normal mode type a colon, then: e sample.lua — and press Enter." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Exercise 2: Create a Vertical Split"
    # ------------------------------------------------------------------

    engine_teach "Now split the screen vertically so you can see two files side-by-side.

From Normal mode run:

  :vsplit sample.py

(or just  :vs sample.py)

You should now have two windows.  The right window shows sample.py;
the left window stays on whatever file was active."

    engine_exercise \
        "ex-vsplit" \
        "Create a vertical split" \
        "Run :vsplit sample.py (or :vs sample.py) to open a vertical split. You should see two windows side by side. Type 'check' when done." \
        verify_vsplit_created \
        "Type :vs sample.py and press Enter. Ctrl-w l and Ctrl-w h will move focus between the two windows." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Exercise 3: Navigate to a Split with a Different File"
    # ------------------------------------------------------------------

    engine_teach "Let's open a third file in a new split and then navigate to it.

1. Run  :vs sample.md  to open sample.md in another vertical split.
2. Press  Ctrl-w l  (or Ctrl-w h) to move focus between splits.
3. Make sure focus is on the window that shows sample.md.

The verifier checks that a window showing sample.md exists and that
your cursor is somewhere in the split layout."

    engine_exercise \
        "ex-navigate-splits" \
        "Open sample.md in a split and navigate to it" \
        "Run :vs sample.md to create a new split, then use Ctrl-w l or Ctrl-w h to move focus to the window showing sample.md. Type 'check' when done." \
        verify_navigate_to_split \
        "First open the split: :vs sample.md — then press Ctrl-w followed by l (right) or h (left) to move between windows. You need a window that contains sample.md." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # ------------------------------------------------------------------
    engine_section "Closing and Tidying Up"
    # ------------------------------------------------------------------

    engine_teach "A few more commands you will use daily:

  Ctrl-w q   — close the current WINDOW (buffer stays loaded)
  :bd        — close (delete) the current BUFFER (removes it from :ls)
  :qa        — quit all windows (prompts if unsaved changes)
  :wa        — write (save) all modified buffers

In LazyVim, <leader>bd closes the current buffer while keeping the
window layout intact — useful when you have splits and do not want
the layout to collapse."

    engine_pause

    # ------------------------------------------------------------------
    engine_section "Lesson Complete"
    # ------------------------------------------------------------------

    engine_teach "You now understand the buffer/window/tab model and can:
  • Open files with :e and navigate the buffer list with :bn / :bp
  • Create horizontal and vertical splits
  • Move between splits with Ctrl-w h/j/k/l
  • Close windows with Ctrl-w q and buffers with :bd

Next lesson: Search and Substitution — finding and replacing text
across a file or the whole project."

    engine_pause
}
