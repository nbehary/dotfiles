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

-- Start listening on /tmp/nvim socket for MCP servers (Claude Desktop, Claude Code)
-- Remove stale socket file, then start; silently skip if another instance owns it
local nvim_sock = '/tmp/nvim'
if vim.uv.fs_stat(nvim_sock) then
  os.remove(nvim_sock)
end
local ok, err = pcall(vim.fn.serverstart, nvim_sock)
if not ok then
  vim.notify('serverstart(/tmp/nvim) skipped: ' .. err, vim.log.levels.WARN)
end

-- Insert-mode escape
vim.keymap.set('i', 'jk', '<ESC>')

-- NvimTree toggle
vim.keymap.set('n', '<leader>pv', function()
  vim.cmd('NvimTreeToggle')
  pcall(vim.cmd, 'NvimTreeFocus')
end, { desc = 'NvimTree toggle and focus' })

-- Focus NvimTree when opened by any command
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    pcall(vim.cmd, 'NvimTreeFocus')
  end,
})

-- Neogit
vim.keymap.set('n', '<leader>n', ':Neogit<cr>', { desc = 'Neogit status' })

-- Diffview
vim.keymap.set('n', '<leader>gd', ':DiffviewOpen HEAD~1..HEAD<cr>', { desc = 'Diffview (latest commit)' })
vim.keymap.set('n', '<leader>gx', ':DiffviewClose<cr>', { desc = 'Close Diffview' })
-- Diff current buffer file between development and current branch
vim.keymap.set('n', '<leader>gF', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end
  -- Try to resolve the git repo root from the file's directory, fall back to cwd
  local file_dir = vim.fn.fnamemodify(bufname, ':h')
  local root = vim.fn.systemlist('git -C ' .. vim.fn.fnameescape(file_dir) .. ' rev-parse --show-toplevel')[1]
  if not root or root == '' then
    root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  end
  if not root or root == '' then
    vim.notify('Not in a git repository', vim.log.levels.WARN)
    return
  end
  local branch = vim.fn.systemlist('git -C ' .. vim.fn.fnameescape(root) .. ' rev-parse --abbrev-ref HEAD')[1]
  if not branch or branch == '' then
    vim.notify('Could not determine current branch', vim.log.levels.WARN)
    return
  end
  -- Compute path relative to repo root
  local relpath = bufname
  if relpath:sub(1, #root) == root then
    -- strip leading root + '/'
    relpath = relpath:sub(#root + 2)
  else
    relpath = vim.fn.fnamemodify(relpath, ':.')
  end
  local prev_cwd = vim.fn.getcwd()
  vim.api.nvim_set_current_dir(root)
  vim.cmd('DiffviewOpen ' .. 'development' .. '..' .. branch .. ' ' .. vim.fn.fnameescape(relpath))
  vim.api.nvim_set_current_dir(prev_cwd)
end, { desc = 'Diff current file between development and current branch' })

-- [[ Gradle.nvim keybindings ]]
vim.keymap.set({ 'n', 'v' }, '<leader>Gg', '<cmd>Gradle<cr>', { desc = 'Gradle Projects' })
vim.keymap.set({ 'n', 'v' }, '<leader>Gf', '<cmd>GradleFavorites<cr>', { desc = 'Gradle Favorite Commands' })

-- [[ Diagnostic keybindings ]]
vim.keymap.set('n', '<leader>dw', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
vim.keymap.set('n', '<leader>dd', function() vim.diagnostic.enable(false, 0) end, { desc = 'Hide diagnostics' })
vim.keymap.set('n', '<leader>de', function() vim.diagnostic.enable(true, 0) end, { desc = 'Show diagnostics' })
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

-- Auto save when leaving insert mode
vim.api.nvim_create_augroup('AutoSaveOnInsertLeave', { clear = true })
vim.api.nvim_create_autocmd('InsertLeave', {
  group = 'AutoSaveOnInsertLeave',
  pattern = '*',
  callback = function()
    if vim.bo.modified and vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' and not vim.bo.readonly then
      vim.cmd('silent! update')
    end
  end,
})

-- Diagnostics: hide on file open, show after save
vim.api.nvim_create_augroup('DiagnosticsAutoToggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNew' }, {
  group = 'DiagnosticsAutoToggle',
  pattern = '*',
  callback = function(args)
    local buftype = vim.bo[args.buf].buftype
    -- Only disable diagnostics for normal file buffers, not special ones
    if buftype == '' and vim.diagnostic then
      vim.diagnostic.enable(false, { bufnr = args.buf })
    end
  end,
})
vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'DiagnosticsAutoToggle',
  pattern = '*',
  callback = function(args)
    local buftype = vim.bo[args.buf].buftype
    if buftype == '' and vim.diagnostic then
      vim.diagnostic.enable(true, { bufnr = args.buf })
    end
  end,
})

-- [[ Load colorscheme ]]
-- Ensure optional colorscheme plugin is loaded before applying
pcall(vim.cmd, 'packadd kanagawa.nvim')
local ok, err = pcall(vim.cmd, 'colorscheme kanagawa')
if not ok then
  vim.notify('Cannot load colorscheme kanagawa: ' .. tostring(err), vim.log.levels.WARN)
end
pcall(vim.cmd, "hi Comment gui=none")

-- vim: ts=2 sts=2 sw=2 et
