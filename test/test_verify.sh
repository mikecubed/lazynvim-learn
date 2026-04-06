#!/usr/bin/env bash
# test/test_verify.sh — Tests for lib/verify.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only source the runner when this file is executed directly (not sourced by it)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$SCRIPT_DIR/test_runner.sh"
fi

source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

# ---------------------------------------------------------------------------
# Mock helpers for unit tests
# ---------------------------------------------------------------------------

mock_pass() { VERIFY_MESSAGE="passed"; return 0; }
mock_fail() { VERIFY_MESSAGE="failed"; return 1; }
mock_fail2() { VERIFY_MESSAGE="second failure"; return 1; }

# ---------------------------------------------------------------------------
# Unit tests — always run, no Neovim instance required
# ---------------------------------------------------------------------------

# --- Global defaults ---

test_globals_verify_message_default_empty() {
    # Re-source to confirm default
    VERIFY_MESSAGE=""
    assert_equals "" "$VERIFY_MESSAGE" "VERIFY_MESSAGE should default to empty"
}

test_globals_verify_hint_default_empty() {
    VERIFY_HINT=""
    assert_equals "" "$VERIFY_HINT" "VERIFY_HINT should default to empty"
}

test_globals_exercise_dir_default_empty() {
    EXERCISE_DIR=""
    assert_equals "" "$EXERCISE_DIR" "EXERCISE_DIR should default to empty"
}

# --- verify_reset ---

test_verify_reset_clears_message() {
    VERIFY_MESSAGE="some message"
    verify_reset
    assert_equals "" "$VERIFY_MESSAGE" "verify_reset should clear VERIFY_MESSAGE"
}

test_verify_reset_clears_hint() {
    VERIFY_HINT="some hint"
    verify_reset
    assert_equals "" "$VERIFY_HINT" "verify_reset should clear VERIFY_HINT"
}

test_verify_reset_clears_both() {
    VERIFY_MESSAGE="msg"
    VERIFY_HINT="hint"
    verify_reset
    assert_equals "" "$VERIFY_MESSAGE" "verify_reset should clear VERIFY_MESSAGE"
    assert_equals "" "$VERIFY_HINT" "verify_reset should clear VERIFY_HINT"
}

# --- Function existence ---

test_function_exists_verify_reset() {
    assert_equals "function" "$(type -t verify_reset)" "verify_reset should be a function"
}

test_function_exists_verify_file_open() {
    assert_equals "function" "$(type -t verify_file_open)" "verify_file_open should be a function"
}

test_function_exists_verify_file_in_buffers() {
    assert_equals "function" "$(type -t verify_file_in_buffers)" "verify_file_in_buffers should be a function"
}

test_function_exists_verify_buffer_contains() {
    assert_equals "function" "$(type -t verify_buffer_contains)" "verify_buffer_contains should be a function"
}

test_function_exists_verify_buffer_not_contains() {
    assert_equals "function" "$(type -t verify_buffer_not_contains)" "verify_buffer_not_contains should be a function"
}

test_function_exists_verify_line_content() {
    assert_equals "function" "$(type -t verify_line_content)" "verify_line_content should be a function"
}

test_function_exists_verify_line_count() {
    assert_equals "function" "$(type -t verify_line_count)" "verify_line_count should be a function"
}

test_function_exists_verify_buffer_modified() {
    assert_equals "function" "$(type -t verify_buffer_modified)" "verify_buffer_modified should be a function"
}

test_function_exists_verify_mode() {
    assert_equals "function" "$(type -t verify_mode)" "verify_mode should be a function"
}

test_function_exists_verify_cursor_line() {
    assert_equals "function" "$(type -t verify_cursor_line)" "verify_cursor_line should be a function"
}

test_function_exists_verify_cursor_col() {
    assert_equals "function" "$(type -t verify_cursor_col)" "verify_cursor_col should be a function"
}

test_function_exists_verify_cursor_on_pattern() {
    assert_equals "function" "$(type -t verify_cursor_on_pattern)" "verify_cursor_on_pattern should be a function"
}

