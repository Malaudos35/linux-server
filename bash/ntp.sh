#!/bin/bash

# Nom du script : add_ntp_server.sh
# Usage : ./add_ntp_server.sh <ntp_server>

# Vérifier si l'utilisateur a fourni un serveur NTP
if [ -z "$1" ]; then
  echo "Usage: $0 <ntp_server>"
  exit 1
fi

NTP_SERVER=$1

# Installer le paquet ntp si nécessaire
if ! dpkg -l | grep -q ntp; then
  echo "Installation de ntp..."
  sudo apt-get install -y ntp
else
  echo "Le paquet ntp est déjà installé."
fi

# Sauvegarder le fichier de configuration actuel
echo "Sauvegarde du fichier de configuration actuel..."
sudo cp /etc/ntp.conf /etc/ntp.conf.bak

# Ajouter le serveur NTP au fichier de configuration
echo "Configuration du serveur NTP..."
sudo sed -i '/^pool /d' /etc/ntp.conf
sudo sed -i '/^server /d' /etc/ntp.conf
echo "server $NTP_SERVER iburst" | sudo tee -a /etc/ntp.conf

# Redémarrer le service NTP
echo "Redémarrage du service NTP..."
sudo systemctl restart ntp

# Vérifier le statut du service NTP
echo "Statut du service NTP:"
sudo systemctl status ntp

echo "Configuration terminée. Le serveur NTP $NTP_SERVER a été ajouté."

exit 0
