-- General Plugin Configuration
-- Defer until plugins are available

-- Float terminal debounce state
local last_floaterm_toggle = 0
local floaterm_debounce_ms = 700

local function floaterm_toggle_debounced()
  local now = vim.loop.hrtime()
  local elapsed = (now - last_floaterm_toggle) / 1e6
  if elapsed < floaterm_debounce_ms then
    return
  end
  last_floaterm_toggle = now
  vim.cmd 'FloatermToggle'
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('plugin-configs', { clear = true }),
  callback = function()
    -- Float terminal toggle with debounce (700ms)
    vim.keymap.set('n', '<leader>;', floaterm_toggle_debounced, { desc = 'Toggle floating terminal' })
    vim.keymap.set('t', '<leader>;', floaterm_toggle_debounced, { desc = 'Toggle floating terminal' })

    -- Gitsigns Configuration
    pcall(function()
      require('gitsigns').setup()
      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk <CR>', { desc = 'Preview git hunk' })
      vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame <CR>', { desc = 'Toggle git blame' })
    end)

    -- Harpoon Configuration
    pcall(function()
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
    end)

    -- Undotree Configuration
    pcall(function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle undotree' })
    end)

    -- Comment.nvim Configuration
    pcall(function()
      require('Comment').setup()
    end)

    -- NvimTree Configuration
    pcall(function()
      require('nvim-tree').setup()
    end)

    -- Mini.nvim Configuration
    pcall(function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup()

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end)

    -- Todo Comments Configuration
    pcall(function()
      require('todo-comments').setup { signs = false }
    end)

    -- Edgy Configuration
    pcall(function()
      require('edgy').setup()
    end)

    -- Aerial (Code Structure) Configuration
    pcall(function()
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
    end)

    -- Leap Configuration
    vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
    vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-from-window)')
    require('leap').opts.case_sensitive = true

    -- Neogit Configuration
    pcall(function()
      require('neogit').setup {
        integrations = {
          diffview = true,
        },
      }
    end)

    -- Fidget Configuration (LSP progress)
    pcall(function()
      require('fidget').setup()
    end)
  end,
  once = true,
})
