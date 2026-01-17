#!/usr/bin/env bash
# Description: Install tmux and setup theme

set -euo pipefail

readonly TMP="$(mktemp -d)"

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

installed_version() {
  if command -v insomnia &>/dev/null; then
    dnf info insomnia | grep Version | sed 's/.*:\s/core@/'
  else
    echo "none"
  fi
}

latest_release() {
  curl -s https://api.github.com/repos/Kong/insomnia/releases/latest
}

latest_version() {
  latest_release | jq -r '.tag_name' | tr -d 'v'
}

latest_rpm_url() {
  latest_release \
    | jq -r '.assets[].browser_download_url' \
    | grep -E '\.rpm$' \
    | head -n1
}

current="$(installed_version)"
latest="$(latest_version)"

if [[ "$current" == "$latest" ]]; then
  logi "Insomnia is already up-to-date ($current)"
else
  logi "Installing/upgrading Insomnia: $current → $latest"
  rpm_url="$(latest_rpm_url)"
  rpm_file="$TMP/insomnia.rpm"

  curl -L "$rpm_url" -o "$rpm_file"
  sudo dnf install -y "$rpm_file"

  logs "Insomnia was successfully installed"
fi

