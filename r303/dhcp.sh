#!/bin/bash
# interface="ens192"
# Récupérer le nom de la carte réseau
interface=$(ip route get 1 | awk '{print $5}')

# ip addr add 10.200.24.252/24 dev $interface

# Fonction pour afficher des messages avec des couleurs
info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}

aide() {
    echo -e "\e[33m[aide] $1\e[0m"
}

# Suppression du paquet UDHCPD s'il existe
echo "Suppression du paquet UDHCPD s'il existe..."
apt-get remove --purge -y udhcpd

# Installation des paquets isc-dhcp-server et bind9
echo "Installation des paquets isc-dhcp-server ..."
apt-get install -y isc-dhcp-server 

# Vérification de l'installation
echo "Vérification de l'installation des paquets..."
dpkg --get-selections | grep "isc-dhcp-server"

# Configuration du serveur DHCP
echo "Configuration du serveur DHCP..."
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.defaut

cat <<EOL > /etc/dhcp/dhcpd.conf
subnet 10.10.9.0 netmask 255.255.0.0 {
    range 10.10.9.1 10.10.9.240;
    #option routers 10.200.24.254;
    #option broadcast-address 10.200.24.255;
    option domain-name-servers 10.10.9.1, 10.10.10s.1;
    default-lease-time 30;
    max-lease-time 30;
}
log-facility local7;

EOL

# Configuration de l'interface réseau pour le serveur DHCP
echo "Configuration de l'interface réseau pour le serveur DHCP..."
# sed -i 's/^INTERFACES=.*$/INTERFACES="ens192"/' /etc/default/isc-dhcp-server
echo "INTERFACESv4=\"$interface\"
INTERFACESv6=\"\"
" >  "/etc/default/isc-dhcp-server"

# Démarrage du service DHCP
echo "Démarrage du service DHCP..."
# service isc-dhcp-server restart

echo "local7.* /var/log/dhcpd.log
" > "/etc/rsyslog.d/dhcpd.conf"

sudo touch /var/log/dhcpd.log
sudo chmod 644 /var/log/dhcpd.log
sudo chown syslog:adm /var/log/dhcpd.log

echo "/var/log/dhcpd.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 644 syslog adm
    sharedscripts
    postrotate
        systemctl restart isc-dhcp-server > /dev/null
    endscript
}
" > "/etc/logrotate.d/isc-dhcp-server"

sudo systemctl restart rsyslog


sudo systemctl restart isc-dhcp-server
# systemctl status isc-dhcp-server

echo "Script d'installation et de configuration du serveur DHCP terminé."

