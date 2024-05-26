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

# Installation d'Apache
info "Installation d'Apache..."
sudo apt update
sudo apt install apache2 -y

# Installation de MariaDB
info "Installation de MariaDB..."
sudo apt install mariadb-server -y

# Démarrage des services
info "Démarrage des services..."
#sudo systemctl start apache2
sudo service apache2 restart
sudo systemctl start mariadb

# Activation des services au démarrage
info "Activation des services au démarrage..."
sudo systemctl enable apache2
sudo systemctl enable mariadb

info "Installation terminée."

#sudo nano /etc/apache2/conf-available/security.conf
#sudo service apache2 restart
sudo apt install php8.2 php8.2-apcu php8.2-bcmath php8.2-bz2 php8.2-cli php8.2-curl php8.2-gd php8.2-igbinary php8.2-imagick php8.2-intl php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-pgsql php8.2-readline php8.2-redis php8.2-soap php8.2-tidy php8.2-xml php8.2-xmlrpc php8.2-zip -y

#sudo apt install mariadb-server -y
#sudo apt install phpmyadmin -y