# WireGuard VPN Setup – README Version 2

## 📌 Überblick
Dieses Projekt automatisiert die Einrichtung eines **WireGuard VPN-Servers** mit **Unbound DNS** und **Pi-hole als Werbeblocker**. Das Skript installiert alle benötigten Pakete, konfiguriert den VPN-Server sowie die Firewall-Regeln und erstellt automatisch eine Client-Konfiguration inklusive QR-Code für eine einfache Verbindung.

## 🔹 Funktionen des Skripts
- **Automatische Installation & Konfiguration von WireGuard**
- **Unbound als lokaler DNS-Resolver für sicheres DNS-Filtering**
- **Pi-hole als Werbeblocker integriert & automatisch eingerichtet**
- **Firewall-Regeln mit iptables für sicheren Zugriff**
- **Automatische Erstellung der WireGuard-Client-Konfiguration**
- **QR-Code Generierung zur einfachen Verbindung für mobile Geräte**
- **Änderung des SSH-Ports auf 1337 für mehr Sicherheit**
- **Anzeige der Client-Konfigurationsdatei am Ende des Setups**
- **Automatische Durchführung eines Speedtests**
- **Aktivierung der deutschen Tastaturbelegung**

## 📥 Installation & Nutzung
Das Skript kann direkt von GitHub heruntergeladen und ausgeführt werden:
```bash
sudo apt install -y git && git clone https://github.com/Entertain-i-Pro/wireguard-vpn-setup-script-v2.git
cd wireguard-vpn-setup-script-v2
sudo bash setup-wireguard-v2.sh
```
Nach der Installation wird die **Client-Konfiguration (`wg-client.conf`)** automatisch angezeigt und kann direkt genutzt oder per QR-Code gescannt werden.

## 🛠 Fehlerbehebung & Debugging
Falls Unbound oder Pi-hole nicht korrekt starten, können folgende Befehle zur Überprüfung genutzt werden:
```bash
sudo systemctl status unbound
sudo systemctl status pihole-FTL
sudo systemctl status wg-quick@wg0
```
Falls der SSH-Zugriff verloren geht, kann er über die Server-Konsole wiederhergestellt werden:
```bash
sudo nano /etc/ssh/sshd_config
```
Hier den **Port zurück auf `22` setzen** und SSH neu starten:
```bash
sudo systemctl restart ssh
```
Falls der VPN-Tunnel keine Verbindung hat, überprüfe die Firewall-Regeln:
```bash
sudo iptables -L -v -n
```
Falls Werbung noch nicht geblockt wird, stelle sicher, dass Pi-hole als DNS-Server genutzt wird:
```bash
pihole status
pihole -a setdns 127.0.0.1#5335
```
Oder teste die Geschwindigkeit mit:
```bash
speedtest-cli
```

---
Dieses Projekt steht unter der **MIT-Lizenz** und kann frei verwendet und angepasst werden.
