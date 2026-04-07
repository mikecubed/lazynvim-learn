#!/usr/bin/env bash
# lessons/02-lazyvim-navigation/03-telescope.sh
# Module 2, Lesson 3: Fuzzy Finder (snacks.nvim picker)

lesson_info() {
    LESSON_TITLE="Fuzzy Finder"
    LESSON_MODULE="02-lazyvim-navigation"
    LESSON_DESCRIPTION="Use the fuzzy finder to instantly find files, search text, switch buffers, and explore your project."
    LESSON_TIME="14 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: the picker was used to find and open sample.lua
verify_picker_opened_file() {
    verify_file_open "sample.lua"
}

# Exercise 2: cursor is sitting on a line that contains "LazyVim"
verify_search_landed_on_lazyvim() {
    verify_cursor_on_pattern "LazyVim"
}

# Exercise 3: a file other than sample.lua is now the active buffer
# (the user switched buffers using <leader>fb)
verify_switched_buffer() {
    verify_reset
    local current
    current=$(nvim_eval "expand('%:t')")

    # We want ANY other file from the sandbox to be active.
    # The dir sandbox always starts with sample.py open; after the previous
    # exercise sample.lua is open.  A successful buffer switch lands on any
    # file that is NOT sample.lua.
    if [[ "$current" == "sample.lua" ]]; then
        VERIFY_MESSAGE="Still showing sample.lua. Open <leader>fb, select a different buffer, and press Enter."
        VERIFY_HINT="Press <leader>fb (Space f b), move to a different file with j/k, and press Enter."
        return 1
    fi

    if [[ -z "$current" ]]; then
        VERIFY_MESSAGE="No file is open. Open the buffer list with <leader>fb and select a file."
        VERIFY_HINT="Press Space then f then b to open the buffer picker."
        return 1
    fi

    VERIFY_MESSAGE="Switched to buffer: $current"
    return 0
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "What is the Fuzzy Finder?"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim ships with snacks.nvim as its default fuzzy finder. It gives
you a live, interactive picker for almost anything: files in your project, lines
matching a pattern, open buffers, Git commits, LSP symbols, keymaps, help tags,
and much more.

The workflow is always the same:
  1. Press a keybinding to open the picker.
  2. Start typing — the list filters instantly (fuzzy matching).
  3. Use j/k to move through results.
  4. Press Enter to accept; Esc or q to cancel."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "How Fuzzy Matching Works"
    # -----------------------------------------------------------------------

    engine_teach "The picker uses fuzzy matching: you do not need to type an exact
substring. Characters are matched in order, but they can be spread across the
filename or text. For example:

  Searching 'mlua'  might match  models/user.lua
  Searching 'schk'  might match  lib/sandbox_check.sh
  Searching 'initl' might match  lua/config/init.lua

The more you type, the narrower the list. You rarely need more than 3-5
characters to pinpoint the file you want."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Finding Files: <leader>ff"
    # -----------------------------------------------------------------------

    engine_teach "The command you will use dozens of times a day:"

    engine_show_key "Space" "ff"  "Find Files — fuzzy search project files"
    engine_show_key "Space" "fF"  "Find Files — search from cwd (all subdirs)"
    engine_show_key "Space" "fr"  "Recent Files — files opened in the past"
    engine_show_key "Space" "fn"  "New file picker"

    engine_teach "Inside the file picker:

  Type       — narrow the list by fuzzy matching filename
  j / k      — move down / up through results
  Enter      — open the selected file in the current window
  Ctrl-v     — open in a vertical split
  Ctrl-x     — open in a horizontal split
  Ctrl-t     — open in a new tab
  Esc or q   — close the picker without opening anything"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Searching Text: <leader>/"
    # -----------------------------------------------------------------------

    engine_teach "<leader>/ opens a live grep across your entire project. Every
keystroke re-runs the search and updates results in real time. When you press
Enter, Neovim jumps directly to that line in that file."

    engine_show_key "Space" "/"   "Live grep across all project files"
    engine_show_key "Space" "sg"  "Grep — same as <leader>/ (search grep)"
    engine_show_key "Space" "sw"  "Search word under cursor across project"
    engine_show_key "Space" "sW"  "Search WORD under cursor across project"

    engine_teach "Tip: if you want to search in a specific directory, use <leader>s/
which lets you specify a path before grepping."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Switching Buffers: <leader>fb"
    # -----------------------------------------------------------------------

    engine_teach "Once you have several files open, switching between them with :bn/:bp
gets tedious. The buffer picker is much faster:"

    engine_show_key "Space" "fb"   "Buffers — fuzzy-find among open buffers"
    engine_show_key "Space" ","    "Buffers (alternate shortcut)"

    engine_teach "Inside the buffer picker you can navigate with j/k, press Enter to
switch, or press d on a selected entry to delete that buffer without opening it."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The <leader>s Search Prefix"
    # -----------------------------------------------------------------------

    engine_teach "LazyVim maps a whole family of pickers under the <leader>s (Search)
prefix. A few you will reach for regularly:"

    engine_show_key "Space" "ss"   "LSP document symbols"
    engine_show_key "Space" "sS"   "LSP workspace symbols"
    engine_show_key "Space" "sk"   "Keymaps — search all keybindings"
    engine_show_key "Space" "sh"   "Help tags — search Neovim documentation"
    engine_show_key "Space" "sc"   "Command history"
    engine_show_key "Space" "sd"   "Diagnostics for current buffer"
    engine_show_key "Space" "sD"   "Diagnostics for whole workspace"
    engine_show_key "Space" "sr"   "Resume last picker session"

    engine_teach "<leader>sk is especially handy when you cannot remember a keybinding —
just search for a description like 'split' or 'lsp' to find what you need."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Navigating Picker Results"
    # -----------------------------------------------------------------------

    engine_teach "The picker opens with a prompt (where you type) and a results list.
Navigation uses standard Vim motions — no mode switching required:

  Type           — filter results by fuzzy match
  j / k          — move down / up through the list
  gg / G         — jump to the top / bottom of the list
  Ctrl-u / Ctrl-d — scroll the preview pane
  Tab            — toggle selection (multi-select)
  Enter          — open / accept the selected item
  Ctrl-v         — open in a vertical split
  Ctrl-x         — open in a horizontal split
  Esc or q       — close the picker

Note: if you have used Telescope before, the main difference is that j/k work
immediately — you do not need to press Esc first. Telescope is also available
as an optional LazyVim extra, but snacks.nvim picker is the default."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise 1: Find and Open a File with <leader>ff"
    # -----------------------------------------------------------------------

    engine_teach "Use the file finder to open sample.lua.

1. Press <leader>ff (Space, then f, then f).
2. Start typing 'lua' — you should see sample.lua in the list.
3. Press Enter to open it.

The check passes when sample.lua is the current buffer."

    engine_nvim_keys "ggdG"

    engine_exercise "picker-find-file" \
        "Open sample.lua with <leader>ff" \
        "Press <leader>ff (Space f f), type 'lua' to filter, navigate to sample.lua with j/k, and press Enter. Press 'check' when done." \
        verify_picker_opened_file \
        "Press Space then f then f. Type 'lua' to filter. Use j/k to select sample.lua, then press Enter." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 2: Search Text with <leader>/"
    # -----------------------------------------------------------------------

    engine_teach "The sandbox files contain the word 'LazyVim' in their content.
Use <leader>/ to find it and jump directly to a matching line.

1. Press <leader>/ (Space then /).
2. Type 'LazyVim' — matches appear across all files.
3. Use j/k to browse results, then press Enter to jump to a match.

The check passes when your cursor is on a line containing 'LazyVim'."

    engine_exercise "picker-live-grep" \
        "Search for 'LazyVim' across files with <leader>/" \
        "Press <leader>/ (Space /), type 'LazyVim', then press Enter on any matching line. Press 'check' when done." \
        verify_search_landed_on_lazyvim \
        "Press Space then /. Type 'LazyVim'. Use j/k to select a result, then press Enter to jump to it." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Exercise 3: Switch Buffer with <leader>fb"
    # -----------------------------------------------------------------------

    engine_teach "You have been opening files throughout these exercises — you now have
several buffers loaded. Use the buffer picker to switch to a different one.

1. Press <leader>fb (Space then f then b).
2. Browse the list of open buffers with j/k.
3. Select any buffer that is NOT the current one and press Enter.

The check passes when a different file is showing in the main window."

    engine_exercise "picker-switch-buffer" \
        "Switch to a different buffer with <leader>fb" \
        "Press <leader>fb (Space f b), choose a buffer other than the current file with j/k, and press Enter. Press 'check' when done." \
        verify_switched_buffer \
        "Press Space then f then b. Move to a different buffer with j/k, then press Enter." \
        "current"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You can now use the fuzzy finder to navigate with precision:

  <leader>ff  — find files by name (fuzzy)
  <leader>fr  — recent files
  <leader>/   — live grep across the project
  <leader>fb  — switch between open buffers
  <leader>sk  — search keymaps (your picker cheat sheet)
  <leader>sr  — resume the last picker session

The fuzzy matching means you almost never need the full filename — a few
distinctive characters are enough. The picker is powered by snacks.nvim, which
is LazyVim's default since Neovim 0.10+. If you prefer Telescope, you can
enable it as a LazyVim extra, and all the same keybindings apply.

Next up: Which-key and the LazyVim keymap system — learning keybindings as
you work instead of memorising them in advance."

    engine_pause
}
