# Copilot Instructions

## Repository Overview

Personal dotfiles for macOS. The primary focus is a heavily customized Neovim configuration, plus shell, tmux, and terminal emulator configs.

## Neovim Config Architecture

The Neovim config lives in `.config/nvim/`. Plugins are managed via **vim.pack** (classic Neovim plugin management), stored in `pack/github/start/` and `pack/github/opt/`.

**File layout:**
- `init.lua` — main config (~90 lines): options, keymaps, autocommands, and colorscheme setup
- `after/plugin/` — plugin-specific configurations (completion, LSP, telescope, treesitter, etc.)
- `after/ftplugin/java.lua` — jdtls setup (runs on Java file open; **not** managed by mason-lspconfig)
- `after/ftplugin/kotlin.lua` — Kotlin indent settings and Gradle keymaps
- `after/ftplugin/roc.vim` — Roc filetype settings
- `after/queries/` — custom tree-sitter queries (for Roc)
- `lua/roc.lua` — Roc language filetype detection and tree-sitter parser registration
- `pack/github/start/` — automatically loaded plugins
- `pack/github/opt/` — optional plugins (loaded with `:packadd`)

**Key architectural rule:** `jdtls` (Java LSP) is intentionally excluded from `mason-lspconfig` handlers and is started manually via `after/ftplugin/java.lua` using `nvim-jdtls`. Do not add it back to the mason handlers.

## Lua Formatting

Lua files are formatted with **stylua**. Config (`.stylua.toml`):
- Column width: 160
- 2-space indent
- Single quotes preferred
- No call parentheses on function calls where optional

Format with: `stylua <file>` from the shell.

## Key Conventions

- **Leader key:** `<Space>`
- **Insert-mode escape:** `jk` (line 17 in `init.lua`)
- **Colorscheme:** `catppuccin-mocha` (kanagawa is installed but unused)
- **Transparent background:** enforced via a `ColorScheme` autocommand in `init.lua` that clears `guibg` on common highlight groups
- **Tab width:** 4 spaces globally (Lua uses 2 via stylua)
- **System clipboard sync:** `vim.opt.clipboard = 'unnamedplus'` — yanks go to the OS clipboard
- **Python support:** Uses dedicated pynvim virtualenv at `~/.venv/nvim/` (configured in `init.lua`, line 14)
- **NvimTree toggle:** `<leader>pv`
- **Gradle commands:** `<leader>Gg` (projects), `<leader>Gf` (favorites)
- **Diagnostics:** `<leader>dw` (float), `<leader>dq` (loclist)

## Build, Test, and Lint Commands

**Install/Update Plugins:**
```bash
bash scripts/install-nvim-plugins.sh
```
This clones or updates all plugins listed in the script and runs necessary build steps (telescope-fzf-native, LuaSnip).

**Format Lua Files:**
```bash
stylua <file>
```
Or inside Neovim: `<leader>l`. Config is in `.stylua.toml` (column width: 160, 2-space indent, single quotes, no call parentheses).

**Lint Kotlin:**
```bash
ktlint <file>
```

## Adding Plugins

**Steps:**
1. Add the plugin repo to `scripts/install-nvim-plugins.sh` (either `$START_DIR` for auto-load or `$OPT_DIR` for manual load)
2. Run `bash scripts/install-nvim-plugins.sh` to clone it
3. Create a configuration file in `after/plugin/<plugin-name>.lua` to set it up
4. Neovim will automatically load the plugin on next startup

**Example plugin setup:**
```lua
-- after/plugin/nvim-tree-setup.lua
require('nvim-tree').setup { ... }
```

Plugins in `pack/github/opt/` require manual loading with `:packadd <plugin-name>` before use.

## Active Language Support

| Language | LSP | Formatter | Notes |
|---|---|---|---|
| Lua | `lua_ls` (Mason) | `stylua` | config aware (loads nvim runtime) |
| Kotlin | `kotlin_language_server` (Mason) | `ktlint` | JVM target 21 |
| Java | `jdtls` (Maven) | — | started via `after/ftplugin/java.lua`; uses Android Studio's bundled JDK if present |
| Roc | — | — | filetype + tree-sitter from `lua/roc.lua` |
| GLSL | — | — | `glslView-nvim` for preview |
| Odin | — | — | syntax highlighting via `odin.vim` |

**Mason Configuration:** Auto-installs tools via `after/plugin/lsp-setup.lua`. Installed tools: `stylua`, `ktlint`, `jdtls`, `kotlin-language-server`.

**Important:** `jdtls` must NOT be added to `mason-lspconfig.setup()`. It is configured manually in `after/ftplugin/java.lua` via `nvim-jdtls`.

## Shell & Tools

- **Zsh:** zinit for plugin management; oh-my-posh prompt (nordtron theme)
- **Nvim alias:** `nvim --listen /tmp/nvim-$(date +%s).sock` — every session exposes a socket
- **Key shell tools:** `fzf`, `zoxide` (aliased as `cd`), `eza` (aliased as `ls`), `bat`, `fd`
- **Tmux:** TPM + catppuccin theme; prefix is `C-b`; vim-tmux-navigator enabled

## Other Configs

- `.wezterm.lua` — WezTerm terminal; GeistMono font, catppuccin macchiato theme, parallax background images
- `.tmux.conf` — tmux with catppuccin theme (git submodule at `tmux/plugins/tmux`)
- `.config/sketchybar/`, `.config/yabai/`, `.config/skhd/` — macOS tiling WM setup
