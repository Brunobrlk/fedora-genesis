#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly FROM_DIR="$HOME/Downloads/Studio"
readonly DEST_DIR="$HOME/src"
readonly DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$DEST_DIR" "$DESKTOP_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

title_case() {
  # electric-eel -> Electric Eel
  sed -E 's/-/ /g; s/\b(.)/\U\1/g'
}

shopt -s nullglob

for archive in "$FROM_DIR"/android-studio-*.tar.gz; do
  filename="$(basename "$archive")"

  # android-studio-electric-eel.tar.gz → android-studio-electric-eel
  base="${filename%.tar.gz}"

  install_dir="$DEST_DIR/$base"
  desktop_file="$DESKTOP_DIR/$base.desktop"

  codename="${base#android-studio-}"
  display_name="$(printf '%s\n' "$codename" | title_case)"

  logi "Processing $filename"

  if [[ -d "$install_dir" ]]; then
    logi "Already extracted: $install_dir (skipping)"
  else
    logi "Extracting to $install_dir"
    mkdir -p "$install_dir"
    tar -xzf "$archive" -C "$install_dir" --strip-components=1
    logs "Extracted $base"
  fi

  if [[ ! -f "$desktop_file" ]]; then
    logi "Creating desktop entry: $desktop_file"
    cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Android Studio $display_name
Comment=Android IDE ($display_name)
Exec=$install_dir/bin/studio.sh
Icon=$install_dir/bin/studio.png
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-studio
EOF
    chmod +x "$desktop_file"
    logs "Desktop entry created"
  else
    logi "Desktop entry already exists (skipping)"
  fi

done

logs "All Android Studio versions processed"

