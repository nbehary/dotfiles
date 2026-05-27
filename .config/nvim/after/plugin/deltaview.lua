-- Minimal configuration for kokusenz/deltaview.nvim
-- Safe: only calls setup / maps when the plugin is available.
local ok, deltaview = pcall(require, 'deltaview')
if not ok then
  vim.notify('deltaview.nvim not found', vim.log.levels.WARN)
  return
end

-- Configure deltaview safely and add keymap to open changes from last commit for current file
if type(deltaview.setup) == 'function' then
  deltaview.setup({
    width = 60,
    side = 'right',
    border = 'rounded',
    -- Keep default keyconfig; user mapping below handles the requested quick action
  })
end

-- Map <leader>dc to open Delta for the current file against HEAD~1 (last commit)
vim.keymap.set('n', '<leader>dc', function()
  local path = vim.fn.expand('%:p')
  if path == nil or path == '' then
    path = vim.fn.getcwd()
  end
  -- Use :Delta <path> <context> <ref> to open file-specific diff. Context 3 chosen as sensible default.
  local cmd = string.format("Delta %s %d %s", vim.fn.fnameescape(path), 3, 'HEAD~1')
  vim.cmd(cmd)
end, { noremap = true, silent = true, desc = 'Delta: show changes from last commit for this file' })
