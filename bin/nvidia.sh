#!/usr/bin/env bash
# Author: Bruno Guimarães
# Description: Install Nvidia drivers (Fedora)
# Version: 1.0
# Last Updated: 2026-01-14

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# Constants / Config
# ──────────────────────────────────────────────────────────────────────────────
readonly STATE_FILE="/var/lib/brlk-nvidia-installer/state"
mkdir -p "$(dirname "$STATE_FILE")"

# ──────────────────────────────────────────────────────────────────────────────
# Functions
# ──────────────────────────────────────────────────────────────────────────────
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logw() { printf '\033[1;33m[BRLK WARNING]\033[0m - %s\n' "$1"; }

read_phase() {
  cat "$STATE_FILE" 2>/dev/null || printf '%s\n' preconditions
}

write_phase() {
  printf '%s\n' "$1" >"$STATE_FILE"
}

ensure_preconditions() {
  if command -v mokutil >/dev/null 2>&1; then
    prinftf '%s\n' "Command not found: mokutil"
    exit 1
  fi

  if [[ "$(mokutil --sb-state)" != *"SecureBoot disabled"* ]]; then
    logw "SecureBoot is enabled. Proceed only if you know how to enroll MOK keys and sign NVIDIA kernel modules, otherwise the driver will not load."
    read -rp "Do you want to proceed? y/[n] " yn
    [[ "$yn" != "y" ]] && exit 1
    logi "Proceeding with Secure Boot enabled (user accepted risk)"
  else
    logs "SecureBoot is disabled"
  fi

  logs "Preconditions OK"
  write_phase system-upgrade
}

upgrade_system() {
  sudo dnf upgrade --refresh -y

  write_phase nvidia-install
  logi "Rebooting after system upgrade"
  sudo reboot
  exit 0
}

install_nvidia() {
  # Enable RPM Fusion repositories
  sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

  sudo dnf upgrade --refresh -y

  # Install NVIDIA drivers
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

  logi "Building NVIDIA kernel modules (akmods)"
  sudo akmods --force
  logi "akmods finished"

  write_phase verify
  logi "Rebooting to load NVIDIA modules"
  sudo reboot
  exit 0
}

verify_nvidia() {
  if ! lsmod | grep -q nvidia; then
    logw "NVIDIA module not loaded"
    logi "Check: journalctl -b | grep -i nvidia"
    exit 1
  fi

  nvidia-smi
  logs "NVIDIA installed successfully"

  rm -f "$STATE_FILE"
  logi "Installer state cleared"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
main() {
  local phase="$(cat "$STATE_FILE" 2>/dev/null || echo preconditions)"

  case "$phase" in
  preconditions)
    ensure_preconditions
    ;;&
  system-upgrade)
    upgrade_system
    ;;
  nvidia-install)
    install_nvidia
    ;;
  verify)
    verify_nvidia
    ;;
  *)
    logw "Unknown phase: $phase"
    exit 1
    ;;
  esac
}

# ──────────────────────────────────────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────────────────────────────────────
# Only run main if script is executed (not sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
