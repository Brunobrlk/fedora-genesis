#!/usr/bin/env bash
# Description: Install starship

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

# Install starship
if ! command -v starship >/dev/null 2>&1; then
  logi "Installing starship"
  dnf copr enable -y atim/starship
  dnf install -y starship

  logs "Starship was successfully installed"
else
  logi "Starship is already installed"
fi

# Activate
logi "Make sure your ~/.bashrc has:"
cat <<'EOF'

  eval "$(starship init bash)"

EOF

# Post-install: NerdFont
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
bash "$SCRIPT_DIR/bin/nerdfont.sh"
