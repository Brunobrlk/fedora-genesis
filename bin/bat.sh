#!/usr/bin/env bash
# Description: Install bat and setup theme

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# Dependency Check
if ! command -v curl >/dev/null 2>&1; then
  loge "Missing dependency: curl"
  exit 1
fi

# Install bat
if ! command -v bat >/dev/null 2>&1; then
  sudo dnf install -y bat
  logs "bat was successfully installed"
else
  logi "bat is already installed"
fi

# Catppuccin Macchiato theme
BAT_CONFIG_DIR="$(bat --config-dir)"
THEME_DIR="$BAT_CONFIG_DIR/themes"
THEME_FILE="$THEME_DIR/Catppuccin-Macchiato.tmTheme"
THEME_URL="https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"

if [[ ! -f "$THEME_FILE" ]]; then
  mkdir -p "$THEME_DIR"

  curl -fL -o "$THEME_FILE" "$THEME_URL"

  bat cache --build
  logs "Theme was successfully installed"
else
  logi "Theme is already installed"
fi

