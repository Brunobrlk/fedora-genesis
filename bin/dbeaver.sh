#!/usr/bin/env bash
# Description: Install tmux and setup theme

set -euo pipefail

readonly TMP="$(mktemp -d)"

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

installed_version() {
  if rpm -q dbeaver-ce &>/dev/null; then
    rpm -q --qf '%{VERSION}\n' dbeaver-ce
  else
    echo "none"
  fi
}

latest_version() {
  curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest \
    | jq -r '.tag_name' | sed 's/^v//'
}

install_or_upgrade() {
  local version="$1"
  local rpm="dbeaver-ce-${version}-stable.x86_64.rpm"
  local url="https://github.com/dbeaver/dbeaver/releases/download/${version}/${rpm}"

  curl -L "$url" -o "$TMP/$rpm"
  sudo dnf install -y "$TMP/$rpm"

  logs "Dbeaver was successfully installed"
}

installed_ver="$(installed_version)"
latest_ver="$(latest_version)"

if [[ "$installed_ver" == "$latest_ver" ]]; then
  logi "DBeaver is already up-to-date ($installed_ver)"
else
  logi "Installing/upgrading DBeaver: $installed_ver → $latest_ver"
  install_or_upgrade "$latest_ver"
fi
