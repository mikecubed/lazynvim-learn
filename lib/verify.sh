#!/usr/bin/env bash
# lib/verify.sh — Exercise verification functions for lazynvim-learn
# All functions query Neovim state via lib/nvim_helpers.sh (NVIM_SOCKET must be set).
#
# Contract every verify_* function follows:
#   1. Set VERIFY_MESSAGE to a human-readable result string
#   2. Optionally set VERIFY_HINT to a help string shown after repeated failures
#   3. Return 0 (pass) or 1 (fail)

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------

VERIFY_MESSAGE=""
VERIFY_HINT=""
EXERCISE_DIR=""   # set by engine before each exercise

# ---------------------------------------------------------------------------
# Reset helper — call at the top of every verify_* function
# ---------------------------------------------------------------------------

verify_reset() {
    VERIFY_MESSAGE=""
    VERIFY_HINT=""
}

# ---------------------------------------------------------------------------
# Buffer state
# ---------------------------------------------------------------------------

# verify_file_open "filename"
# Check if a specific file is open in the current buffer (tail match).
verify_file_open() {
    local expected="$1"
    verify_reset
    local actual
    actual=$(nvim_eval "expand('%:t')")

    if [[ "$actual" == "$expected" ]]; then
        VERIFY_MESSAGE="File '$expected' is open"
        return 0
    else
        VERIFY_MESSAGE="Current file is '$actual', expected '$expected'"
        VERIFY_HINT="Open the file with :e $expected or use <leader>ff"
        return 1
    fi
}

# verify_file_in_buffers "filename"
# Check if a file is open in any buffer (suffix match).
verify_file_in_buffers() {
    local expected="$1"
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_bufs()):any(function(b) return vim.api.nvim_buf_get_name(b):match(\"$expected\") ~= nil end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="File '$expected' found in buffer list"
        return 0
    else
        VERIFY_MESSAGE="File '$expected' not found in any buffer"
        return 1
    fi
}

# verify_buffer_contains "pattern"
# Check that the current buffer content contains a grep pattern.
# Uses "|" as a line separator to avoid single-quote conflicts in nvim_lua().
verify_buffer_contains() {
    local pattern="$1"
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\") ")

    if echo "$content" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Buffer contains expected content"
        return 0
    else
        VERIFY_MESSAGE="Expected content not found in buffer"
        return 1
    fi
}

# verify_buffer_not_contains "pattern"
# Check that the current buffer does NOT contain a pattern.
# Uses "|" as a line separator to avoid single-quote conflicts in nvim_lua().
verify_buffer_not_contains() {
    local pattern="$1"
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), \"|\") ")

    if echo "$content" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Buffer still contains '$pattern'"
        return 1
    else
        VERIFY_MESSAGE="Content successfully removed from buffer"
        return 0
    fi
}

# verify_line_content line_num "expected"
# Check that a specific line's content matches exactly.
verify_line_content() {
    local line_num="$1" expected="$2"
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_buf_get_lines(0, $((line_num - 1)), $line_num, false)[1]")

    if [[ "$actual" == "$expected" ]]; then
        VERIFY_MESSAGE="Line $line_num matches"
        return 0
    else
        VERIFY_MESSAGE="Line $line_num is '$actual', expected '$expected'"
        return 1
    fi
}

# verify_line_count expected [comparison]
# Check the number of lines in the current buffer.
# comparison: eq (default), ge, le
verify_line_count() {
    local expected="$1" comparison="${2:-eq}"
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_buf_line_count(0)")

    case "$comparison" in
        eq) [[ "$actual" -eq "$expected" ]] ;;
        ge) [[ "$actual" -ge "$expected" ]] ;;
        le) [[ "$actual" -le "$expected" ]] ;;
    esac

    if [[ $? -eq 0 ]]; then
        VERIFY_MESSAGE="Buffer has $actual lines"
        return 0
    else
        VERIFY_MESSAGE="Buffer has $actual lines, expected $comparison $expected"
        return 1
    fi
}

