#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

usage() {
    echo "Usage: $0 [module ...]"
    echo ""
    echo "Modules:"
    for script in "$SCRIPTS_DIR"/install_*.sh; do
        [[ -f "$script" ]] || continue
        local name
        name="$(basename "$script" .sh)"
        name="${name#install_}"
        echo "  $name"
    done
    echo ""
    echo "인자 없이 실행하면 모든 모듈을 설치합니다."
}

run_module() {
    local name="$1"
    local script="$SCRIPTS_DIR/install_${name}.sh"
    if [[ ! -f "$script" ]]; then
        echo "[에러] 모듈을 찾을 수 없습니다: $name"
        echo "  사용 가능한 모듈:"
        for s in "$SCRIPTS_DIR"/install_*.sh; do
            [[ -f "$s" ]] || continue
            local n
            n="$(basename "$s" .sh)"
            echo "    ${n#install_}"
        done
        return 1
    fi
    bash "$script"
}

# --help 플래그
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

echo "dotfiles 설치를 시작합니다."
echo ""

if [[ $# -eq 0 ]]; then
    # 모든 모듈 실행
    for script in "$SCRIPTS_DIR"/install_*.sh; do
        [[ -f "$script" ]] || continue
        bash "$script"
    done
else
    # 지정된 모듈만 실행
    for module in "$@"; do
        run_module "$module"
    done
fi

echo ""
echo "설치가 완료되었습니다."
