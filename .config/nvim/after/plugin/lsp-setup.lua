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

-- Auto-initialize Java and Kotlin LSPs in Android projects on startup
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('android-lsp-auto-init', { clear = true }),
  callback = function()
    -- Detect Android project: look for build.gradle/gradlew upward from cwd
    local root_dir = vim.fs.dirname(
      vim.fs.find({ 'build.gradle', 'build.gradle.kts', 'gradlew' }, { upward = true })[1] or ''
    )

    if root_dir == '' or root_dir == '.' then
      return -- Not an Android project
    end

    local function find_jdk()
      local candidates = {
        os.getenv('KOTLIN_LSP_JDK'),
        vim.fn.expand('~/android-studio/jbr'),
        '/opt/android-studio/jbr',
        '/usr/lib/jvm/java-21-openjdk',
        '/usr/lib/jvm/java-17-openjdk',
        '/opt/homebrew/opt/openjdk@21',
        '/opt/homebrew/opt/openjdk@17',
      }
      for _, dir in ipairs(candidates) do
        if dir and vim.fn.executable(dir .. '/bin/java') == 1 then
          return dir
        end
      end
      return nil
    end

    local jdk_home = find_jdk()
    local java_cmd = 'java'
    for _, dir in ipairs({ vim.fn.expand('~/android-studio'), '/opt/android-studio' }) do
      if vim.fn.executable(dir .. '/jbr/bin/java') == 1 then
        java_cmd = dir .. '/jbr/bin/java'
        jdk_home = dir .. '/jbr'
        break
      end
    end
    jdk_home = jdk_home or os.getenv('JAVA_HOME') or '/usr/lib/jvm/java-21-openjdk'

    -- Start JDTLS (Java)
    local jdtls = require('jdtls')
    local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

    local bundles = vim.split(
      vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
      '\n',
      { trimempty = true }
    )

    local jdtls_capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())
    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local jdtls_config = {
      cmd = {
        vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls'),
        '--java-executable', java_cmd,
        '-data', workspace_dir,
      },
      root_dir = root_dir,
      capabilities = jdtls_capabilities,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = 'fernflower' },
          completion = {
            favoriteStaticMembers = {
              'org.junit.Assert.*',
              'org.junit.jupiter.api.Assertions.*',
              'org.mockito.Mockito.*',
              'io.mockk.MockKKt.*',
            },
            filteredTypes = {
              'com.sun.*', 'io.micrometer.shaded.*', 'java.awt.*', 'jdk.*', 'sun.*',
            },
          },
          sources = {
            organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
          },
          codeGeneration = {
            toString = {
              template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            },
            useBlocks = true,
          },
          configuration = {
            runtimes = {
              { name = 'JavaSE-21', path = jdk_home, default = true },
            },
          },
        },
      },
      init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
      },
    }

    jdtls.start_or_attach(jdtls_config)

    -- Start Kotlin LSP
    local kls_jdk = find_jdk()
    local kls_env = nil
    if kls_jdk then
      kls_env = { JAVA_HOME = kls_jdk, PATH = kls_jdk .. '/bin:' .. (vim.env.PATH or '') }
    end

    vim.lsp.start({
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      cmd_env = kls_env,
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
      root_dir = root_dir,
    })

    vim.notify('Android project detected. Java (JDTLS) and Kotlin LSPs initializing...', vim.log.levels.INFO)
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
    
    -- Resolve a JDK kotlin-language-server can actually run (it requires JDK <= 21,
    -- and on some systems JAVA_HOME points at a macOS Android Studio path or the
    -- distro's "default" JDK is too new). Try a few well-known locations.
    local function find_jdk()
      local candidates = {
        os.getenv('KOTLIN_LSP_JDK'),
        vim.fn.expand('~/android-studio/jbr'),
        '/opt/android-studio/jbr',
        '/usr/lib/jvm/java-21-openjdk',
        '/usr/lib/jvm/java-17-openjdk',
        '/opt/homebrew/opt/openjdk@21',
        '/opt/homebrew/opt/openjdk@17',
      }
      for _, dir in ipairs(candidates) do
        if dir and vim.fn.executable(dir .. '/bin/java') == 1 then
          return dir
        end
      end
      return nil
    end
    local kls_jdk = find_jdk()
    local kls_env = nil
    if kls_jdk then
      kls_env = { JAVA_HOME = kls_jdk, PATH = kls_jdk .. '/bin:' .. (vim.env.PATH or '') }
    end

    -- Start kotlin-language-server
    vim.lsp.start {
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      cmd_env = kls_env,
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
