#!/usr/bin/env bash
set -euo pipefail

# Load OS info
. /etc/os-release

# Accept Ubuntu, Mint, or any distro that claims to be Ubuntu‑like.
# Also, accept 22.04 and 24.04 LTS, plus Mint’s own 22/24 releases.
if [[ "$ID" != "ubuntu" && "$ID" != "linuxmint" ]]; then
    echo "Unsupported distro: $ID"
    exit 1
fi

# (Optional) Be stricter on Ubuntu codename if you really want only
# 22.04/24.04:
# if [[ "$UBUNTU_CODENAME" != "noble" && "$UBUNTU_CODENAME" != "jammy" ]]; then
#     echo "Unsupported Ubuntu codename: $UBUNTU_CODENAME"
#     exit 1
# fi


# Install prerequisites
sudo apt-get update
sudo apt-get install -y wget gnupg apt-transport-https software-properties-common

# Register Microsoft repository
wget -q https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb \
     -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install PowerShell
sudo apt-get update
sudo apt-get install -y powershell
