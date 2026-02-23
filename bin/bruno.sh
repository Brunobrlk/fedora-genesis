#!/usr/bin/env bash
# Description: Install Bruno API Client

set -euo pipefail

readonly TMP="$(mktemp -d)"

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

installed_version() {
  if command -v bruno &>/dev/null; then
    rpm -q bruno --queryformat '%{VERSION}\n' 2>/dev/null || echo "unknown"
  else
    echo "none"
  fi
}

latest_release() {
  curl -s https://api.github.com/repos/usebruno/bruno/releases/latest
}

latest_version() {
  latest_release | jq -r '.tag_name' | tr -d 'v'
}

latest_rpm_url() {
  latest_release \
    | jq -r '.assets[].browser_download_url' \
    | grep -E 'linux.*\.rpm$' \
    | head -n1
}

current="$(installed_version)"
latest="$(latest_version)"

if [[ "$current" == "$latest" ]]; then
  logi "Bruno is already up-to-date ($current)"
else
  logi "Installing/upgrading Bruno: $current → $latest"

  rpm_url="$(latest_rpm_url)"
  rpm_file="$TMP/bruno.rpm"

  curl -L "$rpm_url" -o "$rpm_file"
  sudo dnf install -y "$rpm_file"

  logs "Bruno was successfully installed"
fi
