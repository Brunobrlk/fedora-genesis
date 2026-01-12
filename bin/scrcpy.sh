#!/usr/bin/env bash
# Description: Install scrcpy via copr

set -euo pipefail

logs() { echo -e "\033[0;32m[BRLK SUCCESS]\033[0m - $1"; }
logi() { echo -e "\033[0;34m[BRLK INFO]\033[0m - $1"; }

if ! command -v scrcpy >/dev/null 2>&1; then
  sudo dnf copr enable -y zeno/scrcpy
  sudo dnf install -y scrcpy

  logs "scrcpy was successfully installed"
else
  logi "scrcpy is already installed"
fi
