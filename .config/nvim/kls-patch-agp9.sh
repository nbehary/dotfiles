#!/bin/bash
# kls-patch-agp9.sh
#
# Patches the kotlin-language-server shared jar to fix AGP 9 compatibility.
# The bundled projectClassPathFinder.gradle uses removed APIs:
#   - getBootClasspath()  (removed in AGP 9)
#   - getCompileClasspath() on variants (removed in AGP 9)
#
# Usage:
#   ./kls-patch-agp9.sh               # auto-detect KLS jar
#   ./kls-patch-agp9.sh /path/to/shared-x.x.x.jar
#
# Run again after upgrading kotlin-language-server.

set -euo pipefail

FIXED_SCRIPT="$(dirname "$0")/projectClassPathFinder.gradle"

# ── Validate fixed script exists ─────────────────────────────────────────────
if [ ! -f "$FIXED_SCRIPT" ]; then
  echo "Error: fixed script not found at $FIXED_SCRIPT" >&2
  exit 1
fi

if ! grep -q "AGP 9" "$FIXED_SCRIPT"; then
  echo "Error: $FIXED_SCRIPT does not appear to contain the AGP 9 fixes." >&2
  exit 1
fi

# ── Locate the KLS shared jar ─────────────────────────────────────────────────
if [ -n "${1:-}" ]; then
  JAR="$1"
else
  KLS_BIN="$(command -v kotlin-language-server 2>/dev/null || true)"
  if [ -z "$KLS_BIN" ]; then
    echo "Error: kotlin-language-server not found on PATH. Pass the jar path as an argument." >&2
    exit 1
  fi

  # Resolve symlink to find the real libexec directory
  KLS_REAL="$(readlink -f "$KLS_BIN" 2>/dev/null || realpath "$KLS_BIN" 2>/dev/null || echo "$KLS_BIN")"
  KLS_DIR="$(dirname "$KLS_REAL")"
  LIBEXEC_LIB="$KLS_DIR/../libexec/lib"

  JAR="$(ls "$LIBEXEC_LIB"/shared-*.jar 2>/dev/null | head -1)"
  if [ -z "$JAR" ]; then
    echo "Error: could not find shared-*.jar in $LIBEXEC_LIB" >&2
    echo "Try: $0 /path/to/shared-x.x.x.jar" >&2
    exit 1
  fi
fi

JAR="$(realpath "$JAR")"

if [ ! -f "$JAR" ]; then
  echo "Error: jar not found: $JAR" >&2
  exit 1
fi

# ── Check if already patched ──────────────────────────────────────────────────
TMPDIR_EXTRACT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_EXTRACT"' EXIT

(cd "$TMPDIR_EXTRACT" && jar xf "$JAR" projectClassPathFinder.gradle)
BUNDLED="$TMPDIR_EXTRACT/projectClassPathFinder.gradle"

if grep -q "AGP 9" "$BUNDLED" 2>/dev/null; then
  echo "✓ $JAR is already patched. Nothing to do."
  exit 0
fi

# ── Backup and patch ─────────────────────────────────────────────────────────
BACKUP="${JAR}.bak"
if [ ! -f "$BACKUP" ]; then
  cp "$JAR" "$BACKUP"
  echo "Backed up original jar → $BACKUP"
else
  echo "Backup already exists at $BACKUP (skipping)"
fi

cp "$FIXED_SCRIPT" "$TMPDIR_EXTRACT/projectClassPathFinder.gradle"
(cd "$TMPDIR_EXTRACT" && jar uf "$JAR" projectClassPathFinder.gradle)

echo "✓ Patched: $JAR"
echo ""
echo "Verify with:"
echo "  jar xf \"$JAR\" projectClassPathFinder.gradle -C /tmp && grep 'AGP 9' /tmp/projectClassPathFinder.gradle"
echo ""
echo "Restart Neovim fully (not just :LspRestart) for the patch to take effect."
