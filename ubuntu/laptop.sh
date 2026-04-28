#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Force sudo password prompt early
sudo -v

# Install Discord
DEB_PATH="/tmp/discord-setup.deb"
DISCORD_BIN="/usr/bin/discord"

# Check if Discord is already installed
if command -v discord >/dev/null 2>&1 || [ -x "$DISCORD_BIN" ]; then
  echo "Discord is already installed."
else
  echo "Discord is not installed, downloading .deb package..."

  # Download the Discord package
  curl -L \
    "https://discord.com/api/download?platform=linux&format=deb" \
    -o "$DEB_PATH"

  echo "Installing Discord..."
  apt update
  apt install -y "$DEB_PATH"

  # Remove the .deb file
  echo "Removing file $DEB_PATH..."
  rm -f "$DEB_PATH"
fi

# Install signal-desktop

# Check if Signal is already installed
if [ ! -f "/usr/bin/signal-desktop" ]; then
    echo "Signal is not installed. Installing..."

    # Download Signal GPG key
    wget -O /tmp/signal_gpg https://updates.signal.org/desktop/apt/keys.asc

    # De-Armor Signal GPG key
    gpg --dearmor < /tmp/signal_gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    rm /tmp/signal_gpg

    # Add Signal repository line to sources.list.d
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | tee /etc/apt/sources.list.d/signal-xenial.list

    # Update package cache and install Signal
    apt update
    apt install -y signal-desktop

    echo "Signal installation completed."
else
    echo "Signal is already installed. Skipping installation."
fi

# Cam parts
APP_DESKTOP_NOEXIST="${HOME}/.local/share/applications/hu.irl.cameractrls.desktop.noexist"
CAMERACTRLS_DIR="/opt/cameractrls"
USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"

# Check if cameractrls is already "installed" according to your sentinel file
if [ -e "$APP_DESKTOP_NOEXIST" ]; then
  echo "CameraCtrls is considered installed (sentinel file exists): $APP_DESKTOP_NOEXIST"
  exit 0
fi

echo "CameraCtrls not installed (sentinel file missing), proceeding with installation..."

# Install required packages for cameractrls
echo "Installing required packages..."
apt update
apt install -y libsdl2-2.0-0 libturbojpeg git desktop-file-utils

# Clone cameractrls repository
echo "Cloning cameractrls repository into $CAMERACTRLS_DIR..."
if [ -d "$CAMERACTRLS_DIR" ]; then
  rm -rf "$CAMERACTRLS_DIR"
fi
git clone https://github.com/soyersoyer/cameractrls.git "$CAMERACTRLS_DIR"

# Change ownership of the directory
echo "Changing ownership of $CAMERACTRLS_DIR to ${USER_NAME}:${GROUP_NAME}..."
chown -R "$USER_NAME:$GROUP_NAME" "$CAMERACTRLS_DIR"

# Ensure applications directory exists
mkdir -p "${HOME}/.local/share/applications"

# Run cameractrls installer (desktop-file-install command)
echo "Installing desktop file for CameraCtrls..."
(
  cd "$CAMERACTRLS_DIR"
  desktop-file-install \
    --dir="${HOME}/.local/share/applications" \
    --set-key=Exec --set-value="/opt/cameractrls/cameractrlsgtk4.py" \
    --set-key=Path --set-value="/opt/cameractrls" \
    --set-key=Icon --set-value="/opt/cameractrls/pkg/hu.irl.cameractrls.svg" \
    pkg/hu.irl.cameractrls.desktop
)

# Create the sentinel file to mark as installed (mimic .noexist path logic)
touch "$APP_DESKTOP_NOEXIST"

echo "CameraCtrls installation completed."
