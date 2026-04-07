#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/02-neo-tree.sh
# Module 2, Lesson 2: Neo-tree File Explorer

lesson_info() {
    LESSON_TITLE="Neo-tree File Explorer"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Navigate your project, manage files, and use Neo-tree to stay oriented without leaving Neovim."
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: Neo-tree is visible AND a file has been opened from it
verify_neotree_and_file_open() {
    verify_reset

    local neotree_ok=0
    local file_ok=0

    # LazyVim may use neo-tree or snacks.nvim as the file explorer
    { verify_filetype_visible "neo-tree" || verify_filetype_visible "snacks_picker_list" || verify_filetype_visible "snacks_layout_box"; } && neotree_ok=1
    verify_file_open "sample.py" && file_ok=1

    if [[ $neotree_ok -eq 0 ]]; then
        VERIFY_MESSAGE="Neo-tree is not open. Press <leader>e to toggle it."
        VERIFY_HINT="Press Space then 'e' to open Neo-tree, then navigate to sample.py and press Enter."
        return 1
    fi

    if [[ $file_ok -eq 0 ]]; then
        VERIFY_MESSAGE="Neo-tree is open but sample.py is not the current buffer. Navigate to it and press Enter."
        VERIFY_HINT="In Neo-tree move to sample.py with j/k and press Enter to open it."
        return 1
    fi

    VERIFY_MESSAGE="Neo-tree is open and sample.py is the active buffer."
    return 0
}

# Exercise 2: A new file called notes.txt was created inside the sandbox dir
verify_notes_created() {
    verify_reset
    local target="$SANDBOX_DIR/notes.txt"
    verify_file_exists_on_disk "$target"
}

# Exercise 3a: old name is gone
verify_old_name_gone() {
    verify_file_not_exists_on_disk "$SANDBOX_DIR/notes.txt"
}

# Exercise 3b: new name exists
verify_new_name_exists() {
    verify_file_exists_on_disk "$SANDBOX_DIR/notes-renamed.txt"
}

# Combined: rename complete (old gone, new present)
verify_rename_complete() {
    verify_reset

    local old_gone=0
    local new_exists=0

    [[ ! -f "$SANDBOX_DIR/notes.txt" ]]         && old_gone=1
    [[ -f "$SANDBOX_DIR/notes-renamed.txt" ]]   && new_exists=1

    if [[ $old_gone -eq 0 ]]; then
        VERIFY_MESSAGE="notes.txt still exists. Select it in Neo-tree and press 'r' to rename it."
        VERIFY_HINT="Move to notes.txt in Neo-tree, press 'r', type 'notes-renamed.txt', press Enter."
        return 1
    fi

    if [[ $new_exists -eq 0 ]]; then
        VERIFY_MESSAGE="notes-renamed.txt not found. Check the filename you typed — it must be exactly 'notes-renamed.txt'."
        VERIFY_HINT="Select notes.txt in Neo-tree, press 'r', clear the name, type 'notes-renamed.txt', press Enter."
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
    engine_section "Meet Neo-tree"
    # -----------------------------------------------------------------------

    engine_teach "Neo-tree is LazyVim's built-in file explorer. It shows your project
directory as a tree on the left side of the screen, lets you navigate files
with j/k (or arrow keys), and supports full file management operations without
ever opening a terminal."

    engine_teach "Unlike traditional file managers, Neo-tree is non-intrusive: it lives
in a sidebar window, never steals your cursor unless you move to it, and
disappears when you close it. It also integrates with Git — showing changed,
new, or ignored files with coloured icons."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Toggling Neo-tree"
    # -----------------------------------------------------------------------

    engine_teach "The most important keybinding is also the simplest:"

    engine_show_key "Space" "e" "Toggle Neo-tree sidebar (focus or open)"
    engine_show_key "Space" "E" "Toggle Neo-tree — open at current file's location"

    engine_teach "Pressing <leader>e a second time closes the sidebar. If Neo-tree is
already open but your cursor is in the editor, <leader>e shifts focus to
Neo-tree. Press <leader>e once more (or 'q' inside Neo-tree) to close it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigating Inside Neo-tree"
    # -----------------------------------------------------------------------

    engine_teach "Once focus is inside the Neo-tree sidebar:"

    engine_show_key "" "j / k"      "Move down / up through the tree"
    engine_show_key "" "h / l"      "Collapse / expand a directory node"
    engine_show_key "" "Enter"      "Open file in the main window"
    engine_show_key "" "s"          "Open file in a vertical split"
    engine_show_key "" "S"          "Open file in a horizontal split"
    engine_show_key "" "t"          "Open file in a new tab"
    engine_show_key "" "P"          "Toggle preview of the file under cursor"
    engine_show_key "" "Ctrl-w w"   "Move focus back to the editor window"
    engine_show_key "" "q"          "Close Neo-tree"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "File Management Operations"
    # -----------------------------------------------------------------------

    engine_teach "Neo-tree doubles as a file manager. With the cursor on any node:"

    engine_show_key "" "a"   "Add (create) a new file or directory"
    engine_show_key "" "d"   "Delete the file (prompts for confirmation)"
    engine_show_key "" "r"   "Rename the file"
    engine_show_key "" "c"   "Copy the file (then 'p' to paste)"
    engine_show_key "" "m"   "Move the file (cut then paste)"
    engine_show_key "" "p"   "Paste a previously copied/moved file"
    engine_show_key "" "y"   "Copy the filename to clipboard"
    engine_show_key "" "Y"   "Copy the full path to clipboard"

    engine_teach "When adding a file ('a'), you type the path relative to the directory
under the cursor. Typing 'src/utils/helpers.lua' will create all intermediate
directories automatically."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Filtering and Visibility"
    # -----------------------------------------------------------------------

    engine_teach "By default Neo-tree hides dotfiles and files matching .gitignore.
You can toggle visibility:"

    engine_show_key "" "H"   "Toggle hidden files (dotfiles)"
    engine_show_key "" "/"   "Filter (fuzzy search) tree nodes"
    engine_show_key "" "f"   "Filter — same as /"
    engine_show_key "" "Esc" "Clear filter and restore full tree"

    engine_teach "Neo-tree also has three *sources* you can switch between:
  filesystem   — normal file tree (default)
  buffers      — currently open buffers
  git_status   — files with Git changes only

Switch sources with <lt> and > (left/right angle brackets) while in Neo-tree."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Open Neo-tree and Navigate to a File"
    # -----------------------------------------------------------------------

    engine_teach "The sandbox contains several files. Open Neo-tree with <leader>e,
navigate to sample.py using j/k, and press Enter to open it.

The check passes when Neo-tree is visible AND sample.py is the current buffer."

    engine_exercise "neotree-navigate" \
        "Open Neo-tree and open sample.py" \
        "Press <leader>e (Space then e) to open Neo-tree. Use j/k to move to sample.py and press Enter to open it. Press 'check' when done." \
        verify_neotree_and_file_open \
        "Press Space then e to open Neo-tree. Navigate with j/k, open a file with Enter." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Create a New File via Neo-tree"
    # -----------------------------------------------------------------------

    engine_teach "Now create a brand-new file called notes.txt inside the exercise directory.

1. Make sure Neo-tree is open (<leader>e).
2. Navigate to the root of the project directory in the tree.
3. Press 'a' to add a new file.
4. Type 'notes.txt' and press Enter.

The file will appear in the tree and be created on disk immediately."

    engine_exercise "neotree-create" \
        "Create notes.txt via Neo-tree" \
        "Open Neo-tree with <leader>e, navigate to the project root, press 'a', type 'notes.txt', and press Enter. Press 'check' when done." \
        verify_notes_created \
        "In Neo-tree press 'a' on the project root node, type 'notes.txt', press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 3: Rename a File via Neo-tree"
    # -----------------------------------------------------------------------

    engine_teach "Rename the notes.txt file you just created to notes-renamed.txt.

1. In Neo-tree navigate to notes.txt.
2. Press 'r' to start a rename.
3. Clear the current name, type 'notes-renamed.txt', and press Enter.

The old name should disappear and the new name should appear in the tree."

    engine_exercise "neotree-rename" \
        "Rename notes.txt to notes-renamed.txt" \
        "In Neo-tree navigate to notes.txt, press 'r', clear the name, type 'notes-renamed.txt', and press Enter. Press 'check' when done." \
        verify_rename_complete \
        "Navigate to notes.txt in Neo-tree, press 'r', clear the field, type 'notes-renamed.txt', press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You can now use Neo-tree to navigate and manage your project:

  <leader>e        — toggle the sidebar
  j/k              — move through the tree
  Enter            — open a file
  a / d / r        — add, delete, rename files
  c / m / p        — copy, move, paste files
  H                — show/hide dotfiles

Neo-tree keeps your hands in Neovim — no terminal or file manager needed.

Next up: Telescope — instant fuzzy searching across files, buffers, and text."

    engine_pause
}
