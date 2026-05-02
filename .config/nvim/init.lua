-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('i', 'jk', '<ESC>')
vim.keymap.set('n', '<leader>pv', ':NvimTreeToggle<cr>')

-- [[ Setting options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.hlsearch = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local highlights = {
      'Normal', 'LineNr', 'Folded', 'NonText', 'SpecialKey',
      'VertSplit', 'SignColumn', 'EndOfBuffer',
    }
    for _, name in pairs(highlights) do
      vim.cmd.highlight(name .. ' guibg=none ctermbg=none ')
    end
  end,
})

-- [[ Plugins ]]
-- Run build steps after install/update for plugins that need compilation
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    local dir = vim.fn.stdpath('data') .. '/pack/plugins/opt/' .. ev.data.name
    if ev.data.name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.system({ 'make' }, { cwd = dir })
    elseif ev.data.name == 'LuaSnip'
      and vim.fn.has('win32') == 0
      and vim.fn.executable('make') == 1
    then
      vim.system({ 'make', 'install_jsregexp' }, { cwd = dir })
    end
  end,
})

vim.pack.add({
  -- Dependencies first
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/folke/snacks.nvim',

  -- Editing
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/Tetralux/odin.vim',
  'https://github.com/tidalcycles/vim-tidal',
  'https://github.com/mfussenegger/nvim-jdtls',
  'https://github.com/timtro/glslView-nvim',
  'https://github.com/numToStr/Comment.nvim',
  'https://github.com/mbbill/undotree',
  'https://github.com/theprimeagen/harpoon',

  -- File navigation
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/stevearc/aerial.nvim',

  -- Git
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/NeogitOrg/neogit',

  -- UI
  'https://github.com/voldikss/vim-floaterm',
  'https://github.com/folke/edgy.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/echasnovski/mini.nvim',

  -- Telescope
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = '0.1.x' },
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',

  -- AI
  'https://github.com/coder/claudecode.nvim',
  'https://github.com/greggh/claude-code.nvim',

  -- Formatting
  'https://github.com/stevearc/conform.nvim',

  -- LSP
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/neovim/nvim-lspconfig',

  -- Completion
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/saadparwaiz1/cmp_luasnip',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/nvim-cmp',

  -- Colors
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/RRethy/base16-nvim',
})

-- [[ Plugin Configuration ]]

-- leap
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-from-window)')

-- Comment
require('Comment').setup()

-- nvim-tree
require('nvim-tree').setup()

-- vim-floaterm
vim.keymap.set('n', '<leader>;', '<cmd>FloatermToggle<cr>', { desc = 'Toggle floating terminal' })
vim.keymap.set('t', '<leader>;', '<cmd>FloatermToggle<cr>', { desc = 'Toggle floating terminal' })

-- edgy
require('edgy').setup()

-- aerial
require('aerial').setup({
  backends = { 'lsp', 'treesitter' },
  layout = { min_width = 30, default_direction = 'right' },
  filter_kind = {
    'Class', 'Constructor', 'Enum', 'Function', 'Interface',
    'Method', 'Module', 'Struct', 'Property', 'Field',
  },
})
vim.keymap.set('n', '<leader>cs', '<cmd>AerialToggle!<CR>', { desc = '[C]ode [S]tructure (Aerial)' })
vim.keymap.set('n', '<leader>cn', '<cmd>AerialNavToggle<CR>', { desc = '[C]ode [N]avigation (Aerial)' })

-- gitsigns
require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk <CR>')
vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame <CR>')

-- lazygit
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'Open Lazy Git' })

-- harpoon
local mark = require('harpoon.mark')
local ui = require('harpoon.ui')
vim.keymap.set('n', '<leader>a', mark.add_file)
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)
vim.keymap.set('n', '<leader>1', function() ui.nav_file(1) end)
vim.keymap.set('n', '<leader>2', function() ui.nav_file(2) end)
vim.keymap.set('n', '<leader>3', function() ui.nav_file(3) end)
vim.keymap.set('n', '<leader>4', function() ui.nav_file(4) end)

-- undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- neogit
require('neogit').setup()

-- todo-comments
require('todo-comments').setup({ signs = false })

-- mini.nvim
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
local statusline = require('mini.statusline')
statusline.setup()
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- telescope
require('telescope').setup({
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
})
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- oil
require('oil').setup({
  columns = { 'icon' },
  keymaps = {
    ['<C-h>'] = false,
    ['<M-h>'] = 'actions.select.split',
  },
  view_options = {
    show_hidden = true,
  },
})
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '<space>-', require('oil').toggle_float)

-- greggh/claude-code.nvim
require('claude-code').setup()

-- coder/claudecode.nvim
require('claudecode').setup()
vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
vim.keymap.set('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
vim.keymap.set('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Select Claude model' })
vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
  callback = function()
    vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>',
      { buffer = true, desc = 'Add file' })
  end,
})

-- conform
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    kotlin = { 'ktlint' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
vim.keymap.set({ 'n', 'v' }, '<leader>l', function()
  require('conform').format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = 'Format file or range (in visual mode)' })

-- fidget
require('fidget').setup()

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- LSP utility commands (replaces nvim-lspconfig's :LspLog, :LspRestart, :LspInfo)
vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd('edit ' .. vim.lsp.get_log_path())
end, { desc = 'Open LSP log' })

vim.api.nvim_create_user_command('LspRestart', function()
  local bufnr = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    vim.lsp.stop_client(client.id, true)
  end
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds('FileType', { buf = bufnr })
  end, 500)
end, { desc = 'Restart LSP clients for current buffer' })

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify('No LSP clients attached', vim.log.levels.INFO)
    return
  end
  for _, c in ipairs(clients) do
    vim.notify(string.format('[%d] %s  root: %s', c.id, c.name, c.root_dir or '?'), vim.log.levels.INFO)
  end
end, { desc = 'Show attached LSP clients' })

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)

-- Apply cmp capabilities to all auto-enabled servers
vim.lsp.config('*', { capabilities = capabilities })

vim.lsp.config('kotlin_lsp', {
  cmd = (function()
    local kotlin_lsp_dir = vim.fn.glob(vim.fn.expand('~/.local/share/nvim/mason/packages/kotlin-lsp/kotlin-server-*'), false, true)[1]
    if kotlin_lsp_dir then
      return { kotlin_lsp_dir .. '/bin/intellij-server' }
    end
    return { 'kotlin-language-server' }
  end)(),
})
vim.lsp.enable('kotlin_lsp')

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = {
          '${3rd}/luv/library',
          unpack(vim.api.nvim_get_runtime_file('', true)),
        },
      },
      completion = { callSnippet = 'Replace' },
    },
  },
})

require('mason').setup()
require('mason-tool-installer').setup({
  ensure_installed = { 'ktlint', 'jdtls', 'kotlin-lsp', 'stylua' },
})
require('mason-lspconfig').setup({
  automatic_enable = { exclude = { 'jdtls', 'kotlin_lsp' } },
})

-- nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')
luasnip.config.setup()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = 'menu,menuone,noinsert' },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { 'i', 's' }),
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
})

-- nvim-treesitter
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local ok, configs = pcall(require, 'nvim-treesitter.configs')
    if not ok then return end
    configs.setup({
      ensure_installed = { 'kotlin', 'java', 'groovy', 'xml', 'toml', 'lua', 'markdown', 'json', 'yaml' },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
})

-- Colorscheme (load last)
require('plugins.dankcolors')

-- vim: ts=2 sts=2 sw=2 et
