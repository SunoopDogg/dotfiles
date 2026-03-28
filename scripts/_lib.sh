#!/usr/bin/env bash

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
