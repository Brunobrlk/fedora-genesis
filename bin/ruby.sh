#!/usr/bin/env bash
# Description: Dependencies for ruby

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

dnf install -y autoconf gcc rust patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel gdbm-devel ncurses-devel perl-FindBin

# Fedora >= 40
dnf install -y zlib-ng-compat-devel

# Fedora <= 39
# dnf install -y zlib-devel
