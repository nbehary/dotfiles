#!/usr/bin/env bash
# Neovim Dependency Setup Skill
# Installs system packages required for this dotfiles Neovim config to work cleanly
# Targets: Arch Linux, Debian/Ubuntu, macOS (Homebrew)
# Usage: ./setup-nvim-deps.sh [--check|--install|--full|--help]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_info()    { echo -e "${YELLOW}ℹ $1${NC}"; }

# ---------------------------------------------------------------------------
# OS / package-manager detection
# ---------------------------------------------------------------------------
detect_os() {
  case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)
      if [ -f /etc/arch-release ] || command -v pacman &>/dev/null; then
        OS=arch
      elif [ -f /etc/debian_version ] || command -v apt-get &>/dev/null; then
        OS=debian
      else
        print_error "Unsupported Linux distribution (need Arch or Debian/Ubuntu)"
        exit 1
      fi
      ;;
    *) print_error "Unsupported OS: $(uname -s)"; exit 1 ;;
  esac
  print_info "Detected OS: $OS"
}

# ---------------------------------------------------------------------------
# Dependency table
#   For each logical dep we record:
#     cmd  – binary to test with `command -v`
#     arch / debian / macos – package name on that PM
#   "-" means skip on that platform
# ---------------------------------------------------------------------------
# Indexed arrays for portability with bash 3.2 (default macOS)
DEP_NAMES=(
  "neovim"
  "git"
  "curl"
  "unzip"
  "make"
  "gcc"
  "python3"
  "pip"
  "node"
  "ripgrep"
  "fd"
  "fzf"
  "lazygit"
  "jdk"
  "kotlin-language-server"
)

# command to probe for each
DEP_CMDS=(
  "nvim"
  "git"
  "curl"
  "unzip"
  "make"
  "gcc"
  "python3"
  "pip3"
  "node"
  "rg"
  "fd"
  "fzf"
  "lazygit"
  "java"
  "kotlin-language-server"
)

# arch package names
DEP_ARCH=(
  "neovim"
  "git"
  "curl"
  "unzip"
  "make"
  "gcc"
  "python"
  "python-pip"
  "nodejs npm"
  "ripgrep"
  "fd"
  "fzf"
  "lazygit"
  "jdk-openjdk"
  "kotlin-language-server"
)

# debian/ubuntu package names — note: fd is `fd-find`, kotlin-language-server is unavailable in apt
DEP_DEBIAN=(
  "neovim"
  "git"
  "curl"
  "unzip"
  "make"
  "build-essential"
  "python3"
  "python3-pip python3-venv"
  "nodejs npm"
  "ripgrep"
  "fd-find"
  "fzf"
  "-"
  "default-jdk"
  "-"
)

# macos (homebrew) package names
DEP_MACOS=(
  "neovim"
  "git"
  "curl"
  "-"
  "-"
  "-"
  "python3"
  "-"
  "node"
  "ripgrep"
  "fd"
  "fzf"
  "lazygit"
  "openjdk"
  "kotlin-language-server"
)

get_package() {
  local idx=$1
  case "$OS" in
    arch)   echo "${DEP_ARCH[$idx]}" ;;
    debian) echo "${DEP_DEBIAN[$idx]}" ;;
    macos)  echo "${DEP_MACOS[$idx]}" ;;
  esac
}

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------
check_deps() {
  print_header "Checking Neovim dependencies"
  local missing=()
  for i in "${!DEP_NAMES[@]}"; do
    local name="${DEP_NAMES[$i]}"
    local cmd="${DEP_CMDS[$i]}"
    local pkg
    pkg=$(get_package "$i")
    if [ "$pkg" = "-" ]; then
      print_info "$name — not packaged on $OS, see manual section below"
      continue
    fi
    if command -v "$cmd" &>/dev/null; then
      print_success "$name ($cmd)"
    else
      print_error "$name missing (cmd: $cmd)"
      missing+=("$i")
    fi
  done

  # Special: pynvim inside ~/.venv/nvim (init.lua sets vim.g.python3_host_prog)
  if [ -x "$HOME/.venv/nvim/bin/python3" ] && "$HOME/.venv/nvim/bin/python3" -c "import pynvim" 2>/dev/null; then
    print_success "pynvim virtualenv at ~/.venv/nvim"
  else
    print_error "pynvim virtualenv at ~/.venv/nvim missing or no pynvim installed"
    missing+=("pynvim")
  fi

  MISSING=("${missing[@]}")
  if [ ${#MISSING[@]} -eq 0 ]; then
    print_success "All checked dependencies are installed"
    return 0
  fi
  print_info "${#MISSING[@]} item(s) missing — rerun with --install to install"
  return 1
}

# ---------------------------------------------------------------------------
# Installers
# ---------------------------------------------------------------------------
pm_install() {
  # $@ — space-separated package list (may include multi-word entries)
  local pkgs="$*"
  case "$OS" in
    arch)
      # shellcheck disable=SC2086
      sudo pacman -S --needed --noconfirm $pkgs
      ;;
    debian)
      sudo apt-get update -qq
      # shellcheck disable=SC2086
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $pkgs
      ;;
    macos)
      if ! command -v brew &>/dev/null; then
        print_error "Homebrew not installed. Install from https://brew.sh first."
        exit 1
      fi
      # shellcheck disable=SC2086
      brew install $pkgs
      ;;
  esac
}

