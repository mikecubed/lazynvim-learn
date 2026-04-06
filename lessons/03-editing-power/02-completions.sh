#!/usr/bin/env bash
# lessons/03-editing-power/02-completions.sh
# Module 3, Lesson 2: Completions with nvim-cmp

lesson_info() {
    LESSON_TITLE="Completions"
    LESSON_MODULE="03-editing-power"
    LESSON_DESCRIPTION="Master nvim-cmp to get intelligent completions from the LSP, buffer, snippets, and file paths."
    LESSON_TIME="12 minutes"
}

# ---------------------------------------------------------------------------
# Custom verifiers
# ---------------------------------------------------------------------------

# Exercise 1: user typed and completed "print_summary" into the buffer.
# We check the buffer now contains the completed function name.
verify_completion_used() {
    verify_buffer_contains "print_summary"
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "How nvim-cmp Works"
    # -----------------------------------------------------------------------

    engine_teach "nvim-cmp is LazyVim's completion engine. It sits between your keystrokes
and several *sources* — the LSP, the current buffer's words, file paths, Lua
paths, and snippet engines — and merges them into a single ranked list.

The completion menu appears automatically after a short delay as you type.
You can also trigger it manually at any time with Ctrl-Space."

    engine_teach "nvim-cmp is separate from the LSP. Even with no language server running
you still get completions from:

  buffer   — every word currently visible across open buffers
  path     — filesystem paths when you type '/' or './'
  cmdline  — Ex command history when you open ':'

When the LSP is attached, its suggestions are added on top — ranked by
relevance and filtered by type."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Completion Menu"
    # -----------------------------------------------------------------------

    engine_teach "When the menu is open you control it entirely from the keyboard:

  Ctrl-Space       — force open the completion menu
  Ctrl-n / Ctrl-p  — next / previous item (also: Tab / Shift-Tab)
  Enter            — confirm the highlighted item
  Ctrl-e           — dismiss the menu without inserting anything
  Ctrl-b / Ctrl-f  — scroll the documentation preview up / down

The tiny icon on the left of each entry tells you its source:
  f  — function       v  — variable      c  — class
  m  — method         k  — keyword       s  — snippet
  t  — text (buffer word)                ~  — path"

    engine_show_key "Ctrl" "Space"  "Force-open the completion menu"
    engine_show_key "Ctrl" "n"      "Select next completion item"
    engine_show_key "Ctrl" "p"      "Select previous completion item"
    engine_show_key "Tab"  ""       "Select next item (also moves through snippet placeholders)"
    engine_show_key "Shift" "Tab"   "Select previous item"
    engine_show_key "Enter" ""      "Confirm selected item"
    engine_show_key "Ctrl" "e"      "Dismiss the completion menu"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Snippets and Placeholders"
    # -----------------------------------------------------------------------

    engine_teach "Some completions expand into *snippets* — multi-part templates with
placeholders you fill in one by one. LazyVim uses LuaSnip as the snippet
engine with a library of built-in snippets for common patterns.

After confirming a snippet, Tab moves forward to the next placeholder and
Shift-Tab moves backward. When there are no placeholders left, Tab behaves
normally again."

    engine_teach "Examples of built-in Python snippets:

  def   — expands to a function skeleton with placeholders for name,
          arguments, and body
  class — expands to a class with __init__
  for   — a for-loop skeleton

You can also install friendly-snippets (already bundled in LazyVim) which
adds hundreds of snippets for Python, Lua, TypeScript, and more."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "LSP Completions: The Crown Jewel"
    # -----------------------------------------------------------------------

    engine_teach "When the LSP is attached, completions become truly intelligent:

  • Only methods that exist on the object's type are suggested
  • Function signatures show the expected argument types
  • Documentation previews appear in a floating window to the right
  • Completions update as soon as you add a new import or define a new symbol

The LSP also provides *signature help* — a floating hint showing argument
names and types while you are inside a function call. LazyVim shows this
automatically when you press '(' to open a call."

    engine_show_key "Ctrl" "k"      "Show signature help (argument hints)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Controlling What Completes"
    # -----------------------------------------------------------------------

    engine_teach "Sometimes the completion menu gets in the way. A few helpful tricks:

  • Press Ctrl-e to dismiss the menu for the current keystroke.
  • Press Escape to leave Insert mode — the menu closes automatically.
  • If a snippet has too many placeholders, press Ctrl-e mid-snippet to
    abandon it and keep the text typed so far.

You can configure nvim-cmp in  lua/plugins/  to add or remove sources,
change the trigger delay (keyword_length), or even disable it for specific
filetypes. That comes in Module 4 (Customization)."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise: Complete a Function Name"
    # -----------------------------------------------------------------------

    engine_teach "The sandbox has sample.py open. The file defines a function called
print_summary at the bottom. You will call it from a new line.

Steps:
  1. Press G to jump to the last line of the file.
  2. Press o to open a new line below and enter Insert mode.
  3. Start typing:  pr
  4. The completion menu should appear. Press Ctrl-Space if it does not.
  5. Navigate to 'print_summary' with Ctrl-n or Tab.
  6. Press Enter to confirm the completion.
  7. Press Escape to return to Normal mode.

The check passes when 'print_summary' appears in the buffer."

    engine_exercise "cmp-complete" \
        "Complete 'print_summary' with Ctrl-Space" \
        "Jump to the bottom of sample.py with G. Open a new line with o, type 'pr', trigger completions with Ctrl-Space if needed, select 'print_summary', and confirm with Enter. Press Escape when done." \
        verify_completion_used \
        "Type 'pr' in Insert mode, then press Ctrl-Space to open the menu. Use Ctrl-n to highlight 'print_summary', then press Enter." \
        "file" \
        "sample.py"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "Summary"
    # -----------------------------------------------------------------------

    engine_teach "You now know how to drive nvim-cmp:

  Ctrl-Space     — open the completion menu on demand
  Tab / Ctrl-n   — cycle forward through suggestions
  Shift-Tab / Ctrl-p — cycle backward
  Enter          — accept the highlighted item
  Ctrl-e         — dismiss without accepting

Key insight: the menu ranks results by relevance. Usually the item you
want is already at the top — press Tab once and Enter. You rarely need
to scroll through a long list.

Next up: Formatting and Linting — keeping code consistent automatically."

    engine_pause
}
