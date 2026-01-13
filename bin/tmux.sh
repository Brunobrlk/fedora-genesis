#!/usr/bin/env bash
# Description: Install tmux and setup theme

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# Dependency Check
if command -v git >/dev/null 2>&1; then
  loge "Missing dependency: git"
  exit 1
fi

# Install tmux
if ! command -v tmux >/dev/null 2>&1; then
  sudo dnf install -y tmux
  logs "tmux was successfully installed"
else
  logi "tmux is already installed"
fi

# Get Plugin Manager
readonly TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  logs "tpm is successfully available"
else
  logi "tpm is already available"
fi

logi "Shortcut to install plugins:"
cat <<'EOF'

  Run: <leader> + I

EOF

# Install Catppuccin Theme
readonly THEME_DIR="$HOME/.config/tmux/plugins/catppuccin"

if [[ ! -d "$THEME_DIR" ]]; then
  mkdir -p "$THEME_DIR"
  git clone https://github.com/catppuccin/tmux.git "$THEME_DIR/tmux"

  logs "Catppuccin theme was successfully installed"
else
  logi "Catppuccin theme is already installed"
fi
