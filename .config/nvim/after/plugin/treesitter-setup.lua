-- Treesitter Configuration
-- Defer setup until VeryLazy to ensure treesitter is fully loaded

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('treesitter-setup', { clear = true }),
  callback = function()
    local ok, configs = pcall(require, 'nvim-treesitter.configs')
    if not ok then
      return
    end
    configs.setup {
      ensure_installed = {
        'kotlin',
        'java',
        'groovy',
        'xml',
        'toml',
        'lua',
        'markdown',
        'json',
        'yaml',
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
  once = true,
})
