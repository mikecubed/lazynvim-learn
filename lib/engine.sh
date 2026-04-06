#!/usr/bin/env bash
# lib/engine.sh — Lesson runner and exercise state machine for lazynvim-learn
#
# Sources: lib/ui.sh, lib/nvim_helpers.sh, lib/sandbox.sh, lib/progress.sh
# must be sourced before engine.sh, or alongside it.

# Guard against double-sourcing
[[ -n "${_LAZYNVIM_ENGINE_SH:-}" ]] && return 0
_LAZYNVIM_ENGINE_SH=1

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------

EXERCISE_DIR=""        # Set by sandbox_setup_exercise
CURRENT_LESSON=""      # module/lesson-name being run
CURRENT_EXERCISE=""    # exercise ID within lesson

# Internal: used by engine_exercise to signal quit-from-lesson
_ENGINE_QUIT=0

# ---------------------------------------------------------------------------
# engine_section "Title"
# ---------------------------------------------------------------------------
# Render a section header and add a blank line.

engine_section() {
    local title="${1:-}"
    ui_header "$title"
    printf '\n'
}

# ---------------------------------------------------------------------------
# engine_teach "Text"
# ---------------------------------------------------------------------------
# Display instruction text via typewriter effect, then blank line.

engine_teach() {
    local text="${1:-}"
    ui_typewriter "$text"
    printf '\n'
}

# ---------------------------------------------------------------------------
# engine_pause
# ---------------------------------------------------------------------------
# Show "Press Enter to continue..." prompt and wait.

engine_pause() {
    ui_prompt
}

# ---------------------------------------------------------------------------
# engine_demo "description" "keys"
# ---------------------------------------------------------------------------
# Show a description, send keys to sandbox nvim, print a brief indicator.

engine_demo() {
    local description="${1:-}"
    local keys="${2:-}"

    ui_print "$description"
    nvim_send_keys "$keys"
    ui_print "${COLOR_DIM}[demo sent to Neovim]${COLOR_RESET}"
    printf '\n'
}

# ---------------------------------------------------------------------------
# engine_show_key "prefix" "key" "description"
# ---------------------------------------------------------------------------
# Display a formatted keybinding line.
# Format:  [prefix + key]  description

engine_show_key() {
    local prefix="${1:-}"
    local key="${2:-}"
    local description="${3:-}"

    local combo
    if [[ -n "$prefix" ]]; then
        combo="${prefix} + ${key}"
    else
        combo="$key"
    fi

    printf "${COLOR_CYAN}[%s]${COLOR_RESET}  %s\n" "$combo" "$description"
}

# ---------------------------------------------------------------------------
# engine_quiz "Question?" "A" "B" "C" correct_index
# ---------------------------------------------------------------------------
# Multiple-choice quiz. Loops until correct answer or user types 'skip'.
# correct_index is 1-based and is the last positional argument.

