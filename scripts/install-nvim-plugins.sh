#!/bin/bash
# Install/update Neovim plugins using vim.pack

set -e

PACK_DIR="$HOME/.config/nvim/pack/github"
START_DIR="$PACK_DIR/start"
OPT_DIR="$PACK_DIR/opt"

# Create directories
mkdir -p "$START_DIR" "$OPT_DIR"

# Helper function to clone/update plugin
install_plugin() {
  local repo=$1
  local dir=$2
  local url=${3:-"https://github.com/$repo.git"}
  
  if [ -d "$dir" ]; then
    echo "Updating $(basename $dir)..."
    cd "$dir"
    git pull --quiet
    cd - > /dev/null
  else
    echo "Installing $(basename $dir)..."
    git clone --quiet "$url" "$dir"
  fi
}

# Start plugins (loaded automatically)
echo "Installing start plugins..."
install_plugin "tpope/vim-sleuth" "$START_DIR/vim-sleuth"
install_plugin "github/copilot.vim" "$START_DIR/copilot.vim"
install_plugin "Tetralux/odin.vim" "$START_DIR/odin.vim"
install_plugin "folke/edgy.nvim" "$START_DIR/edgy.nvim"
install_plugin "numToStr/Comment.nvim" "$START_DIR/Comment.nvim"
install_plugin "nvim-tree/nvim-tree.lua" "$START_DIR/nvim-tree.lua"
install_plugin "lewis6991/gitsigns.nvim" "$START_DIR/gitsigns.nvim"
install_plugin "NeogitOrg/neogit" "$START_DIR/neogit"
install_plugin "sindrets/diffview.nvim" "$START_DIR/diffview.nvim"
install_plugin "tpope/vim-fugitive" "$START_DIR/vim-fugitive"
install_plugin "voldikss/vim-floaterm" "$START_DIR/vim-floaterm"
install_plugin "nvim-lua/plenary.nvim" "$START_DIR/plenary.nvim"
install_plugin "nvim-telescope/telescope.nvim" "$START_DIR/telescope.nvim"
install_plugin "nvim-telescope/telescope-fzf-native.nvim" "$START_DIR/telescope-fzf-native.nvim"
install_plugin "nvim-telescope/telescope-ui-select.nvim" "$START_DIR/telescope-ui-select.nvim"
install_plugin "andyg/leap.nvim" "$START_DIR/leap.nvim" "https://codeberg.org/andyg/leap.nvim.git"
install_plugin "theprimeagen/harpoon" "$START_DIR/harpoon"
install_plugin "mbbill/undotree" "$START_DIR/undotree"
install_plugin "stevearc/oil.nvim" "$START_DIR/oil.nvim"
install_plugin "nvim-tree/nvim-web-devicons" "$START_DIR/nvim-web-devicons"
install_plugin "mfussenegger/nvim-jdtls" "$START_DIR/nvim-jdtls"
install_plugin "timtro/glslView-nvim" "$START_DIR/glslView-nvim"
install_plugin "stevearc/conform.nvim" "$START_DIR/conform.nvim"
install_plugin "neovim/nvim-lspconfig" "$START_DIR/nvim-lspconfig"
install_plugin "williamboman/mason.nvim" "$START_DIR/mason.nvim"
install_plugin "williamboman/mason-lspconfig.nvim" "$START_DIR/mason-lspconfig.nvim"
install_plugin "WhoIsSethDaniel/mason-tool-installer.nvim" "$START_DIR/mason-tool-installer.nvim"
install_plugin "j-hui/fidget.nvim" "$START_DIR/fidget.nvim"
install_plugin "hrsh7th/nvim-cmp" "$START_DIR/nvim-cmp"
install_plugin "L3MON4D3/LuaSnip" "$START_DIR/LuaSnip"
install_plugin "saadparwaiz1/cmp_luasnip" "$START_DIR/cmp_luasnip"
install_plugin "hrsh7th/cmp-nvim-lsp" "$START_DIR/cmp-nvim-lsp"
install_plugin "hrsh7th/cmp-path" "$START_DIR/cmp-path"
install_plugin "catppuccin/nvim" "$START_DIR/catppuccin"
install_plugin "rebelot/kanagawa.nvim" "$START_DIR/kanagawa.nvim"
install_plugin "folke/todo-comments.nvim" "$START_DIR/todo-comments.nvim"
install_plugin "echasnovski/mini.nvim" "$START_DIR/mini.nvim"
install_plugin "nvim-treesitter/nvim-treesitter" "$START_DIR/nvim-treesitter"
install_plugin "stevearc/aerial.nvim" "$START_DIR/aerial.nvim"
install_plugin "mfussenegger/nvim-dap" "$START_DIR/nvim-dap"
install_plugin "rcarriga/nvim-dap-ui" "$START_DIR/nvim-dap-ui"
install_plugin "nvim-neotest/nvim-nio" "$START_DIR/nvim-nio"

# Optional plugins (loaded with packadd)
echo "Installing optional plugins..."
install_plugin "kdheepak/lazygit.nvim" "$OPT_DIR/lazygit.nvim"

# Build steps
echo "Running build steps..."
if command -v make &> /dev/null; then
  cd "$START_DIR/telescope-fzf-native.nvim" && make && cd - > /dev/null && echo "Built telescope-fzf-native.nvim" || true
fi

if command -v make &> /dev/null; then
  cd "$START_DIR/LuaSnip" && make install_jsregexp && cd - > /dev/null && echo "Built LuaSnip" || true
fi

echo "✓ Plugin installation complete!"
