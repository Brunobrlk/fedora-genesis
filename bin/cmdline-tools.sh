#!/usr/bin/env bash
set -euo pipefail

logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }

readonly ANDROID_HOME="${ANDROID_HOME:-$HOME/opt/android-sdk}"
readonly DEST_DIR="$ANDROID_HOME"

# Dependency Check
if command -v sdkmanager >/dev/null 2>&1; then
  logi "cmdline-tools is already installed"
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ZIP_FILE="$TMP_DIR/android_cmdline_tools.zip"
EXTRACT_DIR="$TMP_DIR/extract"

logi "Fetching latest Android command-line tools URL"
DL_URL="$(
  curl -fsSL https://developer.android.com/studio |
  grep -o 'https://dl.google.com/android/repository/commandlinetools-linux-[0-9]*_latest\.zip' |
  head -n1
)"

logi "Downloading command-line tools"
curl -fL -o "$ZIP_FILE" "$DL_URL"

logi "Extracting"
mkdir -p "$EXTRACT_DIR"
unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR"

logi "Installing into: $DEST_DIR"
mkdir -p "$DEST_DIR/cmdline-tools/latest"
rsync -av "$EXTRACT_DIR/cmdline-tools/" "$DEST_DIR/cmdline-tools/latest/"
logs "Installation complete"
