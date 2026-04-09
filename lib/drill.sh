#!/usr/bin/env bash
# lib/drill.sh — Scoring infrastructure for the Drills feature
#
# Provides timing, counters, score persistence, and scorecard display for
# repeatable drill sessions. Scores are stored in ~/.lazynvim-learn/drill-scores
# as one line per completed run.
#
# Format: drill_name:mode:timestamp:total_secs:first_try_count:hints:skips:clean:splits
#
# This file is sourced AFTER all other libs (ui.sh, nvim_helpers.sh, etc.)
# and should not source anything itself.

# Guard against double-sourcing
[[ -n "${_LAZYNVIM_DRILL_SH:-}" ]] && return 0
_LAZYNVIM_DRILL_SH=1

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------

PROGRESS_DIR="${PROGRESS_DIR:-$HOME/.lazynvim-learn}"

DRILL_MODE="normal"
DRILL_SETTINGS_FILE="$PROGRESS_DIR/drill-settings"
DRILL_SCORES_FILE="$PROGRESS_DIR/drill-scores"

DRILL_START_TIME=0
DRILL_EXERCISE_START=0
DRILL_SPLITS=()

DRILL_FIRST_TRY_COUNT=0
DRILL_HINT_COUNT=0
DRILL_SKIP_COUNT=0
DRILL_EXERCISE_ATTEMPTS=0

# ---------------------------------------------------------------------------
# Mode management
# ---------------------------------------------------------------------------

# drill_load_mode
# Read the drill mode from the settings file. Defaults to "normal" if the
# file is missing or contains an unrecognised value.
drill_load_mode() {
    DRILL_MODE="normal"
    if [[ -f "$DRILL_SETTINGS_FILE" ]]; then
        local stored
        stored="$(cat "$DRILL_SETTINGS_FILE" 2>/dev/null)"
        if [[ "$stored" == "hard" ]]; then
            DRILL_MODE="hard"
        fi
    fi
}

# drill_toggle_mode
# Switch between "normal" and "hard" and persist the choice.
drill_toggle_mode() {
    if [[ "$DRILL_MODE" == "hard" ]]; then
        DRILL_MODE="normal"
    else
        DRILL_MODE="hard"
    fi
    mkdir -p "$PROGRESS_DIR"
    printf '%s\n' "$DRILL_MODE" > "$DRILL_SETTINGS_FILE"
}

# drill_is_hard_mode
# Return 0 if hard mode is active, 1 otherwise.
drill_is_hard_mode() {
    [[ "$DRILL_MODE" == "hard" ]]
}

# ---------------------------------------------------------------------------
# Timer
# ---------------------------------------------------------------------------

# drill_start_timer
# Record the start time for the entire drill run.
drill_start_timer() {
    DRILL_START_TIME=$(date +%s)
}

# drill_start_exercise_timer
# Record the start time for the current exercise.
drill_start_exercise_timer() {
    DRILL_EXERCISE_START=$(date +%s)
}

# drill_stop_exercise_timer
# Compute elapsed seconds for the current exercise and append to DRILL_SPLITS.
drill_stop_exercise_timer() {
    local now
    now=$(date +%s)
    local elapsed=$(( now - DRILL_EXERCISE_START ))
    DRILL_SPLITS+=("$elapsed")
}

# drill_elapsed
# Print the total elapsed seconds since drill_start_timer was called.
drill_elapsed() {
    local now
    now=$(date +%s)
    printf '%d' $(( now - DRILL_START_TIME ))
}

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------

# drill_reset_counters
# Zero all counters and clear the splits array. Call at the start of a drill.
drill_reset_counters() {
    DRILL_FIRST_TRY_COUNT=0
    DRILL_HINT_COUNT=0
    DRILL_SKIP_COUNT=0
    DRILL_EXERCISE_ATTEMPTS=0
    DRILL_SPLITS=()
}

# drill_record_pass
# If this is the first check attempt on the current exercise, count it as
# a first-try pass.
drill_record_pass() {
    if [[ "$DRILL_EXERCISE_ATTEMPTS" -eq 0 ]]; then
        DRILL_FIRST_TRY_COUNT=$(( DRILL_FIRST_TRY_COUNT + 1 ))
    fi
}

