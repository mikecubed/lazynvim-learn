local M = {}

M.events = {}

function M.reset()
  M.events = {}
end

function M.track(event_name)
  table.insert(M.events, {
    name = event_name,
    time = vim.loop.now(),
  })
end

function M.has_event(name)
  for _, e in ipairs(M.events) do
    if e.name == name then return true end
  end
  return false
end

-- Set up autocommand to track LSP rename actions
function M.watch_lsp_rename()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LspRenameFile",
    callback = function() M.track("lsp_rename") end,
    once = true,
  })
end

-- Set up tracking for conform format actions
function M.watch_format()
  local ok, _ = pcall(require, "conform")
  if ok then
    M.track_format_pending = true
  end
end

return M
