#!/usr/bin/env bash
# Lightweight bash test runner
# Usage: ./test/test_runner.sh [test_file.sh ...]
# If no files given, runs all test/test_*.sh files

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Guard counter initialization against re-sourcing
if [[ -z "${_TEST_RUNNER_LOADED:-}" ]]; then
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    FAILURES=()
    _TEST_RUNNER_LOADED=1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# --- Assertion functions ---

assert_equals() {
    local expected="$1" actual="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="expected '$expected', got '$actual'"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1" actual="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$unexpected" != "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="did not expect '$unexpected'"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="'$haystack' does not contain '$needle'"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$haystack" != *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="'$haystack' should not contain '$needle'"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_exit_code() {
    local expected="$1" actual="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$expected" -eq "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="expected exit code $expected, got $actual"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_true() {
    local msg="${1:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
}

assert_file_exists() {
    local path="$1" msg="${2:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -f "$path" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="file '$path' does not exist"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

assert_matches() {
    local string="$1" pattern="$2" msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$string" =~ $pattern ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        local detail="'$string' does not match pattern '$pattern'"
        [[ -n "$msg" ]] && detail="$msg: $detail"
        FAILURES+=("  FAIL: $detail (${BASH_SOURCE[1]}:${BASH_LINENO[0]})")
        return 1
    fi
}

# --- Test discovery and running ---

run_test_func() {
    local func_name="$1"
    local test_label="${func_name#test_}"
    local before_failed=$TESTS_FAILED

    # Run setup if defined
    if declare -f setup &>/dev/null; then
        setup
    fi

    # Run the test
    "$func_name"
    local result=$?

    # Run teardown if defined
    if declare -f teardown &>/dev/null; then
        teardown
    fi

    if [[ $TESTS_FAILED -gt $before_failed ]]; then
        printf "  ${RED}x${RESET} %s\n" "$test_label"
    else
        printf "  ${GREEN}✓${RESET} %s\n" "$test_label"
    fi
}

run_test_file() {
    local file="$1"
    local file_label
    file_label="$(basename "$file" .sh)"

    printf "\n${YELLOW}%s${RESET}\n" "$file_label"

    # Source the test file in a subshell-like environment
    # but we need shared counters, so source directly
    source "$file"

    # Find and run all test_ functions
    local funcs
    funcs=$(declare -F | awk '{print $3}' | grep '^test_' | sort)

    for func in $funcs; do
        run_test_func "$func"
    done

    # Unset test functions to avoid contamination between files
    for func in $funcs; do
        unset -f "$func" 2>/dev/null
    done
    unset -f setup teardown 2>/dev/null
}

# --- Main ---

main() {
    local test_files=()

    if [[ $# -gt 0 ]]; then
        test_files=("$@")
    else
        while IFS= read -r -d '' f; do
            test_files+=("$f")
        done < <(find "$SCRIPT_DIR" -name 'test_*.sh' -print0 | sort -z)
    fi

    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo "No test files found."
        exit 0
    fi

    printf "${YELLOW}Running tests...${RESET}\n"

    for file in "${test_files[@]}"; do
        run_test_file "$file"
    done

    # Summary
    printf "\n---\n"
    if [[ $TESTS_FAILED -eq 0 ]]; then
        printf "${GREEN}All %d tests passed${RESET}\n" "$TESTS_RUN"
    else
        printf "${RED}%d of %d tests failed${RESET}\n" "$TESTS_FAILED" "$TESTS_RUN"
        printf "\nFailures:\n"
        for f in "${FAILURES[@]}"; do
            printf "${RED}%s${RESET}\n" "$f"
        done
    fi

    [[ $TESTS_FAILED -eq 0 ]]
}

# Only run main if this script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
