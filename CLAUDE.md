# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

lazynvim-learn is an interactive terminal-based tutorial for learning Neovim and LazyVim. It is a pure bash application that runs inside a tmux pane, spawns sandboxed Neovim instances for exercises, and verifies user actions by querying Neovim state via its RPC interface (`nvim --server`).

This project is a port/adaptation of tmux-learn, repurposed for teaching Neovim+LazyVim instead of tmux.

## Architecture

**Runtime model:** The tutorial splits the user's existing tmux window into two panes. The top pane runs the bash tutorial engine. The bottom pane runs a sandboxed Neovim instance (`NVIM_APPNAME=lazynvim-learn`) that communicates with the engine over a Unix domain socket at `/tmp/lazynvim-learn-<pid>.sock`.

**Key components:**
- `lazynvim-learn` — Entry point. Checks prerequisites (bash 4.0+, nvim 0.9+, tmux), handles first-run config setup, sources libs, drives the main menu loop
- `lib/engine.sh` — Lesson runner and exercise state machine. Exposes the lesson authoring API (`engine_section`, `engine_teach`, `engine_exercise`, `engine_quiz`, etc.)
- `lib/ui.sh` — ANSI terminal UI primitives (typewriter text, boxes, colors)
- `lib/nvim_helpers.sh` — Thin wrappers around `nvim --server` for Neovim RPC (`nvim_eval`, `nvim_lua`, `nvim_exec`, `nvim_send_keys`, and state getters)
- `lib/verify.sh` — Exercise verification functions that query Neovim state and set `VERIFY_MESSAGE`/`VERIFY_HINT`, returning 0 (pass) or 1 (fail)
- `lib/sandbox.sh` — Manages the sandboxed Neovim lifecycle (`sandbox_launch`, `sandbox_kill`, `sandbox_reset`)
- `lib/progress.sh` — Flat-file progress tracking at `~/.lazynvim-learn/progress`
- `configs/base/` — Complete LazyVim config copied to `~/.config/lazynvim-learn/` on first run
- `configs/base/lua/lazynvim-learn/` — Companion Neovim plugin (verify.lua, scaffold.lua, tracker.lua) callable via `nvim_lua()` from the bash engine

**Lesson files** (`lessons/<module>/<nn>-<topic>.sh`) are bash scripts defining `lesson_info()` and `lesson_run()` functions that use the engine API. Modules unlock sequentially (80% of previous module required).

## Lesson Authoring Conventions

Each lesson file defines two functions: `lesson_info()` (sets LESSON_TITLE, LESSON_MODULE, etc.) and `lesson_run()` (the lesson content using engine API calls).

Engine API for lessons:
- `engine_section "Title"` — section header
- `engine_teach "Text"` — typewriter-style instruction
- `engine_pause` — wait for Enter
- `engine_show_key "Leader" "ff" "Find files"` — keybinding display
- `engine_quiz "Question?" "A" "B" "C" 2` — quiz (last arg = correct index)
- `engine_exercise "id" "Title" "Instructions" verify_func "hint" "sandbox-type"` — interactive exercise
- `engine_nvim_keys "keys"` / `engine_nvim_open "file"` — control sandbox Neovim

Sandbox types for exercises: `file`, `dir`, `empty`, `config`, `current`, `none`.

## Verification Pattern

Verification functions follow a strict contract: call `verify_reset`, query Neovim state via `nvim_helpers.sh` or the companion plugin, set `VERIFY_MESSAGE` (and optionally `VERIFY_HINT`), return 0 or 1. Complex verifications use the companion plugin via `nvim_lua "require('lazynvim-learn.verify').function_name()"` which returns `"pass:message"` or `"fail:message:hint"` strings.

Custom verifiers in lessons should compose the standard functions from `lib/verify.sh`. See `docs/verification.md` for the full API.

## Companion Plugin Constraints

The companion plugin (`configs/base/lua/lazynvim-learn/`) must: have no UI, no keybindings, be stateless between exercises (call `tracker.reset()` and `scaffold.clear_marks()` before each), return strings instead of throwing errors, and stay under 200 lines total.
