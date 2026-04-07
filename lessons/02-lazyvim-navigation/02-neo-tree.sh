#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/02-file-explorer.sh
# Module 2, Lesson 2: File Explorer (snacks.nvim)

lesson_info() {
    LESSON_TITLE="File Explorer"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Navigate your project and manage files using the built-in file explorer."
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: File explorer is visible AND sample.py has been opened
verify_explorer_and_file_open() {
    verify_reset

    local explorer_ok=0
    local file_ok=0

    # snacks.nvim explorer uses snacks_explorer filetype;
    # also check snacks_picker_list, snacks_layout_box, and neo-tree as fallbacks
    { verify_filetype_visible "snacks_explorer" \
        || verify_filetype_visible "snacks_picker_list" \
        || verify_filetype_visible "snacks_layout_box" \
        || verify_filetype_visible "neo-tree"; } && explorer_ok=1
    verify_file_open "sample.py" && file_ok=1

    if [[ $explorer_ok -eq 0 ]]; then
        VERIFY_MESSAGE="File explorer is not open. Press <leader>e to toggle it."
        VERIFY_HINT="Press Space then 'e' to open the explorer, then navigate to sample.py and press Enter."
        return 1
    fi

    if [[ $file_ok -eq 0 ]]; then
        VERIFY_MESSAGE="Explorer is open but sample.py is not the current buffer. Navigate to it and press Enter."
        VERIFY_HINT="In the explorer move to sample.py with j/k and press Enter to open it."
        return 1
    fi

    VERIFY_MESSAGE="Explorer is open and sample.py is the active buffer."
    return 0
}

# Exercise 2: A new file called notes.txt was created inside the sandbox dir
verify_notes_created() {
    verify_reset
    local target="$SANDBOX_DIR/notes.txt"
    verify_file_exists_on_disk "$target"
}

# Exercise 3: rename complete (old gone, new present)
verify_rename_complete() {
    verify_reset

    local old_gone=0
    local new_exists=0

    [[ ! -f "$SANDBOX_DIR/notes.txt" ]]         && old_gone=1
    [[ -f "$SANDBOX_DIR/notes-renamed.txt" ]]   && new_exists=1

    if [[ $old_gone -eq 0 ]]; then
        VERIFY_MESSAGE="notes.txt still exists. Select it in the explorer and rename it."
        VERIFY_HINT="Move to notes.txt, press 'r', type 'notes-renamed.txt', press Enter."
        return 1
    fi

    if [[ $new_exists -eq 0 ]]; then
        VERIFY_MESSAGE="notes-renamed.txt not found. Check the filename you typed — it must be exactly 'notes-renamed.txt'."
        VERIFY_HINT="Select notes.txt, press 'r', clear the name, type 'notes-renamed.txt', press Enter."
        return 1
    fi

    VERIFY_MESSAGE="File renamed successfully from notes.txt to notes-renamed.txt."
    return 0
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "The File Explorer"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim includes a built-in file explorer that shows your project
directory as a tree on the left side of the screen. You can navigate files
with j/k (or arrow keys) and manage files without ever opening a terminal."

    engine_teach "The explorer is non-intrusive: it lives in a sidebar window, never
steals your cursor unless you move to it, and disappears when you close it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Opening the Explorer"
    # -----------------------------------------------------------------------

    engine_teach "The most important keybinding:"

    engine_show_key "Space" "e" "Toggle file explorer (focus or open)"
    engine_show_key "Space" "E" "Toggle explorer — open at current file's location"

    engine_teach "Pressing <leader>e a second time closes the sidebar. If the explorer
is already open but your cursor is in the editor, <leader>e shifts focus to
it. Press <leader>e once more (or 'q' inside the explorer) to close it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigating the Explorer"
    # -----------------------------------------------------------------------

    engine_teach "Once focus is inside the explorer sidebar:"

    engine_show_key "" "j / k"      "Move down / up through the tree"
    engine_show_key "" "h / l"      "Collapse / expand a directory node"
    engine_show_key "" "Enter"      "Open file in the main window"
    engine_show_key "" "Ctrl-w w"   "Move focus back to the editor window"
    engine_show_key "" "q"          "Close the explorer"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "File Management"
    # -----------------------------------------------------------------------

    engine_teach "The explorer doubles as a file manager. With the cursor on any node:"

    engine_show_key "" "a"   "Add (create) a new file or directory"
    engine_show_key "" "d"   "Delete the file (prompts for confirmation)"
    engine_show_key "" "r"   "Rename the file"
    engine_show_key "" "c"   "Copy the file"
    engine_show_key "" "m"   "Move the file"
    engine_show_key "" "y"   "Copy the filename to clipboard"

    engine_teach "When adding a file ('a'), type the path relative to the directory
under the cursor. Typing 'src/utils/helpers.lua' will create all intermediate
directories automatically."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Open the Explorer and Navigate"
    # -----------------------------------------------------------------------

    engine_teach "The sandbox contains several files. Open the explorer with <leader>e,
navigate to sample.py using j/k, and press Enter to open it.

The check passes when the explorer is visible AND sample.py is the current buffer."

    engine_exercise "explorer-navigate" \
        "Open the Explorer and open sample.py" \
        "Press <leader>e (Space then e) to open the file explorer. Use j/k to move to sample.py and press Enter to open it. Press 'check' when done." \
        verify_explorer_and_file_open \
        "Press Space then e to open the explorer. Navigate with j/k, open a file with Enter." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Create a New File"
    # -----------------------------------------------------------------------

    engine_teach "Now create a brand-new file called notes.txt inside the exercise directory.

1. Make sure the explorer is open (<leader>e).
2. Navigate to the root of the project directory in the tree.
3. Press 'a' to add a new file.
4. Type 'notes.txt' and press Enter.

The file will appear in the tree and be created on disk immediately."

    engine_exercise "explorer-create" \
        "Create notes.txt" \
        "Open the explorer with <leader>e, navigate to the project root, press 'a', type 'notes.txt', and press Enter. Press 'check' when done." \
        verify_notes_created \
        "In the explorer press 'a' on the project root, type 'notes.txt', press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 3: Rename a File"
    # -----------------------------------------------------------------------

    engine_teach "Rename the notes.txt file you just created to notes-renamed.txt.

1. In the explorer navigate to notes.txt.
2. Press 'r' to start a rename.
3. Clear the current name, type 'notes-renamed.txt', and press Enter.

The old name should disappear and the new name should appear in the tree."

    engine_exercise "explorer-rename" \
        "Rename notes.txt to notes-renamed.txt" \
        "In the explorer navigate to notes.txt, press 'r', clear the name, type 'notes-renamed.txt', and press Enter. Press 'check' when done." \
        verify_rename_complete \
        "Navigate to notes.txt, press 'r', clear the field, type 'notes-renamed.txt', press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You can now use the file explorer to navigate and manage your project:

  <leader>e        — toggle the sidebar
  j/k              — move through the tree
  Enter            — open a file
  a / d / r        — add, delete, rename files
  c / m            — copy, move files

The explorer keeps your hands in Neovim — no terminal or file manager needed.

Next up: the fuzzy finder for instant searching across files, buffers, and text."

    engine_pause
}
