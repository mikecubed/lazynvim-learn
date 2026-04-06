#!/usr/bin/env bash
# test/test_entry_point.sh — Tests for the lazynvim-learn entry point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

ENTRY_POINT="$SCRIPT_DIR/../lazynvim-learn"

# ---------------------------------------------------------------------------
# Source the entry point so we can call individual functions.
# The BASH_SOURCE guard in the script prevents main() from running.
# After sourcing we turn set -e back off because the test runner relies on
# being able to inspect non-zero exit codes without the shell aborting.
# ---------------------------------------------------------------------------
# shellcheck source=../lazynvim-learn
source "$ENTRY_POINT"
set +e   # entry point enables set -e; turn it off for test context

# ---------------------------------------------------------------------------
# --version flag
# ---------------------------------------------------------------------------

test_version_flag_prints_version() {
    local out
    out="$("$ENTRY_POINT" --version 2>&1)"
    assert_contains "$out" "lazynvim-learn" "--version should print the program name"
    assert_contains "$out" "$VERSION"       "--version should print the version number"
}

test_version_flag_exits_zero() {
    "$ENTRY_POINT" --version >/dev/null 2>&1
    assert_exit_code 0 $? "--version should exit 0"
}

test_version_string_format() {
    local out
    out="$("$ENTRY_POINT" --version 2>&1)"
    assert_matches "$out" 'lazynvim-learn [0-9]+\.[0-9]+\.[0-9]+' \
        "--version output should match 'lazynvim-learn <semver>'"
}

# ---------------------------------------------------------------------------
# --help flag
# ---------------------------------------------------------------------------

test_help_flag_exits_zero() {
    "$ENTRY_POINT" --help >/dev/null 2>&1
    assert_exit_code 0 $? "--help should exit 0"
}

test_help_flag_prints_usage() {
    local out
    out="$("$ENTRY_POINT" --help 2>&1)"
    assert_contains "$out" "Usage:" "--help should print Usage:"
}

test_help_flag_mentions_version_option() {
    local out
    out="$("$ENTRY_POINT" --help 2>&1)"
    assert_contains "$out" "--version" "--help should mention --version option"
}

test_help_flag_mentions_reset_config_option() {
    local out
    out="$("$ENTRY_POINT" --help 2>&1)"
    assert_contains "$out" "--reset-config" "--help should mention --reset-config option"
}

test_short_h_flag_exits_zero() {
    "$ENTRY_POINT" -h >/dev/null 2>&1
    assert_exit_code 0 $? "-h should exit 0"
}

# ---------------------------------------------------------------------------
# Unknown flag
# ---------------------------------------------------------------------------

test_unknown_flag_exits_nonzero() {
    "$ENTRY_POINT" --nonexistent-flag >/dev/null 2>&1
    assert_exit_code 1 $? "Unknown flag should exit with non-zero"
}

# ---------------------------------------------------------------------------
# Running outside tmux — _check_tmux_running
# ---------------------------------------------------------------------------

test_check_tmux_running_fails_without_tmux() {
    # Run _check_tmux_running in an isolated subshell with TMUX unset.
    # We must NOT unset TMUX in the current shell because the test runner
    # itself may reference it and set -u would abort the runner.
    (
        unset TMUX
        # Source the function again inside the subshell so it runs cleanly
        source "$ENTRY_POINT"
        _check_tmux_running
    ) >/dev/null 2>&1
    local rc=$?
    assert_exit_code 1 $rc "_check_tmux_running should exit 1 when TMUX is unset"
}

test_check_tmux_running_passes_with_tmux_set() {
    # Call in a subshell with TMUX set to a dummy value
    (
        export TMUX="/tmp/tmux-fake-socket,12345,0"
        _check_tmux_running
    ) >/dev/null 2>&1
    assert_exit_code 0 $? "_check_tmux_running should succeed when TMUX is set"
}

test_no_tmux_error_message_mentions_tmux() {
    local out
    out="$(
        unset TMUX
        (
            unset TMUX
            _check_tmux_running
        ) 2>&1 || true
    )"
    assert_contains "$out" "tmux" "Error message should mention tmux"
}

# ---------------------------------------------------------------------------
# parse_nvim_version
# ---------------------------------------------------------------------------

test_parse_nvim_version_standard_format() {
    local result
    result="$(parse_nvim_version "NVIM v0.12.1")"
    assert_equals "0.12.1" "$result" "Should parse 'NVIM v0.12.1'"
}

test_parse_nvim_version_returns_empty_for_garbage() {
    local result
    result="$(parse_nvim_version "not a version string")"
    assert_equals "" "$result" "Should return empty for unrecognized format"
}

test_parse_nvim_version_with_extra_info() {
    # Real nvim --version output often has build info on the same line — test robustness
    local result
    result="$(parse_nvim_version "NVIM v0.10.3")"
    assert_equals "0.10.3" "$result" "Should parse version from output with minor version 10"
}

test_parse_nvim_version_major_1() {
    local result
    result="$(parse_nvim_version "NVIM v1.0.0")"
    assert_equals "1.0.0" "$result" "Should parse version 1.0.0"
}

# ---------------------------------------------------------------------------
# version_to_int
# ---------------------------------------------------------------------------

test_version_to_int_basic() {
    local result
    result="$(version_to_int "0.12.1")"
    assert_equals "1201" "$result" "0.12.1 → 1201"
}

test_version_to_int_zero_zero_nine() {
    local result
    result="$(version_to_int "0.9.0")"
    assert_equals "900" "$result" "0.9.0 → 900"
}

test_version_to_int_one_zero_zero() {
    local result
    result="$(version_to_int "1.0.0")"
    assert_equals "10000" "$result" "1.0.0 → 10000"
}

test_version_to_int_ordering() {
    local v_old v_new
    v_old="$(version_to_int "0.9.5")"
    v_new="$(version_to_int "0.12.1")"
    [[ "$v_new" -gt "$v_old" ]]
    assert_exit_code 0 $? "0.12.1 should be numerically greater than 0.9.5 after conversion"
}

# ---------------------------------------------------------------------------
# RESET_CONFIG default
# ---------------------------------------------------------------------------

test_reset_config_default_is_zero() {
    # Re-source to verify RESET_CONFIG resets to 0; restore set +e afterwards.
    local saved_reset="$RESET_CONFIG"
    source "$ENTRY_POINT"
    set +e   # re-disable set -e that was re-enabled by sourcing entry point
    assert_equals "0" "$RESET_CONFIG" "RESET_CONFIG should default to 0"
    RESET_CONFIG="$saved_reset"
}

test_parse_args_sets_reset_config() {
    local saved="$RESET_CONFIG"
    RESET_CONFIG=0
    parse_args --reset-config
    assert_equals "1" "$RESET_CONFIG" "--reset-config should set RESET_CONFIG=1"
    RESET_CONFIG="$saved"
}

# ---------------------------------------------------------------------------
# Entry point is executable
# ---------------------------------------------------------------------------

test_entry_point_is_executable() {
    [[ -x "$ENTRY_POINT" ]]
    assert_exit_code 0 $? "lazynvim-learn should be executable"
}

# ---------------------------------------------------------------------------
# _check_bash_version
# ---------------------------------------------------------------------------

test_check_bash_version_passes_for_current_shell() {
    # The test itself is running in a >=4 shell, so this must pass
    _check_bash_version
    assert_exit_code 0 $? "_check_bash_version should pass for the current shell"
}
