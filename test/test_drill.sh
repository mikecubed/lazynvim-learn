#!/usr/bin/env bash
# test/test_drill.sh — Tests for lib/drill.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

# Stub out ui.sh color constants (drill.sh uses them in scorecard)
COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_CYAN=$'\033[0;36m'
COLOR_BOLD=$'\033[1m'
COLOR_DIM=$'\033[2m'
COLOR_RESET=$'\033[0m'

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

setup() {
    TEST_DRILL_DIR="$(mktemp -d)"
    PROGRESS_DIR="$TEST_DRILL_DIR"
    DRILL_SETTINGS_FILE="$TEST_DRILL_DIR/drill-settings"
    DRILL_SCORES_FILE="$TEST_DRILL_DIR/drill-scores"
    # Reset the source guard so we can re-source with new globals
    _LAZYNVIM_DRILL_SH=""
    source "$SCRIPT_DIR/../lib/drill.sh"
}

teardown() {
    rm -rf "$TEST_DRILL_DIR"
}

# ---------------------------------------------------------------------------
# Mode management
# ---------------------------------------------------------------------------

test_load_mode_defaults_to_normal() {
    drill_load_mode
    assert_equals "normal" "$DRILL_MODE" "default mode should be normal"
}

test_load_mode_reads_hard() {
    echo "hard" > "$DRILL_SETTINGS_FILE"
    drill_load_mode
    assert_equals "hard" "$DRILL_MODE" "should read hard from settings file"
}

test_load_mode_ignores_invalid() {
    echo "invalid" > "$DRILL_SETTINGS_FILE"
    drill_load_mode
    assert_equals "normal" "$DRILL_MODE" "invalid value should default to normal"
}

test_toggle_mode_to_hard() {
    DRILL_MODE="normal"
    drill_toggle_mode
    assert_equals "hard" "$DRILL_MODE" "toggle from normal should set hard"
    assert_equals "hard" "$(cat "$DRILL_SETTINGS_FILE")" "hard should be persisted"
}

test_toggle_mode_to_normal() {
    DRILL_MODE="hard"
    drill_toggle_mode
    assert_equals "normal" "$DRILL_MODE" "toggle from hard should set normal"
}

test_is_hard_mode_returns_true() {
    DRILL_MODE="hard"
    drill_is_hard_mode
    assert_exit_code 0 $? "should return 0 when hard"
}

test_is_hard_mode_returns_false() {
    DRILL_MODE="normal"
    drill_is_hard_mode
    assert_exit_code 1 $? "should return 1 when normal"
}

# ---------------------------------------------------------------------------
# Timer
# ---------------------------------------------------------------------------

test_drill_elapsed_returns_seconds() {
    DRILL_START_TIME=$(date +%s)
    local elapsed
    elapsed=$(drill_elapsed)
    assert_equals "0" "$elapsed" "elapsed should be 0 immediately after start"
}

test_exercise_timer_records_split() {
    DRILL_SPLITS=()
    DRILL_EXERCISE_START=$(date +%s)
    drill_stop_exercise_timer
    assert_equals "1" "${#DRILL_SPLITS[@]}" "should add one split"
}

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------

test_reset_counters_zeroes_all() {
    DRILL_FIRST_TRY_COUNT=5
    DRILL_HINT_COUNT=3
    DRILL_SKIP_COUNT=2
    DRILL_EXERCISE_ATTEMPTS=1
    DRILL_SPLITS=(10 20 30)
    drill_reset_counters
    assert_equals "0" "$DRILL_FIRST_TRY_COUNT" "first_try should be 0"
    assert_equals "0" "$DRILL_HINT_COUNT" "hints should be 0"
    assert_equals "0" "$DRILL_SKIP_COUNT" "skips should be 0"
    assert_equals "0" "$DRILL_EXERCISE_ATTEMPTS" "attempts should be 0"
    assert_equals "0" "${#DRILL_SPLITS[@]}" "splits should be empty"
}

test_record_pass_first_try() {
    DRILL_EXERCISE_ATTEMPTS=0
    DRILL_FIRST_TRY_COUNT=0
    drill_record_pass
    assert_equals "1" "$DRILL_FIRST_TRY_COUNT" "first pass on zero attempts should count"
}

test_record_pass_not_first_try() {
    DRILL_EXERCISE_ATTEMPTS=1
    DRILL_FIRST_TRY_COUNT=0
    drill_record_pass
    assert_equals "0" "$DRILL_FIRST_TRY_COUNT" "pass after failures should not count"
}

test_record_fail_increments() {
    DRILL_EXERCISE_ATTEMPTS=0
    drill_record_fail
    assert_equals "1" "$DRILL_EXERCISE_ATTEMPTS" "fail should increment attempts"
}

test_record_hint_increments() {
    DRILL_HINT_COUNT=0
    drill_record_hint
    assert_equals "1" "$DRILL_HINT_COUNT" "hint should increment count"
}

test_record_skip_increments() {
    DRILL_SKIP_COUNT=0
    drill_record_skip
    assert_equals "1" "$DRILL_SKIP_COUNT" "skip should increment count"
}

test_reset_exercise_zeroes_attempts() {
    DRILL_EXERCISE_ATTEMPTS=3
    drill_reset_exercise
    assert_equals "0" "$DRILL_EXERCISE_ATTEMPTS" "reset_exercise should zero attempts"
}

# ---------------------------------------------------------------------------
# Score storage
# ---------------------------------------------------------------------------

