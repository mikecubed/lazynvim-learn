#!/usr/bin/env bash
# test/run-lesson.sh — E2E smoke-test harness for lazynvim-learn lessons.
#
# Runs lesson files non-interactively by stubbing out all Neovim, sandbox,
# and UI I/O functions, then calling lesson_info() and lesson_run().
#
# Usage:
#   ./test/run-lesson.sh                              # run all lessons
#   ./test/run-lesson.sh --all                        # run all lessons
#   ./test/run-lesson.sh lessons/01-neovim-essentials/01-modal-editing.sh

set -uo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------

_C_GREEN=$'\033[0;32m'
_C_RED=$'\033[0;31m'
_C_YELLOW=$'\033[0;33m'
_C_DIM=$'\033[2m'
_C_RESET=$'\033[0m'

# ---------------------------------------------------------------------------
# Skip delays and typewriter effects
# ---------------------------------------------------------------------------

export LAZYNVIM_LEARN_FAST=1
export LAZYNVIM_LEARN_WIDTH=80   # fixed width so ui_term_width never calls tmux

# ---------------------------------------------------------------------------
# Isolate progress tracking to a temp directory
# ---------------------------------------------------------------------------

_E2E_TMPDIR="$(mktemp -d)"
export PROGRESS_DIR="$_E2E_TMPDIR/progress-dir"
export PROGRESS_FILE="$_E2E_TMPDIR/progress-dir/progress"
mkdir -p "$PROGRESS_DIR"
touch "$PROGRESS_FILE"

