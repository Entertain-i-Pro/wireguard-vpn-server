# Debian 12 Server - Schritt-für-Schritt Einrichtung

Diese Anleitung beschreibt, wie du einen frisch installierten Debian 12 Server für den sicheren Betrieb mit SSH, Firewall, WireGuard und BIND konfigurierst.

---

## **1. System aktualisieren & Grundpakete installieren**
Nach der Installation von Debian 12 als **Root-Benutzer** einloggen und ausführen:
```bash
apt update && apt upgrade -y
apt install -y sudo curl nano ufw fail2ban locales whiptail dialog
```
✅ **Erklärung:**
- **`sudo`**: Falls du mit einem Benutzer statt Root arbeitest.
- **`curl`**: Für Downloads und API-Anfragen.
- **`nano`**: Einfache Textbearbeitung.
- **`ufw`**: Firewall.
- **`fail2ban`**: Schutz gegen Brute-Force-Angriffe.
- **`locales`**: Für Spracheinstellungen.
- **`whiptail` & `dialog`**: Für interaktive Menüs.

---

## **2. Sprache & Tastatur auf Deutsch setzen**
### **2.1 Sprache auf Deutsch setzen**
```bash
dpkg-reconfigure locales
```
➡ Wähle `de_DE.UTF-8 UTF-8` mit **Leertaste**, dann **ENTER**.

Falls erforderlich:
```bash
nano /etc/default/locale
```
Füge hinzu oder ändere:
```
LANG=de_DE.UTF-8
LANGUAGE=de_DE:de
LC_ALL=de_DE.UTF-8
```
Dann anwenden:
```bash
export LANG=de_DE.UTF-8
export LANGUAGE=de_DE:de
export LC_ALL=de_DE.UTF-8
```

### **2.2 Tastatur auf Deutsch setzen**
```bash
dpkg-reconfigure keyboard-configuration
```
➡ Wähle `Generic 105-key PC (intl.)` → `German` → `German (Standard)`.

```bash
systemctl restart keyboard-setup
loadkeys de  # Falls in der Konsole noch nicht aktiv
```
Prüfen:
```bash
localectl status
```
Falls noch nicht `de`, setzen:
```bash
localectl set-keymap de
```

---

## **3. SSH absichern**
### **3.1 SSH-Port ändern & Root-Login erlauben**
```bash
nano /etc/ssh/sshd_config
```
Ändere diese Zeilen:
```
Port 1337  # Oder einen anderen Port setzen
PermitRootLogin yes
PasswordAuthentication yes
```
Speichern & SSH neu starten:
```bash
systemctl restart ssh
```
Verbindung testen:
```bash
ssh -p 1337 root@<DEINE_SERVER_IP>
```

### **3.2 Public-Key-Authentifizierung einrichten (optional)**
Falls du dich per **Schlüssel** einloggen willst:
```powershell
ssh-keygen -t rsa -b 4096
ssh-copy-id -p 1337 root@<DEINE_SERVER_IP>
```
Falls `ssh-copy-id` nicht geht, kopiere den öffentlichen Schlüssel manuell in:
```bash
/root/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## **4. Firewall (UFW) aktivieren**
```bash
ufw allow 1337/tcp  # Falls du SSH-Port geändert hast
ufw allow 22/tcp    # Falls SSH auf Port 22 bleibt
ufw enable
```
Prüfen:
```bash
ufw status
```

---

## **5. WireGuard VPN installieren**
Falls du WireGuard als VPN nutzen möchtest:
```bash
apt install -y wireguard
```
Private & öffentliche Schlüssel generieren:
```bash
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
```
Konfigurationsdatei (`/etc/wireguard/wg0.conf`) erstellen.

---

## **6. BIND als DNS-Server installieren**
Falls du einen **BIND DNS-Server** brauchst:
```bash
apt install -y bind9
```
Konfigurationsdatei bearbeiten:
```bash
nano /etc/bind/named.conf.options
```
Anschließend den Dienst neu starten:
```bash
systemctl restart bind9
```

---

## **7. Eigenes Konfigurationsmenü (Optional)**
Falls du ein **menübasiertes Setup wie `raspi-config`** haben willst:
```bash
nano setup-config.sh
```
Füge dieses Skript ein:
```bash
#!/bin/bash
while true; do
  OPTION=$(whiptail --title "Debian Server Konfiguration" --menu "Wähle eine Option:" 20 60 10 \
  "1" "Tastatur-Layout ändern" \
  "2" "Sprache und Lokalisierung setzen" \
  "3" "Zeitzone ändern" \
  "4" "Netzwerkeinstellungen anpassen" \
  "5" "SSH-Server konfigurieren" \
  "6" "Beenden" 3>&1 1>&2 2>&3)

  case $OPTION in
    1) dpkg-reconfigure keyboard-configuration ;;
    2) dpkg-reconfigure locales ;;
    3) dpkg-reconfigure tzdata ;;
    4) dpkg-reconfigure network-manager ;;
    5) nano /etc/ssh/sshd_config && systemctl restart ssh ;;
    6) exit ;;
    *) echo "Ungültige Option." ;;
  esac
done
```
Skript ausführbar machen:
```bash
chmod +x setup-config.sh
```
Starten mit:
```bash
./setup-config.sh
```

---

## **🚀 Fazit**
Mit dieser Anleitung ist dein Debian 12 Server:
✅ **Aktualisiert & abgesichert**
✅ **Auf Deutsch eingestellt (Sprache & Tastatur)**
✅ **Mit SSH & Firewall konfiguriert**
✅ **Bereit für WireGuard & BIND**
✅ **Optional mit eigenem `raspi-config`-ähnlichem Menü**
