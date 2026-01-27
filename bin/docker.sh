#!/usr/bin/env bash
# Description: Install Docker Engine

set -euo pipefail

logs() { printf '\033[0;32m[BRLK SUCCESS]\033[0m - %s\n' "$1"; }
logi() { printf '\033[0;34m[BRLK INFO]\033[0m - %s\n' "$1"; }
loge() { printf '\033[0;31m[BRLK ERROR]\033[0m - %s\n' "$1" >&2; }

TARGET_USER="$(id -un)"

logi "Removing old Docker packages (if any)"
sudo dnf -y remove \
  docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine || true

logi "Installing dnf plugins"
sudo dnf install -y dnf-plugins-core

logi "Adding Docker repository"
sudo dnf config-manager addrepo \
  --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

logi "Installing Docker Engine"
sudo dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

logi "Ensuring docker group exists"
getent group docker >/dev/null || sudo groupadd docker

logi "Adding $TARGET_USER to docker group"
sudo usermod -aG docker "$TARGET_USER"

logi "Enabling Docker service"
sudo systemctl enable --now docker

logs "Docker installation completed"
logi "Log out for docker group permissions to apply"
