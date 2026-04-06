#!/usr/bin/env bash
# Tests for lib/ui.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_runner.sh"

# Use fast mode so typewriter tests don't sleep
export LAZYNVIM_LEARN_FAST=1

source "$SCRIPT_DIR/../lib/ui.sh"

# ---------------------------------------------------------------------------
# Color constants
# ---------------------------------------------------------------------------

test_color_constants_are_defined() {
    assert_not_equals "" "$COLOR_RED"   "COLOR_RED should be defined"
    assert_not_equals "" "$COLOR_GREEN" "COLOR_GREEN should be defined"
    assert_not_equals "" "$COLOR_YELLOW" "COLOR_YELLOW should be defined"
    assert_not_equals "" "$COLOR_BLUE"  "COLOR_BLUE should be defined"
    assert_not_equals "" "$COLOR_CYAN"  "COLOR_CYAN should be defined"
    assert_not_equals "" "$COLOR_BOLD"  "COLOR_BOLD should be defined"
    assert_not_equals "" "$COLOR_DIM"   "COLOR_DIM should be defined"
    assert_not_equals "" "$COLOR_RESET" "COLOR_RESET should be defined"
}

test_color_constants_use_escape_sequences() {
    # Constants use ANSI-C quoting ($'\033[') so they hold actual ESC bytes
    assert_contains "$COLOR_RED"   $'\033[' "COLOR_RED should contain ESC byte"
    assert_contains "$COLOR_RESET" $'\033[' "COLOR_RESET should contain ESC byte"
}

# ---------------------------------------------------------------------------
# ui_term_width
# ---------------------------------------------------------------------------

test_term_width_returns_a_number() {
    local w
    w="$(ui_term_width)"
    assert_matches "$w" '^[0-9]+$' "ui_term_width should return a number"
}

test_term_width_at_least_1() {
    local w
    w="$(ui_term_width)"
    [[ "$w" -ge 1 ]]
    assert_exit_code 0 $? "ui_term_width should be >= 1"
}

# ---------------------------------------------------------------------------
# ui_print
# ---------------------------------------------------------------------------

test_ui_print_outputs_text() {
    local out
    out="$(ui_print "hello world")"
    assert_contains "$out" "hello world" "ui_print should output its argument"
}

test_ui_print_adds_newline() {
    local out
    # wc -l counts newlines; ui_print should produce exactly one line
    local lines
    lines="$(ui_print "hello" | wc -l)"
    assert_equals "1" "$lines" "ui_print should produce a single line"
}

# ---------------------------------------------------------------------------
# ui_print_wrapped
# ---------------------------------------------------------------------------

test_ui_print_wrapped_outputs_text() {
    local out
    out="$(ui_print_wrapped "short text")"
    assert_contains "$out" "short text" "ui_print_wrapped should include the text"
}

