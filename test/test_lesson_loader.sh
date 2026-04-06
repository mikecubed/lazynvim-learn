#!/usr/bin/env bash
# Tests for lesson loader functionality in the entry point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

LAZYNVIM_LEARN_FAST=1

# Source libs before the entry point (entry point doesn't source them when sourced)
source "$SCRIPT_DIR/../lib/ui.sh"
source "$SCRIPT_DIR/../lib/nvim_helpers.sh"
source "$SCRIPT_DIR/../lib/sandbox.sh"
source "$SCRIPT_DIR/../lib/progress.sh"
source "$SCRIPT_DIR/../lib/verify.sh"
source "$SCRIPT_DIR/../lib/engine.sh"

# Source the entry point (guarded by BASH_SOURCE check, so main won't run)
source "$SCRIPT_DIR/../lazynvim-learn"
set +e

# Override sandbox for tests
sandbox_setup_exercise() { return 0; }
sandbox_kill() { return 0; }

# ---------------------------------------------------------------------------
# Setup / teardown for temp lesson structure
# ---------------------------------------------------------------------------
TEST_LESSONS_DIR=""

setup() {
    TEST_LESSONS_DIR=$(mktemp -d)
    PROJECT_ROOT="$TEST_LESSONS_DIR"
    mkdir -p "$TEST_LESSONS_DIR/lessons/01-test-module"
    mkdir -p "$TEST_LESSONS_DIR/lessons/02-second-module"

    # Create test lesson files
    cat > "$TEST_LESSONS_DIR/lessons/01-test-module/01-first-lesson.sh" << 'LESSON'
lesson_info() {
    LESSON_TITLE="First Lesson"
    LESSON_MODULE="01-test-module"
    LESSON_DESCRIPTION="A test lesson."
    LESSON_TIME="5 minutes"
}
lesson_run() {
    engine_section "Test Section"
    engine_teach "This is a test."
}
LESSON

    cat > "$TEST_LESSONS_DIR/lessons/01-test-module/02-second-lesson.sh" << 'LESSON'
lesson_info() {
    LESSON_TITLE="Second Lesson"
    LESSON_MODULE="01-test-module"
    LESSON_DESCRIPTION="Another test."
    LESSON_TIME="3 minutes"
}
lesson_run() {
    engine_teach "Second lesson content."
}
LESSON

    # Override progress dir
    PROGRESS_DIR=$(mktemp -d)
    PROGRESS_FILE="$PROGRESS_DIR/progress"
    progress_init
}

teardown() {
    rm -rf "$TEST_LESSONS_DIR"
    rm -rf "$PROGRESS_DIR"
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_discover_modules_finds_modules() {
    setup
    local modules
    modules=$(discover_modules)
    assert_contains "$modules" "01-test-module"
    assert_contains "$modules" "02-second-module"
    teardown
}

test_discover_modules_sorted() {
    setup
    local first
    first=$(discover_modules | head -1)
    assert_equals "01-test-module" "$first"
    teardown
}

test_discover_lessons_finds_lessons() {
    setup
    local lessons
    lessons=$(discover_lessons "01-test-module")
    assert_contains "$lessons" "01-first-lesson"
    assert_contains "$lessons" "02-second-lesson"
    teardown
}

test_discover_lessons_sorted() {
    setup
    local first
    first=$(discover_lessons "01-test-module" | head -1)
    assert_equals "01-first-lesson" "$first"
    teardown
}

test_discover_lessons_empty_for_nonexistent_module() {
    setup
    local lessons
    lessons=$(discover_lessons "99-nonexistent")
    assert_equals "" "$lessons"
    teardown
}

test_run_lesson_sets_current_lesson() {
    setup
    run_lesson "01-test-module" "01-first-lesson" > /dev/null 2>&1
    assert_equals "01-test-module/01-first-lesson" "$CURRENT_LESSON"
    teardown
}

test_run_lesson_calls_lesson_info() {
    setup
    run_lesson "01-test-module" "01-first-lesson" > /dev/null 2>&1
    assert_equals "First Lesson" "$LESSON_TITLE"
    teardown
}

test_run_lesson_marks_progress() {
    setup
    run_lesson "01-test-module" "01-first-lesson" > /dev/null 2>&1
    local status
    status=$(progress_get_status "01-test-module/01-first-lesson")
    assert_equals "complete" "$status"
    teardown
}

test_run_lesson_error_for_missing_file() {
    setup
    run_lesson "01-test-module" "99-nonexistent" 2>/dev/null
    local rc=$?
    assert_equals "1" "$rc" "should return 1 for missing lesson"
    teardown
}

test_find_last_in_progress_empty_when_none() {
    setup
    local last
    last=$(find_last_in_progress)
    assert_equals "" "$last"
    teardown
}

test_find_last_in_progress_finds_entry() {
    setup
    progress_mark_in_progress "01-test-module/01-first-lesson"
    local last
    last=$(find_last_in_progress)
    assert_equals "01-test-module/01-first-lesson" "$last"
    teardown
}

test_run_lesson_produces_output() {
    setup
    local output
    output=$(run_lesson "01-test-module" "01-first-lesson" 2>/dev/null)
    assert_contains "$output" "Test Section"
    teardown
}
