# 🛠️ Neovim Configuration Installation Guide

This guide details how to install, configure, and bootstrap this custom Neovim setup on a brand-new machine.

The configuration has been carefully migrated from `lazy.nvim` to **`vim.pack`** (Neovim's classic built-in package system), providing a highly performant, robust, and clean development environment.

---

## 📋 System Requirements & Support

This configuration and its automated setup scripts support:
*   **Arch Linux** (via `pacman`)
*   **Debian / Ubuntu** (via `apt-get`)
*   **macOS** (via `Homebrew`)

---

## 🚀 Step-by-Step Installation

### Step 1: Clone this Dotfiles Repository
First, clone the dotfiles repository to your local user directory (e.g., `~/dotfiles` or `~/working_dotfiles`):

```bash
git clone https://github.com/nbehary/dotfiles ~/dotfiles
cd ~/dotfiles
```

Next, checkout the `android_neovim2` branch:

```bash
git checkout android_neovim2
```

### Step 2: Establish the Neovim Config Symlink
Neovim expects its configuration at `~/.config/nvim`. Establish a symlink from your cloned dotfiles folder so that all updates remain tracked:

```bash
# Ensure the configuration directory exists
mkdir -p ~/.config

# Link the nvim config folder
ln -sfn ~/dotfiles/.config/nvim ~/.config/nvim
```

### Step 3: Install System & Tool Dependencies
Neovim relies on several CLI utilities for treesitter parsing, file searches, LSPs, and terminal commands. An automated script is provided to manage these.

Run the dependency check and automatic installation:

```bash
# Check what is currently installed
./scripts/setup-nvim-deps.sh --check

# Install all missing dependencies (requires sudo permissions)
./scripts/setup-nvim-deps.sh --install
```

> [!NOTE]
> **What this script installs/configures for you:**
> *   **Core tools**: `neovim` (0.12+), `git`, `curl`, `unzip`, `make`, `gcc` (to compile treesitter parsers and telescope)
> *   **Search helpers**: `ripgrep` (`rg`), `fd-find` (`fd`), `fzf`
> *   **Language runtimes**: `node` / `npm`, `default-jdk`
> *   **Dedicated Virtualenv**: Creates a isolated Python 3 environment at `~/.venv/nvim` and installs `pynvim` for high-performance python providers (safely bypassing Homebrew/Debian PEP-668 restrictions).
> *   **Debian/Ubuntu Specifics**: Automatically symlinks `fdfind` to `~/.local/bin/fd` (ensure `~/.local/bin` is in your `$PATH`).

### Step 4: Install and Compile Neovim Plugins
Next, download the Neovim plugins using the built-in package management scheme and run any necessary compilation steps (such as compiling C modules for high-speed fuzzy searching):

```bash
./scripts/install-nvim-plugins.sh
```

This script will:
1.  Clone/update all start & optional plugins directly into `~/.config/nvim/pack/github/`.
2.  Compile the native C components of `telescope-fzf-native.nvim`.
3.  Compile `jsregexp` bindings for `LuaSnip` to allow premium snippets.

### Step 5: Launch & Bootstrap Mason
Now you are ready to start Neovim:

```bash
nvim
```

Upon your first launch, the `mason-tool-installer` plugin will automatically run in the background to fetch and install all remaining external LSPs, formatters, and debug adapters:
*   `ktlint`, `jdtls`, `stylua`
*   `java-debug-adapter`, `kotlin-debug-adapter`

Ensure your internet connection is active during this process.

### Step 6: Verify Setup Quality
Once installation finishes, you can run the built-in health check to confirm everything is perfectly green:

```vim
:checkhealth
```

Verify that the following are fully operational:
*   `provider.python` (points to `~/.venv/nvim/bin/python3`)
*   `treesitter` (successfully compiles language syntax highlight parsers)
*   `mason` (reports external tools are installed)
*   `nvim-lspconfig` (LSP server hooks are active)

---

## ☕ Optional: Gradle & Kotlin LSP Support

If you develop Kotlin or Java Gradle applications, you can enable modern project-level LSP features (correct class indexing, workspace symbol search, definitions) using our custom Kotlin setup script:

```bash
# Set up and configure Kotlin LSP support
./scripts/setup-kotlin-lsp.sh --full
```

This will automatically configure custom FileType autocommands, build workspace roots using your build/settings Gradle files, and wire LSPs to trigger cleanly. See [KOTLIN_LSP_SKILL.md](file:///home/nate/working_dotfiles/scripts/KOTLIN_LSP_SKILL.md) for more details.

---

## 🎹 Essential Keyboard Controls

This configuration uses `<space>` as the map leader key:

| Shortcut | Description | Mode |
| :--- | :--- | :--- |
| `jk` | Fast exit back to Normal mode | Insert |
| `<leader>pv` | Toggle and focus `NvimTree` file navigation | Normal |
| `<leader>n` | Launch `Neogit` Git management dashboard | Normal |
| `<leader>gd` | Open `Diffview` for the latest git changes | Normal |
| `<leader>gx` | Close the open `Diffview` panel | Normal |
| `<leader>gF` | Diff active file between `development` and current branch | Normal |
| `<leader>dw` | Open floating diagnostics window for error details | Normal |
| `]d` / `[d` | Navigate to Next / Prev diagnostic message | Normal |
| `]e` / `[e` | Navigate to Next / Prev compiler error | Normal |
| `<leader>tn` / `tp`| Move to Next / Previous workspace tab | Normal |
| `<leader>tN` / `td`| Open a new workspace tab / Close current tab | Normal |

---

## 🛠️ Troubleshooting

### Command-line Tool Not Found Warnings
If telescope reports errors like `rg` or `fd` are missing, verify that they are installed and located in your system `$PATH`. On Debian, make sure `~/.local/bin` is in your `$PATH` so the `fd` symlink can be resolved:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Treesitter / Parser Compiler Failures
Ensure `gcc` or `clang` is fully functional on your host. On macOS, ensure you have initialized Xcode CLT:
```bash
xcode-select --install
```

### Python Provider Errors
If `:checkhealth provider.python` reports errors, recreate the virtual environment manually:
```bash
rm -rf ~/.venv/nvim
./scripts/setup-nvim-deps.sh --install
```
