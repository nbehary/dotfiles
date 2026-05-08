-- ============================================================================
-- Neovim Configuration (Migrated from lazy.nvim to vim.pack)
-- ============================================================================
-- This config uses vim.pack (classic plugin management) for plugin loading.
-- Plugins are stored in ~/.config/nvim/pack/github/start/ and pack/github/opt/
-- Plugin configurations are in after/plugin/ and plugin/ directories
-- ============================================================================

-- Set <space> as the leader key (must happen before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Point Neovim at the dedicated pynvim virtualenv (avoids Homebrew PEP 668 restriction)
vim.g.python3_host_prog = vim.fn.expand '~/.venv/nvim/bin/python3'

-- Start listening on /tmp/nvim socket for MCP servers (Claude Desktop, Copilot CLI)
vim.fn.serverstart '/tmp/nvim'

-- Insert-mode escape
vim.keymap.set('i', 'jk', '<ESC>')

-- NvimTree toggle
vim.keymap.set('n', '<leader>pv', ':NvimTreeToggle<cr>')

-- Neogit
vim.keymap.set('n', '<leader>n', ':Neogit<cr>', { desc = 'Neogit status' })

-- [[ Gradle.nvim keybindings ]]
vim.keymap.set({ 'n', 'v' }, '<leader>Gg', '<cmd>Gradle<cr>', { desc = 'Gradle Projects' })
vim.keymap.set({ 'n', 'v' }, '<leader>Gf', '<cmd>GradleFavorites<cr>', { desc = 'Gradle Favorite Commands' })

-- [[ Diagnostic keybindings ]]
vim.keymap.set('n', '<leader>dw', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Next error' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Prev error' })

-- [[ Tab navigation ]]
vim.keymap.set('n', '<leader>tn', '<cmd>tabnext<cr>', { desc = 'Next tab' })
vim.keymap.set('n', '<leader>tp', '<cmd>tabprev<cr>', { desc = 'Prev tab' })
vim.keymap.set('n', '<leader>tN', '<cmd>tabnew<cr>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>td', '<cmd>tabclose<cr>', { desc = 'Close tab' })

-- [[ Diagnostic display ]]
vim.diagnostic.config {
  virtual_text = { prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = true },
}

-- [[ Setting options ]]
-- See `:help vim.opt`
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.clipboard = 'unnamedplus'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- [[ Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Transparent background
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local highlights = {
      'Normal',
      'LineNr',
      'Folded',
      'NonText',
      'SpecialKey',
      'VertSplit',
      'SignColumn',
      'EndOfBuffer',
    }
    for _, name in pairs(highlights) do
      vim.cmd.highlight(name .. ' guibg=none ctermbg=none ')
    end
  end,
})

-- [[ Load colorscheme ]]
-- Load plugins first (via vim.pack automatic loading), then set colorscheme
-- This ensures colorscheme plugin is available before we try to use it
vim.cmd.colorscheme 'catppuccin-mocha'
vim.cmd.hi 'Comment gui=none'

-- vim: ts=2 sts=2 sw=2 et
