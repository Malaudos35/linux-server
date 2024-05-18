#!/bin/bash

# Fonction pour afficher des messages avec des couleurs
info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}

# Mettre à jour les paquets et installer Fail2Ban
info "Mise à jour des paquets..."
sudo apt-get update || { error "Échec de la mise à jour des paquets"; exit 1; }

info "Installation de Fail2Ban..."
sudo apt-get install -y fail2ban || { error "Échec de l'installation de Fail2Ban"; exit 1; }

# Créer un fichier jail.local avec la configuration de base
info "Création de la configuration de base pour Fail2Ban..."
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
# Temps de bannissement (1 heure)
bantime = 3600
# Fenêtre de détection (10 minutes)
findtime = 600
# Nombre de tentatives avant bannissement
maxretry = 3
# Action de bannissement
banaction = iptables-multiport

[sshd]
# Activer la surveillance SSH
enabled = true
# Port de SSH
port = ssh
# Filtre Fail2Ban pour SSH
filter = sshd
# Chemin du fichier de journal pour SSH
logpath = /var/log/auth.log
# Nombre de tentatives avant bannissement pour SSH
maxretry = 3
EOF

# Redémarrer Fail2Ban pour appliquer les changements
info "Redémarrage de Fail2Ban..."
sudo systemctl restart fail2ban || { error "Échec du redémarrage de Fail2Ban"; exit 1; }

# Vérifier le statut de Fail2Ban
info "Vérification du statut de Fail2Ban..."
sudo systemctl status fail2ban --no-pager

# Afficher un message de succès
info "Installation et configuration de Fail2Ban terminées avec succès !"

# Conseils supplémentaires
info "N'oubliez pas de vérifier les règles iptables avec la commande : sudo iptables -L"
info "Pour des configurations supplémentaires, éditez les fichiers de configuration dans /etc/fail2ban/."
