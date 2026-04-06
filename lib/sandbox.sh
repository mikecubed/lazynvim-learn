#!/usr/bin/env bash
# lib/sandbox.sh — Manages the sandboxed Neovim instance lifecycle

LAZYNVIM_LEARN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------

NVIM_APPNAME="lazynvim-learn"
NVIM_SOCKET="/tmp/lazynvim-learn-$$.sock"
SANDBOX_PANE=""
SANDBOX_DIR=""

# ---------------------------------------------------------------------------
# sandbox_launch [file]
# ---------------------------------------------------------------------------
# Split the current tmux window (bottom pane, ~40%), launch nvim inside it,
# then wait until nvim is accepting RPC connections.
sandbox_launch() {
    local file="${1:-}"
    local cmd

    export NVIM_SOCKET

    if [[ -n "$file" ]]; then
        cmd="NVIM_APPNAME=$NVIM_APPNAME nvim --listen $NVIM_SOCKET $(printf '%q' "$file")"
    else
        cmd="NVIM_APPNAME=$NVIM_APPNAME nvim --listen $NVIM_SOCKET"
    fi

    SANDBOX_PANE=$(tmux split-window -v -p 40 -P -F '#{pane_id}' "$cmd")

    nvim_wait_ready
}

# ---------------------------------------------------------------------------
# sandbox_kill
# ---------------------------------------------------------------------------
# Terminate the running nvim process, kill the tmux pane, and clean up.
sandbox_kill() {
    if [[ -n "$SANDBOX_PANE" ]]; then
        # Ask nvim to quit gracefully; ignore errors if already gone.
        nvim_exec "qa!" 2>/dev/null || true
        sleep 0.1
        tmux kill-pane -t "$SANDBOX_PANE" 2>/dev/null || true
        SANDBOX_PANE=""
    fi
    [[ -S "$NVIM_SOCKET" ]] && rm -f "$NVIM_SOCKET"
    return 0
}

# ---------------------------------------------------------------------------
# sandbox_reset [file]
# ---------------------------------------------------------------------------
sandbox_reset() {
    sandbox_kill
    sandbox_launch "${1:-}"
}

# ---------------------------------------------------------------------------
# sandbox_open_file "path"
# ---------------------------------------------------------------------------
sandbox_open_file() {
    local path="$1"
    nvim_exec "edit $(printf '%q' "$path")"
}

# ---------------------------------------------------------------------------
# sandbox_setup_exercise "type" [args...]
# ---------------------------------------------------------------------------
# Set up the sandbox for a particular exercise type.
#   file    — copy a single exercise file to a temp dir; open it in nvim
#   dir     — copy configs/exercise-files/ to a temp dir; open nvim in that dir
#   empty   — launch nvim with an empty buffer (no file)
#   config  — launch nvim pointed at the lazynvim-learn config directory
#   current — leave the existing sandbox as-is
#   none    — no sandbox needed; do nothing
sandbox_setup_exercise() {
    local type="${1:-none}"
    shift || true

    case "$type" in
        file)
            local src="${1:-}"
            SANDBOX_DIR=$(mktemp -d /tmp/lazynvim-learn-exercise-XXXXXX)
            if [[ -n "$src" && -f "$src" ]]; then
                cp "$src" "$SANDBOX_DIR/"
                local dest="$SANDBOX_DIR/$(basename "$src")"
                sandbox_reset "$dest"
            else
                sandbox_reset
            fi
            ;;
        dir)
            SANDBOX_DIR=$(mktemp -d /tmp/lazynvim-learn-exercise-XXXXXX)
            local exercise_src="$LAZYNVIM_LEARN_ROOT/configs/exercise-files"
            if [[ -d "$exercise_src" ]]; then
                cp -r "$exercise_src/." "$SANDBOX_DIR/"
            fi
            sandbox_reset "$SANDBOX_DIR"
            ;;
        empty)
            sandbox_reset
            ;;
        config)
            local config_dir="${HOME}/.config/lazynvim-learn"
            sandbox_reset "$config_dir"
            ;;
        current)
            # Leave the existing sandbox unchanged.
            ;;
        none)
            # No sandbox needed.
            ;;
        *)
            printf 'sandbox_setup_exercise: unknown type "%s"\n' "$type" >&2
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# sandbox_is_alive
# ---------------------------------------------------------------------------
# Returns 0 if the sandbox pane exists in tmux AND nvim is responding.
sandbox_is_alive() {
    [[ -z "$SANDBOX_PANE" ]] && return 1

    # Check that the pane still exists.
    tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -qF "$SANDBOX_PANE" || return 1

    # Check that nvim is responding.
    nvim_is_running
}
