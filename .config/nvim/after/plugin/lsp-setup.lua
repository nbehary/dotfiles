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

    -- jdtls is started in after/ftplugin/java.lua; skip duplicate initialization here

    -- Only start KLS from VimEnter if we have a real named file buffer.
    -- Attaching to an unnamed buffer sends textDocument/didOpen with uri "file://"
    -- which crashes KLS. The FileType autocmd handles starting KLS for actual .kt files.
    local bufname = vim.api.nvim_buf_get_name(0)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
    if bufname == '' or buftype ~= '' then
      return
    end

    -- KLS disabled: causes -32603 internal errors on second file and unstable highlighting
    -- Tree-sitter provides reliable syntax highlighting across all files
  end,
  once = true,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kotlin',
  group = vim.api.nvim_create_augroup('kotlin-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    local root_dir = find_gradle_root()

    -- Reuse existing KLS client for this project root — never start a second instance
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.name == 'kotlin-language-server' and client.config.root_dir == root_dir then
        vim.lsp.buf_attach_client(bufnr, client.id)
        return
      end
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
    local storage_dir = vim.fn.stdpath('data') .. '/kls-workspace/' .. vim.fn.fnamemodify(root_dir, ':t')
    local kls_env = {
      -- Reduced to 512m to leave room for Gradle builds (4.5GB+)
      KOTLIN_LANGUAGE_SERVER_OPTS = '-Xmx512m -Xss2m -XX:+UseG1GC -XX:MaxGCPauseMillis=200',
    }
    if kls_jdk then
      kls_env.JAVA_HOME = kls_jdk
      kls_env.PATH = kls_jdk .. '/bin:' .. (vim.env.PATH or '')
    end

    vim.lsp.start {
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      cmd_env = kls_env,
      reuse_client = function(client, config)
        return client.name == config.name and client.config.root_dir == config.root_dir
      end,
      root_dir = root_dir,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        kotlin = {
          compiler = {
            jvm = { target = '21' },
          },
          linting = { enabled = false },
          completion = { snippets = { enabled = false } },
          diagnostics = { enabled = false },
          debounceTime = 2000,
          workspace = {
            -- Per-project cache dir prevents re-analysing classpath on each file open
            storagePath = storage_dir,
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

    -- Lazy telescope wrapper: falls back to vim.lsp.buf if telescope isn't ready
    local function tele(method, fallback)
      return function()
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then
          builtin[method]()
        else
          fallback()
        end
      end
    end

    map('gd', tele('lsp_definitions', vim.lsp.buf.definition), '[G]oto [D]efinition')
    map('gr', tele('lsp_references', vim.lsp.buf.references), '[G]oto [R]eferences')
    map('gI', tele('lsp_implementations', vim.lsp.buf.implementation), '[G]oto [I]mplementation')
    map('<leader>D', tele('lsp_type_definitions', vim.lsp.buf.type_definition), 'Type [D]efinition')
    map('<leader>ds', tele('lsp_document_symbols', vim.lsp.buf.document_symbol), '[D]ocument [S]ymbols')
    map('<leader>ws', tele('lsp_dynamic_workspace_symbols', vim.lsp.buf.workspace_symbol), '[W]orkspace [S]ymbols')
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