test_function_exists_verify_window_count() {
    assert_equals "function" "$(type -t verify_window_count)" "verify_window_count should be a function"
}

test_function_exists_verify_split_has_file() {
    assert_equals "function" "$(type -t verify_split_has_file)" "verify_split_has_file should be a function"
}

test_function_exists_verify_register_contains() {
    assert_equals "function" "$(type -t verify_register_contains)" "verify_register_contains should be a function"
}

test_function_exists_verify_register_not_empty() {
    assert_equals "function" "$(type -t verify_register_not_empty)" "verify_register_not_empty should be a function"
}

test_function_exists_verify_lsp_attached() {
    assert_equals "function" "$(type -t verify_lsp_attached)" "verify_lsp_attached should be a function"
}

test_function_exists_verify_jumped_to_line() {
    assert_equals "function" "$(type -t verify_jumped_to_line)" "verify_jumped_to_line should be a function"
}

test_function_exists_verify_plugin_installed() {
    assert_equals "function" "$(type -t verify_plugin_installed)" "verify_plugin_installed should be a function"
}

test_function_exists_verify_plugin_loaded() {
    assert_equals "function" "$(type -t verify_plugin_loaded)" "verify_plugin_loaded should be a function"
}

test_function_exists_verify_keymap_exists() {
    assert_equals "function" "$(type -t verify_keymap_exists)" "verify_keymap_exists should be a function"
}

test_function_exists_verify_filetype_visible() {
    assert_equals "function" "$(type -t verify_filetype_visible)" "verify_filetype_visible should be a function"
}

test_function_exists_verify_file_exists_on_disk() {
    assert_equals "function" "$(type -t verify_file_exists_on_disk)" "verify_file_exists_on_disk should be a function"
}

test_function_exists_verify_file_not_exists_on_disk() {
    assert_equals "function" "$(type -t verify_file_not_exists_on_disk)" "verify_file_not_exists_on_disk should be a function"
}

test_function_exists_verify_git_commit_exists() {
    assert_equals "function" "$(type -t verify_git_commit_exists)" "verify_git_commit_exists should be a function"
}

test_function_exists_verify_all() {
    assert_equals "function" "$(type -t verify_all)" "verify_all should be a function"
}

test_function_exists_verify_via_companion() {
    assert_equals "function" "$(type -t verify_via_companion)" "verify_via_companion should be a function"
}

# --- verify_file_exists_on_disk ---

test_file_exists_on_disk_passes_for_real_file() {
    local tmpfile
    tmpfile=$(mktemp)
    verify_file_exists_on_disk "$tmpfile"
    local rc=$?
    rm -f "$tmpfile"
    assert_exit_code 0 $rc "verify_file_exists_on_disk should pass for a real file"
}

test_file_exists_on_disk_sets_message_on_pass() {
    local tmpfile
    tmpfile=$(mktemp)
    verify_file_exists_on_disk "$tmpfile"
    local msg="$VERIFY_MESSAGE"
    rm -f "$tmpfile"
    assert_contains "$msg" "exists" "VERIFY_MESSAGE should indicate file exists"
}

test_file_exists_on_disk_fails_for_missing_file() {
    verify_file_exists_on_disk "/tmp/lazynvim-learn-no-such-file-$$"
    assert_exit_code 1 $? "verify_file_exists_on_disk should fail for a missing file"
}

test_file_exists_on_disk_sets_message_on_fail() {
    verify_file_exists_on_disk "/tmp/lazynvim-learn-no-such-file-$$"
    assert_contains "$VERIFY_MESSAGE" "does not exist" "VERIFY_MESSAGE should indicate file is missing"
}

test_file_exists_on_disk_resets_hint() {
    VERIFY_HINT="stale hint"
    local tmpfile
    tmpfile=$(mktemp)
    verify_file_exists_on_disk "$tmpfile"
    rm -f "$tmpfile"
    assert_equals "" "$VERIFY_HINT" "verify_file_exists_on_disk should reset VERIFY_HINT"
}

