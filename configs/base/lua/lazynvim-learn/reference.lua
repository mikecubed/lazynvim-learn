local M, api = { _state = {} }, vim.api

function M.show(text)
  M.hide()
  local lines, w, buf = vim.split(text, "\n"), 0, api.nvim_create_buf(false, true)
  for _, l in ipairs(lines) do w = math.max(w, #l) end
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_set_option_value("modifiable", false, { buf = buf })
  api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  local win = api.nvim_open_win(buf, false, { relative = "editor", anchor = "NE",
    row = 1, col = vim.o.columns, width = math.min(w + 4, 50), height = #lines,
    style = "minimal", border = "rounded" })
  api.nvim_set_option_value("wrap", false, { win = win })
  M._state = { win = win, buf = buf }
end

function M.show_file(p)
  local f = io.open(p, "r"); if not f then return end; local t = f:read("*a"); f:close(); M.show(vim.trim(t))
end

function M.hide()
  if M._state.win and api.nvim_win_is_valid(M._state.win) then api.nvim_win_close(M._state.win, true) end; M._state = {}
end

return M
