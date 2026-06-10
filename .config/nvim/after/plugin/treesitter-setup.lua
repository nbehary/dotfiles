-- Treesitter Configuration
-- New nvim-treesitter (v0.9+) only manages parser installation.
-- Highlighting is enabled per-buffer via vim.treesitter.start().

local ts_languages = { 'kotlin', 'java', 'groovy', 'xml', 'toml', 'lua', 'markdown', 'json', 'yaml' }

-- Install parsers on startup
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('treesitter-install', { clear = true }),
  callback = function()
    vim.schedule(function()
      local ok, ts = pcall(require, 'nvim-treesitter')
      if not ok then return end
      for _, lang in ipairs(ts_languages) do
        ts.install(lang)
      end
    end)
  end,
  once = true,
})

-- Enable treesitter highlighting for every buffer whose filetype maps to a known parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-highlight', { clear = true }),
  callback = function(ev)
    local ft_to_lang = {
      kotlin = 'kotlin',
      java = 'java',
      groovy = 'groovy',
      xml = 'xml',
      toml = 'toml',
      lua = 'lua',
      markdown = 'markdown',
      json = 'json',
      yaml = 'yaml',
    }
    local lang = ft_to_lang[vim.bo[ev.buf].filetype]
    if not lang then return end
    local ok = pcall(vim.treesitter.start, ev.buf, lang)
    if not ok then
      -- Parser not yet compiled; silently skip (will work after TSInstall)
    end
  end,
})

