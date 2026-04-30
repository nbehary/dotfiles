-- Treesitter Configuration

require('nvim-treesitter.configs').setup {
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
