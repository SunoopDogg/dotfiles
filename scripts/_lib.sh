#!/usr/bin/env bash

# Substitute glyph placeholders with actual Unicode characters.
# Keeps config files editor-safe by avoiding invisible Unicode literals.
#   Usage: substitute_glyphs <file>
substitute_glyphs() {
    local file="$1"
    sed -i \
        -e "s|__PILL_L__|$(printf '\ue0b6')|g" \
        -e "s|__PILL_R__|$(printf '\ue0b4')|g" \
        -e "s|__ICON_TERMINAL__|$(printf '\U000f018d')|g" \
        -e "s|__ICON_FOLDER__|$(printf '\U000f024b')|g" \
        -e "s|__ICON_CPU__|$(printf '\uf4bc')|g" \
        -e "s|__ICON_MEMORY__|$(printf '\uefc5')|g" \
        -e "s|__ICON_CALENDAR__|$(printf '\U000f00f0')|g" \
        "$file"
}

# Check if required commands are available
check_commands() {
    local missing=()
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "  [ERROR] Missing required commands: ${missing[*]}"
        echo "  Please install them before continuing."
        return 1
    fi
}

# Backup and copy helper (timestamped backup)
install_file() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$src" ]]; then
        echo "  [ERROR] Source file not found: $src"
        return 1
    fi
    if [[ -f "$dest" ]]; then
        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        echo "  [BACKUP] $dest -> $backup"
        cp "$dest" "$backup"
    fi
    cp "$src" "$dest"
    echo "  [COPY] $src -> $dest"
}
