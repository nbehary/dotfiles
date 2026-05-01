# lazy.nvim → pack migration

Migrated the nvim config from lazy.nvim to Neovim's built-in package manager (`pack`).

## What changed

- Removed `lazy.nvim` bootstrap and `require('lazy').setup { ... }` from `init.lua`
- Removed `lazy-lock.json`
- Removed `lua/custom/` and `lua/kickstart/` directories
- Split all plugin configs into individual files under `lua/plugins/`
- Added all plugins as git submodules under `pack/plugins/start/`
- Fixed: `conform.nvim` was registered twice in the old config — merged into one

## New structure

```
lua/plugins/
  mini.lua              mini.ai, mini.surround, statusline
  telescope.lua         telescope setup + all keymaps
  lsp.lua               mason, lspconfig, fidget, LspAttach keymaps
  completion.lua        nvim-cmp + LuaSnip
  conform.lua           format on save + <leader>l keymap
  gitsigns.lua          gitsigns + keymaps
  neogit.lua
  lazygit.lua           <leader>lg keymap
  oil.lua               oil setup + keymaps
  harpoon.lua           mark/ui + keymaps
  leap.lua
  undotree.lua          <leader>u keymap
  nvimtree.lua
  edgy.lua
  misc.lua              Comment, todo-comments (sleuth/odin/glslView/jdtls need no setup)

pack/plugins/start/     (34 git submodules)
  Comment.nvim
  LuaSnip               built: make install_jsregexp
  catppuccin
  cmp-nvim-lsp
  cmp-path
  cmp_luasnip
  conform.nvim
  diffview.nvim
  edgy.nvim
  fidget.nvim
  gitsigns.nvim
  glslView-nvim
  harpoon
  lazygit.nvim
  leap.nvim
  mason-lspconfig.nvim
  mason-tool-installer.nvim
  mason.nvim
  mini.nvim
  neogit
  nvim-cmp
  nvim-jdtls
  nvim-lspconfig
  nvim-tree.lua
  nvim-web-devicons
  odin.vim
  oil.nvim
  plenary.nvim
  telescope-fzf-native.nvim  built: make
  telescope-ui-select.nvim
  telescope.nvim
  todo-comments.nvim
  undotree
  vim-sleuth
```

## Plugin management

**On a fresh machine:**
```sh
git submodule update --init --recursive
cd pack/plugins/start/telescope-fzf-native.nvim && make
cd pack/plugins/start/LuaSnip && make install_jsregexp
```

**To update all plugins to latest:**
```sh
git submodule update --remote
```

**To update a single plugin:**
```sh
git submodule update --remote pack/plugins/start/<plugin-name>
```

## What was dropped

- `kanagawa.nvim` — was installed but only ever called `vim.cmd.colorscheme 'catppuccin-mocha'`; catppuccin is now the only colorscheme
- Lazy-loading (`event`, `cmd`, `keys`, `build` triggers) — all plugins now load at startup via `pack/start`
