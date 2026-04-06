#!/usr/bin/env bash
# lib/ui.sh — ANSI terminal UI primitives for lazynvim-learn
# Requires bash 4.0+. No external dependencies beyond standard coreutils.

# Guard against double-sourcing
[[ -n "${_LAZYNVIM_UI_SH:-}" ]] && return 0
_LAZYNVIM_UI_SH=1

# ---------------------------------------------------------------------------
# ANSI color constants  (\033[ sequences — not tput — for consistency)
# ---------------------------------------------------------------------------

COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_CYAN=$'\033[0;36m'
COLOR_BOLD=$'\033[1m'
COLOR_DIM=$'\033[2m'
COLOR_RESET=$'\033[0m'

# ---------------------------------------------------------------------------
# ui_term_width — return the current terminal/pane column count
#   Priority: LAZYNVIM_LEARN_WIDTH env var (tests) → tmux → tput → 80
# ---------------------------------------------------------------------------

ui_term_width() {
    if [[ -n "${LAZYNVIM_LEARN_WIDTH:-}" ]]; then
        printf '%s' "$LAZYNVIM_LEARN_WIDTH"
        return
    fi

    local w=0
    if [[ -n "${TMUX:-}" ]]; then
        w="$(tmux display-message -p '#{pane_width}' 2>/dev/null || true)"
    fi

    if [[ -z "$w" || "$w" -lt 1 ]] 2>/dev/null; then
        w="$(tput cols 2>/dev/null || true)"
    fi

    if [[ -z "$w" || "$w" -lt 1 ]] 2>/dev/null; then
        w=80
    fi

    printf '%s' "$w"
}

# ---------------------------------------------------------------------------
# ui_clear — clear the terminal pane
# ---------------------------------------------------------------------------

ui_clear() {
    printf '\033[H\033[2J'
}

# ---------------------------------------------------------------------------
# ui_print "Text" — print text followed by a newline
# ---------------------------------------------------------------------------

ui_print() {
    printf '%s\n' "${1:-}"
}

# ---------------------------------------------------------------------------
# ui_print_wrapped "Text" — word-wrap text at ui_term_width columns
# ---------------------------------------------------------------------------

ui_print_wrapped() {
    local text="${1:-}"
    local width
    width="$(ui_term_width)"

    # Split input into words and build lines
    local line="" word
    for word in $text; do
        if [[ -z "$line" ]]; then
            line="$word"
        elif [[ $(( ${#line} + 1 + ${#word} )) -le $width ]]; then
            line="$line $word"
        else
            printf '%s\n' "$line"
            line="$word"
        fi
    done
    # Print any remaining text
    [[ -n "$line" ]] && printf '%s\n' "$line"
}

# ---------------------------------------------------------------------------
# ui_typewriter "Text" [delay_seconds]
#   Prints text character by character.
#   Honors LAZYNVIM_LEARN_FAST=1 to skip delays (for tests / CI).
# ---------------------------------------------------------------------------

ui_typewriter() {
    local text="${1:-}"
    local delay="${2:-0.03}"

    if [[ "${LAZYNVIM_LEARN_FAST:-0}" == "1" ]]; then
        printf '%s\n' "$text"
        return
    fi

    # Print character by character. If the user presses Enter (or any key),
    # dump the remaining text instantly.
    local i char
    for (( i=0; i<${#text}; i++ )); do
        # Check if input is available (non-blocking read with 0 timeout)
        if read -r -t 0 2>/dev/null; then
            # Consume the keypress
            read -r -n 1 _ui_tw_dummy 2>/dev/null || true
            # Print the rest of the text at once
            printf '%s\n' "${text:$i}"
            return
        fi
        char="${text:$i:1}"
        printf '%s' "$char"
        sleep "$delay"
    done
    printf '\n'
}

# ---------------------------------------------------------------------------
# ui_header "Title" — boxed section header
# ---------------------------------------------------------------------------

ui_header() {
    local title="${1:-}"
    local width
    width="$(ui_term_width)"

    # Build the border line: ─ repeated to fill the width
    local border
    border="$(printf '─%.0s' $(seq 1 "$width"))"

    printf '\n'
    printf "${COLOR_BOLD}${COLOR_BLUE}%s${COLOR_RESET}\n" "$border"
    # Center the title
    local pad=$(( (width - ${#title}) / 2 ))
    printf "${COLOR_BOLD}${COLOR_BLUE}%*s%s${COLOR_RESET}\n" "$pad" "" "$title"
    printf "${COLOR_BOLD}${COLOR_BLUE}%s${COLOR_RESET}\n" "$border"
}

# ---------------------------------------------------------------------------
# ui_subheader "Title" — lighter section header (bold + dim separator)
# ---------------------------------------------------------------------------

ui_subheader() {
    local title="${1:-}"
    local width
    width="$(ui_term_width)"

    local sep
    sep="$(printf -- '-%.0s' $(seq 1 "$width"))"

    printf '\n'
    printf "${COLOR_BOLD}%s${COLOR_RESET}\n" "$title"
    printf "${COLOR_DIM}%s${COLOR_RESET}\n" "$sep"
}

# ---------------------------------------------------------------------------
# ui_success "msg" — green ✓ message
# ui_error   "msg" — red   ✗ message
# ui_warn    "msg" — yellow ! message
# ---------------------------------------------------------------------------

ui_success() {
    printf "${COLOR_GREEN}✓ %s${COLOR_RESET}\n" "${1:-}"
}

ui_error() {
    printf "${COLOR_RED}✗ %s${COLOR_RESET}\n" "${1:-}"
}

ui_warn() {
    printf "${COLOR_YELLOW}! %s${COLOR_RESET}\n" "${1:-}"
}

# ---------------------------------------------------------------------------
# ui_prompt — print "Press Enter to continue" and wait for the user
# ---------------------------------------------------------------------------

ui_prompt() {
    printf "${COLOR_DIM}Press Enter to continue...${COLOR_RESET}"
    read -r _ui_prompt_dummy </dev/tty 2>/dev/null || read -r _ui_prompt_dummy
    printf '\n'
}

# ---------------------------------------------------------------------------
# ui_menu item1 item2 ... — numbered menu; prints to stderr, result to stdout
#   Reads from /dev/tty when available so stdout can be captured.
#   Returns the 1-based index of the chosen item on stdout.
# ---------------------------------------------------------------------------

ui_menu() {
    local items=("$@")
    local count=${#items[@]}
    local choice

    # Print menu to stderr so callers can capture stdout for the return value
    {
        printf '\n'
        local i
        for (( i=0; i<count; i++ )); do
            printf "${COLOR_BOLD}%d${COLOR_RESET}) %s\n" "$(( i + 1 ))" "${items[$i]}"
        done
        printf '\n'
    } >&2

    while true; do
        printf "${COLOR_CYAN}Choice [1-%d]: ${COLOR_RESET}" "$count" >&2

        # Read from /dev/tty if available (interactive), fall back to stdin
        if read -r choice </dev/tty 2>/dev/null; then
            :
        else
            read -r choice
        fi

        # Validate: must be an integer in [1, count]
        if [[ "$choice" =~ ^[0-9]+$ ]] && \
           [[ "$choice" -ge 1 ]] && \
           [[ "$choice" -le "$count" ]]; then
            printf '%s' "$choice"
            return 0
        else
            printf "${COLOR_RED}Invalid choice. Please enter a number between 1 and %d.${COLOR_RESET}\n" \
                "$count" >&2
        fi
    done
}