# drill_record_fail
# Increment the attempt counter for the current exercise.
drill_record_fail() {
    DRILL_EXERCISE_ATTEMPTS=$(( DRILL_EXERCISE_ATTEMPTS + 1 ))
}

# drill_record_hint
# Increment the hint counter.
drill_record_hint() {
    DRILL_HINT_COUNT=$(( DRILL_HINT_COUNT + 1 ))
}

# drill_record_skip
# Increment the skip counter.
drill_record_skip() {
    DRILL_SKIP_COUNT=$(( DRILL_SKIP_COUNT + 1 ))
}

# drill_reset_exercise
# Reset the per-exercise attempt counter (call before each new exercise).
drill_reset_exercise() {
    DRILL_EXERCISE_ATTEMPTS=0
}

# ---------------------------------------------------------------------------
# Score storage
# ---------------------------------------------------------------------------

# drill_save_score "drill_name" exercise_count
# Compute the clean flag and append one score line to the scores file.
drill_save_score() {
    local drill_name="$1"
    local exercise_count="$2"

    local total_secs
    total_secs=$(drill_elapsed)

    # Clean run: all first-try, no hints, no skips
    local clean=0
    if [[ "$DRILL_FIRST_TRY_COUNT" -eq "$exercise_count" \
       && "$DRILL_HINT_COUNT" -eq 0 \
       && "$DRILL_SKIP_COUNT" -eq 0 ]]; then
        clean=1
    fi

    # Build comma-separated splits string
    local splits_str=""
    local i
    for (( i=0; i < ${#DRILL_SPLITS[@]}; i++ )); do
        if [[ "$i" -gt 0 ]]; then
            splits_str+=","
        fi
        splits_str+="${DRILL_SPLITS[$i]}"
    done

    local timestamp
    timestamp=$(date +%s)

    mkdir -p "$PROGRESS_DIR"
    printf '%s:%s:%s:%s:%s:%s:%s:%s:%s\n' \
        "$drill_name" \
        "$DRILL_MODE" \
        "$timestamp" \
        "$total_secs" \
        "$DRILL_FIRST_TRY_COUNT" \
        "$DRILL_HINT_COUNT" \
        "$DRILL_SKIP_COUNT" \
        "$clean" \
        "$splits_str" \
        >> "$DRILL_SCORES_FILE"
}

# drill_best_time "drill_name"
# Print the lowest total_secs across all modes for this drill, or empty
# string if there are no recorded runs.
drill_best_time() {
    local drill_name="$1"
    _drill_best_time_filter "$drill_name" ""
}

# drill_best_time_mode "drill_name" "mode"
# Print the lowest total_secs for this drill filtered by mode.
drill_best_time_mode() {
    local drill_name="$1"
    local mode="$2"
    _drill_best_time_filter "$drill_name" "$mode"
}

# drill_has_clean_run "drill_name"
# Return 0 if any recorded run for this drill has clean==1.
drill_has_clean_run() {
    local drill_name="$1"
    if [[ ! -f "$DRILL_SCORES_FILE" ]]; then
        return 1
    fi
    local line
    while IFS= read -r line; do
        local dn
        dn="${line%%:*}"
        if [[ "$dn" == "$drill_name" ]]; then
            # Field 8 (0-indexed: 7) is the clean flag
            local clean
            clean=$(_drill_field "$line" 7)
            if [[ "$clean" == "1" ]]; then
                return 0
            fi
        fi
    done < "$DRILL_SCORES_FILE"
    return 1
}

# ---------------------------------------------------------------------------
# Scorecard display
# ---------------------------------------------------------------------------

# drill_show_scorecard "drill_name" exercise_count
# Save the score and display the end-of-drill scorecard.
drill_show_scorecard() {
    local drill_name="$1"
    local exercise_count="$2"

    # Save score BEFORE displaying
    drill_save_score "$drill_name" "$exercise_count"

    local total_secs
    total_secs=$(drill_elapsed)

    local clean=0
    if [[ "$DRILL_FIRST_TRY_COUNT" -eq "$exercise_count" \
       && "$DRILL_HINT_COUNT" -eq 0 \
       && "$DRILL_SKIP_COUNT" -eq 0 ]]; then
        clean=1
    fi

    # Format drill name for display: "01-quick-refresher" → "Quick Refresher"
    local display_name
    display_name=$(_drill_display_name "$drill_name")

    # Format times
    local time_str
    time_str=$(_drill_format_time "$total_secs")

    # Look up best time (across all modes, excluding the run we just saved
    # which may itself be the best)
    local best_secs best_mode best_str
    best_str=""
    _drill_find_best "$drill_name" best_secs best_mode
    if [[ -n "$best_secs" ]]; then
        local best_mode_label
        if [[ "$best_mode" == "hard" ]]; then
            best_mode_label="Hard"
        else
            best_mode_label="Normal"
        fi
        best_str="$(_drill_format_time "$best_secs") (${best_mode_label})"
    else
        best_str="--"
    fi

    # Mode label
    local mode_label
    if [[ "$DRILL_MODE" == "hard" ]]; then
        mode_label="Hard"
    else
        mode_label="Normal"
    fi

    # Clean run display
    local clean_val
    if [[ "$clean" -eq 1 ]]; then
        clean_val="${COLOR_GREEN}Yes${COLOR_RESET}"
    else
        clean_val="${COLOR_YELLOW}No${COLOR_RESET}"
    fi

    # Fixed inner width of 39 characters
    local W=39

    # Build scorecard
    printf '\n'
    _drill_box_top "$W"
    _drill_box_line "$W" "  ${COLOR_BOLD}${display_name} Drill — Complete!${COLOR_RESET}"
    _drill_box_empty "$W"
    _drill_box_line "$W" "  Mode:       ${mode_label}"
    _drill_box_line "$W" "  Time:       ${time_str}"
    _drill_box_line "$W" "  Best time:  ${best_str}"
    _drill_box_line "$W" "  Exercises:  ${exercise_count}/${exercise_count} passed"
    _drill_box_line "$W" "  First-try:  ${DRILL_FIRST_TRY_COUNT}/${exercise_count}"
    _drill_box_line "$W" "  Hints used: ${DRILL_HINT_COUNT}"
    _drill_box_line "$W" "  Skips:      ${DRILL_SKIP_COUNT}"
    _drill_box_line "$W" "  ★ Clean run: ${clean_val}"
    _drill_box_empty "$W"

    # Splits section
    if [[ ${#DRILL_SPLITS[@]} -gt 0 ]]; then
        _drill_box_line "$W" "  Splits:"

        local split_line=""
        local count=0
        local i
        for (( i=0; i < ${#DRILL_SPLITS[@]}; i++ )); do
            local idx=$(( i + 1 ))
            local secs="${DRILL_SPLITS[$i]}"
            local mins=$(( secs / 60 ))
            local remainder=$(( secs % 60 ))
            local entry
            entry=$(printf '%d: %d:%02d' "$idx" "$mins" "$remainder")

            if [[ "$count" -gt 0 ]]; then
                split_line+="  "
            fi
            split_line+="$entry"
            count=$(( count + 1 ))

            if [[ "$count" -eq 4 || "$i" -eq $(( ${#DRILL_SPLITS[@]} - 1 )) ]]; then
                _drill_box_line "$W" "  ${split_line}"
                split_line=""
                count=0
            fi
        done
    fi

    _drill_box_bottom "$W"
    printf '\n'
}

# ---------------------------------------------------------------------------
# Reference pane
# ---------------------------------------------------------------------------

# drill_show_reference "text"
# In normal mode, open a floating reference window in Neovim via the
# companion plugin. Text uses literal \n for line breaks.
drill_show_reference() {
    local text="$1"
    if ! drill_is_hard_mode; then
        # Write reference text to a temp file, then have Neovim read it.
        # This avoids all quoting issues with single/double quotes in the text.
        local ref_file="/tmp/lazynvim-learn-ref-$$.txt"
        printf '%b\n' "$text" > "$ref_file"
        nvim_exec "lua require('lazynvim-learn.reference').show_file('${ref_file}')"
    fi
}

# drill_hide_reference
# Close the reference window in Neovim.
drill_hide_reference() {
    nvim_exec "lua require('lazynvim-learn.reference').hide()"
    rm -f "/tmp/lazynvim-learn-ref-$$.txt" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# _drill_field "line" field_index
# Extract a colon-delimited field by 0-based index. Field 8 (splits) may
# itself contain commas but no colons, so simple IFS splitting works.
_drill_field() {
    local line="$1"
    local idx="$2"
    local IFS=':'
    local fields
    read -ra fields <<< "$line"
    printf '%s' "${fields[$idx]:-}"
}

# _drill_best_time_filter "drill_name" "mode"
# Print the lowest total_secs for matching entries. If mode is empty, match
# all modes. Prints empty string if no matches.
_drill_best_time_filter() {
    local drill_name="$1"
    local mode_filter="$2"
    if [[ ! -f "$DRILL_SCORES_FILE" ]]; then
        printf ''
        return
    fi
    local best=""
    local line
    while IFS= read -r line; do
        local dn
        dn=$(_drill_field "$line" 0)
        if [[ "$dn" != "$drill_name" ]]; then
            continue
        fi
        if [[ -n "$mode_filter" ]]; then
            local m
            m=$(_drill_field "$line" 1)
            if [[ "$m" != "$mode_filter" ]]; then
                continue
            fi
        fi
        local secs
        secs=$(_drill_field "$line" 3)
        if [[ -z "$best" || "$secs" -lt "$best" ]]; then
            best="$secs"
        fi
    done < "$DRILL_SCORES_FILE"
    printf '%s' "$best"
}

# _drill_find_best "drill_name" var_secs var_mode
# Find the overall best time and its mode, storing results in the named
# variables via nameref.
_drill_find_best() {
    local drill_name="$1"
    local -n _out_secs="$2"
    local -n _out_mode="$3"
    _out_secs=""
    _out_mode=""
    if [[ ! -f "$DRILL_SCORES_FILE" ]]; then
        return
    fi
    local line
    while IFS= read -r line; do
        local dn
        dn=$(_drill_field "$line" 0)
        if [[ "$dn" != "$drill_name" ]]; then
            continue
        fi
        local secs mode
        secs=$(_drill_field "$line" 3)
        mode=$(_drill_field "$line" 1)
        if [[ -z "$_out_secs" || "$secs" -lt "$_out_secs" ]]; then
            _out_secs="$secs"
            _out_mode="$mode"
        fi
    done < "$DRILL_SCORES_FILE"
}

# _drill_format_time seconds
# Print a human-friendly time string like "3m 42s".
_drill_format_time() {
    local secs="$1"
    local mins=$(( secs / 60 ))
    local remainder=$(( secs % 60 ))
    if [[ "$mins" -gt 0 ]]; then
        printf '%dm %ds' "$mins" "$remainder"
    else
        printf '%ds' "$remainder"
    fi
}

# _drill_display_name "drill_name"
# Convert "01-quick-refresher" to "Quick Refresher" by stripping the leading
# number prefix and capitalising each word.
_drill_display_name() {
    local raw="$1"
    # Strip leading digits and dash: "01-quick-refresher" → "quick-refresher"
    local stripped="${raw#[0-9]*-}"
    # Replace dashes with spaces
    stripped="${stripped//-/ }"
    # Capitalise each word
    local result=""
    local word
    for word in $stripped; do
        local first="${word:0:1}"
        local rest="${word:1}"
        first="${first^^}"
        result+="${first}${rest} "
    done
    # Trim trailing space
    result="${result% }"
    printf '%s' "$result"
}

# _drill_box_top width
# Print the top border of a box.
_drill_box_top() {
    local w="$1"
    printf '┌'
    printf '─%.0s' $(seq 1 "$w")
    printf '┐\n'
}

# _drill_box_bottom width
# Print the bottom border of a box.
_drill_box_bottom() {
    local w="$1"
    printf '└'
    printf '─%.0s' $(seq 1 "$w")
    printf '┘\n'
}

# _drill_box_empty width
# Print an empty line inside the box.
_drill_box_empty() {
    local w="$1"
    printf '│'
    printf '%*s' "$w" ''
    printf '│\n'
}

# _drill_box_line width "content"
# Print a content line padded to the box width. ANSI escape sequences are
# stripped when computing visible length so padding is correct.
_drill_box_line() {
    local w="$1"
    local content="$2"
    # Compute visible length by stripping ANSI escapes
    local stripped
    stripped=$(printf '%s' "$content" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#stripped}
    local pad=$(( w - visible_len ))
    if [[ "$pad" -lt 0 ]]; then
        pad=0
    fi
    printf '│%s%*s│\n' "$content" "$pad" ''
}
