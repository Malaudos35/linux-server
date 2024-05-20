#!/bin/bash

# Désinstallation de phpmyadmin
sudo apt remove phpmyadmin -y
sudo a2disconf phpmyadmin
sudo systemctl restart apache2

# Désinstallation de mariadb-server
sudo apt remove mariadb-server php-mysql -y

# Désinstallation de php et libapache2-mod-php
sudo apt remove php libapache2-mod-php -y

# Désinstallation d'Apache
sudo apt remove apache2 -y

# Nettoyage des paquets inutiles
sudo apt autoremove -y

echo "Tous les composants ont été désinstallés avec succès."
