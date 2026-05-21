#!/usr/bin/env python3
"""
Install the claude-diff-hook PreToolUse hook into ~/.claude/settings.json.
Idempotent: safe to run multiple times.
"""

import json
import os
import shutil
from pathlib import Path

SETTINGS = Path.home() / '.claude' / 'settings.json'
BIN_DIR  = Path.home() / '.local' / 'bin'
REPO_BIN = Path(__file__).resolve().parent.parent / 'bin'

HOOK_ENTRY = {
    "matcher": "Edit|Write|MultiEdit",
    "hooks": [{"type": "command", "command": "claude-diff-hook"}],
}


def merge_hook(settings: dict) -> bool:
    """Add the hook entry if not already present. Returns True if changed."""
    hooks = settings.setdefault('hooks', {})
    pre   = hooks.setdefault('PreToolUse', [])

    for entry in pre:
        if entry.get('matcher') == HOOK_ENTRY['matcher']:
            print('Hook already registered — nothing to do.')
            return False

    pre.append(HOOK_ENTRY)
    return True


def install_scripts():
    BIN_DIR.mkdir(parents=True, exist_ok=True)
    for name in ('claude-diff-hook', 'claude-diff-display'):
        src = REPO_BIN / name
        dst = BIN_DIR / name
        if not src.exists():
            print(f'  WARNING: {src} not found — skipping copy')
            continue
        shutil.copy2(src, dst)
        dst.chmod(dst.stat().st_mode | 0o111)
        print(f'  Installed {dst}')


def main():
    print('=== Claude diff-review hook setup ===\n')

    # 1. Copy scripts to ~/.local/bin
    print('Installing scripts to ~/.local/bin ...')
    install_scripts()

    # 2. Merge hook into settings.json
    print('\nUpdating ~/.claude/settings.json ...')
    SETTINGS.parent.mkdir(parents=True, exist_ok=True)

    if SETTINGS.exists():
        with SETTINGS.open() as f:
            settings = json.load(f)
    else:
        settings = {}

    if merge_hook(settings):
        with SETTINGS.open('w') as f:
            json.dump(settings, f, indent=2)
            f.write('\n')
        print('Hook registered.')

    print('\nDone.')


if __name__ == '__main__':
    main()
