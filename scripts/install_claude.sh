#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/scripts/_lib.sh"

echo "==> Installing Claude Code settings"

check_commands jq || exit 1

SRC="$DOTFILES_DIR/claude/settings.json"
DEST="$HOME/.claude/settings.json"

if [[ ! -f "$SRC" ]]; then
    echo "  [ERROR] Source file not found: $SRC"
    exit 1
fi

mkdir -p "$HOME/.claude"

if [[ -f "$DEST" ]]; then
    # Backup existing settings
    BACKUP="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
    echo "  [BACKUP] $DEST -> $BACKUP"
    cp "$DEST" "$BACKUP"

    # Deep merge: existing (base) * dotfiles (override)
    TMPFILE="$(mktemp)"
    trap 'rm -f "$TMPFILE"' EXIT
    jq -s '.[0] * .[1]' "$DEST" "$SRC" > "$TMPFILE"
    mv "$TMPFILE" "$DEST"
    trap - EXIT
    echo "  [MERGE] $SRC -> $DEST"
else
    cp "$SRC" "$DEST"
    echo "  [COPY] $SRC -> $DEST"
fi

# Add shell alias for Claude Code
SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
    bash)
        RC_FILE="$HOME/.bashrc"
        ALIAS_LINE="alias cc='claude --dangerously-skip-permissions'"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        ALIAS_LINE="alias ccd='claude --dangerously-skip-permissions'"
        ;;
    *)
        echo "  [WARN] Unsupported shell: $SHELL_NAME. Skipping alias setup."
        RC_FILE=""
        ;;
esac

if [[ -n "$RC_FILE" ]]; then
    # Add alias
    if [[ -f "$RC_FILE" ]] && grep -qF "$ALIAS_LINE" "$RC_FILE"; then
        echo "  [SKIP] Alias already exists in $RC_FILE"
    else
        echo "$ALIAS_LINE" >> "$RC_FILE"
        echo "  [ADD] $ALIAS_LINE -> $RC_FILE"
    fi

    # Add environment variables
    EXPORTS=(
        "export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
        "export CLAUDE_CODE_NO_FLICKER=1"
    )
    for EXPORT_LINE in "${EXPORTS[@]}"; do
        if [[ -f "$RC_FILE" ]] && grep -qF "$EXPORT_LINE" "$RC_FILE"; then
            echo "  [SKIP] Already exists in $RC_FILE: $EXPORT_LINE"
        else
            echo "$EXPORT_LINE" >> "$RC_FILE"
            echo "  [ADD] $EXPORT_LINE -> $RC_FILE"
        fi
    done
fi

echo "==> Claude Code settings installed"