# --- verify_file_not_exists_on_disk ---

test_file_not_exists_on_disk_passes_for_missing_file() {
    verify_file_not_exists_on_disk "/tmp/lazynvim-learn-absent-$$"
    assert_exit_code 0 $? "verify_file_not_exists_on_disk should pass when file is absent"
}

test_file_not_exists_on_disk_sets_message_on_pass() {
    verify_file_not_exists_on_disk "/tmp/lazynvim-learn-absent-$$"
    assert_contains "$VERIFY_MESSAGE" "removed" "VERIFY_MESSAGE should say file has been removed"
}

test_file_not_exists_on_disk_fails_for_existing_file() {
    local tmpfile
    tmpfile=$(mktemp)
    verify_file_not_exists_on_disk "$tmpfile"
    local rc=$?
    rm -f "$tmpfile"
    assert_exit_code 1 $rc "verify_file_not_exists_on_disk should fail when file exists"
}

test_file_not_exists_on_disk_sets_message_on_fail() {
    local tmpfile
    tmpfile=$(mktemp)
    verify_file_not_exists_on_disk "$tmpfile"
    local msg="$VERIFY_MESSAGE"
    rm -f "$tmpfile"
    assert_contains "$msg" "still exists" "VERIFY_MESSAGE should say file still exists"
}

# --- verify_all ---

test_verify_all_passes_when_all_functions_pass() {
    verify_all mock_pass mock_pass
    assert_exit_code 0 $? "verify_all should return 0 when all functions pass"
}

test_verify_all_sets_message_on_all_pass() {
    verify_all mock_pass mock_pass
    assert_contains "$VERIFY_MESSAGE" "All checks passed" "VERIFY_MESSAGE should confirm all checks passed"
}

test_verify_all_fails_when_any_function_fails() {
    verify_all mock_pass mock_fail
    assert_exit_code 1 $? "verify_all should return 1 when any function fails"
}

test_verify_all_reports_first_failure_message() {
    verify_all mock_fail mock_fail2
    assert_equals "failed" "$VERIFY_MESSAGE" "verify_all should report the first failing function's message"
}

test_verify_all_fails_with_single_failing_function() {
    verify_all mock_fail
    assert_exit_code 1 $? "verify_all should return 1 with one failing function"
}

test_verify_all_passes_with_single_passing_function() {
    verify_all mock_pass
    assert_exit_code 0 $? "verify_all should return 0 with one passing function"
}

test_verify_all_resets_at_start() {
    VERIFY_MESSAGE="stale"
    VERIFY_HINT="stale hint"
    verify_all mock_pass
    assert_not_equals "stale" "$VERIFY_MESSAGE" "verify_all should reset before running"
}

# --- verify_via_companion result parsing ---

test_via_companion_pass_parsing() {
    # Override nvim_lua locally for this test
    nvim_lua() { echo "pass:Telescope is open"; }
    verify_via_companion "telescope_is_open"
    local rc=$?
    unset -f nvim_lua
    # Re-source nvim_helpers to restore nvim_lua
    source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
    assert_exit_code 0 $rc "verify_via_companion should return 0 for pass response"
    assert_equals "Telescope is open" "$VERIFY_MESSAGE" "VERIFY_MESSAGE should be extracted from pass response"
}

test_via_companion_fail_parsing() {
    nvim_lua() { echo "fail:Neo-tree not open:Use <leader>e to open Neo-tree"; }
    verify_via_companion "neotree_is_open"
    local rc=$?
    unset -f nvim_lua
    source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
    assert_exit_code 1 $rc "verify_via_companion should return 1 for fail response"
    assert_equals "Neo-tree not open" "$VERIFY_MESSAGE" "VERIFY_MESSAGE should be extracted from fail response"
    assert_equals "Use <leader>e to open Neo-tree" "$VERIFY_HINT" "VERIFY_HINT should be extracted from fail response"
}

