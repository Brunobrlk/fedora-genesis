#!/usr/bin/env bash
# Description: Install mise

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }

# Install mise
if ! command -v mise >/dev/null 2>&1; then
  logi "Installing mise"
  dnf copr enable -y jdxcode/mise
  dnf install -y mise

  logs "mise was successfully installed"
else
  logi "mise is already installed"
fi

# Activate Mise
logi "Make sure your ~/.bashrc has:"
cat <<'EOF'

  eval "$(mise activate bash)"

EOF

# Setup autocompletion
readonly COMPLETIONS_DIR="$HOME/.local/share/bash-completion/completions"
readonly MISE_COMPLETIONS_FILE="$COMPLETIONS_DIR/mise"

if [[ ! -f "$MISE_COMPLETIONS_FILE" ]]; then
  # Activate mise in the current shell
  eval "$(mise activate bash)"
  mise use -g usage

  mkdir -p "$COMPLETIONS_DIR"
  mise completion bash --include-bash-completion-lib >"$MISE_COMPLETIONS_FILE"
else
  logi "Mise completions are already set"
fi
