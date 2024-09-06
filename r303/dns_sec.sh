#!/bin/bash


echo "
zone \"b9.lan\" {
    type slave;
    file \"/var/cache/bind/db.b9.lan\";
    masters { 10.10.10.1; };  # IP du serveur DNS primaire
};

" > "/etc/bind/named.conf.local"