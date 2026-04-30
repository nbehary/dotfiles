-- Auto-fold import block on file open
local function fold_imports()
  local first, last
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match '^import ' then
      first = first or i
      last = i
    end
  end
  if first and last and last > first then
    vim.opt_local.foldmethod = 'manual'
    vim.cmd(first .. ',' .. last .. 'fold')
  end
end

vim.schedule(fold_imports)

local jdtls = require 'jdtls'

local root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts', '.git', 'mvnw' }, { upward = true })[1])

-- Use a unique workspace directory per project
local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

-- Prefer Android Studio's bundled JDK
local java_cmd = 'java'
local android_studio_java = '/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java'
if vim.fn.executable(android_studio_java) == 1 then
  java_cmd = android_studio_java
end

-- Extended capabilities: merge cmp_nvim_lsp + jdtls extras
local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
  cmd = {
    vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls',
    '--java-executable', java_cmd,
    '-data', workspace_dir,
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
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = '/Applications/Android Studio.app/Contents/jbr/Contents/Home',
            default = true,
          },
        },
      },
    },
  },
  init_options = {
    extendedClientCapabilities = extendedClientCapabilities,
  },
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, desc = '' }

    opts.desc = 'Organize Imports'
    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, opts)

    opts.desc = 'Extract Variable'
    vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, opts)
    vim.keymap.set('v', '<leader>cv', function() jdtls.extract_variable(true) end, opts)

    opts.desc = 'Extract Constant'
    vim.keymap.set('n', '<leader>cc', jdtls.extract_constant, opts)
    vim.keymap.set('v', '<leader>cc', function() jdtls.extract_constant(true) end, opts)

    opts.desc = 'Extract Method'
    vim.keymap.set('v', '<leader>cm', function() jdtls.extract_method(true) end, opts)
  end,
}

jdtls.start_or_attach(config)
