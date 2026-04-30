-- Gitsigns Configuration

require('gitsigns').setup()
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk <CR>', { desc = 'Preview git hunk' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame <CR>', { desc = 'Toggle git blame' })

-- Harpoon Configuration

local mark = require 'harpoon.mark'
local ui = require 'harpoon.ui'

vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Add file to harpoon' })
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu, { desc = 'Toggle harpoon menu' })

vim.keymap.set('n', '<C-h>', function()
  ui.nav_file(1)
end, { desc = 'Navigate to harpoon file 1' })
vim.keymap.set('n', '<C-t>', function()
  ui.nav_file(2)
end, { desc = 'Navigate to harpoon file 2' })
vim.keymap.set('n', '<C-n>', function()
  ui.nav_file(3)
end, { desc = 'Navigate to harpoon file 3' })
vim.keymap.set('n', '<C-s>', function()
  ui.nav_file(4)
end, { desc = 'Navigate to harpoon file 4' })

-- Undotree Configuration

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle undotree' })

-- Comment.nvim Configuration

require('Comment').setup()

-- NvimTree Configuration

require('nvim-tree').setup()

-- Mini.nvim Configuration

require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup()

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- Todo Comments Configuration

require('todo-comments').setup { signs = false }

-- Edgy Configuration

require('edgy').setup()

-- Aerial (Code Structure) Configuration

require('aerial').setup {
  backends = { 'lsp', 'treesitter' },
  layout = {
    min_width = 30,
    default_direction = 'right',
  },
  filter_kind = {
    'Class',
    'Constructor',
    'Enum',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Struct',
    'Property',
    'Field',
  },
}

vim.keymap.set('n', '<leader>cs', '<cmd>AerialToggle!<CR>', { desc = '[C]ode [S]tructure (Aerial)' })
vim.keymap.set('n', '<leader>cn', '<cmd>AerialNavToggle<CR>', { desc = '[C]ode [N]avigation (Aerial)' })

-- Leap Configuration

local leap = require 'leap'
leap.add_default_mappings()
leap.opts.case_sensitive = true

-- Neogit Configuration

require('neogit').setup {
  integrations = {
    diffview = true,
  },
}

-- Fidget Configuration (LSP progress)

require('fidget').setup()
