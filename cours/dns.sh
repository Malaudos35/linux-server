#!/bin/bash

# Fonction pour afficher l'aide


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


sudo rm -f /etc/bind/zones/*

sudo apt install -y bind9 bind9utils bind9-doc

echo "" >> "/etc/bind/named.conf"        
# Configuration de named.conf.local
info "Configuration de named.conf.local..."
echo "
zone \"mon.lan\" {
    type master;
    file \"/etc/bind/db.mon.lan\";
};" > "/etc/bind/named.conf.local" 
        
# Créer le répertoire pour les fichiers de zone si nécessaire
# info "Création du répertoire des zones..."
# sudo mkdir -p "$dossier"
        
# Créer le fichier de zone directe
info "Création du fichier de zone directe..."
echo "
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
serveur.mon.lan. A 10.200.24.250
client.mon.lan. A 10.200.24.11
routeur24.mon.lan. A 10.200.24.254
commut24.mon.lan. A 10.200.24.253

site1.mon.lan. IN A 10.200.24.250
site2.mon.lan. IN A 10.200.24.250



" > "/etc/bind/db.mon.lan" 
    
    
# Vérifier la configuration
# info "Vérification de la configuration de BIND..."
# sudo named-checkconf
# sudo named-checkzone mon.lan 
# sudo named-checkzone 

sudo systemctl restart bind9
# sudo systemctl status bind9