# verify_buffer_modified
# Check if the current buffer has been modified (unsaved changes).
verify_buffer_modified() {
    verify_reset
    local modified
    modified=$(nvim_eval "&modified")

    if [[ "$modified" == "1" ]]; then
        VERIFY_MESSAGE="Buffer has been modified"
        return 0
    else
        VERIFY_MESSAGE="Buffer has not been modified"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Cursor and mode
# ---------------------------------------------------------------------------

# verify_mode "expected_mode"
# Check that Neovim is in the expected mode (n, i, v, V, c, t, etc.).
verify_mode() {
    local expected="$1"
    verify_reset
    local actual
    actual=$(nvim_eval "mode()")

    if [[ "$actual" == "$expected" ]]; then
        VERIFY_MESSAGE="In expected mode: $expected"
        return 0
    else
        VERIFY_MESSAGE="Current mode is '$actual', expected '$expected'"
        return 1
    fi
}

# verify_cursor_line expected_line
# Check that the cursor is on the expected 1-based line number.
verify_cursor_line() {
    local expected="$1"
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")

    if [[ "$actual" == "$expected" ]]; then
        VERIFY_MESSAGE="Cursor is on line $expected"
        return 0
    else
        VERIFY_MESSAGE="Cursor is on line $actual, expected $expected"
        return 1
    fi
}

# verify_cursor_col expected_col
# Check that the cursor is at the expected 0-based column.
verify_cursor_col() {
    local expected="$1"
    verify_reset
    local actual
    actual=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[2]")

    if [[ "$actual" == "$expected" ]]; then
        VERIFY_MESSAGE="Cursor is at column $expected"
        return 0
    else
        VERIFY_MESSAGE="Cursor is at column $actual, expected $expected"
        return 1
    fi
}

# verify_cursor_on_pattern "pattern"
# Check that the cursor's current line contains a grep pattern.
verify_cursor_on_pattern() {
    local pattern="$1"
    verify_reset
    local line
    line=$(nvim_eval "getline('.')")

    if echo "$line" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Cursor is on a line matching '$pattern'"
        return 0
    else
        VERIFY_MESSAGE="Current line doesn't match '$pattern'"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Windows and splits
# ---------------------------------------------------------------------------

# verify_window_count expected [comparison]
# Check the number of windows in the current tabpage.
# comparison: ge (default), eq
verify_window_count() {
    local expected="$1" comparison="${2:-ge}"
    verify_reset
    local actual
    actual=$(nvim_lua "#vim.api.nvim_tabpage_list_wins(0)")

    case "$comparison" in
        eq) [[ "$actual" -eq "$expected" ]] ;;
        ge) [[ "$actual" -ge "$expected" ]] ;;
    esac

    if [[ $? -eq 0 ]]; then
        VERIFY_MESSAGE="Found $actual window(s)"
        return 0
    else
        VERIFY_MESSAGE="Found $actual window(s), expected $comparison $expected"
        VERIFY_HINT="Create splits with :split or :vsplit"
        return 1
    fi
}