test_save_score_creates_file() {
    DRILL_MODE="normal"
    DRILL_START_TIME=$(date +%s)
    DRILL_FIRST_TRY_COUNT=6
    DRILL_HINT_COUNT=1
    DRILL_SKIP_COUNT=0
    DRILL_SPLITS=(18 24 31)
    drill_save_score "02-navigation" 8 42
    assert_file_exists "$DRILL_SCORES_FILE" "save_score should create scores file"
}

test_save_score_correct_format() {
    DRILL_MODE="hard"
    DRILL_START_TIME=$(date +%s)
    DRILL_FIRST_TRY_COUNT=8
    DRILL_HINT_COUNT=0
    DRILL_SKIP_COUNT=0
    DRILL_SPLITS=(10 20)
    drill_save_score "01-quick-refresher" 8 100
    local line
    line=$(cat "$DRILL_SCORES_FILE")
    assert_contains "$line" "01-quick-refresher:hard:" "should contain drill name and mode"
    assert_contains "$line" ":100:" "should contain total seconds"
    assert_contains "$line" ":8:" "should contain first try count"
    assert_contains "$line" ":1:" "should contain clean flag 1"
    assert_contains "$line" "10,20" "should contain comma-separated splits"
}

test_save_score_clean_flag_zero_when_not_clean() {
    DRILL_MODE="normal"
    DRILL_START_TIME=$(date +%s)
    DRILL_FIRST_TRY_COUNT=6
    DRILL_HINT_COUNT=1
    DRILL_SKIP_COUNT=0
    DRILL_SPLITS=()
    drill_save_score "02-navigation" 8 50
    local line
    line=$(cat "$DRILL_SCORES_FILE")
    assert_contains "$line" ":0:" "not-clean run should have flag 0"
}

test_best_time_returns_lowest() {
    printf '%s\n' "02-nav:normal:1000:120:8:0:0:1:18,24" >> "$DRILL_SCORES_FILE"
    printf '%s\n' "02-nav:hard:1001:90:7:1:0:0:15,20" >> "$DRILL_SCORES_FILE"
    printf '%s\n' "02-nav:normal:1002:150:6:0:1:0:30,40" >> "$DRILL_SCORES_FILE"
    local best
    best=$(drill_best_time "02-nav")
    assert_equals "90" "$best" "best_time should return lowest across all modes"
}

test_best_time_mode_filters() {
    printf '%s\n' "02-nav:normal:1000:120:8:0:0:1:18,24" >> "$DRILL_SCORES_FILE"
    printf '%s\n' "02-nav:hard:1001:90:7:1:0:0:15,20" >> "$DRILL_SCORES_FILE"
    local best
    best=$(drill_best_time_mode "02-nav" "normal")
    assert_equals "120" "$best" "best_time_mode should filter by mode"
}

test_best_time_empty_when_no_runs() {
    local best
    best=$(drill_best_time "nonexistent")
    assert_equals "" "$best" "best_time should be empty for unknown drill"
}

test_has_clean_run_true() {
    printf '%s\n' "02-nav:normal:1000:120:8:0:0:1:18,24" >> "$DRILL_SCORES_FILE"
    drill_has_clean_run "02-nav"
    assert_exit_code 0 $? "should find clean run"
}

test_has_clean_run_false() {
    printf '%s\n' "02-nav:normal:1000:120:6:1:0:0:18,24" >> "$DRILL_SCORES_FILE"
    drill_has_clean_run "02-nav"
    assert_exit_code 1 $? "should not find clean run"
}

test_has_clean_run_no_file() {
    drill_has_clean_run "nonexistent"
    assert_exit_code 1 $? "should return 1 when no scores file"
}

# ---------------------------------------------------------------------------
# Display name formatting
# ---------------------------------------------------------------------------

test_display_name_strips_prefix() {
    local result
    result=$(_drill_display_name "01-quick-refresher")
    assert_equals "Quick Refresher" "$result" "should strip number and capitalize"
}

test_display_name_single_word() {
    local result
    result=$(_drill_display_name "02-navigation")
    assert_equals "Navigation" "$result" "single word should capitalize"
}

test_display_name_multi_word() {
    local result
    result=$(_drill_display_name "06-search-replace")
    assert_equals "Search Replace" "$result" "multi-word should capitalize each"
}

# ---------------------------------------------------------------------------
# Time formatting
# ---------------------------------------------------------------------------

test_format_time_seconds_only() {
    local result
    result=$(_drill_format_time 42)
    assert_equals "42s" "$result" "under 60 should show seconds only"
}

test_format_time_minutes_and_seconds() {
    local result
    result=$(_drill_format_time 222)
    assert_equals "3m 42s" "$result" "over 60 should show minutes and seconds"
}

test_format_time_zero() {
    local result
    result=$(_drill_format_time 0)
    assert_equals "0s" "$result" "zero should show 0s"
}

# ---------------------------------------------------------------------------
# _drill_find_best uses globals (no namerefs)
# ---------------------------------------------------------------------------

test_find_best_sets_globals() {
    printf '%s\n' "drill-x:normal:1000:200:8:0:0:1:10" >> "$DRILL_SCORES_FILE"
    printf '%s\n' "drill-x:hard:1001:150:7:0:0:1:10" >> "$DRILL_SCORES_FILE"
    _drill_find_best "drill-x"
    assert_equals "150" "$_DRILL_BEST_SECS" "should find best seconds"
    assert_equals "hard" "$_DRILL_BEST_MODE" "should find best mode"
}

test_find_best_empty_for_no_runs() {
    _drill_find_best "nonexistent"
    assert_equals "" "$_DRILL_BEST_SECS" "should be empty for unknown drill"
    assert_equals "" "$_DRILL_BEST_MODE" "should be empty for unknown drill"
}
