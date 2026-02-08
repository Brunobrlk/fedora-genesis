#!/usr/bin/env bash
set -euo pipefail

readonly SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
readonly AVDIMG_ARCH="x86_64"
readonly AVDIMG_FLAVOR="default"

logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logw() { printf '\033[1;33m[BRLK WARNING]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

safesdkmanager() {
  sdkmanager --sdk_root="$SDK_ROOT" "$@"
}

install_pkg() {
  local pkg="$1"
  if grep -q "^[[:space:]]*$pkg[[:space:]]" <<< "$SDK_INSTALLED_LIST"; then
    logi "$pkg already installed. Skipping."
  else
    logi "Installing $pkg"
    safesdkmanager "$pkg"
  fi
}

# Environment Check
[[ -n "$SDK_ROOT" ]] || {
  loge "ANDROID_SDK_ROOT or ANDROID_HOME must be set"
  exit 1
}

# Dependency Check
for cmd in sdkmanager avdmanager; do
  command -v "$cmd" >/dev/null 2>&1 || {
    loge "Missing dependency: $cmd"
    exit 1
  }
done

# Accept licenses
logi "Accepting Android SDK licenses"
yes | safesdkmanager --licenses >/dev/null || true

# Sdk resolution
logi "Resolving latest Android SDK components"
SDK_LIST="$(safesdkmanager --list)"
SDK_INSTALLED_LIST="$(safesdkmanager --list_installed)"
PLATFORM_VERSION="$(echo "$SDK_LIST" | grep -o 'platforms;android-[0-9.]\+' | sort -V | tail -n1 )"
BUILD_TOOLS_VERSION="$(echo "$SDK_LIST" | grep -o 'build-tools;[0-9.]\+' | sort -V | tail -n1 )"
SOURCES_VERSION="$(echo "$SDK_LIST" | grep -o 'sources;android-[0-9.]\+' | sort -V | tail -n1 )"
AVDIMG_LVL="$(echo "$SDK_LIST" | grep -o 'system-images;android-[0-9]\+' | sort -V | tail -n1 )"
AVDIMG_VERSION="$AVDIMG_LVL;$AVDIMG_FLAVOR;$AVDIMG_ARCH"

# Sdk installation
logi "Installing latest sdk components"
install_pkg "$PLATFORM_VERSION"
install_pkg "$BUILD_TOOLS_VERSION"
install_pkg "$SOURCES_VERSION"
install_pkg "$AVDIMG_VERSION"
install_pkg "platform-tools"
install_pkg "emulator"

# AVD Creation
AVD_DIR="${ANDROID_AVD_HOME:-$HOME/.config/android/avd}"
mkdir -p "$AVD_DIR"

API_LVL="${AVDIMG_LVL##*-}"
AVD_NAME="api$API_LVL-$AVDIMG_FLAVOR-$AVDIMG_ARCH"
logi "Creating basic AVD: $AVD_NAME"
echo "no" | avdmanager create avd \
  -f \
  -n "$AVD_NAME" \
  -k "$AVD_IMG"

logs "Successfully installed android sdk latest components"
