#!/usr/bin/env bash
# Description: Install tmux and setup theme

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# Dependencies
logi "Installing dependencies (file, jq, poppler, rg, fzf, xsel, 7zip, fd and zoxide)"
sudo dnf install -y file jq poppler ripgrep fzf xsel 7zip fd-find zoxide

logi "Installing ffmpeg (RPM Fusion, allow replacing Fedora multimedia libs)"
sudo dnf install -y ffmpeg \
  --allowerasing \
  --setopt=install_weak_deps=False

# Install from copr without dependencies
sudo dnf copr enable -y lihaohong/yazi
sudo dnf install -y yazi --setopt=install_weak_deps=False

logs "yazi was successfully installed"
