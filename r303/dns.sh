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

url = "b9.l an"

sudo apt-get install -y ufw
# Suppression des anciennes zones BIND
# sudo rm -f /etc/bind/zones/*

# Installation des paquets BIND
info "Installation des paquets BIND..."

sudo apt install -y bind9 bind9utils bind9-doc

# Configuration de named.conf.local
info "Configuration de named.conf.local..."
sudo bash -c 'cat <<EOF > /etc/bind/named.conf.local
zone "b9.lan" {
    type master;
    file "/etc/bind/db.b9.lan";
};
EOF'

# Création du fichier de zone directe
info "Création du fichier de zone directe..."
sudo bash -c 'cat <<EOF > /etc/bind/db.b9.lan
;
; BIND data file for 'b9.lan'
;
\$TTL 3H
@ IN SOA  ns.b9.lan. mail.b9.lan (
2         ; Serial
6H        ; Refresh
1H        ; Retry
5D        ; Expire
1D )      ; Negative Cache TTL
;
@ IN NS ns.b9.lan.
@ IN MX 10 mail.b9.lan.
ns.b9.lan. A 10.10.9.1
mail.b9.lan. A 10.10.9.2
serveur.b9.lan. A 10.10.9.1
client.b9.lan. A 10.10.9.4
graylog.b9.lan A 10.10.9.5
EOF'

sudo ufw allow dns

echo "// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

// Include additional configuration files
include \"/etc/bind/named.conf.options\";
include \"/etc/bind/named.conf.local\";
include \"/etc/bind/named.conf.default-zones\";

// Logging configuration
logging {
    // Default log channel
    channel default_log {
        file \"/var/log/named/named.log\" versions 3 size 5m;
        severity info;
        print-time yes;
        print-severity yes;
        print-category yes;
    };

    // Query log channel
    channel query_log {
        file \"/var/log/named/query.log\" versions 3 size 5m;
        severity info;
        print-time yes;
    };

    // Log categories
    category default { default_log; };
    category queries { query_log; };
};
" > "/etc/bind/named.conf"

sudo mkdir -p /var/log/named
sudo chown bind:bind /var/log/named
sudo chmod 755 /var/log/named

sudo apt install logrotate

echo "/var/log/named/*.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 0640 bind bind
    sharedscripts
    postrotate
        systemctl reload bind9 > /dev/null
    endscript
}
" > "/etc/logrotate.d/bind9"

sudo logrotate -f /etc/logrotate.d/bind9

# Redémarrage du service BIND
info "Redémarrage du service BIND..."
sudo systemctl restart bind9

# Vérification de l'état du service BIND
info "Vérification de l'état du service BIND..."
#sudo systemctl status bind9
