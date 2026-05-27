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

    -- Float terminal: new, next, prev
    vim.keymap.set('n', '<leader>T', '<cmd>FloatermNew<CR>', { desc = 'New floating terminal' })
    vim.keymap.set('t', '<leader>T', '<cmd>FloatermNew<CR>', { desc = 'New floating terminal' })
    vim.keymap.set('n', ']t', '<cmd>FloatermNext<CR>', { desc = 'Next floating terminal' })
    vim.keymap.set('t', ']t', '<cmd>FloatermNext<CR>', { desc = 'Next floating terminal' })
    vim.keymap.set('n', '[t', '<cmd>FloatermPrev<CR>', { desc = 'Prev floating terminal' })
    vim.keymap.set('t', '[t', '<cmd>FloatermPrev<CR>', { desc = 'Prev floating terminal' })

    -- Lazylogcat Floaterm
    local lazylogcat_wintype = 'float'
    local function toggle_lazylogcat()
      local bufnr = vim.fn['floaterm#terminal#get_bufnr']('lazylogcat')
      if bufnr == -1 then
        local root = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts' }, { upward = true })[1] or vim.fn.getcwd())
        local cmd_str = "cd " .. vim.fn.shellescape(root) .. " && grep -m 1 -h -oE 'applicationId[[:space:]]*=?[[:space:]]*\"[^\"]+\"' build.gradle.kts app/build.gradle.kts build.gradle app/build.gradle 2>/dev/null | grep -oE '\"[^\"]+\"' | tr -d '\"'"
        local handle = io.popen(cmd_str)
        local pkg = ''
        if handle then
          pkg = handle:read('*a'):gsub('%s+', '')
          handle:close()
        end
        local cmd = 'lazylogcat'
        if pkg ~= '' then
          cmd = cmd .. ' --pkg ' .. vim.fn.shellescape(pkg)
        end
        local pos = lazylogcat_wintype == 'float' and 'center' or 'bottom'
        vim.cmd('FloatermNew --name=lazylogcat --title=lazylogcat --wintype=' .. lazylogcat_wintype .. ' --position=' .. pos .. ' ' .. cmd)
      else
        vim.cmd('FloatermToggle lazylogcat')
      end
    end

    local function swap_lazylogcat_wintype()
      lazylogcat_wintype = lazylogcat_wintype == 'float' and 'split' or 'float'
      local pos = lazylogcat_wintype == 'float' and 'center' or 'bottom'
      local bufnr = vim.fn['floaterm#terminal#get_bufnr']('lazylogcat')
      if bufnr ~= -1 then
        vim.cmd('FloatermUpdate --name=lazylogcat --wintype=' .. lazylogcat_wintype .. ' --position=' .. pos)
      else
        vim.notify('lazylogcat not running, will open as ' .. lazylogcat_wintype .. ' next time.', vim.log.levels.INFO)
      end
    end

    vim.keymap.set('n', '<leader>ll', toggle_lazylogcat, { desc = 'Toggle lazylogcat' })
    vim.keymap.set('t', '<leader>ll', toggle_lazylogcat, { desc = 'Toggle lazylogcat' })
    vim.keymap.set('n', '<leader>ls', swap_lazylogcat_wintype, { desc = 'Swap lazylogcat window type' })
    vim.keymap.set('t', '<leader>ls', swap_lazylogcat_wintype, { desc = 'Swap lazylogcat window type' })

    -- Gitsigns Configuration
    pcall(function()
      require('gitsigns').setup()
      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk <CR>', { desc = 'Preview git hunk' })
      vim.keymap.set('n', '<leader>gl', ':Gitsigns toggle_current_line_blame <CR>', { desc = 'Toggle git blame' })
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = 'Open diffview (all changes)' })
      vim.keymap.set('n', '<leader>gdf', function()
        vim.cmd('DiffviewOpen HEAD -- ' .. vim.fn.expand('%'))
      end, { desc = 'Diff current file' })
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

      vim.keymap.set('n', '<leader>hc', function()
        mark.clear_all()
        vim.notify('Harpoon list cleared', vim.log.levels.INFO)
      end, { desc = 'Clear all harpoon marks' })
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
    pcall(function()
      require('leap').opts.case_sensitive = true
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-from-window)')
    end)

    -- Android Plugin Configuration
    pcall(function()
      require('android').setup()
      vim.keymap.set('n', '<leader>al', '<cmd>AndroidLogcat<cr>', { desc = '[A]ndroid [L]ogcat' })
      vim.keymap.set('n', '<leader>ag', '<cmd>AndroidGradleTasks<cr>', { desc = '[A]ndroid [G]radle tasks' })
    end)

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

    -- CopilotChat Configuration
    pcall(function()
      require('CopilotChat').setup()
      vim.keymap.set('n', '<leader>ai', ':CopilotChat<cr>', { desc = 'CopilotChat' })
      vim.keymap.set('v', '<leader>ai', ':CopilotChat<cr>', { desc = 'CopilotChat' })
    end)

    -- CodeCompanion Configuration
    pcall(function()
      require('codecompanion').setup()
      vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = '[C]ode[C]ompanion Chat' })
      vim.keymap.set('v', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = '[C]ode[C]ompanion Chat' })
      vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = '[C]ode[C]ompanion [A]ctions' })
      vim.keymap.set('v', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = '[C]ode[C]ompanion [A]ctions' })
    end)
  end,
  once = true,
})
