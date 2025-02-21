#!/bin/bash

# WireGuard & Firewall-Setup mit SSH-Port-Änderung
# Erstellt von ChatGPT

echo "📌 1. WireGuard & benötigte Pakete installieren..."
apt update && apt install -y wireguard iptables-persistent

echo "🔑 2. WireGuard Schlüssel generieren..."
mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

PRIVATE_KEY=$(cat privatekey)
PUBLIC_KEY=$(cat publickey)

echo "📝 3. WireGuard-Konfiguration erstellen..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $PRIVATE_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
SaveConfig = false
EOF

echo "🌐 4. IP-Forwarding aktivieren..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo "🛡️ 5. Firewall-Regeln setzen..."
iptables -A INPUT -p udp --dport 51820 -j ACCEPT
iptables -A INPUT -i wg0 -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Regeln dauerhaft speichern
netfilter-persistent save
netfilter-persistent reload

echo "🚀 6. WireGuard-Dienst starten..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "🔄 7. SSH-Port auf 1337 ändern..."
sed -i 's/^#Port 22/Port 1337/' /etc/ssh/sshd_config
sed -i 's/^Port 22/Port 1337/' /etc/ssh/sshd_config

echo "🛡️ 8. Firewall für SSH anpassen..."
ufw allow 1337/tcp
ufw delete allow 22/tcp

echo "🔄 9. SSH-Dienst neu starten..."
systemctl restart ssh

echo "✅ Setup abgeschlossen! Bitte teste SSH auf Port 1337 und starte den Server neu."
