#!/usr/bin/env bash
# test/test_progress.sh — Tests for lib/progress.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

# ---------------------------------------------------------------------------
# Setup / teardown — use a temp dir so we never touch real user data
# ---------------------------------------------------------------------------

setup() {
    TEST_PROGRESS_DIR="$(mktemp -d)"
    # Override globals before sourcing so they pick up test values
    PROGRESS_DIR="$TEST_PROGRESS_DIR"
    PROGRESS_FILE="$TEST_PROGRESS_DIR/progress"

    # Source fresh (functions already defined if runner sourced previously;
    # re-sourcing is safe because all state is in files, not variables)
    source "$SCRIPT_DIR/../lib/progress.sh"
}

teardown() {
    rm -rf "$TEST_PROGRESS_DIR"
}

# ---------------------------------------------------------------------------
# progress_init
# ---------------------------------------------------------------------------

test_init_creates_directory() {
    local new_dir="$TEST_PROGRESS_DIR/subdir"
    PROGRESS_DIR="$new_dir"
    PROGRESS_FILE="$new_dir/progress"
    progress_init
    [[ -d "$new_dir" ]]
    assert_exit_code 0 $? "progress_init should create the progress directory"
}

test_init_creates_file() {
    progress_init
    assert_file_exists "$PROGRESS_FILE" "progress_init should create the progress file"
}

test_init_idempotent() {
    progress_init
    progress_init
    assert_file_exists "$PROGRESS_FILE" "progress_init should be safe to call twice"
}

# ---------------------------------------------------------------------------
# progress_mark_complete
# ---------------------------------------------------------------------------

test_mark_complete_writes_correct_format() {
    progress_init
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    local content
    content="$(cat "$PROGRESS_FILE")"
    assert_contains "$content" "01-neovim-essentials/01-modal-editing:complete" \
        "mark_complete should write key:complete"
}

test_mark_complete_one_line_per_lesson() {
    progress_init
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    local line_count
    line_count="$(wc -l < "$PROGRESS_FILE")"
    assert_equals "1" "$line_count" "duplicate mark_complete should not add a second line"
}

# ---------------------------------------------------------------------------
# progress_mark_in_progress
# ---------------------------------------------------------------------------

test_mark_in_progress_writes_correct_format() {
    progress_init
    progress_mark_in_progress "01-neovim-essentials/02-normal-mode"
    local content
    content="$(cat "$PROGRESS_FILE")"
    assert_contains "$content" "01-neovim-essentials/02-normal-mode:in-progress" \
        "mark_in_progress should write key:in-progress"
}

# ---------------------------------------------------------------------------
# progress_is_complete
# ---------------------------------------------------------------------------

test_is_complete_returns_0_for_complete() {
    progress_init
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    progress_is_complete "01-neovim-essentials/01-modal-editing"
    assert_exit_code 0 $? "is_complete should return 0 for a completed lesson"
}

test_is_complete_returns_1_for_in_progress() {
    progress_init
    progress_mark_in_progress "01-neovim-essentials/01-modal-editing"
    progress_is_complete "01-neovim-essentials/01-modal-editing"
    assert_exit_code 1 $? "is_complete should return 1 for an in-progress lesson"
}

test_is_complete_returns_1_for_unknown() {
    progress_init
    progress_is_complete "01-neovim-essentials/99-nonexistent"
    assert_exit_code 1 $? "is_complete should return 1 for an unknown lesson"
}

# ---------------------------------------------------------------------------
# progress_get_status
# ---------------------------------------------------------------------------

test_get_status_returns_complete() {
    progress_init
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    local status
    status="$(progress_get_status "01-neovim-essentials/01-modal-editing")"
    assert_equals "complete" "$status" "get_status should return 'complete'"
}

test_get_status_returns_in_progress() {
    progress_init
    progress_mark_in_progress "01-neovim-essentials/02-normal-mode"
    local status
    status="$(progress_get_status "01-neovim-essentials/02-normal-mode")"
    assert_equals "in-progress" "$status" "get_status should return 'in-progress'"
}

test_get_status_returns_empty_for_unknown() {
    progress_init
    local status
    status="$(progress_get_status "01-neovim-essentials/99-nonexistent")"
    assert_equals "" "$status" "get_status should return empty string for unknown lesson"
}

# ---------------------------------------------------------------------------
# Updating an existing entry
# ---------------------------------------------------------------------------

test_update_entry_from_in_progress_to_complete() {
    progress_init
    progress_mark_in_progress "01-neovim-essentials/01-modal-editing"
    progress_mark_complete   "01-neovim-essentials/01-modal-editing"

    # Only one line should exist
    local line_count
    line_count="$(wc -l < "$PROGRESS_FILE")"
    assert_equals "1" "$line_count" "update should replace the existing entry, not add a new one"

    local status
    status="$(progress_get_status "01-neovim-essentials/01-modal-editing")"
    assert_equals "complete" "$status" "status should be 'complete' after updating from in-progress"
}

# ---------------------------------------------------------------------------
# progress_reset
# ---------------------------------------------------------------------------

test_reset_removes_progress_file() {
    progress_init
    progress_mark_complete "01-neovim-essentials/01-modal-editing"
    progress_reset
    [[ ! -f "$PROGRESS_FILE" ]]
    assert_exit_code 0 $? "progress_reset should remove the progress file"
}

