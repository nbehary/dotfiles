vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8
vim.g.floaterm_position = 'center'

vim.keymap.set('n', '<leader>t', '<cmd>FloatermToggle<CR>', { desc = 'Toggle float terminal' })
vim.keymap.set('t', '<leader>t', '<cmd>FloatermToggle<CR>', { desc = 'Toggle float terminal' })
vim.keymap.set('n', '<leader>tn', '<cmd>FloatermNew<CR>', { desc = 'New float terminal' })
vim.keymap.set('t', '<leader>tn', '<cmd>FloatermNew<CR>', { desc = 'New float terminal' })
vim.keymap.set('n', '<leader>tl', '<cmd>FloatermNext<CR>', { desc = 'Next float terminal' })
vim.keymap.set('t', '<leader>tl', '<cmd>FloatermNext<CR>', { desc = 'Next float terminal' })
vim.keymap.set('n', '<leader>tr', '<cmd>FloatermPrev<CR>', { desc = 'Prev float terminal' })
vim.keymap.set('t', '<leader>tr', '<cmd>FloatermPrev<CR>', { desc = 'Prev float terminal' })
vim.keymap.set('n', '<leader>tk', '<cmd>FloatermKill<CR>', { desc = 'Kill float terminal' })
vim.keymap.set('t', '<leader>tk', '<cmd>FloatermKill<CR>', { desc = 'Kill float terminal' })
