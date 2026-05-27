# 💫 Nate's Dotfiles

Welcome to my personal, high-performance dotfiles configuration repository! This codebase houses a modular, responsive, and robust Unix environment optimized for rapid software engineering.

---

## 🎨 Highlights & Key Features

### ⚡ 1. Neovim Setup (`.config/nvim/`)
A fully-featured, ultra-fast development environment engineered from the ground up:
*   **Package Architecture**: Leverages Neovim's built-in **`vim.pack`** system rather than third-party wrappers, guaranteeing near-instantaneous startup times and predictable plugin updates.
*   **LSP & Formatters**: Automated via **Mason** and `mason-tool-installer`. Built-in hooks auto-configure LSP diagnostics, completions, and code-formatting (via `conform.nvim`).
*   **Git Dashboard**: Fully integrated workspace Git management via `Neogit`, `Diffview`, and `gitsigns.nvim`.
*   **Kotlin & Java Support**: Fully customized project classpaths and Gradle indexing support (FXMisc Kotlin Language Server) for large-scale enterprise development.
*   **Visual Aesthetics**: Styled with the beautiful `Kanagawa` and `Catppuccin` themes, utilizing dynamic color overrides for transparent background support.

### 🐚 2. Zsh Terminal environment (`.zshrc`)
A modern interactive command line shell built on **Zinit**:
*   **Fast Plugins**: Loads syntax highlighting, autosuggestions, tab completions (`fzf-tab`), and vi mode (`zsh-vim-mode`) asynchronously.
*   **Premium Prompt**: Styled using **Powerlevel10k** with instant-prompting active.
*   **Interactive Aliases**:
    *   `inv` — Launches fuzzy-search file finder (`fzf` + `bat` previewer) directly into Neovim.
    *   `nzo` — Interactively opens recent/frequent directories via Zoxide and mounts files.
    *   `ls` — Modern list directory powered by `eza` showing icons, grids, and colors.
    *   `fman` — Fuzzy searches all available system manual pages.

### 🪟 3. Tmux Multiplexer (`.tmux.conf`)
An elegant pane/window multiplexer configured for terminal split management:
*   **Plugin Manager**: Managed via TPM (Tmux Plugin Manager).
*   **Navigation**: Integrates **`vim-tmux-navigator`** for seamless pane traversals using `Ctrl + h/j/k/l` across Neovim buffers and Tmux splits.
*   **Style**: Beautiful top-mounted status bar matching the Catppuccin design system.
*   **Layout Controls**: Ergonomic pane splits, maximization hooks, and intuitive window resizing.

---

## 📦 Quick Start & Installation

To deploy this entire Neovim and dotfiles layout onto a brand-new host machine, consult the comprehensive, step-by-step setup guide:

👉 **[INSTALL.md](INSTALL.md)**

---

## ⚙️ Included Automation Scripts (`scripts/`)

| Script | Purpose | Learn More |
| :--- | :--- | :--- |
| [`setup-nvim-deps.sh`](file:///home/nate/working_dotfiles/scripts/setup-nvim-deps.sh) | Automatically installs package manager dependencies, build tools, search utilities, and configures a isolated Python 3 `pynvim` virtualenv. | [NVIM_DEPS_SKILL.md](file:///home/nate/working_dotfiles/scripts/NVIM_DEPS_SKILL.md) |
| [`install-nvim-plugins.sh`](file:///home/nate/working_dotfiles/scripts/install-nvim-plugins.sh) | Fetches, tracks, updates, and compiles C modules for all core and optional plugins in the Neovim package paths. | — |
| [`setup-kotlin-lsp.sh`](file:///home/nate/working_dotfiles/scripts/setup-kotlin-lsp.sh) | Automated compiler setting hooks and Gradle classpath setup for advanced Kotlin development. | [KOTLIN_LSP_SKILL.md](file:///home/nate/working_dotfiles/scripts/KOTLIN_LSP_SKILL.md) |