engine_quiz() {
    # Last arg is the correct index; everything before it is question + options.
    local args=("$@")
    local n=${#args[@]}

    if [[ $n -lt 3 ]]; then
        ui_warn "engine_quiz: too few arguments"
        return 1
    fi

    local correct_index="${args[$((n-1))]}"
    local question="${args[0]}"
    local options=("${args[@]:1:$((n-2))}")

    # Display the question
    ui_print "${COLOR_BOLD}${question}${COLOR_RESET}"
    printf '\n'

    # Display numbered options
    local i
    for (( i=0; i<${#options[@]}; i++ )); do
        printf "  ${COLOR_BOLD}%d${COLOR_RESET}) %s\n" "$(( i+1 ))" "${options[$i]}"
    done
    printf '\n'

    # Answer loop
    local answer
    while true; do
        printf "${COLOR_CYAN}Your answer (number, or 'skip'): ${COLOR_RESET}"

        # Read from /dev/tty when interactive, fall back to stdin for tests
        if read -r answer </dev/tty 2>/dev/null; then
            :
        else
            read -r answer
        fi

        if [[ "$answer" == "skip" ]]; then
            ui_warn "Skipped."
            return 0
        fi

        if [[ "$answer" == "$correct_index" ]]; then
            ui_success "Correct!"
            printf '\n'
            return 0
        else
            ui_error "Not quite — try again."
            printf '\n'
        fi
    done
}

# ---------------------------------------------------------------------------
# engine_exercise "id" "Title" "Instructions" verify_func "hint" "sandbox_type" [sandbox_args...]
# ---------------------------------------------------------------------------
# The main exercise loop.

engine_exercise() {
    local id="${1:-}"
    local title="${2:-}"
    local instructions="${3:-}"
    local verify_func="${4:-}"
    local hint="${5:-}"
    local sandbox_type="${6:-none}"
    shift 6 || true
    local sandbox_args=("$@")

    _ENGINE_QUIT=0
    CURRENT_EXERCISE="$id"

    # Set up sandbox unless type is "current" or "none"
    if [[ "$sandbox_type" != "current" && "$sandbox_type" != "none" ]]; then
        if ! sandbox_setup_exercise "$sandbox_type" "${sandbox_args[@]}"; then
            ui_error "Failed to set up the Neovim sandbox. Skipping exercise."
            return 1
        fi
    fi

    # Display exercise header and instructions
    ui_subheader "$title"
    ui_print_wrapped "$instructions"
    printf '\n'

    # Show available commands hint
    ui_print "${COLOR_DIM}Commands: check | hint | help | skip | quit${COLOR_RESET}"
    printf '\n'

    local fail_count=0
    local input

    while true; do
        printf "${COLOR_CYAN}exercise> ${COLOR_RESET}"

        # Read from /dev/tty when interactive, fall back to stdin for tests
        if read -r input </dev/tty 2>/dev/null; then
            :
        else
            read -r input
        fi

        case "$input" in
            check)
                # If the sandbox has died, restart it before verifying
                if declare -f sandbox_is_alive &>/dev/null && ! sandbox_is_alive; then
                    ui_warn "Neovim appears to have crashed. Restarting sandbox..."
                    sandbox_reset
                    printf '\n'
                fi

                # Reset hint/message globals before calling verifier
                VERIFY_MESSAGE=""
                VERIFY_HINT=""

                if "$verify_func"; then
                    ui_success "${VERIFY_MESSAGE:-Done!}"
                    printf '\n'
                    # Mark complete in progress tracking
                    if [[ -n "$CURRENT_LESSON" && -n "$id" ]]; then
                        progress_mark_complete "${CURRENT_LESSON}/${id}"
                    fi
                    break
                else
                    fail_count=$(( fail_count + 1 ))
                    ui_error "${VERIFY_MESSAGE:-Not there yet.}"
                    printf '\n'
                    # Show hint automatically after 2 failures
                    if [[ $fail_count -ge 2 && -n "${VERIFY_HINT:-}" ]]; then
                        ui_warn "Hint: ${VERIFY_HINT}"
                        printf '\n'
                    fi
                fi
                ;;
            hint)
                if [[ -n "$hint" ]]; then
                    ui_warn "Hint: ${hint}"
                else
                    ui_warn "No hint available for this exercise."
                fi
                printf '\n'
                ;;
            skip)
                ui_warn "Exercise skipped."
                printf '\n'
                if [[ -n "$CURRENT_LESSON" && -n "$id" ]]; then
                    progress_mark_complete "${CURRENT_LESSON}/${id}"
                fi
                break
                ;;
            quit)
                ui_warn "Quitting lesson."
                printf '\n'
                _ENGINE_QUIT=1
                return 2
                ;;
            help)
                ui_print "${COLOR_DIM}  check  — verify your work in Neovim${COLOR_RESET}"
                ui_print "${COLOR_DIM}  hint   — show a hint for this exercise${COLOR_RESET}"
                ui_print "${COLOR_DIM}  skip   — mark this exercise done and move on${COLOR_RESET}"
                ui_print "${COLOR_DIM}  quit   — exit the lesson and return to the menu${COLOR_RESET}"
                ui_print "${COLOR_DIM}  (work in the Neovim pane below, then type 'check' here)${COLOR_RESET}"
                printf '\n'
                ;;
            "")
                # Empty input — show help
                ui_print "${COLOR_DIM}  check  — verify your work in Neovim${COLOR_RESET}"
                ui_print "${COLOR_DIM}  hint   — show a hint${COLOR_RESET}"
                ui_print "${COLOR_DIM}  skip   — skip this exercise${COLOR_RESET}"
                ui_print "${COLOR_DIM}  quit   — exit the lesson${COLOR_RESET}"
                printf '\n'
                ;;
            *)
                # Unrecognised input — show help
                ui_print "${COLOR_DIM}Unknown command '${input}'. Try: check, hint, help, skip, quit${COLOR_RESET}"
                printf '\n'
                ;;
        esac
    done

    return 0
}

# ---------------------------------------------------------------------------
# engine_nvim_keys "keys"
# ---------------------------------------------------------------------------
# Send keystrokes to the sandbox Neovim instance.

engine_nvim_keys() {
    nvim_send_keys "$1"
}

# ---------------------------------------------------------------------------
# engine_nvim_open "file"
# ---------------------------------------------------------------------------
# Open a file in the sandbox Neovim instance.

engine_nvim_open() {
    sandbox_open_file "$1"
}
