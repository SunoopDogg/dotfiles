#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> tmux 설정 설치"

# tmux 설치 확인
if ! command -v tmux &>/dev/null; then
    echo "  [경고] tmux가 설치되어 있지 않습니다. 설정 파일만 복사합니다."
fi

# 대상 디렉토리 생성
mkdir -p ~/.config/tmux

# 백업 및 복사 함수
install_file() {
    local src="$1"
    local dest="$2"
    if [[ -f "$dest" ]]; then
        echo "  [백업] $dest -> ${dest}.bak"
        cp "$dest" "${dest}.bak"
    fi
    cp "$src" "$dest"
    echo "  [복사] $src -> $dest"
}

# 설정 파일 복사
install_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_file "$DOTFILES_DIR/tmux/keybindings.conf" "$HOME/.config/tmux/keybindings.conf"
install_file "$DOTFILES_DIR/tmux/theme.conf" "$HOME/.config/tmux/theme.conf"

# TPM 설치
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    echo "  [설치] TPM (Tmux Plugin Manager)"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "  [스킵] TPM이 이미 설치되어 있습니다."
fi

# TPM 플러그인 설치
if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
    echo "  [설치] tmux 플러그인"
    "$TPM_DIR/bin/install_plugins"
else
    echo "  [경고] TPM install_plugins를 실행할 수 없습니다. tmux 실행 후 prefix + I로 수동 설치하세요."
fi

echo "==> tmux 설정 설치 완료"
