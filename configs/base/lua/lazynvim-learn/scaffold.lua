local M = {}

-- Set up a buffer with specific content for an exercise
function M.setup_buffer(content, filetype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
  vim.api.nvim_set_current_buf(buf)
  if filetype then
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
  end
end

-- Create a temp project structure for exercises
function M.setup_project(base_dir, files)
  vim.fn.mkdir(base_dir, "p")
  for path, content in pairs(files) do
    local full = base_dir .. "/" .. path
    local dir = vim.fn.fnamemodify(full, ":h")
    vim.fn.mkdir(dir, "p")
    local f = io.open(full, "w")
    if f then
      f:write(content)
      f:close()
    end
  end
  vim.cmd.cd(base_dir)
end

-- Mark a target in the buffer with extmarks (visual hint for user)
function M.mark_target(line, col, text)
  local ns = vim.api.nvim_create_namespace("lazynvim-learn")
  vim.api.nvim_buf_set_extmark(0, ns, line - 1, col, {
    virt_text = { { " <-- " .. text, "DiagnosticHint" } },
    virt_text_pos = "eol",
  })
end

-- Clear all tutorial markers
function M.clear_marks()
  local ns = vim.api.nvim_create_namespace("lazynvim-learn")
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
