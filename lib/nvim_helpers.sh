#!/usr/bin/env bash
# lib/nvim_helpers.sh — Thin wrappers around nvim --server RPC
# Set NVIM_SOCKET before calling any function (done by sandbox_launch).

NVIM_SOCKET=""

# ---------------------------------------------------------------------------
# Low-level RPC wrappers
# ---------------------------------------------------------------------------

# All nvim --server calls unset NVIM to prevent client-mode confusion
# when the tutorial itself runs inside an nvim terminal (e.g. Claude Code).

# nvim_eval "vimscript_expr"
# Evaluate a Vimscript expression; print stdout; return 1 on failure.
nvim_eval() {
    NVIM= nvim --server "$NVIM_SOCKET" --remote-expr "$1" 2>/dev/null
    local rc=$?
    [[ $rc -eq 0 ]] && return 0 || return 1
}

# nvim_lua "lua_expr"
# Evaluate a Lua expression via luaeval().
# NOTE: single quotes inside lua_expr will break the wrapping — callers
# must escape them or use double-quote-safe Lua syntax.
nvim_lua() {
    nvim_eval "luaeval('$1')"
}

# nvim_exec "vim_command"
# Execute a Normal-mode Ex command inside Neovim (no output returned).
nvim_exec() {
    NVIM= nvim --server "$NVIM_SOCKET" --remote-send "<Cmd>$1<CR>" 2>/dev/null
}

# nvim_send_keys "keys"
# Send raw keystrokes to Neovim (supports special notation like <Esc>).
nvim_send_keys() {
    NVIM= nvim --server "$NVIM_SOCKET" --remote-send "$1" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Connection checks
# ---------------------------------------------------------------------------

# nvim_is_running
# Returns 0 if the Neovim instance at NVIM_SOCKET is responsive, 1 otherwise.
nvim_is_running() {
    local result
    result=$(nvim_eval "1+1" 2>/dev/null)
    [[ "$result" == "2" ]]
}

# nvim_wait_ready [timeout_secs]
# Poll nvim_is_running every 0.5s until it responds or timeout expires.
# Default timeout: 10 seconds.
# Returns 0 on success, 1 on timeout.
nvim_wait_ready() {
    local timeout="${1:-10}"
    # Convert timeout to max attempts (2 per second). Use awk for fractional support.
    local attempts
    attempts=$(awk "BEGIN{v=int(${timeout}*2); if(v<1) v=1; print v}")
    local i=0

    while ! nvim_is_running; do
        sleep 0.5
        i=$(( i + 1 ))
        if [[ $i -ge $attempts ]]; then
            return 1
        fi
    done
    return 0
}

# ---------------------------------------------------------------------------
# State getters
# ---------------------------------------------------------------------------

# nvim_get_mode
# Returns the current Neovim mode string (e.g. "n", "i", "v").
nvim_get_mode() {
    nvim_eval "mode()"
}

# nvim_get_bufname
# Returns the tail of the current buffer's filename.
nvim_get_bufname() {
    nvim_eval "expand('%:t')"
}

# nvim_get_filetype
# Returns the filetype of the current buffer.
nvim_get_filetype() {
    nvim_eval "&filetype"
}

# nvim_get_cursor
# Returns the cursor position as "line,col" (1-based line, 0-based col).
# Uses Vimscript string() + col arithmetic to avoid luaeval table issues.
nvim_get_cursor() {
    nvim_eval "string(line('.')).','.string(col('.')-1)"
}

# nvim_get_line "n"
# Returns the content of line n (1-based) in the current buffer.
nvim_get_line() {
    nvim_lua "vim.api.nvim_buf_get_lines(0, $(($1-1)), $1, false)[1]"
}

# nvim_get_current_line
# Returns the content of the line the cursor is on.
nvim_get_current_line() {
    nvim_eval "getline('.')"
}

# nvim_get_register "reg"
# Returns the content of the named register (e.g. "a", "+", "\"").
nvim_get_register() {
    nvim_eval "getreg('$1')"
}

# nvim_get_option "opt"
# Returns the value of a Vim option (e.g. "tabstop", "number").
nvim_get_option() {
    nvim_eval "&$1"
}

# nvim_get_var "var"
# Returns the value of a Vim variable expression (e.g. "g:loaded_foo").
nvim_get_var() {
    nvim_eval "$1"
}
