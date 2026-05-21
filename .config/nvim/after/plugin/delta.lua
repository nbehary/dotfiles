-- Minimal configuration for kokusenz/delta.lua
-- Safe: only configures the plugin when available.
local ok, delta = pcall(require, 'delta')
if not ok then
  vim.notify('delta.lua not found', vim.log.levels.WARN)
  return
end

if type(delta.setup) == 'function' then
  delta.setup({
    -- sensible defaults; tweak as desired
    width = 80,
    side = 'right',
    border = 'rounded',
    diagnostics = true,
  })
end

-- Example keymap: prefer an "open" or "toggle" method if available
if type(delta.open) == 'function' then
  vim.keymap.set('n', '<leader>dd', delta.open, { noremap = true, silent = true, desc = 'Open Delta' })
elseif type(delta.toggle) == 'function' then
  vim.keymap.set('n', '<leader>dd', delta.toggle, { noremap = true, silent = true, desc = 'Toggle Delta' })
end
