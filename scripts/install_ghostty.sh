#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing ghostty config"

# Check if ghostty is installed
if ! command -v ghostty &>/dev/null; then
    echo "  [WARN] ghostty is not installed. Copying config files only."
fi

# Create target directory
mkdir -p "$HOME/.config/ghostty"

# Backup and copy helper
install_file() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$src" ]]; then
        echo "  [ERROR] Source file not found: $src"
        return 1
    fi
    if [[ -f "$dest" ]]; then
        echo "  [BACKUP] $dest -> ${dest}.bak"
        cp "$dest" "${dest}.bak"
    fi
    cp "$src" "$dest"
    echo "  [COPY] $src -> $dest"
}

# Copy config file
install_file "$DOTFILES_DIR/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"

echo "==> ghostty config installed"
