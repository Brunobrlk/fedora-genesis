#!/usr/bin/env bash
# Author: Bruno Guimarães
# Description: Install qemu-kvm
# Article: https://sysguides.com/install-kvm-on-linux
# Version: 1.0

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# Constants / Config
# ──────────────────────────────────────────────────────────────────────────────
logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }
logw() { printf '\033[1;33m[BRLK WARNING]\033[0m - %s\n' "$1"; }

# ──────────────────────────────────────────────────────────────────────────────
# Functions
# ──────────────────────────────────────────────────────────────────────────────
ensure_dependencies(){
  # Dependency Check
  for cmd in lscpu virt-host-validate zgrep; do
    command -v "$cmd" >/dev/null 2>&1 || {
      loge "Missing dependency: $cmd"
      exit 1
    }
  done
}

ensure_hardware_support() {
  logi "Checking CPU virtualization support"

  if ! lscpu | grep -qiE 'vmx|svm'; then
    loge "CPU does not support hardware virtualization (VT-x / AMD-V)"
    exit 1
  fi

  logs "Hardware virtualization supported"
}

ensure_kvm_modules() {
  logi "Checking kernel KVM support"

  if ! zgrep -q CONFIG_KVM /boot/config-"$(uname -r)"; then
    loge "Kernel does not have KVM support enabled"
    exit 1
  fi

  logs "Kernel KVM support present"
}

install_main_components(){
  sudo dnf install -y qemu-kvm libvirt
}

install_clients(){
  # Virsh is included on libvirt
  sudo dnf install -y virt-install virt-manager
}

install_extra_tools(){
  sudo dnf install -y virt-viewer edk2-ovmf swtpm qemu-img guestfs-tools libosinfo tuned
}

install_windows_virtio(){
  logi "Installing Windows VirtIO drivers"

  if [[ ! -f /etc/yum.repos.d/virtio-win.repo ]]; then
    sudo wget -q \
      https://fedorapeople.org/groups/virt/virtio-win/virtio-win.repo \
      -O /etc/yum.repos.d/virtio-win.repo
  fi

  sudo dnf install -y virtio-win
}

enable_libvirt_services() {
  logi "Enabling libvirt services"

  sudo systemctl enable --now \
    virtqemud.socket \
    virtnetworkd.socket \
    virtstoraged.socket \
    virtlogd.socket \
    virtsecretd.socket
}

check_virtualization_setup() {
  local grub_file="/etc/default/grub"
  local config_validation

  logi "Validating virtualization host configuration"

  config_validation="$(sudo virt-host-validate qemu || true)"
  echo "$config_validation"

  # Detect IOMMU kernel warning
  if ! grep -qi "WARN.*IOMMU" <<<"$config_validation"; then
    logs "IOMMU already enabled in kernel"
    return 0
  fi
  logi "Configuring IOMMU"

  local grub_cmdline
  grub_cmdline="$(grep '^GRUB_CMDLINE_LINUX=' "$grub_file")"

  if grep -qi "intel" /proc/cpuinfo; then
    if ! grep -q "intel_iommu=on" <<<"$grub_cmdline"; then
      sed -i \
        's/^GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="\1 intel_iommu=on iommu=pt"/' \
        "$grub_file"
    fi

  elif grep -qi "amd" /proc/cpuinfo; then
    if ! grep -q "amd_iommu=on" <<<"$grub_cmdline"; then
      sed -i \
        's/^GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="\1 amd_iommu=on iommu=pt"/' \
        "$grub_file"
    fi

  else
    loge "Unable to detect CPU vendor"
    return 1
  fi

  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  logw "Please reboot to ensure that no issues remain"
}

optmize_performance(){
  logi "Applying tuned virtual-host profile"

  sudo systemctl enable --now tuned
  sudo tuned-adm profile virtual-host

  logs "Performance profile 'virtual-host' applied"
}

ensure_regular_user_on_groups(){
  logi "Configuring user permissions for libvirt"

  sudo usermod -aG libvirt "$USER"

  mkdir -p "$HOME/.config/profile/env.d"

  local env_file="$HOME/.config/profile/env.d/fedora.sh"
  grep -q LIBVIRT_DEFAULT_URI "$env_file" 2>/dev/null || \
    echo "export LIBVIRT_DEFAULT_URI='qemu:///system'" >> "$env_file"

  logw "Logout/login required to apply group changes"
}

allow_images_access_control(){
  sudo setfacl -R -b /var/lib/libvirt/images
  sudo setfacl -R -m u:$USER:rwX /var/lib/libvirt/images
  sudo setfacl -m d:u:$USER:rwx /var/lib/libvirt/images

  logs "You now have full access to the /var/lib/libvirt/images directory"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
main() {
  ensure_dependencies
  ensure_hardware_support
  ensure_kvm_modules

  install_packages
  install_windows_virtio

  enable_libvirt_services
  check_virtualization_setup
  optimize_performance
  ensure_regular_user_on_groups

  logs "KVM/libvirt installation completed successfully"
}

# ──────────────────────────────────────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────────────────────────────────────
# Only run main if script is executed (not sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
