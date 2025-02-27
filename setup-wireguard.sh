#!/bin/bash

# WireGuard & Firewall-Setup mit SSH-Port-Änderung, Unbound DNS-Server & Pi-hole
# Version 2 – Mit Pi-hole Integration
# Erstellt von ChatGPT

# Deutsche Tastatur aktivieren
loadkeys de

SERVER_WG_IP="10.0.0.1"
CLIENT_WG_IP="10.0.0.2"
WG_PORT="51820"
SSH_PORT="1337"
SERVER_INTERFACE="eth0"

# Root-Rechte überprüfen
if [ "$EUID" -ne 0 ]; then
    echo "❌ Dieses Skript muss als Root ausgeführt werden!"
    exit 1
fi

echo "📸 1. Unbound & Pi-hole installieren..."
apt update && apt install -y unbound dnsutils speedtest-cli curl

# Unbound konfigurieren
cat <<EOF > /etc/unbound/unbound.conf.d/pi-hole.conf
server:
    port: 5335
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes
    root-hints: "/var/lib/unbound/root.hints"
    cache-min-ttl: 3600
    cache-max-ttl: 86400
    val-permissive-mode: no
    harden-dnssec-stripped: yes
    use-caps-for-id: yes
    num-threads: 2
    so-rcvbuf: 4m
    so-sndbuf: 4m
EOF

# Root-DNS-Server aktualisieren
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
systemctl enable --now unbound
systemctl restart unbound

# Testen ob Unbound läuft
if ! systemctl is-active --quiet unbound; then
    echo "❌ Unbound ist nicht aktiv! Logs anzeigen..."
    journalctl -u unbound --no-pager | tail -n 20
    exit 1
fi

# Pi-hole Installation
curl -sSL https://install.pi-hole.net | bash

# Pi-hole DNS auf Unbound setzen
pihole -a setdns 127.0.0.1#5335

# WireGuard Installation
apt install -y wireguard iptables-persistent

echo "🔑 3. WireGuard Schlüssel für Server & Client generieren..."
mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077

wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key

SERVER_PRIVATE_KEY=$(cat server_private.key)
SERVER_PUBLIC_KEY=$(cat server_public.key)
CLIENT_PRIVATE_KEY=$(cat client_private.key)
CLIENT_PUBLIC_KEY=$(cat client_public.key)

echo "📝 4. WireGuard-Server Konfiguration erstellen..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = $SERVER_WG_IP/24
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $SERVER_INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $SERVER_INTERFACE -j MASQUERADE
SaveConfig = false

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_WG_IP/32
EOF

echo "🌐 5. IP-Forwarding aktivieren..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

echo "🛡️ 6. Firewall-Regeln setzen..."
if ! iptables -C INPUT -p udp --dport $WG_PORT -j ACCEPT 2>/dev/null; then
    iptables -A INPUT -p udp --dport $WG_PORT -j ACCEPT
fi
iptables -A INPUT -i wg0 -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT
iptables -t nat -A POSTROUTING -o $SERVER_INTERFACE -j MASQUERADE

# Regeln dauerhaft speichern
netfilter-persistent save
netfilter-persistent reload

echo "🚀 7. WireGuard-Dienst starten..."
systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

echo "📄 8. WireGuard-Client Konfiguration erstellen..."
cat <<EOF > /etc/wireguard/wg-client.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_WG_IP/24
DNS = 10.0.0.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $(curl -s ifconfig.me):$WG_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

echo "📸 9. QR-Code für Mobile Clients generieren..."
qrencode -t ansiutf8 < /etc/wireguard/wg-client.conf

echo "🔄 10. SSH-Port auf 1337 ändern..."
sed -i 's/^#Port 22/Port '$SSH_PORT'/' /etc/ssh/sshd_config
sed -i 's/^Port 22/Port '$SSH_PORT'/' /etc/ssh/sshd_config

echo "🛡️ 11. Firewall für SSH anpassen..."
iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT
iptables -D INPUT -p tcp --dport 22 -j ACCEPT

# Regeln dauerhaft speichern
netfilter-persistent save

echo "🔄 12. SSH-Dienst neu starten..."
systemctl restart ssh

echo "🚀 13. Speedtest ausführen..."
speedtest-cli

echo "📜 14. WireGuard-Client Konfiguration anzeigen..."
cat /etc/wireguard/wg-client.conf

echo "✅ Setup abgeschlossen! Dein WireGuard-VPN mit Unbound-DNS & Pi-hole läuft jetzt!"