test_reset_does_not_error_when_file_absent() {
    # Don't call progress_init — file won't exist
    progress_reset
    assert_exit_code 0 $? "progress_reset should not error when file doesn't exist"
}

# ---------------------------------------------------------------------------
# progress_module_percent
# ---------------------------------------------------------------------------

test_module_percent_no_lessons_returns_0() {
    progress_init
    # Create a module dir with no .sh files
    local fake_module_dir="$TEST_PROGRESS_DIR/lessons/01-empty-module"
    mkdir -p "$fake_module_dir"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"
    local pct
    pct="$(progress_module_percent "01-empty-module")"
    assert_equals "0" "$pct" "module_percent should return 0 when there are no lesson files"
}

test_module_percent_all_complete_returns_100() {
    progress_init
    local fake_module_dir="$TEST_PROGRESS_DIR/lessons/01-test-module"
    mkdir -p "$fake_module_dir"
    touch "$fake_module_dir/01-lesson-a.sh"
    touch "$fake_module_dir/02-lesson-b.sh"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_mark_complete "01-test-module/01-lesson-a"
    progress_mark_complete "01-test-module/02-lesson-b"

    local pct
    pct="$(progress_module_percent "01-test-module")"
    assert_equals "100" "$pct" "module_percent should return 100 when all lessons complete"
}

test_module_percent_half_complete_returns_50() {
    progress_init
    local fake_module_dir="$TEST_PROGRESS_DIR/lessons/01-test-module"
    mkdir -p "$fake_module_dir"
    touch "$fake_module_dir/01-lesson-a.sh"
    touch "$fake_module_dir/02-lesson-b.sh"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_mark_complete "01-test-module/01-lesson-a"

    local pct
    pct="$(progress_module_percent "01-test-module")"
    assert_equals "50" "$pct" "module_percent should return 50 when half the lessons are complete"
}

test_module_percent_none_complete_returns_0() {
    progress_init
    local fake_module_dir="$TEST_PROGRESS_DIR/lessons/01-test-module"
    mkdir -p "$fake_module_dir"
    touch "$fake_module_dir/01-lesson-a.sh"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    local pct
    pct="$(progress_module_percent "01-test-module")"
    assert_equals "0" "$pct" "module_percent should return 0 when no lessons are complete"
}

# ---------------------------------------------------------------------------
# progress_module_unlocked
# ---------------------------------------------------------------------------

test_module_unlocked_first_module_always_unlocked() {
    progress_init
    local lessons_dir="$TEST_PROGRESS_DIR/lessons"
    mkdir -p "$lessons_dir/01-first-module"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_module_unlocked "01-first-module"
    assert_exit_code 0 $? "first module should always be unlocked"
}

test_module_unlocked_second_module_locked_at_zero_percent() {
    progress_init
    local lessons_dir="$TEST_PROGRESS_DIR/lessons"
    mkdir -p "$lessons_dir/01-first-module"
    mkdir -p "$lessons_dir/02-second-module"
    touch "$lessons_dir/01-first-module/01-lesson.sh"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    # No progress recorded — first module is at 0%
    progress_module_unlocked "02-second-module"
    assert_exit_code 1 $? "second module should be locked when first module is at 0%"
}

test_module_unlocked_second_module_unlocked_at_100_percent() {
    progress_init
    local lessons_dir="$TEST_PROGRESS_DIR/lessons"
    mkdir -p "$lessons_dir/01-first-module"
    mkdir -p "$lessons_dir/02-second-module"
    touch "$lessons_dir/01-first-module/01-lesson.sh"
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_mark_complete "01-first-module/01-lesson"

    progress_module_unlocked "02-second-module"
    assert_exit_code 0 $? "second module should be unlocked when first module is 100% complete"
}

test_module_unlocked_second_module_locked_below_80_percent() {
    progress_init
    local lessons_dir="$TEST_PROGRESS_DIR/lessons"
    mkdir -p "$lessons_dir/01-first-module"
    mkdir -p "$lessons_dir/02-second-module"
    # 5 lessons, only 3 complete = 60% < 80%
    local i
    for i in 01 02 03 04 05; do
        touch "$lessons_dir/01-first-module/${i}-lesson.sh"
    done
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_mark_complete "01-first-module/01-lesson"
    progress_mark_complete "01-first-module/02-lesson"
    progress_mark_complete "01-first-module/03-lesson"

    progress_module_unlocked "02-second-module"
    assert_exit_code 1 $? "second module should be locked when first module is at 60%"
}

test_module_unlocked_second_module_unlocked_at_80_percent() {
    progress_init
    local lessons_dir="$TEST_PROGRESS_DIR/lessons"
    mkdir -p "$lessons_dir/01-first-module"
    mkdir -p "$lessons_dir/02-second-module"
    # 5 lessons, 4 complete = 80%
    local i
    for i in 01 02 03 04 05; do
        touch "$lessons_dir/01-first-module/${i}-lesson.sh"
    done
    PROJECT_ROOT="$TEST_PROGRESS_DIR"

    progress_mark_complete "01-first-module/01-lesson"
    progress_mark_complete "01-first-module/02-lesson"
    progress_mark_complete "01-first-module/03-lesson"
    progress_mark_complete "01-first-module/04-lesson"

    progress_module_unlocked "02-second-module"
    assert_exit_code 0 $? "second module should be unlocked when first module is at 80%"
}
