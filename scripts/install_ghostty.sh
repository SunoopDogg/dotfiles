#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/scripts/_lib.sh"

echo "==> Installing ghostty config"

# Check if ghostty is installed
if ! command -v ghostty &>/dev/null; then
    echo "  [WARN] ghostty is not installed. Copying config files only."
fi

# Create target directory
mkdir -p "$HOME/.config/ghostty"

# Copy config file
install_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

echo "==> ghostty config installed"
