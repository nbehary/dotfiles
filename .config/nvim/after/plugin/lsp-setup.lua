-- LSP Configuration
-- Defer setup until plugins are available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('lsp-setup-defer', { clear = true }),
  callback = function()
    -- Enable verbose LSP logging
    vim.lsp.set_log_level 'debug'

    local ok, lspconfig = pcall(require, 'lspconfig')
    if not ok then
      return
    end

    -- Set up Mason first
    require('mason').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- kotlin-lsp (JetBrains intellij-server) needs --stdio for stdin/stdout LSP mode
    vim.lsp.config('kotlin_lsp', {
      cmd = (function()
        local mason_dir = vim.fn.expand '~/.local/share/nvim/mason/packages/kotlin-lsp'
        local kotlin_server_dir = vim.fn.glob(mason_dir .. '/kotlin-server-*', false, true)[1]
        if kotlin_server_dir then
          local server_path = kotlin_server_dir .. '/bin/intellij-server'
          if vim.fn.executable(server_path) == 1 then
            return { server_path, '--stdio' }
          end
        end
        return { 'kotlin-language-server' }
      end)(),
      capabilities = capabilities,
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
      root_dir = require('lspconfig.util').root_pattern('build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', '.git'),
      init_options = {
        storagePath = vim.fn.expand '~/.cache/kotlin-lsp',
      },
      on_attach = function(client, bufnr)
        -- Force workspace scan for Android project on first attach
        if client.name == 'kotlin_lsp' then
          vim.notify('Kotlin LSP indexing workspace…', vim.log.levels.INFO)
          vim.schedule(function()
            if client.server_capabilities.workspaceSymbolProvider then
              local success = pcall(function()
                client.request('workspace/symbol', { query = '*' }, function()
                  vim.notify('Kotlin LSP indexing complete', vim.log.levels.INFO)
                end, bufnr)
              end)
            end
          end)
        end
      end,
    })
    vim.lsp.enable 'kotlin_lsp'

    local servers = {
      lua_ls = {
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
      },
    }

    require('mason-tool-installer').setup {
      ensure_installed = {
        'ktlint',
        'jdtls',
        'kotlin-lsp',
        'stylua',
        'java-debug-adapter',
        'kotlin-debug-adapter',
      },
      skip_update = false,
    }

    -- Explicitly disable kotlin-language-server to prevent auto-installation
    local registry = require 'mason-registry'
    registry.refresh(function()
      local pkg = registry.get_package 'kotlin-language-server'
      if pkg:is_installed() then
        pkg:uninstall()
      end
    end)

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          lspconfig[server_name].setup(server)
        end,
        ['jdtls'] = function() end,
        -- kotlin_lsp (JetBrains IntelliJ server) is configured manually above
        -- via vim.lsp.config/vim.lsp.enable and handles Android generated sources
        -- (BuildConfig, R, etc.) through Gradle project import. Suppress the
        -- community kotlin_language_server which has no Android/AGP awareness.
        ['kotlin_lsp'] = function() end,
        ['kotlin_language_server'] = function() end,
      },
      automatic_installation = false, -- Don't auto-install; only use ensure_installed
    }
  end,
  once = true,
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
