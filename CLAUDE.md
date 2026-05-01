# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

Personal dotfiles for a Linux environment (Hyprland on laptop, X11/dk on desktop). The repo is symlinked or copied to `~` so paths like `.config/nvim/` map directly to `~/.config/nvim/`.

Key configs:
- **Neovim** — `.config/nvim/` (primary development environment)
- **Shell** — `zshrc` (zinit plugin manager, vim keybindings, fzf/zoxide integrations)
- **Hyprland** — `hypr/` (laptop WM) and `Hyprland/` (source build)
- **X11 WM** — `.config/dk/` with sxhkd keybindings
- **Terminal** — `.config/alacritty/`
- **Status bar** — `.config/sketchybar/` (macOS) and `.config/rofi/` (launcher)

## Neovim architecture

The config migrated from lazy.nvim to Neovim's built-in `packpath` manager. Plugins are git submodules, configs are split files.

**Entry point:** `init.lua` — sets options, keymaps, autocommands, colorscheme (catppuccin-mocha), then requires each plugin config module.

**Plugin configs:** `lua/plugins/<name>.lua` — one file per plugin group, all required explicitly from `init.lua`.

**Plugin binaries:** `pack/plugins/start/` — 34 git submodules, all load at startup (no lazy-loading).

**Language-specific:** `plugin/java.lua`, `plugin/roc.vim`, `plugin/floatterminal.lua`; filetype overrides in `after/ftplugin/`.

**Formatter config:** `.stylua.toml` — 160 col width, 2-space indent, single quotes.

## Plugin management (submodules)

Fresh machine setup:
```sh
git submodule update --init --recursive
cd .config/nvim/pack/plugins/start/telescope-fzf-native.nvim && make
cd .config/nvim/pack/plugins/start/LuaSnip && make install_jsregexp
```

Update all plugins:
```sh
git submodule update --remote
```

Update a single plugin:
```sh
git submodule update --remote .config/nvim/pack/plugins/start/<plugin-name>
```

Add a new plugin:
```sh
git submodule add <url> .config/nvim/pack/plugins/start/<name>
# then create lua/plugins/<name>.lua and require it in init.lua
```

## Lua formatting

Format Lua files with stylua (config in `.config/nvim/.stylua.toml`):
```sh
stylua .config/nvim/lua/
```

## Shell (zshrc)

Uses **zinit** for plugin management. Key integrations: fzf, zoxide (`cd` replacement), eza (`ls` replacement), bat, fd. vim mode enabled with `jk` as escape chord.
