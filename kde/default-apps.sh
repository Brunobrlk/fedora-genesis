#!/usr/bin/env bash
# Description: 

set -euo pipefail


# Switch File manager to nemo
sudo dnf install -y nemo nemo-fileroller
nemo -q

sudo dnf remove -y dolphin
sudo dnf autoremove -y

# Switch Email client
sudo dnf install -y thunderbird

sudo dnf remove -y kmail kontact akonadi akonadi-server akregator korganizer kaddressbook
rm -rf ~/.local/share/akonadi
rm -rf ~/.config/akonadi
rm -rf ~/.cache/akonadi
