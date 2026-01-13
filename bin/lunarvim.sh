#!/usr/bin/env bash
# Description: Install tmux and setup theme

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# Helper: Install dependencies via default methods
install_dependencies() {
  # Basic stuff available on dnf
  sudo dnf install -y git make curl neovim ripgrep

  # Programming language specific - Let mise manage them
  if ! command -v mise >/dev/null 2>&1; then
    bash "$SCRIPT_DIR/bin/mise.sh"
    eval "$(mise activate bash)"
    mise use -g python
    mise use -g node
    mise use -g rust
  fi
}

if [[ $# -eq 1 ]]; then
  if [[ "$1" == "--use-defaults" ]]; then
    install_dependencies
  else
    loge "Unknown argument"
    exit 1
  fi
fi

# Dependency Check
for cmd in git make curl pip python npm node cargo rg neovim; do
  command -v "$cmd" >/dev/null 2>&1 || {
    loge "Missing dependency: $cmd (install manually or rerun with --use-defaults)"
    exit 1
  }
done

# Install Lunarvim
printf '\n\n\n' | bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

# Post-install: NerdFont
bash "$SCRIPT_DIR/bin/nerdfont.sh"
