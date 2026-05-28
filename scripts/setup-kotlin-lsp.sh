#!/bin/bash
# setup-kotlin-lsp.sh
#
# Sets up Kotlin Language Server (KLS) for use with Neovim on Android/Gradle projects.
# Installs KLS via Homebrew and applies the AGP 9 compatibility patch to the KLS jar.
#
# The Neovim LSP configuration (lsp-setup.lua) and Gradle init script
# (projectClassPathFinder.gradle) are part of the dotfiles and are already in place
# at ~/.config/nvim — this script does NOT overwrite them.
#
# Usage:
#   ./setup-kotlin-lsp.sh             # same as --full
#   ./setup-kotlin-lsp.sh --check     # verify everything is set up correctly
#   ./setup-kotlin-lsp.sh --install   # install kotlin-language-server only
#   ./setup-kotlin-lsp.sh --patch     # (re-)apply the AGP 9 jar patch only
#   ./setup-kotlin-lsp.sh --full      # install + patch + verify

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
PATCH_SCRIPT="${NVIM_CONFIG_DIR}/kls-patch-agp9.sh"
FINDER_SCRIPT="${NVIM_CONFIG_DIR}/projectClassPathFinder.gradle"
LSP_SETUP_FILE="${NVIM_CONFIG_DIR}/after/plugin/lsp-setup.lua"

print_header() { echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_info()    { echo -e "${YELLOW}ℹ $1${NC}"; }

# ── Install KLS via Homebrew ──────────────────────────────────────────────────
install_kotlin_lsp() {
  print_header "Installing Kotlin Language Server"

  if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found. Install it first: https://brew.sh"
    return 1
  fi

  if command -v kotlin-language-server &> /dev/null; then
    print_info "kotlin-language-server already installed ($(kotlin-language-server --version 2>/dev/null || echo 'version unknown'))"
    return 0
  fi

  print_info "Installing kotlin-language-server via Homebrew..."
  brew install kotlin-language-server
  print_success "kotlin-language-server installed"
}

# ── Apply the AGP 9 compatibility patch to the KLS jar ───────────────────────
apply_agp9_patch() {
  print_header "Applying AGP 9 Compatibility Patch"

  if [ ! -f "$PATCH_SCRIPT" ]; then
    print_error "Patch script not found: $PATCH_SCRIPT"
    print_info "Make sure dotfiles are checked out and ~/.config/nvim is symlinked."
    return 1
  fi

  if [ ! -f "$FINDER_SCRIPT" ]; then
    print_error "projectClassPathFinder.gradle not found: $FINDER_SCRIPT"
    return 1
  fi

  bash "$PATCH_SCRIPT"
}

# ── Verify everything is in place ────────────────────────────────────────────
verify_setup() {
  print_header "Verifying KLS Setup"
  local status=0

  # KLS binary
  if command -v kotlin-language-server &> /dev/null; then
    print_success "kotlin-language-server binary found"
  else
    print_error "kotlin-language-server not found in PATH"
    status=1
  fi

  # Dotfiles: projectClassPathFinder.gradle
  if [ -f "$FINDER_SCRIPT" ]; then
    if grep -q "android-classes-jar" "$FINDER_SCRIPT"; then
      print_success "projectClassPathFinder.gradle present and AGP 9 compatible"
    else
      print_error "projectClassPathFinder.gradle exists but may be outdated (missing android-classes-jar fix)"
      status=1
    fi
  else
    print_error "projectClassPathFinder.gradle not found: $FINDER_SCRIPT"
    status=1
  fi

  # Dotfiles: lsp-setup.lua
  if [ -f "$LSP_SETUP_FILE" ]; then
    print_success "lsp-setup.lua present"
  else
    print_error "lsp-setup.lua not found: $LSP_SETUP_FILE"
    print_info "Is ~/.config/nvim symlinked to your dotfiles?"
    status=1
  fi

  # Jar patch
  if command -v kotlin-language-server &> /dev/null; then
    KLS_BIN="$(command -v kotlin-language-server)"
    KLS_REAL="$(readlink -f "$KLS_BIN" 2>/dev/null || realpath "$KLS_BIN" 2>/dev/null || echo "$KLS_BIN")"
    KLS_LIB="$(dirname "$KLS_REAL")/../libexec/lib"
    JAR="$(ls "$KLS_LIB"/shared-*.jar 2>/dev/null | head -1)"
    if [ -n "$JAR" ]; then
      TMPDIR_CHECK="$(mktemp -d)"
      (cd "$TMPDIR_CHECK" && jar xf "$JAR" projectClassPathFinder.gradle 2>/dev/null)
      if grep -q "android-classes-jar" "$TMPDIR_CHECK/projectClassPathFinder.gradle" 2>/dev/null; then
        print_success "KLS jar is patched for AGP 9"
      else
        print_error "KLS jar is NOT patched — run: $PATCH_SCRIPT"
        status=1
      fi
      rm -rf "$TMPDIR_CHECK"
    else
      print_error "KLS shared jar not found in $KLS_LIB"
      status=1
    fi
  fi

  # kls-patch-agp9.sh
  if [ -f "$PATCH_SCRIPT" ] && [ -x "$PATCH_SCRIPT" ]; then
    print_success "kls-patch-agp9.sh present and executable"
  else
    print_error "kls-patch-agp9.sh missing or not executable: $PATCH_SCRIPT"
    status=1
  fi

  echo ""
  if [ $status -eq 0 ]; then
    print_success "KLS setup looks good."
    print_info "For each Android project, run: android-kls-setup (from project root)"
  else
    print_error "Some checks failed. Run './setup-kotlin-lsp.sh --full' to fix."
  fi

  return $status
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  local mode="${1:---full}"

  case "$mode" in
    --check)
      verify_setup
      ;;
    --install)
      install_kotlin_lsp
      ;;
    --patch)
      apply_agp9_patch
      ;;
    --full|--all|"")
      install_kotlin_lsp && apply_agp9_patch && verify_setup
      ;;
    --help)
      cat << 'HELP'
setup-kotlin-lsp.sh — Kotlin Language Server setup for AGP 9 Android projects

Usage: ./setup-kotlin-lsp.sh [OPTION]

Options:
  (no args)     Full setup: install KLS + apply AGP 9 patch + verify
  --full        Same as above
  --check       Verify everything is installed and patched correctly
  --install     Install kotlin-language-server via Homebrew only
  --patch       (Re-)apply the AGP 9 compatibility patch to the KLS jar
  --help        Show this help

After machine setup, for each Android project:
  cd /path/to/your/project
  android-kls-setup

Re-run --patch after any: brew upgrade kotlin-language-server
HELP
      ;;
    *)
      print_error "Unknown option: $mode"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
}

main "$@"
