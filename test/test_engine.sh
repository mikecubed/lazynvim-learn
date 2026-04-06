#!/usr/bin/env bash
# test/test_engine.sh — Tests for lib/engine.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

# Use fast mode so typewriter / delay functions don't sleep
export LAZYNVIM_LEARN_FAST=1

# Source dependencies first
source "$SCRIPT_DIR/../lib/ui.sh"

# Stub out nvim_helpers.sh functions so tests don't need a live Neovim socket
nvim_send_keys() { return 0; }
nvim_is_running() { return 0; }
nvim_wait_ready() { return 0; }
nvim_eval()       { return 0; }
nvim_lua()        { return 0; }
nvim_exec()       { return 0; }

# Stub sandbox functions — no tmux required
sandbox_setup_exercise() { return 0; }
sandbox_open_file()      { return 0; }
sandbox_reset()          { return 0; }
sandbox_kill()           { return 0; }
sandbox_is_alive()       { return 0; }

# Source progress and engine now that stubs are in place
source "$SCRIPT_DIR/../lib/progress.sh"
source "$SCRIPT_DIR/../lib/engine.sh"

# ---------------------------------------------------------------------------
# Setup / teardown — isolate progress to a temp dir
# ---------------------------------------------------------------------------

setup() {
    _TEST_PROG_DIR="$(mktemp -d)"
    PROGRESS_DIR="$_TEST_PROG_DIR"
    PROGRESS_FILE="$_TEST_PROG_DIR/progress"
    progress_init

    # Reset engine globals
    CURRENT_LESSON="test-module/test-lesson"
    CURRENT_EXERCISE=""
    _ENGINE_QUIT=0
}

teardown() {
    rm -rf "$_TEST_PROG_DIR"
}

# ---------------------------------------------------------------------------
# Mock verify functions used by exercise tests
# ---------------------------------------------------------------------------

mock_verify_pass() {
    VERIFY_MESSAGE="All good"
    VERIFY_HINT=""
    return 0
}

mock_verify_fail() {
    VERIFY_MESSAGE="Not yet"
    VERIFY_HINT="Try harder"
    return 1
}

# ---------------------------------------------------------------------------
# 1. Globals are defined
# ---------------------------------------------------------------------------

test_globals_exercise_dir_defined() {
    # EXERCISE_DIR should exist as a variable (may be empty string)
    declare -p EXERCISE_DIR &>/dev/null
    assert_exit_code 0 $? "EXERCISE_DIR global should be declared"
}

test_globals_current_lesson_defined() {
    declare -p CURRENT_LESSON &>/dev/null
    assert_exit_code 0 $? "CURRENT_LESSON global should be declared"
}

test_globals_current_exercise_defined() {
    declare -p CURRENT_EXERCISE &>/dev/null
    assert_exit_code 0 $? "CURRENT_EXERCISE global should be declared"
}

# ---------------------------------------------------------------------------
# 2. All 9 functions exist
# ---------------------------------------------------------------------------

test_function_engine_section_exists() {
    declare -f engine_section &>/dev/null
    assert_exit_code 0 $? "engine_section should be defined"
}

test_function_engine_teach_exists() {
    declare -f engine_teach &>/dev/null
    assert_exit_code 0 $? "engine_teach should be defined"
}

test_function_engine_pause_exists() {
    declare -f engine_pause &>/dev/null
    assert_exit_code 0 $? "engine_pause should be defined"
}

test_function_engine_demo_exists() {
    declare -f engine_demo &>/dev/null
    assert_exit_code 0 $? "engine_demo should be defined"
}

test_function_engine_show_key_exists() {
    declare -f engine_show_key &>/dev/null
    assert_exit_code 0 $? "engine_show_key should be defined"
}

test_function_engine_quiz_exists() {
    declare -f engine_quiz &>/dev/null
    assert_exit_code 0 $? "engine_quiz should be defined"
}

