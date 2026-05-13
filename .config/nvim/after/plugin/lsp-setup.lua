-- LSP Configuration
-- Defer setup until plugins are available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('lsp-setup-defer', { clear = true }),
  callback = function()
    -- Set up Mason first
    require('mason').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    require('mason-tool-installer').setup {
      ensure_installed = {
        'ktlint',
        'jdtls',
        'stylua',
        'java-debug-adapter',
        'kotlin-debug-adapter',
      },
      skip_update = false,
    }
  end,
  once = true,
})

-- Manually start Kotlin LSP on FileType
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kotlin',
  group = vim.api.nvim_create_augroup('kotlin-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    
    -- Check if already attached
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
    end
    
    -- Start kotlin-language-server
    vim.lsp.start {
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      bufnr = bufnr,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        kotlin = {
          compiler = {
            jvm = {
              target = '21',
            },
          },
          linting = {
            enabled = true,
          },
          completion = {
            snippets = {
              enabled = true,
            },
          },
          diagnostics = {
            enabled = true,
          },
        },
      },
      root_dir = vim.fs.dirname(vim.fs.find({ 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'pom.xml', '.git' }, { upward = true })[1] or '.'),
    }
  end,
})

-- Manually start Lua LSP on FileType
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  group = vim.api.nvim_create_augroup('lua-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    
    -- Check if already attached
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
    end
    
    -- Start lua-language-server
    vim.lsp.start {
      name = 'lua-language-server',
      cmd = { 'lua-language-server' },
      bufnr = bufnr,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
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
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    }
  end,
})

-- LspAttach autocommand for keymaps (can run at startup)
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
