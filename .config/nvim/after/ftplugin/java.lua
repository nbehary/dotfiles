local function fold_imports()
  local first, last
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match('^import ') then
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

local jdtls = require('jdtls')

local _root = vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts', '.git', 'mvnw' }, { upward = true })
local root_dir = nil
if _root and _root[1] then
  root_dir = vim.fs.dirname(_root[1])
end

local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

-- Prefer Android Studio's bundled JDK; fall back to JAVA_HOME or system java
local java_cmd = 'java'
local as_jbr = nil
for _, dir in ipairs({ vim.fn.expand('~/android-studio'), '/opt/android-studio' }) do
  if vim.fn.executable(dir .. '/jbr/bin/java') == 1 then
    java_cmd = dir .. '/jbr/bin/java'
    as_jbr = dir .. '/jbr'
    break
  end
end
local jdk_home = as_jbr or os.getenv('JAVA_HOME') or '/usr/lib/jvm/java-21-openjdk'

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
  cmd = {
    vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls'),
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
      maxConcurrentBuilds = 1,
    },
  },
  init_options = {
    extendedClientCapabilities = extendedClientCapabilities,
  },
  on_attach = function(_, bufnr)
    local opts = { buffer = bufnr }

    opts.desc = 'Organize Imports'
    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, opts)

    opts.desc = 'Extract Variable'
    vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, opts)
    vim.keymap.set('v', '<leader>cv', function() jdtls.extract_variable(true) end, opts)

    opts.desc = 'Extract Constant'
    vim.keymap.set('n', '<leader>ce', jdtls.extract_constant, opts)
    vim.keymap.set('v', '<leader>ce', function() jdtls.extract_constant(true) end, opts)

    opts.desc = 'Extract Method'
    vim.keymap.set('v', '<leader>cm', function() jdtls.extract_method(true) end, opts)
  end,
}

-- jdtls disabled for testing (high CPU usage). KLS provides basic Java support.
-- To re-enable: uncomment the line below
-- jdtls.start_or_attach(config)
