#!/usr/bin/env bash
# Description: Install brave browser

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

# Install bat
if ! command -v brave-browser >/dev/null 2>&1; then
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
  sudo dnf install -y brave-browser

  logs "brave was successfully installed"
else
  logi "brave is already installed"
fi
