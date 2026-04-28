#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

export PATH="$PATH:$HOME/.local/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ ! $(grep -F 24.04 /etc/issue.net -c) -eq 1 ]] ; then 
    echo "Install has been tested on Ubuntu 24.04 only."
    echo "Please install Ubuntu 24.04 or attempt install at your own risks"
    exit 42
fi

if [ -x "$(command -v apt)" ]; then
    :
else
    echo 'This script is only compatible Ubuntu'
    exit
fi

# Force sudo password prompt early
sudo -v

# Update System
## 1. Disable Ubuntu Pro ESM spam messages if the hook exists
ESM_HOOK_FILE="/etc/apt/apt.conf.d/20apt-esm-hook.conf"

if [ -f "$ESM_HOOK_FILE" ]; then
    echo "Disabling Ubuntu Pro ESM messages..."
    sudo sed -i 's/^\([^#].*\)$/#\1/' "$ESM_HOOK_FILE"
fi

## 2. Update APT cache
echo "Updating APT repositories..."
sudo apt update -y
sudo apt -o Acquire::Retries=3 update

## 3. Upgrade all packages
echo "Upgrading all packages..."
sudo apt upgrade -y

## 4. Install packages
# ----------- CLI Tools -----------
echo "Installing CLI tools..."
sudo apt update
sudo apt install -y \
    apt-transport-https autoconf binwalk bison build-essential bzip2 ca-certificates cloc cmake cmake-curses-gui curl \
    dos2unix expect ffmpeg foremost fswebcam gcc gdb gettext git gnupg hashid hexyl htop hwinfo imagemagick inotify-tools \
    iproute2 jq kdenlive libbz2-dev libcurl4-openssl-dev libedit-dev libffi-dev libgd-dev libicu-dev libimage-exiftool-perl \
    libjpeg-dev libleptonica-dev liblzma-dev libmysqlclient-dev libncursesw5-dev libonig-dev libpcap-dev libpng-dev libpq-dev \
    libreadline-dev libsqlite3-dev libssl-dev libtesseract-dev libxml2-dev libxml2-utils libxmlsec1-dev libyaml-dev libzip-dev \
    linux-tools-common linux-tools-generic llvm locate lsb-release lsof ltrace make meld ncurses-bin net-tools \
    ngrep nmap openssh-client openssh-server openssl parallel perl pkg-config powerline python3-dev python3-pip python3-venv \
    python3-virtualenv re2c ripgrep rlwrap socat software-properties-common sshpass tk-dev tmate tmux tor traceroute tree ufw \
    unzip neofetch vbindiff vim wget wl-clipboard xclip xz-utils zip zlib1g-dev zsh asciinema html-xml-utils less

# Install cheat
wget https://github.com/cheat/cheat/releases/download/4.4.2/cheat-linux-amd64.gz
gunzip cheat-linux-amd64.gz
chmod +x cheat-linux-amd64
sudo mv cheat-linux-amd64 /usr/local/bin/cheat

# Install xsv
curl -LO https://github.com/BurntSushi/xsv/releases/download/0.13.0/xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
tar -xvzf xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
sudo mv xsv /usr/local/bin/

# Install exa and bat equivalents
sudo apt install -y eza bat
sudo ln -sf /usr/bin/bat /usr/local/bin/batcat

# ----------- GUI Tools -----------
echo "Installing GUI tools..."

# Wireshark debconf answer
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

sudo apt install -y vlc arandr blueman cheese dunst flameshot ghex gparted kdenlive kompare \
    libreoffice meld okular wireshark guvcview audacity policykit-1-gnome

# Optional: install additional tools via third-party or snap
# Snap install OnlyOffice, glow
sudo snap install onlyoffice-desktopeditors glow

# ----------- Brave Browser -----------
echo "Installing Brave Browser..."

sudo apt install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo apt install -y brave-browser

echo "All tools installed successfully!"

# SSH
## Ensure ~/.ssh exists with proper permissions
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    sudo chown -R "$USER:$USER" "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

# Shell
## 1. Install Zsh and useful Zsh plugins
echo "Installing Zsh and plugins..."
sudo apt update
sudo apt install -y zsh git curl

## 2. Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

## 3. Backup existing ~/.zshrc if it's not a symlink
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

cp "./config/aliases" "$HOME/.aliases"
cp "./config/zshrc" "$HOME/.zshrc"

## 4. Install and configure fzf
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth=1 https://github.com/junegunn/fzf "$HOME/.fzf"
    "$HOME/.fzf/install" --all
fi

## 5. Set default shell to zsh
echo "Setting default shell to zsh for user $USER..."
sudo chsh -s /usr/bin/zsh "$USER"

## 6. Clone missing plugins
echo "Clone missing plugins..."

declare -A PLUGIN_REPOS=(
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
)

for plugin in "${!PLUGIN_REPOS[@]}"; do
    if [ ! -d "$HOME/.oh-my-zsh/plugins/$plugin" ]; then
        git clone --depth=1 "${PLUGIN_REPOS[$plugin]}" "$HOME/.oh-my-zsh/plugins/$plugin"
    fi
done

echo "Shell setup complete. Logout required to apply default shell."

## 7. Fastfetch
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo apt update
sudo apt install -y fastfetch

## Cheat folder creation
mkdir -p ~/.local/share/cheats
mkdir -p ~/.config/cheat

# VS Code part
DEB_PATH="/tmp/vscode-setup.deb"
VSCODE_BIN="/usr/bin/code"

# Check if VS Code is already installed
if command -v code >/dev/null 2>&1 || [ -x "$VSCODE_BIN" ]; then
    echo "VS Code is already installed."
else
    echo "VS Code is not installed, downloading .deb package..."

    # Download the VS Code package
    curl -L \
    -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) snap Chromium/83.0.4103.106 Chrome/83.0.4103.106 Safari/537.36" \
    "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
    -o "$DEB_PATH"

    # Install the package 
    echo "Installing VS Code..."
    sudo apt install -y "$DEB_PATH"

    # Remove the .deb file
    echo "Removing file $DEB_PATH..."
    rm -f "$DEB_PATH"
fi

dos2unix config/extensions.txt

# Install VS Code extensions
if command -v code &> /dev/null 2>&1; then
    xargs -I{} code --install-extension {} --force < config/extensions.txt
fi

# Disable root password login for SSH
echo "Disabling password authentication for root in SSH..."
sudo sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo systemctl reload ssh || true

# Configure UF (if not in Docker)
echo "Configuring UFW firewall..."

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Enable logging
sudo ufw logging on

# Enable UFW
sudo ufw --force enable

# Reload UFW
sudo ufw reload

echo "UFW configuration complete."

# Set wallpaper
WALLPAPER="$HOME/Pictures/wallpaper.jpg"

cp wallpaper.jpg "$WALLPAPER"

gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"

sudo chown -R "$USER:$USER" "$HOME/"
