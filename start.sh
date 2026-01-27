#!/usr/bin/env bash
# Author: Bruno Guimarães
# Description: Fedora Genesis bootstrap script
# Version: 1.1
# Last Updated: 2026-01-15

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# Constants / Config
# ──────────────────────────────────────────────────────────────────────────────
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PKGS_DNF="$SCRIPT_DIR/config/packages-dnf"
readonly PKGS_DNF_RM="$SCRIPT_DIR/config/packages-dnf-rm"
readonly PKGS_FLATPAK="$SCRIPT_DIR/config/packages-flatpak"
readonly CUSTOM_SCRIPTS="$SCRIPT_DIR/bin"

# ──────────────────────────────────────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────────────────────────────────────
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

# ──────────────────────────────────────────────────────────────────────────────
# Package helpers
# ──────────────────────────────────────────────────────────────────────────────
add_fusion_repositories() {
  # Check if RPM Fusion is already installed
  if rpm -q rpmfusion-free-release rpmfusion-nonfree-release &>/dev/null; then
    logi "RPM Fusion repositories already configured"
    return
  fi

  # Detect Fedora version
  local fedora_version="$(rpm -E %fedora)"

  logi "Installing RPM Fusion Free and Nonfree repositories (Fedora $fedora_version)"

  sudo dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"

  # Refresh metadata
  sudo dnf makecache

  logs "RPM Fusion repositories enabled"
}

install_dnf_pkgs() {
  local pkgs_file="$1"

  [[ -s "$pkgs_file" ]] || {
    logi "No dnf packages to install ($pkgs_file missing or empty)"
    return
  }

  logi "Installing dnf packages from: $pkgs_file"
  sudo xargs -a "$pkgs_file" dnf install -y
  logs "DNF installation completed"
}

remove_dnf_pkgs() {
  local pkgs_file="$1"

  [[ -s "$pkgs_file" ]] || {
    logi "No dnf packages to remove ($pkgs_file missing or empty)"
    return
  }

  logi "Removing dnf packages from: $pkgs_file"
  sudo xargs -a "$pkgs_file" dnf remove -y
  logs "DNF removal completed"
}

install_flatpak_pkgs() {
  local pkgs_file="$1"

  [[ -s "$pkgs_file" ]] || {
    logi "No flatpak packages to install ($pkgs_file missing or empty)"
    return
  }

  logi "Installing flatpak packages from: $pkgs_file"
  xargs -a "$pkgs_file" flatpak install -y --noninteractive
  logs "Flatpak installation completed"
}

# ──────────────────────────────────────────────────────────────────────────────
# Custom software
# ──────────────────────────────────────────────────────────────────────────────
install_custom_software() {
  local dir="$1"

  [[ -d "$dir" ]] || {
    logi "Custom scripts directory not found: $dir"
    return
  }

  logi "Installing custom software from: $dir"

  find "$dir" -type f -name "*.sh" | sort | while read -r script; do
    logi "Running: $(basename "$script")"
    chmod +x "$script"
    "$script"
  done

  logs "Custom software installation completed"
}

# ──────────────────────────────────────────────────────────────────────────────
# Desktop Environment detection
# ──────────────────────────────────────────────────────────────────────────────
_current_desktop() {
  echo "${XDG_CURRENT_DESKTOP:-}${DESKTOP_SESSION:-}${XDG_SESSION_DESKTOP:-}" | tr '[:upper:]' '[:lower:]'
}

is_gnome() {
  _current_desktop | grep -q "gnome"
}

is_kde() {
  _current_desktop | grep -q "kde\|plasma"
}

is_sway() {
  _current_desktop | grep -q "sway"
}

# ──────────────────────────────────────────────────────────────────────────────
# DE-specific setup
# ──────────────────────────────────────────────────────────────────────────────
setup_desktop_specific_software() {
  if is_gnome; then
    logi "Detected GNOME"
    install_custom_software "$SCRIPT_DIR/gnome"
  elif is_kde; then
    logi "Detected KDE Plasma"
    install_custom_software "$SCRIPT_DIR/kde"
  elif is_sway; then
    logi "Detected Sway"
    install_custom_software "$SCRIPT_DIR/sway"
  else
    logi "No supported desktop environment detected. Skipping DE specific setup"
  fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
main() {
  add_fusion_repositories
  install_dnf_pkgs "$PKGS_DNF"
  install_flatpak_pkgs "$PKGS_FLATPAK"
  remove_dnf_pkgs "$PKGS_DNF_RM"
  install_custom_software "$CUSTOM_SCRIPTS"
  setup_desktop_specific_software
}

# ──────────────────────────────────────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────────────────────────────────────
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