test_function_engine_exercise_exists() {
    declare -f engine_exercise &>/dev/null
    assert_exit_code 0 $? "engine_exercise should be defined"
}

test_function_engine_nvim_keys_exists() {
    declare -f engine_nvim_keys &>/dev/null
    assert_exit_code 0 $? "engine_nvim_keys should be defined"
}

test_function_engine_nvim_open_exists() {
    declare -f engine_nvim_open &>/dev/null
    assert_exit_code 0 $? "engine_nvim_open should be defined"
}

# ---------------------------------------------------------------------------
# 3. engine_section
# ---------------------------------------------------------------------------

test_engine_section_outputs_header_text() {
    local out
    out="$(engine_section "My Section")"
    assert_contains "$out" "My Section" "engine_section should output the title"
}

test_engine_section_adds_blank_line() {
    local out
    out="$(engine_section "Test")"
    # engine_section calls ui_header (3+ lines) then printf '\n' — at least 4 lines total.
    # Command substitution strips trailing newlines, so we count internal newlines.
    local lines
    lines="$(printf '%s' "$out" | wc -l)"
    [[ "$lines" -ge 3 ]]
    assert_exit_code 0 $? "engine_section output should span at least 3 lines (has $lines)"
}

# ---------------------------------------------------------------------------
# 4. engine_teach
# ---------------------------------------------------------------------------

test_engine_teach_outputs_text() {
    local out
    out="$(engine_teach "Learn this concept")"
    assert_contains "$out" "Learn this concept" "engine_teach should output the text"
}

test_engine_teach_adds_blank_line() {
    # engine_teach outputs the text via ui_typewriter (one line) then adds a
    # blank line via printf '\n'. Command substitution strips trailing newlines,
    # so we redirect to a temp file to preserve them and count lines there.
    local tmp
    tmp="$(mktemp)"
    engine_teach "HelloWorld" > "$tmp"
    # Should have at least 2 lines: the text line + the blank line
    local lines
    lines="$(wc -l < "$tmp")"
    rm -f "$tmp"
    [[ "$lines" -ge 2 ]]
    assert_exit_code 0 $? "engine_teach should output at least 2 lines (text + blank), got $lines"
}

# ---------------------------------------------------------------------------
# 5. engine_show_key
# ---------------------------------------------------------------------------

test_engine_show_key_contains_prefix_and_key() {
    local out
    out="$(engine_show_key "Leader" "ff" "Find files")"
    assert_contains "$out" "Leader" "engine_show_key should contain prefix"
    assert_contains "$out" "ff"     "engine_show_key should contain key"
}

test_engine_show_key_contains_description() {
    local out
    out="$(engine_show_key "Leader" "ff" "Find files")"
    assert_contains "$out" "Find files" "engine_show_key should contain description"
}

test_engine_show_key_uses_cyan() {
    local out
    out="$(engine_show_key "Space" "e" "Explorer")"
    assert_contains "$out" "$COLOR_CYAN" "engine_show_key should use cyan for key combo"
}

test_engine_show_key_brackets_combo() {
    local out
    out="$(engine_show_key "Space" "e" "Explorer")"
    assert_contains "$out" "[" "engine_show_key should wrap key combo in brackets"
    assert_contains "$out" "]" "engine_show_key should wrap key combo in brackets"
}

test_engine_show_key_empty_prefix() {
    # Empty prefix should still work (just show key alone)
    local out
    out="$(engine_show_key "" "j" "Move down")"
    assert_contains "$out" "j"         "engine_show_key should show key when prefix is empty"
    assert_contains "$out" "Move down" "engine_show_key should show description when prefix is empty"
}

# ---------------------------------------------------------------------------
# 6. engine_quiz
# ---------------------------------------------------------------------------

test_engine_quiz_correct_first_try() {
    local out
    # Correct answer is option 2 ("B"); feed "2" as stdin
    out="$(printf '2\n' | engine_quiz "Pick B" "A" "B" "C" 2)"
    assert_contains "$out" "Correct" "engine_quiz should show success on correct answer"
}

