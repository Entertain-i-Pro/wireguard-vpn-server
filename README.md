# WireGuard + Unbound + BIND Setup

## ✨ Was macht dieses Skript?
Dieses Skript installiert und konfiguriert **WireGuard VPN**, **Unbound** (rekursiver DNS-Resolver) und **BIND9** (DNS-Server) auf einem Linux-Server.

- **WireGuard:** Sichere VPN-Verbindung einrichten.
- **Unbound:** Schnelle DNS-Weiterleitung und Caching.
- **BIND9:** DNS-Server, der Anfragen an Unbound weiterleitet.
- **Automatische Überprüfung:** Stellt sicher, dass alle Dienste erfolgreich starten.

## 👁 Installation
### 1. Skript herunterladen und ausführen
```bash
wget https://example.com/setup-wireguard-bind.sh -O setup-wireguard-bind.sh
chmod +x setup-wireguard-bind.sh
sudo ./setup-wireguard-bind.sh
```

### 2. Nach der Installation
Die Konfigurationsdateien befinden sich hier:
- **WireGuard:** `/etc/wireguard/wg0.conf`
- **Unbound:** `/etc/unbound/unbound.conf`
- **BIND9:** `/etc/bind/named.conf.options`

## ✅ Status überprüfen
Nach der Installation kannst du die wichtigsten Dienste überprüfen:
```bash
systemctl status wireguard
systemctl status unbound
systemctl status bind9
```
Falls ein Dienst nicht läuft:
```bash
sudo systemctl restart <dienstname>
```

## 🔧 Debugging
Falls DNS-Anfragen nicht funktionieren, teste sie mit:
```bash
dig @127.0.0.1 google.com  # Teste BIND

dig @127.0.0.1 -p 5353 google.com  # Teste Unbound
```
Logs anzeigen für Fehleranalyse:
```bash
journalctl -xeu wireguard
journalctl -xeu unbound
journalctl -xeu bind9
```

## ✨ Fertig!
Die WireGuard-Client-Konfigurationsdatei findest du unter:
```bash
/etc/wireguard/client.conf
```
Scanne den QR-Code oder kopiere die Datei für dein Gerät. Viel Spaß mit deinem sicheren VPN! 🚀
