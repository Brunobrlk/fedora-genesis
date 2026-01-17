#!/usr/bin/env bash
set -euo pipefail

# Uninstall: rm -rf ~/.local/opt/postman ~/.local/bin/postman ~/.local/share/applications/postman.desktop

readonly APP_NAME="Postman"
readonly BASE_DIR="$HOME/.local"
readonly APP_DIR="$BASE_DIR/opt/postman"
readonly BIN_DIR="$BASE_DIR/bin"
readonly BIN="$BIN_DIR/postman"
readonly DESKTOP_DIR="$BASE_DIR/share/applications"
readonly DESKTOP_FILE="$DESKTOP_DIR/postman.desktop"
readonly TMP="$(mktemp -d)"

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1"; }

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

# -----------------------------------------------------------------------------
# Version detection
# -----------------------------------------------------------------------------
installed_version() {
  local pkg="$APP_DIR/app/resources/app/package.json"

  if [[ -f "$pkg" ]]; then
    jq -r '.version' "$pkg"
  else
    echo "none"
  fi
}

latest_version() {
  # Getting latest version options are trash
  echo "none"
}

# -----------------------------------------------------------------------------
# Install / Upgrade
# -----------------------------------------------------------------------------
install_or_upgrade() {
  logi "Downloading latest Postman…"

  curl -L https://dl.pstmn.io/download/latest/linux64 -o "$TMP/postman.tar.gz"

  mkdir -p "$APP_DIR"
  rm -rf "$APP_DIR"/*

  tar -xzf "$TMP/postman.tar.gz" \
    -C "$APP_DIR" \
    --strip-components=1

  mkdir -p "$BIN_DIR"
  ln -sf "$APP_DIR/Postman" "$BIN"

  create_desktop_entry

  logs "Postman installed successfully"
}

# -----------------------------------------------------------------------------
# Desktop entry
# -----------------------------------------------------------------------------
create_desktop_entry() {
  mkdir -p "$DESKTOP_DIR"

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Postman
Comment=API Development Environment
Exec=$BIN
Icon=$APP_DIR/app/resources/app/assets/icon.png
Terminal=false
Categories=Development;Network;
StartupWMClass=Postman
EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
current="$(installed_version)"
latest="$(latest_version)"

if [[ "$current" == "$latest" ]]; then
  logi "Postman is already up-to-date ($current)"
else
  logi "Installing/upgrading Postman: $current → $latest"
  install_or_upgrade
fi

