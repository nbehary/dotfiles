-- Ensure the Kotlin tree-sitter parser is installed for DeltaView
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  vim.notify('nvim-treesitter not available; kotlin parser not configured', vim.log.levels.WARN)
  return
end

configs.setup({
  ensure_installed = { 'kotlin' }, -- add more languages as desired
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})
