WireGuard VPN mit Unbound DNS-Server

Überblick

Dieses Projekt automatisiert die Einrichtung eines WireGuard VPN-Servers mit Unbound DNS und iptables-Firewall auf einem Linux-Server.

Funktionen

WireGuard VPN wird automatisch installiert und konfiguriert.

Unbound als DNS-Server, um eine sichere Namensauflösung bereitzustellen.

Firewall-Regeln mit iptables, um sicheren Zugriff zu gewährleisten.

Automatische Erstellung der WireGuard-Client-Konfiguration.

QR-Code Generierung, um Clients einfach zu verbinden.

SSH-Port Änderung auf 1337 zur Erhöhung der Sicherheit.

Automatische Anzeige der Client-Konfiguration nach der Installation.

Speedtest-Unterstützung, um die Verbindungsgeschwindigkeit zu überprüfen.

Deutsche Tastaturbelegung wird aktiviert.

Installation & Nutzung

Voraussetzungen

Ein Linux-Server mit Debian oder Ubuntu.

Root-Rechte zur Ausführung des Skripts.

Skript ausführen

Führe das Skript mit Root-Rechten aus:

sudo bash setup-wireguard.sh

Nach der Installation wird die WireGuard-Client-Konfiguration automatisch ausgegeben, sodass du sie kopieren kannst.

WireGuard-Client verbinden

Die generierte Datei wg-client.conf kann direkt in den WireGuard-Client importiert werden.
Falls du ein mobiles Gerät nutzt, kannst du den QR-Code scannen, der am Ende der Installation angezeigt wird.

Firewall & Sicherheit

Das Skript setzt automatisch iptables-Regeln, um den VPN- und SSH-Zugriff abzusichern. Falls gewünscht, können weitere Regeln manuell hinzugefügt werden.

Fehlerbehebung

Falls Unbound oder WireGuard nicht starten:

sudo systemctl status unbound
sudo systemctl status wg-quick@wg0

Falls der SSH-Zugriff verloren geht, kann er über die Konsole des Hosters wiederhergestellt werden:

sudo nano /etc/ssh/sshd_config

Dort den Port zurück auf 22 setzen und SSH neu starten.

Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Du kannst es frei nutzen und anpassen.

Erstellt von ChatGPT 🚀

