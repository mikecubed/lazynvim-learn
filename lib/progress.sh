#!/usr/bin/env bash
# lib/progress.sh — Flat-file progress tracking for lazynvim-learn
#
# Progress is stored in ~/.lazynvim-learn/progress as one line per lesson:
#   module/lesson:status
# where status is one of: complete, in-progress

PROGRESS_DIR="${PROGRESS_DIR:-$HOME/.lazynvim-learn}"
PROGRESS_FILE="${PROGRESS_FILE:-$PROGRESS_DIR/progress}"

# ---------------------------------------------------------------------------
# progress_init
# Create PROGRESS_DIR and PROGRESS_FILE if they don't already exist.
# ---------------------------------------------------------------------------
progress_init() {
    mkdir -p "$PROGRESS_DIR"
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        touch "$PROGRESS_FILE"
    fi
}

# ---------------------------------------------------------------------------
# progress_mark_complete "module/lesson"
# Write or update the lesson entry to: module/lesson:complete
# ---------------------------------------------------------------------------
progress_mark_complete() {
    local key="$1"
    _progress_upsert "$key" "complete"
}

# ---------------------------------------------------------------------------
# progress_mark_in_progress "module/lesson"
# Write or update the lesson entry to: module/lesson:in-progress
# ---------------------------------------------------------------------------
progress_mark_in_progress() {
    local key="$1"
    _progress_upsert "$key" "in-progress"
}

# ---------------------------------------------------------------------------
# progress_is_complete "module/lesson"
# Return 0 if the lesson's status is "complete", 1 otherwise.
# ---------------------------------------------------------------------------
progress_is_complete() {
    local key="$1"
    local status
    status="$(_progress_read "$key")"
    [[ "$status" == "complete" ]]
}

# ---------------------------------------------------------------------------
# progress_get_status "module/lesson"
# Print the status string: complete, in-progress, or empty string.
# ---------------------------------------------------------------------------
progress_get_status() {
    local key="$1"
    _progress_read "$key"
}

# ---------------------------------------------------------------------------
# progress_module_percent "module"
# Count completed lessons / total lesson files in lessons/$module/.
# Print an integer 0-100.  Returns 0 if no lesson files exist.
# ---------------------------------------------------------------------------
progress_module_percent() {
    local module="$1"
    local lessons_dir

    # Resolve the lessons directory relative to PROJECT_ROOT if set,
    # otherwise fall back to a path relative to PROGRESS_DIR's parent
    # (useful in tests where PROJECT_ROOT is set explicitly).
    if [[ -n "${PROJECT_ROOT:-}" ]]; then
        lessons_dir="$PROJECT_ROOT/lessons/$module"
    else
        # Try to find lessons/ relative to the directory that contains lib/
        local lib_dir
        lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        lessons_dir="$lib_dir/../lessons/$module"
    fi

    # Count .sh files in the lessons module directory
    local total=0
    if [[ -d "$lessons_dir" ]]; then
        local count
        count="$(find "$lessons_dir" -maxdepth 1 -name '*.sh' -type f 2>/dev/null | wc -l)"
        total="${count// /}"   # trim whitespace from wc
    fi

    if [[ "$total" -eq 0 ]]; then
        echo "0"
        return 0
    fi

    # Count completed LESSON entries (module/lesson:complete) — not exercise
    # entries (module/lesson/exercise:complete) which have two slashes.
    local completed=0
    if [[ -f "$PROGRESS_FILE" ]]; then
        local line key
        while IFS= read -r line; do
            if [[ "$line" == "${module}/"*":complete" ]]; then
                key="${line%%:*}"
                # Only count if key has exactly one slash (lesson level)
                local stripped="${key//[!\/]/}"
                if [[ ${#stripped} -eq 1 ]]; then
                    completed=$((completed + 1))
                fi
            fi
        done < "$PROGRESS_FILE"
    fi

    # Integer percentage (rounds down)
    echo $(( completed * 100 / total ))
}

# ---------------------------------------------------------------------------
# progress_module_unlocked "module"
# Return 0 if the module is unlocked, 1 if locked.
# Module 01 (lexicographically first) is always unlocked.
# Subsequent modules require >= 80% completion of the previous module.
# ---------------------------------------------------------------------------
progress_module_unlocked() {
    local module="$1"
    local lessons_dir

    if [[ -n "${PROJECT_ROOT:-}" ]]; then
        lessons_dir="$PROJECT_ROOT/lessons"
    else
        local lib_dir
        lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        lessons_dir="$lib_dir/../lessons"
    fi

    # Gather sorted list of module directories
    local modules=()
    if [[ -d "$lessons_dir" ]]; then
        while IFS= read -r -d '' dir; do
            modules+=("$(basename "$dir")")
        done < <(find "$lessons_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
    fi

    # If no modules discovered, treat the queried module as the first → unlocked
    if [[ ${#modules[@]} -eq 0 ]]; then
        return 0
    fi

    # First module is always unlocked
    if [[ "${modules[0]}" == "$module" ]]; then
        return 0
    fi

    # Find the previous module
    local prev_module=""
    local i
    for (( i=1; i < ${#modules[@]}; i++ )); do
        if [[ "${modules[$i]}" == "$module" ]]; then
            prev_module="${modules[$((i-1))]}"
            break
        fi
    done

    # Module not found in list → treat as unlocked (future-proofing)
    if [[ -z "$prev_module" ]]; then
        return 0
    fi

    local pct
    pct="$(progress_module_percent "$prev_module")"
    [[ "$pct" -ge 80 ]]
}

# ---------------------------------------------------------------------------
# progress_reset
# Remove the progress file (does not remove the directory).
# ---------------------------------------------------------------------------
progress_reset() {
    rm -f "$PROGRESS_FILE"
}

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# _progress_upsert "key" "status"
# If a line beginning with "key:" exists, replace it; otherwise append.
_progress_upsert() {
    local key="$1"
    local status="$2"
    local new_line="${key}:${status}"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "$new_line" > "$PROGRESS_FILE"
        return
    fi

    local tmp
    tmp="$(mktemp)"

    local found=0
    local line
    while IFS= read -r line; do
        if [[ "$line" == "${key}:"* ]]; then
            echo "$new_line" >> "$tmp"
            found=1
        else
            echo "$line" >> "$tmp"
        fi
    done < "$PROGRESS_FILE"

    if [[ "$found" -eq 0 ]]; then
        echo "$new_line" >> "$tmp"
    fi

    mv "$tmp" "$PROGRESS_FILE"
}

# _progress_read "key"
# Print the status portion of the key's line, or empty string if not found.
_progress_read() {
    local key="$1"
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo ""
        return
    fi
    local line
    while IFS= read -r line; do
        if [[ "$line" == "${key}:"* ]]; then
            echo "${line#*:}"
            return
        fi
    done < "$PROGRESS_FILE"
    echo ""
}
