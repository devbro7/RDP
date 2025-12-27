#!/bin/bash
set -e

# ========= CONFIG =========
USERNAME="user"
PASSWORD="root"
PIN="123456"
AUTOSTART=true
CRP=""

# ==========================

echo "=== Creating user ==="
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
fi

echo "=== Updating system ==="
apt update

echo "=== Installing packages ==="
apt install -y \
    xfce4 \
    xfce4-terminal \
    desktop-base \
    xscreensaver \
    wget \
    curl

echo "=== Installing Chrome Remote Desktop ==="
if ! dpkg -s chrome-remote-desktop &>/dev/null; then
    wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    dpkg -i chrome-remote-desktop_current_amd64.deb || apt -f install -y
fi

echo "=== Installing Google Chrome ==="
if ! dpkg -s google-chrome-stable &>/dev/null; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb || apt -f install -y
fi

echo "=== Configuring Chrome Remote Desktop session ==="
echo "exec /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session

systemctl disable lightdm.service || true

echo "=== Autostart setup ==="
if [ "$AUTOSTART" = true ]; then
    AUTOSTART_DIR="/home/$USERNAME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"

    cat <<EOF > "$AUTOSTART_DIR/colab.desktop"
[Desktop Entry]
Type=Application
Name=Colab
Exec=xdg-open https://youtu.be/d9ui27vVePY
X-GNOME-Autostart-enabled=true
EOF

    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
fi

echo "=== Chrome Remote Desktop Registration ==="
read -p "Enter CRP command: " CRP

usermod -aG chrome-remote-desktop "$USERNAME"

su - "$USERNAME" -c "$CRP --pin=$PIN"

systemctl start chrome-remote-desktop

echo "✅ Setup completed successfully!"
