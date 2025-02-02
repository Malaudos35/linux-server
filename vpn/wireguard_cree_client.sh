#!/bin/bash

# Vérifier si le script est exécuté en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root."
  exit 1
fi

# shellcheck source=/dev/null
source /etc/wireguard/server/conf.sh
# Demander le nom du client
read -p "Entrez le nom du client : " CLIENT_NAME

# Définir les variables
SERVER_PUBLIC_KEY="VOTRE_CLÉ_PUBLIQUE_SERVEUR"
SERVER_ENDPOINT="$domain_public:51820"
CLIENT_IP="10.0.0.X" # Remplacez X par l'adresse IP du client dans le sous-réseau VPN
WG_INTERFACE="wg0"

# Générer les clés du client
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# Créer le répertoire de configuration du client
mkdir -p /etc/wireguard/clients

# Créer le fichier de configuration du client
cat <<EOF > /etc/wireguard/clients/$CLIENT_NAME.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Afficher le fichier de configuration du client
echo "Fichier de configuration du client /etc/wireguard/clients/$CLIENT_NAME.conf :"
cat /etc/wireguard/clients/$CLIENT_NAME.conf

# Afficher le QR code pour une configuration facile sur les appareils mobiles
if command -v qrencode &> /dev/null; then
  echo "QR Code pour l'application mobile :"
  qrencode -t ansiutf8 < /etc/wireguard/clients/$CLIENT_NAME.conf
else
  echo "qrencode n'est pas installé. Vous pouvez l'installer avec 'apt install qrencode' pour générer des QR codes."
fi

# Afficher la clé publique du client
echo "Clé publique du client $CLIENT_NAME : $CLIENT_PUBLIC_KEY"

# Ajouter le client en tant que peer sur le serveur
wg set $WG_INTERFACE peer $CLIENT_PUBLIC_KEY allowed-ips $CLIENT_IP/32

echo "Le client $CLIENT_NAME a été ajouté avec succès."
