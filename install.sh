#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

list_modules() {
    local prefix="${1:-  }"
    local found=0
    for script in "$SCRIPTS_DIR"/install_*.sh; do
        [[ -f "$script" ]] || continue
        local name
        name="$(basename "$script" .sh)"
        echo "${prefix}${name#install_}"
        found=1
    done
    if [[ "$found" -eq 0 ]]; then
        echo "${prefix}(no modules found)"
    fi
}

usage() {
    echo "Usage: $0 [module ...]"
    echo ""
    echo "Modules:"
    list_modules "  "
    echo ""
    echo "Run without arguments to install all modules."
}

run_module() {
    local name="$1"
    local script="$SCRIPTS_DIR/install_${name}.sh"
    if [[ ! -f "$script" ]]; then
        echo "[ERROR] Module not found: $name"
        echo "  Available modules:"
        list_modules "    "
        return 1
    fi
    bash "$script"
}

# --help flag
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

echo "Starting dotfiles installation."
echo ""

if [[ $# -eq 0 ]]; then
    # Run all modules
    for script in "$SCRIPTS_DIR"/install_*.sh; do
        [[ -f "$script" ]] || continue
        bash "$script"
    done
else
    # Run specified modules only
    for module in "$@"; do
        run_module "$module"
    done
fi

echo ""
echo "Installation complete."
