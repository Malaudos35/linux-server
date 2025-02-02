#!/bin/bash

# l0USsHF4z+49xLkrdZ9hPpbHts6x63jFn/Kb9vIKkGc=

# Vérifier si le script est exécuté en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root."
  exit 1
fi

# Mise à jour du système
sudo apt-get update && sudo apt-get upgrade -y


# Variables
WG_INTERFACE="wg0"
WG_PORT=51820
SERVER_IP="10.0.0.1/24"
CLIENT_IP="0.0.0.0/0"
CLIENT_PUBLIC_KEY=""

# Demander la clé publique du client
read -p "Entrez la clé publique du client : " CLIENT_PUBLIC_KEY

# Installation de WireGuard et des outils nécessaires
apt install -y wireguard wireguard-tools procps iptables

# Création du répertoire de configuration
mkdir -p /etc/wireguard/server
mkdir -p /etc/wireguard/clients
chmod 700 /etc/wireguard

SERVER_PRIVATE_KEY=$(wg genkey)
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

# echo $SERVER_PRIVATE_KEY > /etc/wireguard/server/privatekey
# echo $SERVER_PUBLIC_KEY > /etc/wireguard/server/publickey


# Création du fichier de configuration de l'interface
cat <<EOF > /etc/wireguard/$WG_INTERFACE.conf
[Interface]
Address = $SERVER_IP
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = $CLIENT_IP
EOF

# sauvegarde des info
echo "

WG_INTERFACE=\"wg0\"
WG_PORT=51820
SERVER_IP=\"10.0.0.1/24\"
CLIENT_IP=\"0.0.0.0/0\"

SERVER_PRIVATE_KEY=\"$SERVER_PRIVATE_KEY\"
SERVER_PUBLIC_KEY=\"$SERVER_PUBLIC_KEY\"

domain_public=\"sm.lvp.ovh\"
" > /etc/wireguard/server/conf.sh

sudo chmod +x /etc/wireguard/server/conf.sh

sudo chmod 600 /etc/wireguard/$WG_INTERFACE.conf

# Activation de l'IP forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# Configuration du pare-feu
sudo iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o $(ip route | grep '^default' | awk '{print $5}') -j MASQUERADE

# Enregistrement des règles iptables
sudo mkdir -p /etc/iptables
sudo iptables-save > /etc/iptables/rules.v4

# Démarrage et activation de l'interface WireGuard
wg-quick up $WG_INTERFACE
systemctl enable wg-quick@$WG_INTERFACE

# Afficher le statut du service
systemctl status wg-quick@$WG_INTERFACE

echo "Installation et configuration de WireGuard terminées."
echo "Clé publique du serveur : $SERVER_PUBLIC_KEY"
