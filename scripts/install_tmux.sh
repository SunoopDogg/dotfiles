#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing tmux config"

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
    echo "  [WARN] tmux is not installed. Copying config files only."
fi

# Create target directories
mkdir -p "$HOME/.config/tmux"

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

# Copy config files
install_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_file "$DOTFILES_DIR/tmux/keybindings.conf" "$HOME/.config/tmux/keybindings.conf"

# Copy theme.conf with home directory substitution for portability
src="$DOTFILES_DIR/tmux/theme.conf"
dest="$HOME/.config/tmux/theme.conf"
if [[ ! -f "$src" ]]; then
    echo "  [ERROR] Source file not found: $src"
else
    if [[ -f "$dest" ]]; then
        echo "  [BACKUP] $dest -> ${dest}.bak"
        cp "$dest" "${dest}.bak"
    fi
    sed "s|/home/airo-workstation|$HOME|g" "$src" > "$dest"
    echo "  [COPY] $src -> $dest (home path substituted)"
fi

# Install TPM
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    echo "  [INSTALL] TPM (Tmux Plugin Manager)"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "  [SKIP] TPM is already installed."
fi

# Install TPM plugins
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins"
if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
    echo "  [INSTALL] tmux plugins"
    "$TPM_DIR/bin/install_plugins" || echo "  [WARN] Plugin auto-install failed. Run prefix + I inside tmux to install manually."
else
    echo "  [WARN] Cannot run TPM install_plugins. Run prefix + I inside tmux to install manually."
fi

echo "==> tmux config installed"