# verify_split_has_file "filename"
# Check that at least one window in the current tabpage displays the file.
verify_split_has_file() {
    local filename="$1"
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w) return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match(\"$filename\") ~= nil end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Found a window with '$filename'"
        return 0
    else
        VERIFY_MESSAGE="No window contains '$filename'"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Registers
# ---------------------------------------------------------------------------

# verify_register_contains "reg" "pattern"
# Check that a named register's content matches a grep pattern.
verify_register_contains() {
    local reg="$1" pattern="$2"
    verify_reset
    local content
    content=$(nvim_eval "getreg('$reg')")

    if echo "$content" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Register '$reg' contains expected content"
        return 0
    else
        VERIFY_MESSAGE="Register '$reg' doesn't contain expected content"
        VERIFY_HINT="Yank into register $reg with \"${reg}y{motion}"
        return 1
    fi
}

# verify_register_not_empty ["reg"]
# Check that a register has content.  Defaults to the unnamed register (").
verify_register_not_empty() {
    local reg="${1:-\"}"
    verify_reset
    local content
    content=$(nvim_eval "getreg('$reg')")

    if [[ -n "$content" ]]; then
        VERIFY_MESSAGE="Register '$reg' has content"
        return 0
    else
        VERIFY_MESSAGE="Register '$reg' is empty"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# LSP
# ---------------------------------------------------------------------------

# verify_lsp_attached
# Check that at least one LSP client is attached to the current buffer.
verify_lsp_attached() {
    verify_reset
    local count
    count=$(nvim_lua "#vim.lsp.get_clients({bufnr=0})")

    if [[ "$count" -gt 0 ]]; then
        VERIFY_MESSAGE="LSP client attached ($count active)"
        return 0
    else
        VERIFY_MESSAGE="No LSP client attached to current buffer"
        VERIFY_HINT="LSP may still be starting. Wait a moment and try again."
        return 1
    fi
}

# verify_jumped_to_line original_line
# Check that the cursor has moved away from original_line (e.g. after gd).
verify_jumped_to_line() {
    local original_line="$1"
    verify_reset
    local current
    current=$(nvim_lua "vim.api.nvim_win_get_cursor(0)[1]")

    if [[ "$current" -ne "$original_line" ]]; then
        VERIFY_MESSAGE="Jumped from line $original_line to line $current"
        return 0
    else
        VERIFY_MESSAGE="Still on line $original_line"
        VERIFY_HINT="Use gd to jump to definition"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# LazyVim / plugin state
# ---------------------------------------------------------------------------

# verify_plugin_installed "name"
# Check that a plugin is present in lazy.nvim's config.
verify_plugin_installed() {
    local name="$1"
    verify_reset
    local result
    result=$(nvim_lua "require(\"lazy.core.config\").plugins[\"$name\"] ~= nil")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Plugin '$name' is installed"
        return 0
    else
        VERIFY_MESSAGE="Plugin '$name' is not installed"
        return 1
    fi
}

# verify_plugin_loaded "name"
# Check that a plugin is not only installed but has been loaded.
verify_plugin_loaded() {
    local name="$1"
    verify_reset
    local result
    result=$(nvim_lua "require(\"lazy.core.config\").plugins[\"$name\"] ~= nil and require(\"lazy.core.config\").plugins[\"$name\"]._.loaded ~= nil")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Plugin '$name' is loaded"
        return 0
    else
        VERIFY_MESSAGE="Plugin '$name' is not loaded"
        return 1
    fi
}

# verify_keymap_exists "lhs" ["mode"]
# Check that a keymap exists in the given mode (default: n).
verify_keymap_exists() {
    local lhs="$1" mode="${2:-n}"
    verify_reset
    local result
    result=$(nvim_eval "maparg('$lhs', '$mode')")

    if [[ -n "$result" ]]; then
        VERIFY_MESSAGE="Keymap '$lhs' exists in mode '$mode'"
        return 0
    else
        VERIFY_MESSAGE="Keymap '$lhs' not found in mode '$mode'"
        return 1
    fi
}

# verify_filetype_visible "filetype"
# Check that at least one open window displays a buffer with the given filetype.
verify_filetype_visible() {
    local expected_ft="$1"
    verify_reset
    local result
    # Use double quotes in Lua strings — single quotes break luaeval('...') wrapping
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_wins()):any(function(w) return vim.api.nvim_get_option_value(\"filetype\", {buf=vim.api.nvim_win_get_buf(w)}) == \"$expected_ft\" end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Found window with filetype '$expected_ft'"
        return 0
    else
        VERIFY_MESSAGE="No window with filetype '$expected_ft' found"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# File system
# ---------------------------------------------------------------------------

# verify_file_exists_on_disk "filepath"
# Check that a file exists on the real filesystem (for Neo-tree create exercises).
verify_file_exists_on_disk() {
    local filepath="$1"
    verify_reset

    if [[ -f "$filepath" ]]; then
        VERIFY_MESSAGE="File '$filepath' exists"
        return 0
    else
        VERIFY_MESSAGE="File '$filepath' does not exist"
        return 1
    fi
}

# verify_file_not_exists_on_disk "filepath"
# Check that a file does NOT exist (for delete exercises).
verify_file_not_exists_on_disk() {
    local filepath="$1"
    verify_reset

    if [[ ! -f "$filepath" ]]; then
        VERIFY_MESSAGE="File '$filepath' has been removed"
        return 0
    else
        VERIFY_MESSAGE="File '$filepath' still exists"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Git state
# ---------------------------------------------------------------------------

# verify_git_commit_exists "pattern"
# Check that the git log in EXERCISE_DIR contains a recent commit matching the pattern.
verify_git_commit_exists() {
    local pattern="$1"
    verify_reset
    local result
    result=$(cd "$EXERCISE_DIR" && git log --oneline -5 2>/dev/null)

    if echo "$result" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Found commit matching '$pattern'"
        return 0
    else
        VERIFY_MESSAGE="No recent commit matching '$pattern'"
        VERIFY_HINT="Stage changes and commit with lazygit (<leader>gg) or :!git commit"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Compound verifiers
# ---------------------------------------------------------------------------

# verify_all func1 func2 ...
# Run multiple verification functions; all must pass (AND logic).
# On first failure, that function's VERIFY_MESSAGE is surfaced.
verify_all() {
    verify_reset
    local all_passed=true
    local messages=()

    for func in "$@"; do
        if ! $func; then
            all_passed=false
            messages+=("$VERIFY_MESSAGE")
        fi
    done

    if $all_passed; then
        VERIFY_MESSAGE="All checks passed"
        return 0
    else
        VERIFY_MESSAGE=$(printf '%s\n' "${messages[@]}" | head -1)
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Companion plugin bridge
# ---------------------------------------------------------------------------

# verify_via_companion "func_name" [args...]
# Call a function in the companion Lua plugin (lazynvim-learn.verify).
# The plugin must return "pass:message" or "fail:message:hint".
verify_via_companion() {
    local func_name="$1"
    shift
    local args="$*"
    verify_reset

    local result
    result=$(nvim_lua "require(\"lazynvim-learn.verify\").$func_name($args)")

    # Parse "pass:message" or "fail:message:hint"
    local status="${result%%:*}"
    local rest="${result#*:}"
    VERIFY_MESSAGE="${rest%%:*}"
    VERIFY_HINT="${rest#*:}"
    [[ "$VERIFY_HINT" == "$VERIFY_MESSAGE" ]] && VERIFY_HINT=""

    [[ "$status" == "pass" ]]
}
