#!/usr/bin/env bash
# test/test_sandbox.sh — Tests for lib/sandbox.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only source the runner when this file is executed directly (not sourced by it)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$SCRIPT_DIR/test_runner.sh"
fi

source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
source "$SCRIPT_DIR/../lib/sandbox.sh"

# ---------------------------------------------------------------------------
# Unit tests — always run, no tmux or Neovim instance required
# ---------------------------------------------------------------------------

test_nvim_appname_is_correct() {
    assert_equals "lazynvim-learn" "$NVIM_APPNAME" \
        "NVIM_APPNAME should be 'lazynvim-learn'"
}

test_nvim_socket_contains_pid() {
    assert_contains "$NVIM_SOCKET" "$$" \
        "NVIM_SOCKET should contain the current PID"
}

test_nvim_socket_is_in_tmp() {
    assert_contains "$NVIM_SOCKET" "/tmp/" \
        "NVIM_SOCKET should live under /tmp"
}

test_nvim_socket_format_matches_pattern() {
    assert_matches "$NVIM_SOCKET" "^/tmp/lazynvim-learn-[0-9]+\.sock$" \
        "NVIM_SOCKET should match /tmp/lazynvim-learn-<pid>.sock"
}

test_sandbox_pane_default_is_empty() {
    assert_equals "" "$SANDBOX_PANE" \
        "SANDBOX_PANE should default to empty string"
}

test_sandbox_dir_default_is_empty() {
    assert_equals "" "$SANDBOX_DIR" \
        "SANDBOX_DIR should default to empty string"
}

test_sandbox_launch_function_exists() {
    assert_equals "function" "$(type -t sandbox_launch)" \
        "sandbox_launch should be a function"
}

test_sandbox_kill_function_exists() {
    assert_equals "function" "$(type -t sandbox_kill)" \
        "sandbox_kill should be a function"
}

test_sandbox_reset_function_exists() {
    assert_equals "function" "$(type -t sandbox_reset)" \
        "sandbox_reset should be a function"
}

test_sandbox_open_file_function_exists() {
    assert_equals "function" "$(type -t sandbox_open_file)" \
        "sandbox_open_file should be a function"
}

test_sandbox_setup_exercise_function_exists() {
    assert_equals "function" "$(type -t sandbox_setup_exercise)" \
        "sandbox_setup_exercise should be a function"
}

test_sandbox_is_alive_function_exists() {
    assert_equals "function" "$(type -t sandbox_is_alive)" \
        "sandbox_is_alive should be a function"
}

test_sandbox_is_alive_returns_false_when_pane_empty() {
    local saved_pane="$SANDBOX_PANE"
    SANDBOX_PANE=""
    sandbox_is_alive
    local rc=$?
    SANDBOX_PANE="$saved_pane"
    assert_exit_code 1 $rc \
        "sandbox_is_alive should return 1 when SANDBOX_PANE is empty"
}

test_sandbox_is_alive_returns_false_when_pane_nonexistent() {
    local saved_pane="$SANDBOX_PANE"
    # Use a pane ID that cannot possibly exist.
    SANDBOX_PANE="%99999"
    sandbox_is_alive
    local rc=$?
    SANDBOX_PANE="$saved_pane"
    assert_exit_code 1 $rc \
        "sandbox_is_alive should return 1 when pane does not exist in tmux"
}

test_sandbox_kill_is_safe_when_no_pane() {
    local saved_pane="$SANDBOX_PANE"
    local saved_socket="$NVIM_SOCKET"
    SANDBOX_PANE=""
    NVIM_SOCKET="/tmp/no-such-socket-unit-$$.sock"
    sandbox_kill
    local rc=$?
    SANDBOX_PANE="$saved_pane"
    NVIM_SOCKET="$saved_socket"
    assert_exit_code 0 $rc \
        "sandbox_kill should succeed silently when no pane is set"
}

test_sandbox_kill_clears_pane_var() {
    # Give SANDBOX_PANE a dummy value that does NOT exist in tmux so
    # tmux kill-pane fails silently, then verify SANDBOX_PANE is cleared.
    local saved_pane="$SANDBOX_PANE"
    local saved_socket="$NVIM_SOCKET"
    SANDBOX_PANE="%99998"
    NVIM_SOCKET="/tmp/no-such-socket-unit-$$.sock"
    sandbox_kill
    local pane_after="$SANDBOX_PANE"
    SANDBOX_PANE="$saved_pane"
    NVIM_SOCKET="$saved_socket"
    assert_equals "" "$pane_after" \
        "sandbox_kill should reset SANDBOX_PANE to empty string"
}

