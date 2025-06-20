#!/bin/bash
# Script: kali-tools-installer.sh
# Description: Installs WiFi hacking and pentesting tools on Ubuntu with Kali repos (temporary)
# Usage: sudo ./kali-tools-installer.sh

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo!" >&2
    exit 1
fi

# Add Kali repos temporarily
add_kali_repo() {
    echo "[+] Adding Kali repositories..."
    echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee /etc/apt/sources.list.d/kali-temp.list >/dev/null
    wget -qO - https://archive.kali.org/archive-key.asc | sudo apt-key add - >/dev/null 2>&1
    apt update -qq
}

# Remove Kali repos after install
remove_kali_repo() {
    echo "[+] Cleaning up Kali repositories..."
    rm -f /etc/apt/sources.list.d/kali-temp.list
    apt-key del "Archive Key" >/dev/null 2>&1
    apt update -qq
}

# Main installation
echo "===== Ubuntu Pentest Tools Installer ====="

# Standard tools (from Ubuntu repos)
STANDARD_TOOLS=(
    iw awk aircrack-ng xterm iproute2 pciutils procps 
    dnsmasq tcpdump tshark openssl nftables lighttpd
    isc-dhcp-server hostapd
)

# Kali-specific tools (need temporary repo)
KALI_TOOLS=(
    bettercap ettercap-graphical hostapd-wpe bully pixiewps 
    asleap hashcat mdk4 reaver john crunch beef-xss
)

# Install standard tools first
echo "[1/3] Installing standard tools..."
apt install -y "${STANDARD_TOOLS[@]}" >/dev/null

# Add Kali repos for special tools
add_kali_repo

# Install Kali tools
echo "[2/3] Installing Kali-specific tools..."
for tool in "${KALI_TOOLS[@]}"; do
    echo -n "Installing $tool..."
    if apt install -y "$tool" >/dev/null 2>&1; then
        echo " ✓"
    else
        echo " ✗ (Failed)"
    fi
done

# Clean up
remove_kali_repo

# Special cases
echo "[3/3] Handling special cases..."
# Wifite (special install)
git clone https://github.com/kimocoder/wifite2.git /opt/wifite
ln -s /opt/wifite/Wifite.py /usr/local/bin/wifite

# Verify installations
echo ""
echo "===== Installation Summary ====="
for tool in "${STANDARD_TOOLS[@]}" "${KALI_TOOLS[@]}"; do
    if command -v "${tool%% *}" >/dev/null; then
        echo "✓ $tool"
    else
        echo "✗ $tool (Not installed)"
    fi
done

echo "Done! Kali repositories removed. Tools remain installed."