test_via_companion_fail_without_hint_clears_hint() {
    nvim_lua() { echo "fail:Something went wrong"; }
    verify_via_companion "some_check"
    local rc=$?
    unset -f nvim_lua
    source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
    assert_exit_code 1 $rc "verify_via_companion should return 1 for fail without hint"
    assert_equals "Something went wrong" "$VERIFY_MESSAGE" "VERIFY_MESSAGE should be set"
    assert_equals "" "$VERIFY_HINT" "VERIFY_HINT should be empty when no hint in response"
}

test_via_companion_pass_clears_hint() {
    VERIFY_HINT="stale hint"
    nvim_lua() { echo "pass:Done"; }
    verify_via_companion "some_check"
    unset -f nvim_lua
    source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
    assert_equals "" "$VERIFY_HINT" "VERIFY_HINT should be empty on pass without hint"
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

_start_nvim() {
    TEST_SOCKET="/tmp/lazynvim-learn-verify-test-$$.sock"
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

test_integration_verify_mode_normal() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_mode "n"
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_mode 'n' should pass when nvim starts in Normal mode"
}

test_integration_verify_mode_wrong() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_mode "i"
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_mode 'i' should fail when nvim is in Normal mode"
}

test_integration_verify_mode_message_on_fail() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_mode "i"
    local msg="$VERIFY_MESSAGE"
    _stop_nvim
    assert_contains "$msg" "expected 'i'" "VERIFY_MESSAGE should indicate expected mode"
}

test_integration_verify_cursor_line_default() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_cursor_line 1
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "cursor should be on line 1 in a fresh nvim session"
}

test_integration_verify_cursor_col_default() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_cursor_col 0
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "cursor column should be 0 in a fresh nvim session"
}

test_integration_verify_buffer_contains_pass() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'hello world')"
    verify_buffer_contains "hello"
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_buffer_contains should pass when pattern is present"
}

test_integration_verify_buffer_contains_fail() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'hello world')"
    verify_buffer_contains "notpresent"
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_buffer_contains should fail when pattern is absent"
}

test_integration_verify_buffer_not_contains_pass() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'hello world')"
    verify_buffer_not_contains "notpresent"
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_buffer_not_contains should pass when pattern is absent"
}

test_integration_verify_buffer_not_contains_fail() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'hello world')"
    verify_buffer_not_contains "hello"
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_buffer_not_contains should fail when pattern is present"
}

test_integration_verify_line_content_pass() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'exact content')"
    verify_line_content 1 "exact content"
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_line_content should pass when line matches exactly"
}

test_integration_verify_line_content_fail() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'actual content')"
    verify_line_content 1 "wrong content"
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_line_content should fail when line does not match"
}

test_integration_verify_window_count_ge_one() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_window_count 1 ge
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_window_count ge 1 should pass with at least one window"
}

test_integration_verify_window_count_eq_one() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_window_count 1 eq
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_window_count eq 1 should pass with exactly one window"
}

test_integration_verify_window_count_fails_when_too_few() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_window_count 3 ge
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_window_count ge 3 should fail with only one window"
}

test_integration_verify_register_not_empty_after_yank() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'yank me')"
    # Yank line 1 into the unnamed register via Ex command
    nvim_exec "1y"
    verify_register_not_empty '"'
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_register_not_empty should pass after yanking"
}

test_integration_verify_file_open_empty_for_scratch() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    verify_file_open ""
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_file_open '' should pass for scratch buffer with no filename"
}

test_integration_verify_cursor_on_pattern_pass() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'function main() {}')"
    verify_cursor_on_pattern "function"
    local rc=$?
    _stop_nvim
    assert_exit_code 0 $rc "verify_cursor_on_pattern should pass when pattern is on cursor line"
}

test_integration_verify_cursor_on_pattern_fail() {
    if ! _integration_setup; then
        printf "    (skipped: nvim not available)\n"
        assert_true "skipped"
        return
    fi
    _start_nvim
    nvim_exec "call setline(1, 'function main() {}')"
    verify_cursor_on_pattern "nothere"
    local rc=$?
    _stop_nvim
    assert_exit_code 1 $rc "verify_cursor_on_pattern should fail when pattern is not on cursor line"
}