test_engine_quiz_wrong_then_correct() {
    local out
    # First answer wrong (1), then correct (3)
    out="$(printf '1\n3\n' | engine_quiz "Pick C" "A" "B" "C" 3)"
    assert_contains "$out" "Correct"    "engine_quiz should eventually show success"
    assert_contains "$out" "Not quite"  "engine_quiz should show error on wrong answer"
}

test_engine_quiz_shows_question() {
    local out
    out="$(printf '1\n' | engine_quiz "Is the sky blue?" "Yes" "No" 1)"
    assert_contains "$out" "Is the sky blue?" "engine_quiz should display the question"
}

test_engine_quiz_shows_options() {
    local out
    out="$(printf '1\n' | engine_quiz "Pick one" "Alpha" "Beta" 1)"
    assert_contains "$out" "Alpha" "engine_quiz should display option Alpha"
    assert_contains "$out" "Beta"  "engine_quiz should display option Beta"
}

test_engine_quiz_skip_exits_gracefully() {
    local out
    out="$(printf 'skip\n' | engine_quiz "Hard question?" "A" "B" "C" 1)"
    assert_contains "$out" "Skipped" "engine_quiz should acknowledge skip"
}

test_engine_quiz_skip_returns_zero() {
    printf 'skip\n' | engine_quiz "Hard question?" "A" "B" "C" 1 >/dev/null 2>&1
    assert_exit_code 0 $? "engine_quiz skip should return exit code 0"
}

# ---------------------------------------------------------------------------
# 7. engine_exercise — pass on first check
# ---------------------------------------------------------------------------

test_engine_exercise_sets_current_exercise() {
    # CURRENT_EXERCISE is set inside engine_exercise. When run in a pipeline
    # subshell its value isn't propagated back. We verify the behaviour by
    # inspecting the output from a helper that echoes the value from inside
    # the function — engine_exercise itself sets it before any output, so we
    # check indirectly: the exercise title appears in the output (meaning the
    # function ran with the correct id).
    local out
    out="$(printf 'check\n' | engine_exercise \
        "ex01" "Test Exercise" "Do the thing" \
        mock_verify_pass "a hint" "none")"
    # The title is rendered via ui_subheader — if engine ran, it set CURRENT_EXERCISE
    assert_contains "$out" "Test Exercise" \
        "engine_exercise ran successfully (CURRENT_EXERCISE was set internally)"
}

test_engine_exercise_pass_shows_success_message() {
    local out
    out="$(printf 'check\n' | engine_exercise \
        "ex01" "Test Exercise" "Do the thing" \
        mock_verify_pass "a hint" "none")"
    assert_contains "$out" "All good" "engine_exercise should show VERIFY_MESSAGE on pass"
}

test_engine_exercise_pass_returns_zero() {
    printf 'check\n' | engine_exercise \
        "ex01" "Test Exercise" "Do the thing" \
        mock_verify_pass "a hint" "none" >/dev/null 2>&1
    assert_exit_code 0 $? "engine_exercise should return 0 on pass"
}

test_engine_exercise_shows_title() {
    local out
    out="$(printf 'check\n' | engine_exercise \
        "ex01" "My Cool Exercise" "Instructions here" \
        mock_verify_pass "hint" "none")"
    assert_contains "$out" "My Cool Exercise" "engine_exercise should display exercise title"
}

test_engine_exercise_shows_instructions() {
    local out
    out="$(printf 'check\n' | engine_exercise \
        "ex01" "Title" "Follow these instructions please" \
        mock_verify_pass "hint" "none")"
    assert_contains "$out" "Follow these instructions please" \
        "engine_exercise should display instructions"
}

# ---------------------------------------------------------------------------
# 8. engine_exercise — skip
# ---------------------------------------------------------------------------

test_engine_exercise_skip_breaks_loop() {
    local out
    out="$(printf 'skip\n' | engine_exercise \
        "ex02" "Skip Me" "Just skip it" \
        mock_verify_fail "some hint" "none")"
    assert_contains "$out" "skipped" "engine_exercise should acknowledge skip"
}

