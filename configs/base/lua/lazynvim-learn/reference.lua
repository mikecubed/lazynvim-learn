local M = { _state = {} }

function M.show(text)
  M.hide()
  local lines = vim.split(text, "\n")
  local w, buf = 0, vim.api.nvim_create_buf(false, true)
  for _, l in ipairs(lines) do w = math.max(w, #l) end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor", anchor = "NE", row = 1, col = vim.o.columns,
    width = math.min(w + 4, 50), height = #lines, style = "minimal", border = "rounded",
  })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  M._state = { win = win, buf = buf }
end

function M.hide()
  if M._state.win and vim.api.nvim_win_is_valid(M._state.win) then vim.api.nvim_win_close(M._state.win, true) end
  M._state = {}
end

return M
