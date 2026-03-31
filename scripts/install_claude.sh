#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/scripts/_lib.sh"

echo "==> Installing Claude Code settings"

check_commands jq || exit 1

SRC="$DOTFILES_DIR/claude/settings.json"
DEST="$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude"

if [[ -f "$DEST" ]]; then
    # Backup existing settings
    BACKUP="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
    echo "  [BACKUP] $DEST -> $BACKUP"
    cp "$DEST" "$BACKUP"

    # Deep merge: existing (base) * dotfiles (override)
    TMPFILE="$(mktemp)"
    jq -s '.[0] * .[1]' "$DEST" "$SRC" > "$TMPFILE"
    mv "$TMPFILE" "$DEST"
    echo "  [MERGE] $SRC -> $DEST"
else
    cp "$SRC" "$DEST"
    echo "  [COPY] $SRC -> $DEST"
fi

echo "==> Claude Code settings installed"
