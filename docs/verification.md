# Verification API

## Overview

Verification functions check whether the user has completed an exercise by querying Neovim state via its RPC interface. Every verification function follows the same contract:

1. Set `VERIFY_MESSAGE` to a human-readable result string
2. Optionally set `VERIFY_HINT` to a help string shown after repeated failures
3. Return 0 (pass) or 1 (fail)

The engine calls these functions when the user types `check` in the exercise prompt.

## Transport Layer

All verification goes through `lib/nvim_helpers.sh`, which communicates with the sandboxed Neovim instance over a Unix domain socket:

```bash
NVIM_SOCKET="/tmp/lazynvim-learn-$$.sock"

# Low-level: evaluate a vimscript expression
nvim_eval() {
    nvim --server "$NVIM_SOCKET" --remote-expr "$1" 2>/dev/null
}

# Low-level: evaluate a Lua expression (via luaeval)
nvim_lua() {
    nvim_eval "luaeval('$1')"
}

# Low-level: execute a vim command
nvim_exec() {
    nvim --server "$NVIM_SOCKET" --remote-send "<Cmd>$1<CR>" 2>/dev/null
}

# Low-level: send raw keystrokes
nvim_send_keys() {
    nvim --server "$NVIM_SOCKET" --remote-send "$1" 2>/dev/null
}
```

## Standard Verification Functions

### Buffer State

```bash
# Check if a specific file is open in the current buffer
verify_file_open() {
    local expected="$1"  # filename (tail only) or full path
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

# Check if a file is open in any buffer
verify_file_in_buffers() {
    local expected="$1"
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_bufs()):any(function(b) return vim.api.nvim_buf_get_name(b):match('$expected$') ~= nil end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="File '$expected' found in buffer list"
        return 0
    else
        VERIFY_MESSAGE="File '$expected' not found in any buffer"
        return 1
    fi
}

# Check current buffer content contains a pattern
verify_buffer_contains() {
    local pattern="$1"
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')")

    if echo "$content" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Buffer contains expected content"
        return 0
    else
        VERIFY_MESSAGE="Expected content not found in buffer"
        return 1
    fi
}

# Check that buffer does NOT contain a pattern
verify_buffer_not_contains() {
    local pattern="$1"
    verify_reset
    local content
    content=$(nvim_lua "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')")

    if echo "$content" | grep -q "$pattern"; then
        VERIFY_MESSAGE="Buffer still contains '$pattern'"
        return 1
    else
        VERIFY_MESSAGE="Content successfully removed from buffer"
        return 0
    fi
}

# Check a specific line's content
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

# Check line count in current buffer
verify_line_count() {
    local expected="$1" comparison="${2:-eq}"  # eq, ge, le
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

# Check if buffer has been modified
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
```

### Cursor and Mode

```bash
# Check current mode
verify_mode() {
    local expected="$1"  # n, i, v, V, \x16 (ctrl-v), c, t, etc.
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

# Check cursor is on a specific line
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

# Check cursor is on a specific column
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

# Check cursor is on a line containing a pattern
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
```

### Windows and Splits

```bash
# Check window count
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

# Check if a split exists with a specific buffer
verify_split_has_file() {
    local filename="$1"
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w) return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match('$filename$') ~= nil end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Found a window with '$filename'"
        return 0
    else
        VERIFY_MESSAGE="No window contains '$filename'"
        return 1
    fi
}
```

### Registers

```bash
# Check register content
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

# Check that unnamed register has content (something was yanked/deleted)
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
```

### LSP

```bash
# Check if an LSP client is attached to current buffer
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

# Check if cursor moved to a definition (different line from start)
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
```

### LazyVim / Plugin State

```bash
# Check if a plugin is installed
verify_plugin_installed() {
    local name="$1"
    verify_reset
    local result
    result=$(nvim_lua "require('lazy.core.config').plugins['$name'] ~= nil")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Plugin '$name' is installed"
        return 0
    else
        VERIFY_MESSAGE="Plugin '$name' is not installed"
        return 1
    fi
}

# Check if a plugin is loaded (not just installed)
verify_plugin_loaded() {
    local name="$1"
    verify_reset
    local result
    result=$(nvim_lua "require('lazy.core.config').plugins['$name'] ~= nil and require('lazy.core.config').plugins['$name']._.loaded ~= nil")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Plugin '$name' is loaded"
        return 0
    else
        VERIFY_MESSAGE="Plugin '$name' is not loaded"
        return 1
    fi
}

# Check if a keymap exists
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

# Check if a specific UI element is visible (Neo-tree, Telescope, etc.)
verify_filetype_visible() {
    local expected_ft="$1"
    verify_reset
    local result
    result=$(nvim_lua "vim.iter(vim.api.nvim_list_wins()):any(function(w) return vim.api.nvim_get_option_value('filetype', {buf=vim.api.nvim_win_get_buf(w)}) == '$expected_ft' end)")

    if [[ "$result" == "true" ]]; then
        VERIFY_MESSAGE="Found window with filetype '$expected_ft'"
        return 0
    else
        VERIFY_MESSAGE="No window with filetype '$expected_ft' found"
        return 1
    fi
}
```

### File System

```bash
# Check if a file exists on disk (for Neo-tree create exercises)
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

# Check if a file does NOT exist (for delete exercises)
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
```

### Git State (for workflow exercises)

```bash
# Check if the working directory has a new commit
verify_git_commit_exists() {
    local pattern="$1"  # grep pattern for commit message
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
```

### Compound Verifiers

For exercises that require multiple conditions:

```bash
# Check multiple conditions (AND logic)
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
```

## Companion Plugin Verifiers

For complex verifications that are awkward via `--remote-expr`, the companion plugin exposes Lua functions callable from bash:

```bash
# Call a companion plugin verification function
verify_via_companion() {
    local func_name="$1"
    shift
    local args="$*"
    verify_reset

    local result
    result=$(nvim_lua "require('lazynvim-learn.verify').$func_name($args)")

    # Companion returns "pass:message" or "fail:message:hint"
    local status="${result%%:*}"
    local rest="${result#*:}"
    VERIFY_MESSAGE="${rest%%:*}"
    VERIFY_HINT="${rest#*:}"
    [[ "$VERIFY_HINT" == "$VERIFY_MESSAGE" ]] && VERIFY_HINT=""

    [[ "$status" == "pass" ]]
}
```

## Timing Considerations

Some verifications need a brief delay because Neovim operations are async:
- LSP attachment can take 1-3 seconds after opening a file
- Plugin lazy-loading triggers on events that may not have fired yet
- Telescope/Neo-tree windows take a frame to appear

The exercise loop naturally handles this: if the user checks too early, they just get a failure message and try again. No artificial delays in verification functions.

## Writing Custom Verifiers in Lessons

Lesson files can define custom verification functions that compose the standard ones:

```bash
verify_my_exercise() {
    verify_reset

    # Custom logic using nvim_helpers
    local bufname=$(nvim_eval "expand('%:t')")
    local line_count=$(nvim_lua "vim.api.nvim_buf_line_count(0)")

    if [[ "$bufname" == "sample.py" ]] && [[ "$line_count" -lt 20 ]]; then
        VERIFY_MESSAGE="Opened sample.py and removed extra lines"
        return 0
    elif [[ "$bufname" != "sample.py" ]]; then
        VERIFY_MESSAGE="Wrong file open (expected sample.py)"
        VERIFY_HINT="Use <leader>ff to find and open sample.py"
        return 1
    else
        VERIFY_MESSAGE="File has $line_count lines, expected fewer than 20"
        VERIFY_HINT="Delete the extra lines using dd"
        return 1
    fi
}
```
