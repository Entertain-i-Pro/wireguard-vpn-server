#!/bin/bash

# WireGuard & DNS-Resolver Setup mit BIND und Unbound
# Keine Änderungen an bestehender BIND-Konfiguration!

set -e  # Beendet das Skript bei Fehlern

echo "🚀 Starte die Installation von WireGuard, Unbound & BIND..."

# 🔍 Root-Check
if [[ $EUID -ne 0 ]]; then
   echo "❌ Dieses Skript muss als Root ausgeführt werden! Bitte nutze 'sudo'."
   exit 1
fi

# Variablen
SERVER_WG_IP="10.0.0.1"
SERVER_PORT="51820"
CLIENT_WG_IP="10.0.0.2"
CLIENT_DNS="10.0.0.1"
SSH_PORT="1337"

# Funktion zur Fehlerbehandlung
function check_success {
    if [ $? -eq 0 ]; then
        echo "✅ $1 erfolgreich!"
    else
        echo "❌ FEHLER: $1 fehlgeschlagen!"
        exit 1
    fi
}

# Update und Installation der benötigten Pakete
echo "🔄 Aktualisiere Paketlisten..."
apt-get update
check_success "Paketlisten aktualisiert"

echo "📦 Installiere WireGuard, Unbound, BIND9 & QRencode..."
apt-get install -y wireguard unbound qrencode dnsutils speedtest-cli git curl wget qrencode
check_success "Pakete erfolgreich installiert"

# SSH-Port ändern (nur wenn nötig)
if grep -q "^#Port 22" /etc/ssh/sshd_config; then
    echo "🔄 Ändere SSH-Port auf $SSH_PORT..."
    sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
    systemctl restart ssh
    check_success "SSH neu gestartet mit Port $SSH_PORT"
fi

# WireGuard konfigurieren
echo "🔑 Generiere WireGuard-Schlüssel..."
umask 077
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)
check_success "WireGuard-Schlüssel erstellt"

echo "📝 Erstelle WireGuard-Konfiguration..."
cat > /etc/wireguard/wg0.conf <<EOL
[Interface]
Address = $SERVER_WG_IP/24
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIVATE_KEY

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_WG_IP/32
EOL
check_success "WireGuard-Konfiguration erstellt"

echo "🛠️ Starte WireGuard..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
check_success "WireGuard gestartet"

# Unbound als lokaler DNS-Resolver installieren und konfigurieren
echo "📝 Erstelle Unbound-Konfiguration..."
cat > /etc/unbound/unbound.conf <<EOL
server:
    interface: 127.0.0.1
    port: 5353  # Läuft auf Port 5353, damit kein Konflikt mit BIND entsteht
    access-control: 127.0.0.1 allow
    access-control: ::1 allow
    verbosity: 1
    root-hints: "/etc/unbound/root.hints"
    auto-trust-anchor-file: "/var/lib/unbound/root.key"

    # Caching aktivieren
    cache-min-ttl: 3600
    cache-max-ttl: 86400
    prefetch: yes
EOL
check_success "Unbound-Konfiguration erstellt"

echo "🌍 Lade Root-Hints für Unbound herunter..."
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
check_success "Root-Hints heruntergeladen"

echo "🛠️ Starte Unbound..."
systemctl enable unbound
systemctl restart unbound
check_success "Unbound gestartet"

# BIND als Forwarder für Unbound konfigurieren
echo "📝 Konfiguriere BIND, um Unbound als Resolver zu nutzen..."
if ! grep -q "forwarders" /etc/bind/named.conf.options; then
    sed -i '/options {/a \
        forwarders { 127.0.0.1 port 5353; }; \
        forward only;' /etc/bind/named.conf.options
    check_success "BIND-Forwarding hinzugefügt"
fi

echo "🛠️ Starte BIND neu..."
systemctl restart bind9
check_success "BIND erfolgreich neu gestartet"

# WireGuard Client-Konfiguration erstellen
echo "📝 Erstelle WireGuard-Client-Konfiguration..."
cat > /etc/wireguard/client.conf <<EOL
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_WG_IP/24
DNS = $CLIENT_DNS

[Peer]
PublicKey = $(cat /etc/wireguard/publickey)
Endpoint = $(curl -s ifconfig.me):$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 21
EOL
check_success "WireGuard-Client-Konfiguration erstellt"

echo "📱 Generiere QR-Code für die Client-Konfiguration..."
qrencode -t ansiutf8 < /etc/wireguard/client.conf
check_success "QR-Code erfolgreich generiert"

# Abschließende Statusprüfung
echo "🔍 Überprüfe den Status der Dienste..."
systemctl is-active --quiet wireguard && echo "✅ WireGuard läuft!" || echo "❌ WireGuard ist NICHT aktiv!"
systemctl is-active --quiet unbound && echo "✅ Unbound läuft!" || echo "❌ Unbound ist NICHT aktiv!"
systemctl is-active --quiet bind9 && echo "✅ BIND läuft!" || echo "❌ BIND ist NICHT aktiv!"

echo "🎉 **Installation erfolgreich abgeschlossen!**"
echo "📄 Die WireGuard-Client-Konfigurationsdatei befindet sich unter: /etc/wireguard/client.conf"
