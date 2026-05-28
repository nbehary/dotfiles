-- LSP Configuration
-- Defer setup until plugins are available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('lsp-setup-defer', { clear = true }),
  callback = function()
    local mason_ok, mason = pcall(require, 'mason')
    if not mason_ok then
      vim.notify('mason not available; LSP setup deferred', vim.log.levels.WARN)
      return
    end
    mason.setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if cmp_ok and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
      capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
    end

    local mti_ok, mti = pcall(require, 'mason-tool-installer')
    if mti_ok and mti.setup then
      mti.setup {
        ensure_installed = {
          'ktlint',
          'jdtls',
          'stylua',
          'java-debug-adapter',
          'kotlin-debug-adapter',
        },
        skip_update = false,
      }
    end
  end,
  once = true,
})

local function find_gradle_root()
  -- Prioritize settings.gradle (project root) over build.gradle (module root)
  local root = vim.fs.find({ 'settings.gradle', 'settings.gradle.kts' }, { upward = true })[1]
  if not root then
    root = vim.fs.find({ 'build.gradle', 'build.gradle.kts' }, { upward = true })[1]
  end
  if not root then
    root = vim.fs.find({ '.git' }, { upward = true })[1]
  end
  if root then
    local dir = vim.fs.dirname(root)
    if dir and dir ~= '' and dir ~= '.' then
      return dir
    end
  end
  return vim.fn.getcwd()
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('android-lsp-auto-init', { clear = true }),
  callback = function()
    -- Only auto-init if we are in an actual Gradle project
    local gradle_marker = vim.fs.find({ 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts' }, { upward = true })[1]
    if not gradle_marker then
      return
    end

    local root_dir = find_gradle_root()
    if not root_dir or root_dir == '' or root_dir == '.' then
      return
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

    local jdtls_ok, jdtls = pcall(require, 'jdtls')
    if jdtls_ok and jdtls then
      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
      local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

      local bundles = vim.split(
        vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
        '\n',
        { trimempty = true }
      )

      local cmp_ok2, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      local jdtls_capabilities = vim.lsp.protocol.make_client_capabilities()
      if cmp_ok2 and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
        jdtls_capabilities = vim.tbl_deep_extend('force', jdtls_capabilities, cmp_nvim_lsp.default_capabilities())
      end

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
    end

    local kls_jdk = find_jdk()
    local kls_env = nil
    if kls_jdk then
      kls_env = { JAVA_HOME = kls_jdk, PATH = kls_jdk .. '/bin:' .. (vim.env.PATH or '') }
    end

    vim.lsp.start({
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      cmd_env = kls_env,
      root_dir = root_dir,
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
          -- Disable LSP diagnostics (unreliable with false positives)
          -- Use ktlint via conform for reliable diagnostics instead
          diagnostics = {
            enabled = false,
          },
        },
      },
    })

    vim.schedule(function()
      vim.notify('Android project detected. Java (JDTLS) and Kotlin LSPs initializing... Kotlin LSP diagnostics disabled (ktlint for linting)', vim.log.levels.INFO)
    end)
  end,
  once = true,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kotlin',
  group = vim.api.nvim_create_augroup('kotlin-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
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
    local kls_jdk = find_jdk()
    local kls_env = nil
    if kls_jdk then
      kls_env = { JAVA_HOME = kls_jdk, PATH = kls_jdk .. '/bin:' .. (vim.env.PATH or '') }
    end

    local root_dir = find_gradle_root()

    vim.lsp.start {
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      cmd_env = kls_env,
      bufnr = bufnr,
      root_dir = root_dir,
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
            enabled = false,
          },
        },
      },
    }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  group = vim.api.nvim_create_augroup('lua-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
    end
    
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

vim.api.nvim_create_user_command('KotlinLspRestart', function()
  local clients = vim.lsp.get_clients { name = 'kotlin-language-server' }
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  vim.notify('Kotlin LSP stopped. It will restart on next buffer edit.', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command('LspStatus', function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify('No LSP clients active', vim.log.levels.WARN)
    return
  end
  local status = {}
  for _, client in ipairs(clients) do
    table.insert(status, client.name .. ' (ID: ' .. client.id .. ')')
  end
  vim.notify('Active LSP clients:\n' .. table.concat(status, '\n'), vim.log.levels.INFO)
end, {})
