#!/usr/bin/env bash
# Description: Install JetBrainsMono NerdFont

set -euo pipefail

logs() { echo -e "\033[0;32m[BRLK SUCCESS]\033[0m - $1"; }
logi() { echo -e "\033[0;34m[BRLK INFO]\033[0m - $1"; }
loge() { echo -e "\033[0;31m[BRLK ERROR]\033[0m - $1"; }

readonly FONT_NAME="JetBrainsMono"
readonly FONT_DIR="$HOME/.local/share/fonts"

# Font Check
if [[ -d "$FONT_DIR/$FONT_NAME" ]]; then
  logi "$FONT_NAME NerdFont is already installed"
  exit 0
fi

# Dependency Check
for cmd in curl unzip; do
  command -v "$cmd" >/dev/null 2>&1 || {
    loge "Missing dependency: $cmd"
    exit 1
  }
done

# Download
logi "Downloading $FONT_NAME NerdFont"
cd /tmp
curl -LO "$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest |
  grep browser_download_url |
  grep "$FONT_NAME.zip" |
  cut -d '"' -f 4)"

# Install font in user scope
logi "Installing $FONT_NAME NerdFont in user scope"

mkdir -p "$FONT_DIR"
unzip "$FONT_NAME.zip" -d "$FONT_DIR/$FONT_NAME"

fc-cache -fv

logs "$FONT_NAME Nerd Font was successfully installed"
