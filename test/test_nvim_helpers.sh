#!/usr/bin/env bash
# test/test_nvim_helpers.sh — Tests for lib/nvim_helpers.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only source the runner when this file is executed directly (not sourced by it)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$SCRIPT_DIR/test_runner.sh"
fi

source "$SCRIPT_DIR/../lib/nvim_helpers.sh"

# ---------------------------------------------------------------------------
# Unit tests — always run, no Neovim instance required
# ---------------------------------------------------------------------------

test_nvim_socket_default_is_empty() {
    assert_equals "" "$NVIM_SOCKET" "NVIM_SOCKET should default to empty string"
}

test_nvim_eval_function_exists() {
    assert_equals "function" "$(type -t nvim_eval)" "nvim_eval should be a function"
}

test_nvim_lua_function_exists() {
    assert_equals "function" "$(type -t nvim_lua)" "nvim_lua should be a function"
}

test_nvim_exec_function_exists() {
    assert_equals "function" "$(type -t nvim_exec)" "nvim_exec should be a function"
}

test_nvim_send_keys_function_exists() {
    assert_equals "function" "$(type -t nvim_send_keys)" "nvim_send_keys should be a function"
}

test_nvim_is_running_function_exists() {
    assert_equals "function" "$(type -t nvim_is_running)" "nvim_is_running should be a function"
}

test_nvim_wait_ready_function_exists() {
    assert_equals "function" "$(type -t nvim_wait_ready)" "nvim_wait_ready should be a function"
}

test_nvim_get_mode_function_exists() {
    assert_equals "function" "$(type -t nvim_get_mode)" "nvim_get_mode should be a function"
}

test_nvim_get_bufname_function_exists() {
    assert_equals "function" "$(type -t nvim_get_bufname)" "nvim_get_bufname should be a function"
}

test_nvim_get_filetype_function_exists() {
    assert_equals "function" "$(type -t nvim_get_filetype)" "nvim_get_filetype should be a function"
}

test_nvim_get_cursor_function_exists() {
    assert_equals "function" "$(type -t nvim_get_cursor)" "nvim_get_cursor should be a function"
}

test_nvim_get_line_function_exists() {
    assert_equals "function" "$(type -t nvim_get_line)" "nvim_get_line should be a function"
}

test_nvim_get_current_line_function_exists() {
    assert_equals "function" "$(type -t nvim_get_current_line)" "nvim_get_current_line should be a function"
}

test_nvim_get_register_function_exists() {
    assert_equals "function" "$(type -t nvim_get_register)" "nvim_get_register should be a function"
}

test_nvim_get_option_function_exists() {
    assert_equals "function" "$(type -t nvim_get_option)" "nvim_get_option should be a function"
}

test_nvim_get_var_function_exists() {
    assert_equals "function" "$(type -t nvim_get_var)" "nvim_get_var should be a function"
}

# With no server, functions that contact Neovim should return non-zero
test_nvim_eval_fails_without_server() {
    local saved_socket="$NVIM_SOCKET"
    NVIM_SOCKET="/tmp/no-such-socket-$$.sock"
    nvim_eval "1+1" >/dev/null 2>&1
    local rc=$?
    NVIM_SOCKET="$saved_socket"
    assert_exit_code 1 $rc "nvim_eval should return 1 when server is unavailable"
}

test_nvim_is_running_returns_false_without_server() {
    local saved_socket="$NVIM_SOCKET"
    NVIM_SOCKET="/tmp/no-such-socket-$$.sock"
    nvim_is_running
    local rc=$?
    NVIM_SOCKET="$saved_socket"
    assert_exit_code 1 $rc "nvim_is_running should return 1 when server is unavailable"
}

test_nvim_wait_ready_times_out_without_server() {
    local saved_socket="$NVIM_SOCKET"
    NVIM_SOCKET="/tmp/no-such-socket-$$.sock"
    nvim_wait_ready 0.3
    local rc=$?
    NVIM_SOCKET="$saved_socket"
    assert_exit_code 1 $rc "nvim_wait_ready should return 1 after timeout with no server"
}

# ---------------------------------------------------------------------------
# Integration tests — skipped when nvim is not available
# ---------------------------------------------------------------------------

_integration_setup() {
    if ! command -v nvim &>/dev/null; then
        return 1
    fi
    return 0
}

# Launch a headless nvim and export the PID + socket path
_start_nvim() {
    TEST_SOCKET="/tmp/lazynvim-learn-test-$$.sock"
    nvim --headless --listen "$TEST_SOCKET" &
    NVIM_TEST_PID=$!
    NVIM_SOCKET="$TEST_SOCKET"
    nvim_wait_ready 10
}

_stop_nvim() {
    if [[ -n "${NVIM_TEST_PID:-}" ]]; then
        kill "$NVIM_TEST_PID" 2>/dev/null
        wait "$NVIM_TEST_PID" 2>/dev/null
        NVIM_TEST_PID=""
    fi
    NVIM_SOCKET=""
}

test_integration_nvim_is_running_returns_true() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_is_running
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "nvim_is_running should return 0 when server responds"
}

test_integration_nvim_eval_arithmetic() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local result
    result=$(nvim_eval "1+1")
    _stop_nvim
    assert_equals "2" "$result" "nvim_eval should evaluate arithmetic"
}

test_integration_nvim_lua_basic() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local result
    result=$(nvim_lua "1 + 1")
    _stop_nvim
    assert_equals "2" "$result" "nvim_lua should evaluate Lua expressions"
}

test_integration_nvim_get_mode_is_normal() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local mode
    mode=$(nvim_get_mode)
    _stop_nvim
    assert_equals "n" "$mode" "headless nvim should start in Normal mode"
}

test_integration_nvim_get_option_returns_value() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local ts
    ts=$(nvim_get_option "tabstop")
    _stop_nvim
    assert_matches "$ts" "^[0-9]+$" "tabstop option should be a number"
}

test_integration_nvim_get_bufname_empty_for_scratch() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local name
    name=$(nvim_get_bufname)
    _stop_nvim
    # In headless mode with no file opened, bufname tail is empty
    assert_equals "" "$name" "bufname should be empty for a scratch buffer"
}

test_integration_nvim_get_cursor_format() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    local cursor
    cursor=$(nvim_get_cursor)
    _stop_nvim
    assert_matches "$cursor" "^[0-9]+,[0-9]+$" "cursor should be in 'line,col' format"
}

test_integration_nvim_get_register_default_empty() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    # Register 'z' should be empty in a fresh session
    local content
    content=$(nvim_get_register "z")
    _stop_nvim
    assert_equals "" "$content" "register z should be empty in a fresh session"
}

test_integration_nvim_exec_runs_command() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    # Set a global variable via exec, then read it back
    nvim_exec "let g:lazynvim_test_var = 42"
    local val
    val=$(nvim_get_var "g:lazynvim_test_var")
    _stop_nvim
    assert_equals "42" "$val" "nvim_exec should execute a vim command"
}

test_integration_nvim_get_line_content() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    # Put text on line 1 via a command, then read it back
    nvim_exec "call setline(1, 'hello world')"
    local line
    line=$(nvim_get_line 1)
    _stop_nvim
    assert_equals "hello world" "$line" "nvim_get_line should return line content"
}

test_integration_nvim_get_current_line_content() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'current line test')"
    local line
    line=$(nvim_get_current_line)
    _stop_nvim
    assert_equals "current line test" "$line" "nvim_get_current_line should return cursor line"
}
