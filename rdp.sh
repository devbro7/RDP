#!/bin/bash
set -e

# =========================
# CONFIG
# =========================
USERNAME="user"
PASSWORD="root"
PIN="123456"

# =========================
# Create user
# =========================
echo "Creating user..."

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
fi

# =========================
# Update system
# =========================
apt update

# =========================
# Install packages
# =========================
apt install -y \
    xfce4 \
    xfce4-terminal \
    desktop-base \
    wget \
    curl \
    xscreensaver

# =========================
# Install Chrome Remote Desktop
# =========================
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg -i chrome-remote-desktop_current_amd64.deb || apt -f install -y

# =========================
# Install Google Chrome
# =========================
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb || apt -f install -y

# =========================
# Configure CRD session
# =========================
echo "exec /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session

# =========================
# Permissions
# =========================
usermod -aG chrome-remote-desktop "$USERNAME"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

# =========================
# CRD Registration
# =========================
echo ""
echo "Paste your Chrome Remote Desktop command:"
read -r CRP_CMD

su - "$USERNAME" -c "$CRP_CMD --pin=$PIN"

# =========================
# Start service
# =========================
service chrome-remote-desktop start

echo "=================================="
echo "✅ Setup completed successfully!"
echo "=================================="

# =========================
# Disable LightDM (optional)
# =========================
systemctl disable lightdm.service || true

# =========================
# Autostart (NO YOUTUBE)
# =========================
if [ "$AUTOSTART" = true ]; then
    AUTOSTART_DIR="/home/$USERNAME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"

    cat <<EOF > "$AUTOSTART_DIR/app.desktop"
[Desktop Entry]
Type=Application
Name=Startup App
Exec=xfce4-terminal
X-GNOME-Autostart-enabled=true
EOF

    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
fi

# =========================
# Final CRD Start
# =========================
systemctl start chrome-remote-desktop

echo "✅ Setup completed successfully!"
