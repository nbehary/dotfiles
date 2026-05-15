#!/usr/bin/env bash
set -euo pipefail

DEST="$HOME/.tmux/plugins/tpm"
REPO="https://github.com/tmux-plugins/tpm.git"

echo "Target: $DEST"

if [ -d "$DEST/.git" ]; then
  echo "TPM already installed — updating..."
  if git -C "$DEST" pull --ff-only --quiet; then
    echo "Updated TPM (fast-forward)."
  else
    echo "Fast-forward failed; fetching and resetting to remote HEAD."
    git -C "$DEST" fetch --all --quiet && git -C "$DEST" reset --hard origin/HEAD
    echo "TPM reset to remote HEAD."
  fi
else
  echo "Installing TPM to $DEST"
  mkdir -p "$(dirname "$DEST")"
  git clone --depth 1 "$REPO" "$DEST"
  echo "TPM cloned."
fi

cat <<EOF
Done. To finish plugin installation:
  1) Start tmux (or reload configuration: tmux source-file ~/.tmux.conf)
  2) Inside tmux press <prefix> + I (capital i) to install plugins
OR run directly:
  $DEST/bin/install_plugins
EOF
