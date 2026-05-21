-- Minimal configuration for kokusenz/deltaview.nvim
-- Safe: only calls setup / maps when the plugin is available.
local ok, deltaview = pcall(require, 'deltaview')
if not ok then
  vim.notify('deltaview.nvim not found', vim.log.levels.WARN)
  return
end

if type(deltaview.setup) == 'function' then
  deltaview.setup({
    -- sensible defaults; tweak as desired
    width = 60,
    side = 'right',
    border = 'rounded',
    -- mappings here are examples — adjust according to the plugin's API
    mappings = {
      open = '<leader>do',
      close = 'q',
      next = 'j',
      prev = 'k',
    },
  })
end

-- Example keymap: only set if plugin exposes an "open" function
if type(deltaview.open) == 'function' then
  vim.keymap.set('n', '<leader>dv', deltaview.open, { noremap = true, silent = true, desc = 'Open Deltaview' })
end
