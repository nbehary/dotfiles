# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for an Arch Linux + Hyprland setup. Files here are intended to be symlinked (or directly placed) into `$HOME` — the in-repo paths mirror their target locations (`.zshrc`, `.tmux.conf`, `.wezterm.lua`, `.config/<tool>/`, `hypr/`, `bin/`).

There is no build system or test suite. Changes are validated by reloading the relevant tool (e.g. restart Hyprland, `:source` in nvim, new shell for zsh).

## Neovim config (`.config/nvim/`)

Forked from kickstart.nvim, but **migrated off lazy.nvim to Neovim 0.11+ `vim.pack`**. Several conventions follow from that:

- Plugins are declared with `vim.pack.add({...})` in `init.lua` (lines ~92–162). To add a plugin, append its git URL there. Use `{ src = '...', version = '...' }` for pinned versions (e.g. telescope) or `{ src = '...', name = '...' }` to override the directory name (e.g. catppuccin).
- Plugin build steps (`telescope-fzf-native`, `LuaSnip`) run from a `PackChanged` autocmd at the top of `init.lua` — add new build hooks there, not inline with the plugin spec.
- `init.lua` is intentionally a single ~580-line file (kickstart style). Plugin setup lives directly in it under `[[ Plugin Configuration ]]`. Don't split things into `lua/plugins/*.lua` modules unless there's a reason — `lua/custom/plugins/init.lua` exists but returns `{}`.
- LSP uses Neovim 0.11's native `vim.lsp.config` / `vim.lsp.enable` API, **not** `lspconfig.setup`. `:LspLog`, `:LspRestart`, `:LspInfo` are reimplemented as user commands (search "LSP utility commands" in `init.lua`) since nvim-lspconfig no longer provides them in this setup.
- `mason-lspconfig` is configured with `automatic_enable = { exclude = { 'jdtls', 'kotlin_lsp' } }` — those two are managed manually (jdtls via `nvim-jdtls` ftplugin, kotlin_lsp via explicit `vim.lsp.config` block that locates the mason-installed `intellij-server` binary).

### Android / Kotlin debug flow

This config has a non-trivial Android debugging pipeline worth understanding before touching it. See `.config/nvim/Android_Debugging.md` for the full design.

- `:AndroidDebug` (`<leader>da`) shells out to `bin/android-debug-launch` (a bash script that reads `applicationId` from `build.gradle(.kts)`, runs `./gradlew installDebug`, resolves the launcher activity, launches with `am start -D`, and `adb forward`s JDWP to localhost:5005), then calls `dap.continue()` to attach.
- The DAP adapter is `kotlin-debug-adapter` (mason-installed). It's bound to **both** `dap.configurations.kotlin` and `dap.configurations.java` because Android apps run on the JVM regardless of source language.
- Logcat integration lives in `.config/nvim/lua/custom/logcat.lua` and exposes `:AndroidLogcat[Toggle|Max|Stop]` commands.
- Tools auto-installed via `mason-tool-installer`: `ktlint`, `jdtls`, `kotlin-lsp`, `kotlin-debug-adapter`, `stylua`.

### Formatting

`conform.nvim` with `format_on_save` enabled (500ms timeout, lsp_fallback). Configured formatters: `lua → stylua`, `kotlin → ktlint`. Manual format: `<leader>l`.

## zsh config (`.zshrc`)

Plugin manager is **zinit** (not oh-my-zsh, though OMZ snippets are pulled in via `zinit snippet OMZP::...`). Vim mode is enabled with `jk` as the vicmd escape (matches the nvim insert-mode `jk → <ESC>` binding).

## Submodules

`tmux/plugins/tmux` is a git submodule (catppuccin/tmux). Note that `tmux.no/` exists as a parallel directory — `tmux/` itself is gitignored or unpopulated; tmux config currently lives at `.tmux.conf` in the repo root.

## Conventions

- Leader key is `<space>` (both `mapleader` and `maplocalleader`).
- New `<leader>a*` bindings are reserved for AI / Claude integrations (see the `claudecode.nvim` block).
- New `<leader>d*` bindings are reserved for debug / Android (`da` debug, `dl` logcat, `dm` logcat-max, plus DAP `b/B`).
