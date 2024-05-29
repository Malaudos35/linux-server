#!/bin/bash

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

# Suppression des anciennes zones BIND
# sudo rm -f /etc/bind/zones/*

# Installation des paquets BIND
info "Installation des paquets BIND..."

sudo apt install -y bind9 bind9utils bind9-doc

# Configuration de named.conf.local
info "Configuration de named.conf.local..."
sudo bash -c 'cat <<EOF > /etc/bind/named.conf.local
zone "mon.lan" {
    type master;
    file "/etc/bind/db.mon.lan";
};
EOF'

# Création du fichier de zone directe
info "Création du fichier de zone directe..."
sudo bash -c 'cat <<EOF > /etc/bind/db.mon.lan
;
; BIND data file for 'mon.lan'
;
\$TTL 3H
@ IN SOA  ns.mon.lan. mailaddress.mon.lan (
2         ; Serial
6H        ; Refresh
1H        ; Retry
5D        ; Expire
1D )      ; Negative Cache TTL
;
@ IN NS ns.mon.lan.
@ IN MX 10 mail.mon.lan.
ns.mon.lan. A 10.200.24.1
mail.mon.lan. A 10.200.24.1
serveur.mon.lan. A 10.200.24.250
client.mon.lan. A 10.200.24.11
routeur24.mon.lan. A 10.200.24.254
commut24.mon.lan. A 10.200.24.253
site1.mon.lan. IN A 10.200.24.250
site2.mon.lan. IN A 10.200.24.250
EOF'

sudo ufw allow dns

# Redémarrage du service BIND
info "Redémarrage du service BIND..."
sudo systemctl restart bind9

# Vérification de l'état du service BIND
info "Vérification de l'état du service BIND..."
sudo systemctl status bind9
