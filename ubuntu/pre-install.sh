#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Check if root and if Ubuntu 
if [ "$EUID" -ne 0 ]
  then echo " ❌ Please run as root"
  exit
fi

# Handle the --laptop argument
RUN_LAPTOP_SCRIPT=false
for arg in "$@"; do
    if [ "$arg" == "--laptop" ]; then
        RUN_LAPTOP_SCRIPT=true
    fi
done

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

# Always run install.sh
echo "[*] Running install.sh"
bash install.sh
curl -fsSL https://raw.githubusercontent.com/ZarKyo/utils/refs/heads/main/bin/install-docker.sh -o install-docker.sh
chmod +x install-docker.sh
sh install-docker.sh

# Run laptop script if --laptop is provided
if [ "$RUN_LAPTOP_SCRIPT" = true ]; then
    echo "[*] Running laptop-specific script"
    bash laptop.sh
fi