test_ui_print_wrapped_respects_width() {
    # Build a very long word-friendly string and force narrow width
    local long_text="one two three four five six seven eight nine ten eleven twelve"
    # Override ui_term_width temporarily via env var hint
    local out
    out="$(LAZYNVIM_LEARN_WIDTH=20 ui_print_wrapped "$long_text")"
    local too_wide=0
    while IFS= read -r line; do
        # Strip ANSI before measuring
        local plain
        plain="$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')"
        if [[ ${#plain} -gt 20 ]]; then
            too_wide=1
        fi
    done <<< "$out"
    assert_equals "0" "$too_wide" "No line should exceed the width limit"
}

test_ui_print_wrapped_multiline_output() {
    local long_text="one two three four five six seven eight nine ten eleven twelve"
    local out
    out="$(LAZYNVIM_LEARN_WIDTH=20 ui_print_wrapped "$long_text")"
    local lines
    lines="$(printf '%s' "$out" | wc -l)"
    [[ "$lines" -gt 1 ]]
    assert_exit_code 0 $? "Long text should wrap into multiple lines"
}

# ---------------------------------------------------------------------------
# ui_typewriter
# ---------------------------------------------------------------------------

test_ui_typewriter_outputs_text() {
    local out
    out="$(ui_typewriter "type me")"
    assert_contains "$out" "type me" "ui_typewriter should output the text"
}

test_ui_typewriter_fast_mode_no_delay() {
    # In LAZYNVIM_LEARN_FAST=1 mode this should complete near-instantly
    local start end elapsed
    start="$(date +%s%N)"
    ui_typewriter "hello" > /dev/null
    end="$(date +%s%N)"
    elapsed=$(( (end - start) / 1000000 )) # ms
    [[ "$elapsed" -lt 500 ]]
    assert_exit_code 0 $? "ui_typewriter in fast mode should complete in < 500ms (took ${elapsed}ms)"
}

# ---------------------------------------------------------------------------
# ui_header
# ---------------------------------------------------------------------------

test_ui_header_contains_title() {
    local out
    out="$(ui_header "My Title")"
    assert_contains "$out" "My Title" "ui_header should contain the title"
}

test_ui_header_contains_border_chars() {
    local out
    out="$(ui_header "X")"
    # Should contain some kind of border — at minimum a repeated character
    assert_matches "$out" '[-=─#*]' "ui_header should contain border characters"
}

test_ui_header_multiline() {
    local out
    local lines
    lines="$(ui_header "Test" | wc -l)"
    [[ "$lines" -ge 2 ]]
    assert_exit_code 0 $? "ui_header should span at least 2 lines"
}

# ---------------------------------------------------------------------------
# ui_subheader
# ---------------------------------------------------------------------------

test_ui_subheader_contains_title() {
    local out
    out="$(ui_subheader "Sub Section")"
    assert_contains "$out" "Sub Section" "ui_subheader should contain the title"
}

test_ui_subheader_uses_bold() {
    local out
    out="$(ui_subheader "Bold Check")"
    assert_contains "$out" "$COLOR_BOLD" "ui_subheader should use COLOR_BOLD"
}

# ---------------------------------------------------------------------------
# ui_success / ui_error / ui_warn
# ---------------------------------------------------------------------------

test_ui_success_contains_message() {
    local out
    out="$(ui_success "all good")"
    assert_contains "$out" "all good" "ui_success should print the message"
}

test_ui_success_uses_green() {
    local out
    out="$(ui_success "ok")"
    assert_contains "$out" "$COLOR_GREEN" "ui_success should use green color"
}

test_ui_success_has_checkmark_prefix() {
    local out
    out="$(ui_success "done")"
    assert_contains "$out" "✓" "ui_success should include ✓ prefix"
}

test_ui_error_contains_message() {
    local out
    out="$(ui_error "something broke")"
    assert_contains "$out" "something broke" "ui_error should print the message"
}

test_ui_error_uses_red() {
    local out
    out="$(ui_error "bad")"
    assert_contains "$out" "$COLOR_RED" "ui_error should use red color"
}

test_ui_error_has_x_prefix() {
    local out
    out="$(ui_error "fail")"
    assert_contains "$out" "✗" "ui_error should include ✗ prefix"
}

test_ui_warn_contains_message() {
    local out
    out="$(ui_warn "be careful")"
    assert_contains "$out" "be careful" "ui_warn should print the message"
}

test_ui_warn_uses_yellow() {
    local out
    out="$(ui_warn "careful")"
    assert_contains "$out" "$COLOR_YELLOW" "ui_warn should use yellow color"
}

test_ui_warn_has_bang_prefix() {
    local out
    out="$(ui_warn "watch out")"
    assert_contains "$out" "!" "ui_warn should include ! prefix"
}

# ---------------------------------------------------------------------------
# ui_prompt
# ---------------------------------------------------------------------------

test_ui_prompt_accepts_enter() {
    # Feed empty input (just Enter) — should return 0
    local result
    printf '\n' | ui_prompt > /dev/null 2>&1
    assert_exit_code 0 $? "ui_prompt should return 0 when Enter is pressed"
}

test_ui_prompt_prints_message() {
    local out
    out="$(printf '\n' | ui_prompt 2>&1)"
    assert_contains "$out" "Enter" "ui_prompt should print a message mentioning Enter"
}

# ---------------------------------------------------------------------------
# ui_menu
# ---------------------------------------------------------------------------

test_ui_menu_valid_selection() {
    local result
    # Choose option 2 from a 3-item menu
    result="$(printf '2\n' | ui_menu "Alpha" "Beta" "Gamma")"
    assert_equals "2" "$result" "ui_menu should return the selected index"
}

test_ui_menu_selection_1() {
    local result
    result="$(printf '1\n' | ui_menu "First" "Second")"
    assert_equals "1" "$result" "ui_menu should return 1 for first item"
}

test_ui_menu_last_item() {
    local result
    result="$(printf '3\n' | ui_menu "A" "B" "C")"
    assert_equals "3" "$result" "ui_menu should return 3 for last of 3 items"
}

test_ui_menu_invalid_then_valid() {
    # First input is out of range, second is valid
    local result
    result="$(printf '9\n2\n' | ui_menu "X" "Y" "Z")"
    assert_equals "2" "$result" "ui_menu should reprompt on invalid input and accept valid one"
}

test_ui_menu_shows_items() {
    local out
    out="$(printf '1\n' | ui_menu "Apple" "Banana" "Cherry" 2>&1)"
    assert_contains "$out" "Apple"  "ui_menu output should contain first item"
    assert_contains "$out" "Banana" "ui_menu output should contain second item"
    assert_contains "$out" "Cherry" "ui_menu output should contain third item"
}

test_ui_menu_shows_numbers() {
    local out
    out="$(printf '1\n' | ui_menu "One" "Two" 2>&1)"
    assert_contains "$out" "1" "ui_menu should number items starting at 1"
    assert_contains "$out" "2" "ui_menu should show item 2"
}

# ---------------------------------------------------------------------------
# ui_clear (smoke test — just shouldn't error)
# ---------------------------------------------------------------------------

test_ui_clear_exits_zero() {
    ui_clear > /dev/null 2>&1
    assert_exit_code 0 $? "ui_clear should exit 0"
}
