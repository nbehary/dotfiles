-- Oil.nvim Configuration
-- Defer until oil is available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('oil-setup', { clear = true }),
  callback = function()
    local ok, oil = pcall(require, 'oil')
    if not ok then
      return
    end

    oil.setup {
      columns = { 'icon' },
      keymaps = {
        ['<C-h>'] = false,
        ['<M-h>'] = 'actions.select.split',
      },
      view_options = {
        show_hidden = true,
      },
    }

    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '<space>-', oil.toggle_float, { desc = 'Toggle floating oil window' })
  end,
  once = true,
})
