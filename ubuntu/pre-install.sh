#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Handle arguments
RUN_LAPTOP_SCRIPT=false
RUN_VM_INSTALL=false
for arg in "$@"; do
    if [ "$arg" == "--laptop" ]; then
        RUN_LAPTOP_SCRIPT=true
    elif [ "$arg" == "--vm" ]; then
        RUN_VM_INSTALL=true
    fi
done

# Force sudo password prompt early
sudo -v

echo "[*] Setting DNS to Google for stability"
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "[*] Installing Linux basics"
sudo apt clean
sudo apt update
sudo apt upgrade -y
sudo apt install -y pipx curl vim git wget tzdata sudo tmux
echo "[*] Installing Pipx"
pipx ensurepath
export PATH="$PATH:$HOME/.local/bin"

# Install VMware guest tools if --vm is provided
if [ "$RUN_VM_INSTALL" = true ]; then
    echo "[*] Installing VMware guest tools"
    sudo apt install -y open-vm-tools open-vm-tools-desktop
fi

# Always run install.sh
echo "[*] Running install.sh"
bash install.sh
curl -fsSL https://raw.githubusercontent.com/ZarKyo/utils/refs/heads/main/bin/install_docker.sh -o install_docker.sh
chmod +x install_docker.sh
bash install_docker.sh

# Run laptop script if --laptop is provided
if [ "$RUN_LAPTOP_SCRIPT" = true ]; then
    echo "[*] Running laptop-specific script"
    bash laptop.sh
fi
