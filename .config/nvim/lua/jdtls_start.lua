-- Shared jdtls startup used by both java.lua and kotlin.lua (Android projects).
-- opts.java_keymaps = true  →  adds jdtls Java refactor keymaps (java.lua only)
return function(opts)
  opts = opts or {}

  local jdtls = require 'jdtls'

  local root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts', '.git', 'mvnw' }, { upward = true })[1])

  local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

  local java_cmd = 'java'
  local as_jbr = nil
  for _, dir in ipairs { vim.fn.expand '~/android-studio', '/opt/android-studio' } do
    if vim.fn.executable(dir .. '/jbr/bin/java') == 1 then
      java_cmd = dir .. '/jbr/bin/java'
      as_jbr = dir .. '/jbr'
      break
    end
  end
  local jdk_home = as_jbr or os.getenv 'JAVA_HOME' or '/usr/lib/jvm/java-21-openjdk'

  local bundles = vim.split(
    vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
    '\n',
    { trimempty = true }
  )

  local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local config = {
    cmd = {
      vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls',
      '--java-executable',
      java_cmd,
      '-data',
      workspace_dir,
    },
    root_dir = root_dir,
    capabilities = capabilities,
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
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
          },
        },
        sources = {
          organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
        },
        codeGeneration = {
          toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
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
    on_attach = function(client, bufnr)
      if #bundles > 0 then
        jdtls.setup_dap { hotcodereplace = 'auto' }
      end

      if opts.java_keymaps then
        local o = { buffer = bufnr, desc = '' }
        o.desc = 'Organize Imports'
        vim.keymap.set('n', '<leader>co', jdtls.organize_imports, o)
        o.desc = 'Extract Variable'
        vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, o)
        vim.keymap.set('v', '<leader>cv', function() jdtls.extract_variable(true) end, o)
        o.desc = 'Extract Constant'
        vim.keymap.set('n', '<leader>cc', jdtls.extract_constant, o)
        vim.keymap.set('v', '<leader>cc', function() jdtls.extract_constant(true) end, o)
        o.desc = 'Extract Method'
        vim.keymap.set('v', '<leader>cm', function() jdtls.extract_method(true) end, o)
      end
    end,
  }

  jdtls.start_or_attach(config)
end
