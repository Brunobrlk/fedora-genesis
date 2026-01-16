#!/usr/bin/env bash
# Description: Install brave browser

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

# Install
if ! command -v anydesk >/dev/null 2>&1; then
  sudo tee /etc/yum.repos.d/AnyDesk-Fedora.repo <<"EOF"
[anydesk]
name=AnyDesk Fedora - stable
baseurl=http://rpm.anydesk.com/fedora/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF

  sudo dnf install -y anydesk

  logs "anydesk was successfully installed"
else
  logi "anydesk is already installed"
fi
