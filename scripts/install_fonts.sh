#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"

echo "==> Installing fonts"

# Create font directory
mkdir -p "$FONT_DIR"

# Fetch latest release tag from GitHub API
get_latest_release() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4
}

# Download and extract zip from GitHub release
download_release_zip() {
    local repo="$1"
    local tag="$2"
    local asset="$3"
    local dest_dir="$4"
    local url="https://github.com/${repo}/releases/download/${tag}/${asset}"
    local tmp_zip
    tmp_zip="$(mktemp /tmp/font-XXXXXX.zip)"

    echo "  [DOWNLOAD] ${asset} (${tag})"
    curl -fsSL -o "$tmp_zip" "$url"
    unzip -o -q "$tmp_zip" -d "$dest_dir"
    rm -f "$tmp_zip"
}

# Download single file
download_font() {
    local url="$1"
    local dest="$2"
    if [[ -f "$dest" ]]; then
        echo "  [SKIP] $(basename "$dest") already exists"
        return 0
    fi
    echo "  [DOWNLOAD] $(basename "$dest")"
    curl -fsSL -o "$dest" "$url"
}

# -- FiraCode Nerd Font (from ryanoasis/nerd-fonts) --
echo "  Fetching latest nerd-fonts release..."
NERD_VERSION="$(get_latest_release "ryanoasis/nerd-fonts")"
echo "  Installing FiraCode Nerd Font ${NERD_VERSION}..."
download_release_zip "ryanoasis/nerd-fonts" "$NERD_VERSION" "FiraCode.zip" "$FONT_DIR"

# -- Fira Code (from tonsky/FiraCode) --
echo "  Fetching latest FiraCode release..."
FIRACODE_VERSION="$(get_latest_release "tonsky/FiraCode")"
echo "  Installing Fira Code ${FIRACODE_VERSION}..."
FIRACODE_TMP="$(mktemp -d /tmp/firacode-XXXXXX)"
download_release_zip "tonsky/FiraCode" "$FIRACODE_VERSION" "Fira_Code_v${FIRACODE_VERSION}.zip" "$FIRACODE_TMP"
cp "$FIRACODE_TMP"/ttf/*.ttf "$FONT_DIR/"
rm -rf "$FIRACODE_TMP"

# -- MesloLGS NF (from romkatv/powerlevel10k-media) --
MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"

MESLO_FONTS=(
    "MesloLGS%20NF%20Regular.ttf|MesloLGS NF Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf|MesloLGS NF Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf|MesloLGS NF Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf|MesloLGS NF Bold Italic.ttf"
)

echo "  Installing MesloLGS NF..."
for entry in "${MESLO_FONTS[@]}"; do
    url_name="${entry%%|*}"
    filename="${entry##*|}"
    download_font "${MESLO_BASE}/${url_name}" "${FONT_DIR}/${filename}"
done

# Refresh font cache
echo "  [REFRESH] Font cache"
fc-cache -f "$FONT_DIR"

echo "==> Fonts installed"
