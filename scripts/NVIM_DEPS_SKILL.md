# Neovim Dependency Setup Skill

Installs the system packages required for this dotfiles Neovim config to work
without errors. Cross-platform: **Arch Linux**, **Debian/Ubuntu**, **macOS**.

**Script**: `setup-nvim-deps.sh`

## Quick start

```bash
./scripts/setup-nvim-deps.sh --check     # report missing deps only
./scripts/setup-nvim-deps.sh --install   # install everything missing
./scripts/setup-nvim-deps.sh --full      # install + print manual notes
```

## What gets installed

| Dependency | Why this config needs it |
|---|---|
| `neovim` (0.12+) | the editor |
| `git` | plugin/repo operations |
| `curl`, `unzip` | Mason downloads tools as zips |
| `make`, `gcc` / `build-essential` / Xcode CLT | treesitter parsers compile C |
| `python3`, `pip`, venv | `vim.g.python3_host_prog` points at `~/.venv/nvim` |
| `node` + `npm` | LSPs and copilot.vim |
| `ripgrep` (`rg`) | telescope live-grep |
| `fd` (`fd-find` on Debian) | telescope file search |
| `fzf` | telescope-fzf-native fallback |
| `lazygit` | the `lazygit.nvim` plugin |
| JDK (`openjdk` / `default-jdk` / `jdk-openjdk`) | jdtls, kotlin-language-server, debug adapters |
| `kotlin-language-server` | LSP started by `after/plugin/lsp-setup.lua` |
| **pynvim venv** at `~/.venv/nvim` | Python provider; init.lua expects it |

## What is NOT installed by this script

These are handled automatically by Neovim plugins on first launch — the script
only ensures the prerequisites are in place:

- **Mason tools** (auto via `mason-tool-installer`):
  `ktlint`, `jdtls`, `stylua`, `java-debug-adapter`, `kotlin-debug-adapter`
- **Treesitter parsers**: kotlin, java, groovy, xml, toml, lua, markdown, json, yaml
- **Neovim plugins**: managed under `~/.config/nvim/pack/github/start/`

## Platform notes

### Debian / Ubuntu
- `lazygit` and `kotlin-language-server` are not in apt. The script reports
  them as manual; install lazygit from the upstream tarball/Go, and install
  kotlin-language-server via SDKMAN, Homebrew-on-Linux, or
  `scripts/setup-kotlin-lsp.sh`.
- `fd` is packaged as `fd-find` and installs as `fdfind`. The script
  symlinks it to `~/.local/bin/fd` for compatibility with telescope.
- apt's `neovim` is often older than 0.12 — prefer the unstable PPA or the
  AppImage if your Mason/treesitter plugins error out.

### Arch
- If `pacman` doesn't find `kotlin-language-server`, install from AUR:
  `yay -S kotlin-language-server`.

### macOS
- Requires Homebrew. Install from https://brew.sh first.
- After installing `openjdk`, expose it system-wide:
  ```bash
  sudo ln -sfn "$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk" \
    /Library/Java/JavaVirtualMachines/openjdk.jdk
  ```
- `make` / `gcc` / `unzip` come from Xcode Command Line Tools:
  `xcode-select --install`.

## Verifying

After running `--install`, launch Neovim and run:
```
:checkhealth
```

Look for green checks under `provider.python`, `treesitter`, `mason`, and
`nvim-lspconfig`. If `mason` reports tools as "not installed", run
`:MasonToolsInstall` once.

## Related skills
- `KOTLIN_LSP_SKILL.md` — full Kotlin LSP configuration (Gradle project root,
  ftplugin, etc.). Run *after* this script if you work on Kotlin code.
