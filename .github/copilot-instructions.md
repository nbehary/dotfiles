# Copilot Instructions

## Repository Overview

Personal dotfiles for macOS. The primary focus is a heavily customized Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), plus shell, tmux, and terminal emulator configs.

## Neovim Config Architecture

The Neovim config lives in `.config/nvim/`. The entire plugin setup is driven by **lazy.nvim** and defined in a single `init.lua` (~1000 lines).

**File layout:**
- `init.lua` — main config: options, keymaps, autocommands, and all plugin specs
- `lua/custom/plugins/` — drop-in files for additional plugins (currently unused; `init.lua` returns `{}`)
- `lua/kickstart/plugins/` — optional kickstart extras (`debug.lua`, `indent_line.lua`; commented out in `init.lua`)
- `lua/roc.lua` — Roc language filetype detection and tree-sitter parser registration
- `after/ftplugin/java.lua` — jdtls setup (runs on Java file open; **not** managed by mason-lspconfig)
- `after/ftplugin/kotlin.lua` — Kotlin indent settings and Gradle keymaps (`<leader>gb/gt/gc`)
- `after/ftplugin/roc.vim` — Roc filetype settings
- `after/queries/` — custom tree-sitter queries (for Roc)
- `plugin/floatterminal.lua` — custom `:Floatterminal` command

**Key architectural rule:** `jdtls` (Java LSP) is intentionally excluded from `mason-lspconfig` handlers and is started manually via `after/ftplugin/java.lua` using `nvim-jdtls`. Do not add it back to the mason handlers.

## Lua Formatting

Lua files are formatted with **stylua**. Config (`.stylua.toml`):
- Column width: 160
- 2-space indent
- Single quotes preferred
- No call parentheses on function calls where optional

Format with: `<leader>l` inside Neovim, or `stylua <file>` from the shell.

## Key Conventions

- **Leader key:** `<Space>`
- **Insert-mode escape:** `jk`
- **Colorscheme:** `catppuccin-mocha` (kanagawa is installed but unused)
- **Transparent background:** enforced via a `ColorScheme` autocommand in `init.lua` that clears `guibg` on common highlight groups
- **Tab width:** 4 spaces globally (overridden to 4 in Kotlin/Java via ftplugin; Lua uses 2 via `vim-sleuth` and stylua)
- **System clipboard sync:** `vim.opt.clipboard = 'unnamedplus'` — yanks go to the OS clipboard

## Adding Plugins

Add directly to the `require('lazy').setup { ... }` table in `init.lua`, or create a new file in `lua/custom/plugins/` and uncomment the `{ import = 'custom.plugins' }` line near the bottom of `init.lua`.

## Active Language Support

| Language | LSP | Formatter | Notes |
|---|---|---|---|
| Lua | `lua_ls` (Mason) | `stylua` | config aware (loads nvim runtime) |
| Kotlin | `kotlin_language_server` (Mason) | `ktlint` | JVM target 21 |
| Java | `jdtls` (Mason) | — | started via `after/ftplugin/java.lua`; uses Android Studio's bundled JDK if present |
| Roc | — | — | filetype + tree-sitter from `lua/roc.lua` |
| GLSL | — | — | `glslView-nvim` for preview |

Mason auto-installs: `stylua`, `ktlint`, `jdtls`, `kotlin-language-server`.

## Shell & Tools

- **Zsh:** zinit for plugin management; oh-my-posh prompt (nordtron theme)
- **Nvim alias:** `nvim --listen /tmp/nvim-$(date +%s).sock` — every session exposes a socket
- **Key shell tools:** `fzf`, `zoxide` (aliased as `cd`), `eza` (aliased as `ls`), `bat`, `fd`
- **Tmux:** TPM + catppuccin theme; prefix is `C-b`; vim-tmux-navigator enabled

## Other Configs

- `.wezterm.lua` — WezTerm terminal; GeistMono font, catppuccin macchiato theme, parallax background images
- `.tmux.conf` — tmux with catppuccin theme (git submodule at `tmux/plugins/tmux`)
- `.config/sketchybar/`, `.config/yabai/`, `.config/skhd/` — macOS tiling WM setup