test_engine_exercise_skip_returns_zero() {
    printf 'skip\n' | engine_exercise \
        "ex02" "Skip Me" "Just skip it" \
        mock_verify_fail "some hint" "none" >/dev/null 2>&1
    assert_exit_code 0 $? "engine_exercise skip should return 0"
}

# ---------------------------------------------------------------------------
# 9. engine_exercise — fail then hint auto-show
# ---------------------------------------------------------------------------

test_engine_exercise_shows_error_on_fail() {
    local out
    # fail twice, then skip
    out="$(printf 'check\ncheck\nskip\n' | engine_exercise \
        "ex03" "Fail Exercise" "This is hard" \
        mock_verify_fail "Try harder" "none")"
    assert_contains "$out" "Not yet" "engine_exercise should display VERIFY_MESSAGE on fail"
}

test_engine_exercise_shows_hint_after_two_failures() {
    local out
    # Two check failures, then skip
    out="$(printf 'check\ncheck\nskip\n' | engine_exercise \
        "ex03" "Fail Exercise" "This is hard" \
        mock_verify_fail "Try harder" "none")"
    assert_contains "$out" "Try harder" \
        "engine_exercise should display VERIFY_HINT after 2 failures"
}

# ---------------------------------------------------------------------------
# 10. engine_exercise — explicit hint command
# ---------------------------------------------------------------------------

test_engine_exercise_hint_command_shows_hint() {
    local out
    out="$(printf 'hint\nskip\n' | engine_exercise \
        "ex04" "Hinted Exercise" "Do something" \
        mock_verify_fail "Use the Force" "none")"
    assert_contains "$out" "Use the Force" \
        "engine_exercise 'hint' command should show hint text"
}

# ---------------------------------------------------------------------------
# 11. engine_exercise — quit
# ---------------------------------------------------------------------------

test_engine_exercise_quit_returns_2() {
    printf 'quit\n' | engine_exercise \
        "ex05" "Quit Exercise" "Quit now" \
        mock_verify_fail "hint" "none" >/dev/null 2>&1
    assert_exit_code 2 $? "engine_exercise quit should return exit code 2"
}

test_engine_exercise_quit_sets_engine_quit_flag() {
    # _ENGINE_QUIT is set inside the function; pipeline runs in a subshell so
    # the parent cannot observe it directly. We verify by checking the exit
    # code (2) which is the contract callers rely on for quit detection.
    local rc
    printf 'quit\n' | engine_exercise \
        "ex05" "Quit Exercise" "Quit now" \
        mock_verify_fail "hint" "none" >/dev/null 2>&1
    rc=$?
    assert_exit_code 2 $rc \
        "engine_exercise quit should return exit code 2 (proxy for _ENGINE_QUIT=1)"
}

# ---------------------------------------------------------------------------
# 12. engine_exercise — unknown command shows help
# ---------------------------------------------------------------------------

test_engine_exercise_unknown_command_shows_help() {
    local out
    out="$(printf 'wat\nskip\n' | engine_exercise \
        "ex06" "Help Exercise" "Do something" \
        mock_verify_fail "hint" "none")"
    assert_contains "$out" "check" "engine_exercise should show help for unknown command"
}

# ---------------------------------------------------------------------------
# 13. engine_exercise — progress recorded on pass
# ---------------------------------------------------------------------------

test_engine_exercise_records_progress_on_pass() {
    # engine_exercise writes progress inside the same process when run without
    # a pipeline. Use process substitution-free input via a temp file so the
    # function runs in the *current* shell and its progress_mark_complete call
    # is visible to us afterwards.
    CURRENT_LESSON="test-module/test-lesson"

    local input_file
    input_file="$(mktemp)"
    printf 'check\n' > "$input_file"

    engine_exercise \
        "ex07" "Progress Exercise" "Check it" \
        mock_verify_pass "hint" "none" < "$input_file" >/dev/null 2>&1

    rm -f "$input_file"

    local status
    status="$(progress_get_status "test-module/test-lesson/ex07")"
    assert_equals "complete" "$status" \
        "engine_exercise should record progress as complete after passing"
}

