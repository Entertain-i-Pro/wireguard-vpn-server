WireGuard VPN mit Unbound DNS-Server

Überblick

Dieses Skript automatisiert die Installation und Konfiguration eines WireGuard VPN-Servers mit Unbound DNS und iptables-Firewall auf einem Linux-Server. Es beinhaltet:

WireGuard VPN mit automatischer Schlußelerstellung

Unbound als DNS-Server für sichere, lokale Namensauflösung

Firewall-Management mit iptables für sicheren Zugriff

Automatische Konfiguration von VPN-Clients mit QR-Code-Erstellung

Anpassung des SSH-Ports auf 1337 für zusätzliche Sicherheit

Deutsche Tastaturbelegung aktivieren

Voraussetzungen

Debian/Ubuntu-basierte Linux-Distribution

Root-Rechte auf dem Server

Installation

Führe das Skript mit Root-Rechten aus:

sudo bash setup-wireguard.sh

Was das Skript macht

Installiert Unbound und setzt es als lokalen DNS-Server

Installiert WireGuard und generiert automatisch Schlüssel

Erstellt die WireGuard-Server-Konfiguration mit Firewall-Regeln

Ermöglicht IP-Forwarding, damit der VPN-Traffic geroutet wird

Erstellt automatisch eine Client-Konfiguration

Zeigt einen QR-Code für mobile Clients

Ändert den SSH-Port auf 1337 für mehr Sicherheit

Aktiviert die deutsche Tastaturbelegung

Client-Verbindung herstellen

Nach erfolgreicher Installation kannst du die generierte Datei wg-client.conf für deine WireGuard-Clients nutzen.

Scanne den QR-Code mit einer mobilen WireGuard-App, um die Verbindung schnell herzustellen.

Firewall & Sicherheit

Das Skript setzt automatisch iptables-Regeln, um den VPN- und SSH-Zugriff zu sichern. Falls gewünscht, kannst du weitere Regeln manuell über iptables hinzufügen.

Fehlerbehebung

Falls Unbound oder WireGuard nicht korrekt starten:

sudo systemctl status unbound
sudo systemctl status wg-quick@wg0

Falls der SSH-Zugriff verloren geht, kann er über die Konsole des Hosters wiederhergestellt werden:

sudo nano /etc/ssh/sshd_config

und den Port zurück auf 22 setzen.

Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Verwende und modifiziere es frei nach deinen Bedürfnissen.

Erstellt von ChatGPT 🚀