cleanup() {
    rm -rf "$_E2E_TMPDIR"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Source all libs
# ---------------------------------------------------------------------------

source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/nvim_helpers.sh"
source "$PROJECT_ROOT/lib/sandbox.sh"
source "$PROJECT_ROOT/lib/progress.sh"
source "$PROJECT_ROOT/lib/verify.sh"
source "$PROJECT_ROOT/lib/engine.sh"

# ---------------------------------------------------------------------------
# Stub: Neovim RPC — no socket needed
# ---------------------------------------------------------------------------

nvim_eval()       { printf '0\n'; return 0; }
nvim_lua()        { printf 'true\n'; return 0; }
nvim_exec()       { return 0; }
nvim_send_keys()  { return 0; }
nvim_is_running() { return 1; }    # not alive — exercises skip RPC waits
nvim_wait_ready() { return 0; }

# ---------------------------------------------------------------------------
# Stub: sandbox — no tmux needed
# ---------------------------------------------------------------------------

sandbox_launch()          { return 0; }
sandbox_kill()            { return 0; }
sandbox_reset()           { return 0; }
sandbox_open_file()       { return 0; }
sandbox_is_alive()        { return 1; }   # treat as not alive
sandbox_setup_exercise()  { return 0; }

# ---------------------------------------------------------------------------
# Stub: progress — use the temp file (already redirected via env vars)
# The real functions work fine once PROGRESS_DIR/PROGRESS_FILE are redirected.
# ---------------------------------------------------------------------------

# Confirm the overriding env vars are picked up (progress.sh re-reads them).
PROGRESS_DIR="$_E2E_TMPDIR/progress-dir"
PROGRESS_FILE="$_E2E_TMPDIR/progress-dir/progress"

# ---------------------------------------------------------------------------
# Stub: all verify_* functions → auto-pass
# ---------------------------------------------------------------------------

# Build a list of every verify_* function defined in verify.sh and override
# each one to auto-pass so exercises don't fail on missing Neovim state.

_stub_verify_functions() {
    local func
    # Collect function names from the verify library that we've sourced
    while IFS= read -r func; do
        if [[ "$func" == verify_* ]]; then
            # Define a pass-through override
            eval "${func}() { VERIFY_MESSAGE='auto-pass'; VERIFY_HINT=''; return 0; }"
        fi
    done < <(declare -F | awk '{print $3}')
}
_stub_verify_functions

# Also stub verify_reset so it stays a no-op (it only clears globals, safe either way)
verify_reset() {
    VERIFY_MESSAGE=""
    VERIFY_HINT=""
}

# ---------------------------------------------------------------------------
# Stub: ui_prompt — don't block waiting for Enter
# ---------------------------------------------------------------------------

ui_prompt() { return 0; }

# ---------------------------------------------------------------------------
# Override engine_quiz — auto-skip, no tty read
# ---------------------------------------------------------------------------

engine_quiz() {
    # Just display a notice and return; don't wait for input.
    printf '%s[quiz skipped in auto-test]%s\n' "$_C_DIM" "$_C_RESET"
    return 0
}

# ---------------------------------------------------------------------------
# Override engine_exercise — mark complete immediately, no tty read
# ---------------------------------------------------------------------------

engine_exercise() {
    local id="${1:-}"
    local title="${2:-}"
    # remaining args: instructions, verify_func, hint, sandbox_type, sandbox_args...

    CURRENT_EXERCISE="$id"

    # Display the exercise header so any print-side effects run cleanly
    ui_subheader "$title"
    printf '%s[exercise skipped in auto-test]%s\n' "$_C_DIM" "$_C_RESET"

    # Mark complete so progress calls inside lesson_run don't error
    if [[ -n "${CURRENT_LESSON:-}" && -n "$id" ]]; then
        progress_mark_complete "${CURRENT_LESSON}/${id}" 2>/dev/null || true
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Lesson runner
# ---------------------------------------------------------------------------

# run_lesson <lesson_file>
# Sources the lesson file, calls lesson_info() + lesson_run(), captures exit
# code. Returns 0 on pass, 1 on fail.
run_lesson() {
    local lesson_file="$1"

    # Resolve a short label like "01-neovim-essentials/01-modal-editing"
    local label
    label="${lesson_file#"$PROJECT_ROOT/lessons/"}"
    label="${label%.sh}"

    # Derive CURRENT_LESSON from the label (module/lesson)
    # e.g. "01-neovim-essentials/01-modal-editing"
    local module lesson_name
    module="$(dirname "$label")"
    lesson_name="$(basename "$label")"
    export CURRENT_LESSON="${module}/${lesson_name}"

    # Clear lesson globals before each run
    unset LESSON_TITLE LESSON_MODULE LESSON_DESCRIPTION LESSON_TIME
    unset -f lesson_info lesson_run 2>/dev/null || true

    # Capture stderr; stdout flows to /dev/null (we don't need lesson output)
    local err_file
    err_file="$(mktemp "$_E2E_TMPDIR/stderr-XXXXXX")"

    (
        # Run in a subshell so sourced globals don't leak between lessons
        source "$lesson_file"
        lesson_info
        lesson_run
    ) >/dev/null 2>"$err_file"

    local rc=$?
    local stderr_content
    stderr_content="$(< "$err_file")"
    rm -f "$err_file"

    if [[ $rc -eq 0 ]]; then
        printf '  %sPASS%s  %s\n' "$_C_GREEN" "$_C_RESET" "$label"
        return 0
    else
        printf '  %sFAIL%s  %s  %s(exit code %d)%s\n' \
            "$_C_RED" "$_C_RESET" "$label" "$_C_DIM" "$rc" "$_C_RESET"
        if [[ -n "$stderr_content" ]]; then
            # Indent stderr lines for readability
            while IFS= read -r line; do
                printf '         %s%s%s\n' "$_C_DIM" "$line" "$_C_RESET"
            done <<< "$stderr_content"
        fi
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Lesson discovery
# ---------------------------------------------------------------------------

find_all_lessons() {
    local lessons=()
    while IFS= read -r -d '' f; do
        lessons+=("$f")
    done < <(find "$PROJECT_ROOT/lessons" -name '*.sh' -type f -print0 2>/dev/null | sort -z)
    printf '%s\n' "${lessons[@]}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    local lesson_files=()

    if [[ $# -eq 0 || "${1:-}" == "--all" ]]; then
        while IFS= read -r f; do
            [[ -n "$f" ]] && lesson_files+=("$f")
        done < <(find_all_lessons)
    else
        for arg in "$@"; do
            # Accept both absolute paths and paths relative to PROJECT_ROOT
            if [[ -f "$arg" ]]; then
                lesson_files+=("$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")")
            elif [[ -f "$PROJECT_ROOT/$arg" ]]; then
                lesson_files+=("$PROJECT_ROOT/$arg")
            else
                printf '%sERROR%s: lesson file not found: %s\n' \
                    "$_C_RED" "$_C_RESET" "$arg" >&2
                exit 2
            fi
        done
    fi

    if [[ ${#lesson_files[@]} -eq 0 ]]; then
        printf '%sNo lesson files found.%s\n' "$_C_YELLOW" "$_C_RESET"
        exit 0
    fi

    printf 'Testing lessons...\n'

    local passed=0 failed=0 total=${#lesson_files[@]}

    for f in "${lesson_files[@]}"; do
        if run_lesson "$f"; then
            passed=$(( passed + 1 ))
        else
            failed=$(( failed + 1 ))
        fi
    done

    printf '\nResults: %d/%d passed' "$passed" "$total"
    if [[ $failed -gt 0 ]]; then
        printf ', %s%d failed%s' "$_C_RED" "$failed" "$_C_RESET"
    fi
    printf '\n'

    [[ $failed -eq 0 ]]
}

main "$@"
