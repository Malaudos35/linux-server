#!/bin/bash

# Mettre à jour les dépôts et installer OpenVPN
sudo apt-get update
sudo apt-get install -y openvpn

# Vérifier si le fichier de configuration est fourni en argument
if [ -z "$1" ]; then
    echo "Veuillez fournir le chemin vers le fichier de configuration .ovpn en argument."
    exit 1
fi

CONFIG_FILE=$1

# Copier le fichier de configuration dans le répertoire OpenVPN
sudo cp "$CONFIG_FILE" /etc/openvpn/client.conf

# Démarrer le client OpenVPN
sudo systemctl start openvpn@client

# Activer le client OpenVPN au démarrage
sudo systemctl enable openvpn@client

sudo systemctl status openvpn@client

echo "Installation et configuration du client OpenVPN terminées."
