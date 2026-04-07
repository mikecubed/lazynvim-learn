#!/usr/bin/env bash
# lessons/05-workflows/04-putting-it-together.sh
# Module 5, Lesson 4: Putting It All Together (Capstone)

lesson_info() {
    LESSON_TITLE="Putting It All Together"
    LESSON_MODULE="05-workflows"
    LESSON_DESCRIPTION="The capstone challenge: combine file navigation, LSP renaming, and formatting in one fluid workflow."
    LESSON_TIME="20 minutes"
}

# ---------------------------------------------------------------------------
# Verify functions
# ---------------------------------------------------------------------------

# Check 1: sample.py is the active buffer.
# The user must navigate to it using <leader>ff or the file explorer.
verify_capstone_file_open() {
    verify_file_open "sample.py"
}

# Check 2: the function that was originally named "add_tag" no longer exists
# in the buffer — it has been renamed to "attach_tag" via LSP rename (<leader>cr).
verify_capstone_symbol_renamed() {
    verify_reset
    if verify_buffer_contains "attach_tag"; then
        if verify_buffer_not_contains "add_tag"; then
            VERIFY_MESSAGE="Symbol renamed to 'attach_tag'"
            return 0
        else
            VERIFY_MESSAGE="'add_tag' still found in buffer"
            VERIFY_HINT="Place cursor on 'add_tag', press Space c r, type 'attach_tag', press Enter"
            return 1
        fi
    else
        VERIFY_MESSAGE="'attach_tag' not found in buffer"
        VERIFY_HINT="Place cursor on 'add_tag', press Space c r, type 'attach_tag', press Enter"
        return 1
    fi
}

# Check 3: the buffer has been formatted — conform.nvim was invoked.
verify_capstone_formatted() {
    verify_via_companion "buffer_is_formatted"
}

# Compound verifier for the capstone exercise.
# All three checks must pass simultaneously.
verify_capstone_complete() {
    verify_all \
        verify_capstone_file_open \
        verify_capstone_symbol_renamed \
        verify_capstone_formatted
}

# ---------------------------------------------------------------------------
# Lesson content
# ---------------------------------------------------------------------------

lesson_run() {
    # -----------------------------------------------------------------------
    engine_section "The Capstone Challenge"
    # -----------------------------------------------------------------------

    engine_teach "You have reached the final lesson. Everything you have practiced — modal
editing, motions, Telescope, LSP, formatting, git, the terminal, and debugging —
converges here into a single workflow.

This is not a test with a right or wrong answer. It is a chance to feel how
these tools work together and to build the muscle memory that makes Neovim fast
in real work."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Skills Recap"
    # -----------------------------------------------------------------------

    engine_teach "Here is a quick reference of the skills you have built:"

    engine_show_key "Space" "ff"  "Find file (Module 2)"
    engine_show_key "Space" "/"   "Live grep across the project (Module 2)"
    engine_show_key "Space" "e"   "Toggle file explorer (Module 2)"
    engine_show_key ""      "gd"  "Go to definition (Module 3 / LSP)"
    engine_show_key ""      "K"   "Hover documentation (Module 3 / LSP)"
    engine_show_key "Space" "cr"  "Rename symbol via LSP (Module 3)"
    engine_show_key "Space" "cf"  "Format buffer with conform.nvim (Module 3)"
    engine_show_key "Space" "gg"  "Open lazygit (Module 5)"
    engine_show_key "Space" "ft"  "Open floating terminal (Module 5)"
    engine_show_key "Space" "db"  "Set DAP breakpoint (Module 5)"

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "The Task"
    # -----------------------------------------------------------------------

    engine_teach "Your challenge has three steps. Complete them in any order — the check
verifies all three at once.

  Step 1 — Navigate to sample.py
    Use <leader>ff and type 'py' to find and open the file.

  Step 2 — Rename a function with LSP
    The file has a method called add_tag. Place your cursor anywhere on the
    word add_tag (try searching with /add_tag then pressing Enter), then press
    <leader>cr to rename it. Type the new name: attach_tag and confirm.

  Step 3 — Format the buffer
    The file has a deliberate style issue: add_tag (now attach_tag) has a
    missing space after the comma in its signature. Press <leader>cf to run
    the formatter and clean it up.

When all three are done, type 'check'."

    engine_pause

    # -----------------------------------------------------------------------
    engine_section "Exercise: The Full Workflow"
    # -----------------------------------------------------------------------

    engine_teach "Start with Step 1: use <leader>ff to open sample.py.
Then rename add_tag to attach_tag using <leader>cr.
Then format the buffer with <leader>cf.

Take your time. Use which-key (<leader>) if you forget a binding."

    engine_exercise "capstone-workflow" \
        "Navigate, Rename, and Format" \
        "1) Open sample.py with <leader>ff.  2) Place the cursor on 'add_tag' and press <leader>cr, rename it to 'attach_tag'.  3) Press <leader>cf to format the buffer.  type 'check' when all three steps are complete." \
        verify_capstone_complete \
        "Step 1: <leader>ff then type 'py'. Step 2: /add_tag Enter, then <leader>cr and type 'attach_tag'. Step 3: <leader>cf to format." \
        "dir"

    [[ $_ENGINE_QUIT -eq 1 ]] && return

    # -----------------------------------------------------------------------
    engine_section "You Did It"
    # -----------------------------------------------------------------------

    engine_teach "
  ╔══════════════════════════════════════════════════════════════════╗
  ║                                                                  ║
  ║         C O N G R A T U L A T I O N S                           ║
  ║                                                                  ║
  ║   You have completed the lazynvim-learn tutorial.                ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

You started with the basics of modal editing and worked your way through:

  Module 1  — Normal, Insert, Visual, and Command-line modes
  Module 2  — the fuzzy finder, the file explorer, Flash, and Which-key
  Module 3  — LSP, diagnostics, formatting, and refactoring
  Module 4  — LazyVim configuration and plugin customization
  Module 5  — Git (lazygit), terminal, and DAP debugging

That is the full stack. You now have a development environment that is faster,
more capable, and more keyboard-driven than most editors people use — and you
know how to extend it further when you need to."

    engine_pause

    engine_teach "What comes next:

  Practice daily.  The bindings will become automatic faster than you expect.
  Use which-key.  When you forget a key, press <leader> and browse — it is
                  all there.
  Read the docs.  :h <topic> and the LazyVim documentation at lazyvim.org
                  cover far more than this tutorial could.
  Customise.      You now have the foundation to add plugins, remap keys, and
                  shape Neovim into exactly the editor you want.

The community lives at r/neovim, the LazyVim GitHub discussions, and the Neovim
Discord. The questions you have next are ones they love to answer.

Go build something. You are ready."

    engine_pause
}