install_pynvim_venv() {
  print_info "Creating ~/.venv/nvim and installing pynvim"
  python3 -m venv "$HOME/.venv/nvim"
  "$HOME/.venv/nvim/bin/pip" install --upgrade pip pynvim
  print_success "pynvim installed at ~/.venv/nvim"
}

install_missing() {
  if [ ${#MISSING[@]} -eq 0 ]; then
    print_success "Nothing to install"
    return 0
  fi
  print_header "Installing missing dependencies"
  local to_install=()
  local pynvim_needed=0
  for entry in "${MISSING[@]}"; do
    if [ "$entry" = "pynvim" ]; then
      pynvim_needed=1
      continue
    fi
    local pkg
    pkg=$(get_package "$entry")
    [ "$pkg" = "-" ] && continue
    to_install+=("$pkg")
  done
  if [ ${#to_install[@]} -gt 0 ]; then
    print_info "Packages: ${to_install[*]}"
    pm_install "${to_install[@]}"
  fi
  if [ "$pynvim_needed" = "1" ]; then
    install_pynvim_venv
  fi

  # Debian: fd ships as `fdfind` — symlink to `fd` for telescope/nvim convention
  if [ "$OS" = "debian" ] && command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    print_info "Symlinked fdfind -> ~/.local/bin/fd (ensure ~/.local/bin is on PATH)"
  fi
}

# ---------------------------------------------------------------------------
# Platform-specific manual notes
# ---------------------------------------------------------------------------
manual_notes() {
  print_header "Manual / platform-specific notes"
  case "$OS" in
    debian)
      cat <<'EOF'
- lazygit:    not in apt — install via tarball release or `go install github.com/jesseduffield/lazygit@latest`
- kotlin-language-server: not in apt — see scripts/setup-kotlin-lsp.sh, or install via Homebrew on Linux, SDKMAN, or build from source
- neovim:     apt's package may be old. Prefer the unstable PPA or the AppImage if you need 0.12+
EOF
      ;;
    arch)
      cat <<'EOF'
- kotlin-language-server lives in the AUR on some setups; if pacman can't find it, try `yay -S kotlin-language-server`
EOF
      ;;
    macos)
      cat <<'EOF'
- openjdk:    after install, run `sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk` to expose it to /usr/libexec/java_home
- unzip/make/gcc: provided by Xcode Command Line Tools (`xcode-select --install`)
EOF
      ;;
  esac
  cat <<'EOF'

Mason-managed tools (auto-installed on first nvim launch via mason-tool-installer):
  ktlint, jdtls, stylua, java-debug-adapter, kotlin-debug-adapter
These need a working JDK to run — ensure `java` is on PATH before launching nvim.

Treesitter parsers (auto on first nvim launch): kotlin, java, groovy, xml, toml, lua, markdown, json, yaml
These need a C compiler — handled by installing `gcc`/`build-essential`/Xcode CLT.

Claude Code integration:
  claude            — the Claude Code CLI, needed by claudecode.nvim (https://claude.com/claude-code)
  claude-agent-acp  — ACP bridge for CodeCompanion's claude_code adapter:
                      npm install -g @zed-industries/claude-agent-acp
EOF
}

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 [option]

Options:
  --check     Report which dependencies are missing (default)
  --install   Check, then install missing dependencies
  --full      Same as --install, plus print manual notes
  --help      Show this message

Supported platforms: Arch Linux, Debian/Ubuntu, macOS (Homebrew)
EOF
}

main() {
  local mode="${1:---check}"
  case "$mode" in
    -h|--help) usage; exit 0 ;;
    --check)   detect_os; check_deps || true ;;
    --install) detect_os; check_deps || true; install_missing; check_deps || true ;;
    --full)    detect_os; check_deps || true; install_missing; manual_notes; check_deps || true ;;
    *) usage; exit 1 ;;
  esac
}

MISSING=()
main "$@"
