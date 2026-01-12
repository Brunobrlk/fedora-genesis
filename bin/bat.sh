#!/usr/bin/env bash
# Description: Install bat and setup theme

set -euo pipefail

logs() { echo -e "\033[0;32m[BRLK SUCCESS]\033[0m - $1"; }
logi() { echo -e "\033[0;34m[BRLK INFO]\033[0m - $1"; }

# Install bat
if ! command -v bat >/dev/null 2>&1; then
  sudo dnf install -y bat

  logs "bat was successfully installed"
else
  logi "bat is already installed"
fi

# Catppuccin Macchiato theme
if [[ ! -f "$(bat --config-dir)/themes/Catppuccin Macchiato.tmTheme" ]]; then
  mkdir -p "$(bat --config-dir)/themes"
  wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
  bat cache --build
  logs "Theme was successfully installed"
else
  logi "Theme is already installed"
fi