test_sandbox_kill_removes_socket_file() {
    local tmp_sock
    tmp_sock=$(mktemp /tmp/lazynvim-learn-test-XXXXXX.sock)
    local saved_socket="$NVIM_SOCKET"
    local saved_pane="$SANDBOX_PANE"
    NVIM_SOCKET="$tmp_sock"
    SANDBOX_PANE=""
    sandbox_kill
    local exists=0
    [[ -S "$tmp_sock" ]] && exists=1
    NVIM_SOCKET="$saved_socket"
    SANDBOX_PANE="$saved_pane"
    assert_exit_code 0 $exists \
        "sandbox_kill should remove the socket file"
}

test_sandbox_setup_exercise_none_does_nothing() {
    local saved_pane="$SANDBOX_PANE"
    SANDBOX_PANE="sentinel_value"
    sandbox_setup_exercise "none"
    local pane_after="$SANDBOX_PANE"
    SANDBOX_PANE="$saved_pane"
    assert_equals "sentinel_value" "$pane_after" \
        "sandbox_setup_exercise none should leave SANDBOX_PANE unchanged"
}

test_sandbox_setup_exercise_current_does_nothing() {
    local saved_pane="$SANDBOX_PANE"
    SANDBOX_PANE="sentinel_current"
    sandbox_setup_exercise "current"
    local pane_after="$SANDBOX_PANE"
    SANDBOX_PANE="$saved_pane"
    assert_equals "sentinel_current" "$pane_after" \
        "sandbox_setup_exercise current should leave SANDBOX_PANE unchanged"
}

test_sandbox_setup_exercise_unknown_type_returns_error() {
    sandbox_setup_exercise "bogus_type" 2>/dev/null
    local rc=$?
    assert_exit_code 1 $rc \
        "sandbox_setup_exercise with unknown type should return 1"
}

test_lazynvim_learn_root_is_set() {
    assert_not_equals "" "$LAZYNVIM_LEARN_ROOT" \
        "LAZYNVIM_LEARN_ROOT should be set after sourcing sandbox.sh"
}

test_lazynvim_learn_root_points_to_project() {
    assert_file_exists "$LAZYNVIM_LEARN_ROOT/CLAUDE.md" \
        "LAZYNVIM_LEARN_ROOT should point to the project root"
}

# ---------------------------------------------------------------------------
# Integration tests — only run inside a real tmux session
# ---------------------------------------------------------------------------

if [[ -n "${TMUX:-}" ]]; then

    # Helper: kill any lingering test sockets/panes from a previous failed run.
    _sandbox_integration_teardown() {
        sandbox_kill 2>/dev/null || true
        [[ -n "${SANDBOX_DIR:-}" && -d "${SANDBOX_DIR:-}" ]] && rm -rf "$SANDBOX_DIR"
        SANDBOX_DIR=""
    }

    test_integration_launch_creates_pane_and_nvim_responds() {
        if ! command -v nvim &>/dev/null; then
            printf "    (skipped: nvim not available)\n"
            assert_true "skipped"
            return
        fi
        _sandbox_integration_teardown
        sandbox_launch
        local rc_launch=$?
        local alive=1
        sandbox_is_alive && alive=0
        _sandbox_integration_teardown
        assert_exit_code 0 $rc_launch \
            "sandbox_launch should return 0"
        assert_exit_code 0 $alive \
            "sandbox_is_alive should return 0 after successful launch"
    }

    test_integration_kill_stops_nvim_and_pane() {
        if ! command -v nvim &>/dev/null; then
            printf "    (skipped: nvim not available)\n"
            assert_true "skipped"
            return
        fi
        _sandbox_integration_teardown
        sandbox_launch
        sandbox_kill
        sandbox_is_alive
        local alive=$?
        _sandbox_integration_teardown
        assert_exit_code 1 $alive \
            "sandbox_is_alive should return 1 after sandbox_kill"
    }

    test_integration_is_alive_false_after_kill() {
        if ! command -v nvim &>/dev/null; then
            printf "    (skipped: nvim not available)\n"
            assert_true "skipped"
            return
        fi
        _sandbox_integration_teardown
        sandbox_launch
        sandbox_kill
        local pane_after="$SANDBOX_PANE"
        _sandbox_integration_teardown
        assert_equals "" "$pane_after" \
            "SANDBOX_PANE should be empty after sandbox_kill"
    }

    test_integration_reset_relaunches_nvim() {
        if ! command -v nvim &>/dev/null; then
            printf "    (skipped: nvim not available)\n"
            assert_true "skipped"
            return
        fi
        _sandbox_integration_teardown
        sandbox_launch
        local pane_first="$SANDBOX_PANE"
        sandbox_reset
        local pane_second="$SANDBOX_PANE"
        _sandbox_integration_teardown
        assert_not_equals "" "$pane_second" \
            "SANDBOX_PANE should not be empty after sandbox_reset"
    }

fi