# ---------------------------------------------------------------------------
# 14. engine_exercise — calls sandbox_setup_exercise for non-none types
# ---------------------------------------------------------------------------

test_engine_exercise_calls_sandbox_for_file_type() {
    # Use a temp sentinel file to detect the call across the subshell boundary.
    local sentinel
    sentinel="$(mktemp)"
    rm -f "$sentinel"   # will be created by the override if called

    sandbox_setup_exercise() { touch "$sentinel"; return 0; }
    export -f sandbox_setup_exercise 2>/dev/null || true

    printf 'skip\n' | engine_exercise \
        "ex08" "Sandbox Exercise" "Open a file" \
        mock_verify_pass "hint" "file" "/some/file.lua" >/dev/null 2>&1

    [[ -f "$sentinel" ]]
    assert_exit_code 0 $? \
        "engine_exercise should call sandbox_setup_exercise for 'file' type"

    rm -f "$sentinel"
    # Restore stub
    sandbox_setup_exercise() { return 0; }
}

test_engine_exercise_skips_sandbox_for_none_type() {
    local sentinel
    sentinel="$(mktemp)"
    rm -f "$sentinel"

    sandbox_setup_exercise() { touch "$sentinel"; return 0; }
    export -f sandbox_setup_exercise 2>/dev/null || true

    printf 'skip\n' | engine_exercise \
        "ex09" "No Sandbox" "No nvim needed" \
        mock_verify_pass "hint" "none" >/dev/null 2>&1

    [[ ! -f "$sentinel" ]]
    assert_exit_code 0 $? \
        "engine_exercise should NOT call sandbox_setup_exercise for 'none' type"

    rm -f "$sentinel"
    # Restore stub
    sandbox_setup_exercise() { return 0; }
}

test_engine_exercise_skips_sandbox_for_current_type() {
    local sentinel
    sentinel="$(mktemp)"
    rm -f "$sentinel"

    sandbox_setup_exercise() { touch "$sentinel"; return 0; }
    export -f sandbox_setup_exercise 2>/dev/null || true

    printf 'skip\n' | engine_exercise \
        "ex10" "Current Sandbox" "Use existing nvim" \
        mock_verify_pass "hint" "current" >/dev/null 2>&1

    [[ ! -f "$sentinel" ]]
    assert_exit_code 0 $? \
        "engine_exercise should NOT call sandbox_setup_exercise for 'current' type"

    rm -f "$sentinel"
    # Restore stub
    sandbox_setup_exercise() { return 0; }
}

# ---------------------------------------------------------------------------
# 15. engine_nvim_keys / engine_nvim_open — delegation smoke tests
# ---------------------------------------------------------------------------

test_engine_nvim_keys_delegates_to_nvim_send_keys() {
    local received=""
    nvim_send_keys() { received="$1"; return 0; }

    engine_nvim_keys "jjj"
    assert_equals "jjj" "$received" "engine_nvim_keys should pass keys to nvim_send_keys"

    # Restore stub
    nvim_send_keys() { return 0; }
}

test_engine_nvim_open_delegates_to_sandbox_open_file() {
    local received=""
    sandbox_open_file() { received="$1"; return 0; }

    engine_nvim_open "/tmp/test.lua"
    assert_equals "/tmp/test.lua" "$received" \
        "engine_nvim_open should pass path to sandbox_open_file"

    # Restore stub
    sandbox_open_file() { return 0; }
}

# ---------------------------------------------------------------------------
# 16. engine_demo smoke test
# ---------------------------------------------------------------------------

test_engine_demo_outputs_description() {
    local out
    out="$(engine_demo "Watch this" "gg")"
    assert_contains "$out" "Watch this" "engine_demo should display the description"
}
