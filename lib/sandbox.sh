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
    local cwd="${2:-}"

    # Remove stale socket from a previous run
    [[ -S "$NVIM_SOCKET" ]] && rm -f "$NVIM_SOCKET"

    export NVIM_SOCKET
    export NVIM_APPNAME

    # Build the nvim command
    local nvim_cmd="nvim --listen ${NVIM_SOCKET}"
    [[ -n "$file" ]] && nvim_cmd="$nvim_cmd $(printf '%q' "$file")"

    # Build tmux split args — set starting directory if provided
    local -a tmux_args=(-v -P -F '#{pane_id}')
    [[ -n "$cwd" ]] && tmux_args+=(-c "$cwd")

    # Split the tmux window and launch nvim.
    # NVIM_APPNAME is exported so the child process inherits it.
    # Try percentage split first; fall back if pane is small.
    SANDBOX_PANE=$(tmux split-window "${tmux_args[@]}" -p 65 "$nvim_cmd" 2>/dev/null) \
        || SANDBOX_PANE=$(tmux split-window "${tmux_args[@]}" "$nvim_cmd" 2>/dev/null) \
        || {
            echo "Error: failed to create tmux pane for Neovim sandbox." >&2
            echo "       Try making your terminal window taller." >&2
            return 1
        }

    # Resize: ensure the nvim pane gets at least 65% of the window.
    # The tutorial pane (top) can work with fewer lines.
    tmux resize-pane -t "$SANDBOX_PANE" -y 65% 2>/dev/null || true

    # Keep the pane open if nvim exits unexpectedly so the error is visible
    tmux set-option -t "$SANDBOX_PANE" remain-on-exit on 2>/dev/null || true

    # Wait for nvim to be ready. Use a generous timeout on first launch
    # since LazyVim may need to install plugins.
    if ! nvim_wait_ready 30; then
        echo "Warning: Neovim is slow to start (plugin install may be in progress)." >&2
        echo "         Waiting a bit longer..." >&2
        nvim_wait_ready 60 || {
            echo "Error: Neovim did not respond within 90 seconds." >&2
            echo "         Check the bottom pane for errors." >&2
            return 1
        }
    fi
    return 0
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
    sandbox_launch "${1:-}" "${2:-}" || return 1
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

            # Resolve bare filenames (e.g. "sample.py") from exercise-files/
            if [[ -n "$src" && ! -f "$src" && -f "$LAZYNVIM_LEARN_ROOT/configs/exercise-files/$src" ]]; then
                src="$LAZYNVIM_LEARN_ROOT/configs/exercise-files/$src"
            fi

            if [[ -n "$src" && -f "$src" ]]; then
                cp "$src" "$SANDBOX_DIR/"
                sandbox_reset "$SANDBOX_DIR/$(basename "$src")" "$SANDBOX_DIR"
            else
                sandbox_reset "" "$SANDBOX_DIR"
            fi
            ;;
        dir)
            SANDBOX_DIR=$(mktemp -d /tmp/lazynvim-learn-exercise-XXXXXX)
            local exercise_src="$LAZYNVIM_LEARN_ROOT/configs/exercise-files"
            if [[ -d "$exercise_src" ]]; then
                cp -r "$exercise_src/." "$SANDBOX_DIR/"
            fi
            # Open the first file in the dir rather than the dir itself
            local first_file
            first_file=$(find "$SANDBOX_DIR" -maxdepth 1 -type f | sort | head -1)
            sandbox_reset "${first_file:-}" "$SANDBOX_DIR"
            ;;
        empty)
            SANDBOX_DIR=$(mktemp -d /tmp/lazynvim-learn-exercise-XXXXXX)
            sandbox_reset "" "$SANDBOX_DIR"
            ;;
        config)
            local config_dir="${HOME}/.config/lazynvim-learn"
            sandbox_reset "$config_dir" "$config_dir"
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
