#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# Reference:
#
# Flavors: aosp_atd, default, google_apis, google_apis_playstore
# Flavors(api35+): google_apis_ps16k, google_apis_playstore_ps16k
# Architectures: x86_64, x86, arm64_v8a
# Api levels: android-10-36
# Other platforms: android-tv, android-automotive, android-automotive-playstore, android-wear, android-xr, android-desktop

readonly SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
readonly AVDIMG_ARCH="x86_64"
readonly AVDIMGS=( # About xyGB
  "system-images;android-36;default;$AVDIMG_ARCH" # Android 16
  "system-images;android-36;google_apis;$AVDIMG_ARCH" # Android 16
  "system-images;android-36;google_apis_ps16k;$AVDIMG_ARCH" # Android 16
  "system-images;android-36;google_apis_playstore;$AVDIMG_ARCH" # Android 16
  "system-images;android-35;google_apis;$AVDIMG_ARCH" # Android 15
  "system-images;android-34;google_apis;$AVDIMG_ARCH" # Android 14
  "system-images;android-33;google_apis;$AVDIMG_ARCH" # Android 13
  "system-images;android-32;google_apis;$AVDIMG_ARCH" # Android 12L
  "system-images;android-31;google_apis;$AVDIMG_ARCH" # Android 12
  "system-images;android-30;google_apis;$AVDIMG_ARCH" # Android 11
  "system-images;android-29;google_apis;$AVDIMG_ARCH" # Android 10
  "system-images;android-28;google_apis;$AVDIMG_ARCH" # Android 9
  "system-images;android-27;google_apis;$AVDIMG_ARCH" # Android 8.1
  "system-images;android-26;google_apis;$AVDIMG_ARCH" # Android 8
  "system-images;android-25;google_apis;$AVDIMG_ARCH" # Android 7.1
  "system-images;android-24;google_apis;$AVDIMG_ARCH" # Android 7
)

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
[[ -n "${SDK_ROOT:-}" ]] || {
  loge "SDK_ROOT or ANDROID_HOME must be set"
  exit 1
}

# Dependency Check
for cmd in sdkmanager avdmanager; do
  command -v "$cmd" >/dev/null 2>&1 || {
    loge "Missing dependency: $cmd"
    exit 1
  }
done

# AVD Creation
logi "Fetching installed SDK components"
SDK_INSTALLED_LIST="$(safesdkmanager --list_installed)"
AVD_INSTALLED_LIST="$(avdmanager list avd)"

logi "Creating avd directory"
AVD_DIR="${ANDROID_AVD_HOME:-"$HOME/.config/android/avd"}"
mkdir -p "$AVD_DIR"

for image in "${AVDIMGS[@]}"; do
  AVD_NAME="api${image#system-images;android-}"
  AVD_NAME="${AVD_NAME//;/-}"

  # Check AVD existence
  if grep -q "Name: $AVD_NAME" <<< "$AVD_INSTALLED_LIST"; then
    logi "AVD $AVD_NAME already exists. Skipping."
    continue
  fi

  logi "Creating AVD: $AVD_NAME"

  install_pkg "$image"

  echo "no\n" | avdmanager create avd \
    -f \
    -n "$AVD_NAME" \
    -k "$image"
done
