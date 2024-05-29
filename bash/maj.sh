#!/bin/bash

LOGFILE="/var/log/update_script.log"

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [-t DURATION]"
    echo
    echo "Options:"
    echo "  -t DURATION  Planifie l'exécution du script à l'intervalle spécifié par DURATION (en heures)."
    exit 1
}
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

# Vérifier si l'option -t est fournie avec une durée
while getopts ":t:" opt; do
    case ${opt} in
        t)
            DURATION=${OPTARG}
            ;;
        *)
            show_help
            ;;
    esac
done

# Vérifier que DURATION est un entier positif
if [[ -n "$DURATION" && ! "$DURATION" =~ ^[0-9]+$ ]]; then
    error "Erreur : La durée doit être un entier positif." | tee -a $LOGFILE
    exit 1
fi

# Mettre à jour la liste des paquets
info "Mise à jour de la liste des paquets..."
sudo apt update -y

# Effectuer la mise à jour du système
info "Mise à jour du système..."
info apt upgrade -y | tee -a $LOGFILE
sudo apt-get dist-upgrade -y | tee -a $LOGFILE
sudo apt-get full-upgrade -y | tee -a $LOGFILE
sudo apt install build-essential -y | tee -a $LOGFILE

# Nettoyer les paquets obsolètes
info "Nettoyage des paquets obsolètes..."
sudo apt autoremove -y | tee -a $LOGFILE
sudo apt autoclean -y | tee -a $LOGFILE

# Afficher un message de fin
info "Mise à jour terminée." | tee -a $LOGFILE

# Si une durée est fournie, installer cron et planifier le script
if [[ -n "$DURATION" ]]; then
    info "Installation de cron..." | tee -a $LOGFILE
    sudo apt install -y cron | tee -a $LOGFILE

    # Obtenir le chemin complet du script
    SCRIPT_PATH=$(realpath $0)

    # Lire les tâches cron actuelles
    CURRENT_CRON=$(crontab -l 2>/dev/null)

    # Filtrer les tâches cron pour retirer celles qui exécutent le script spécifié
    NEW_CRON=$(echo "$CURRENT_CRON" | grep -v "$SCRIPT_PATH")

    # Appliquer les nouvelles tâches cron (sans les tâches à retirer)
    echo "$NEW_CRON" | crontab -

    # Afficher un message de confirmation
    echo "Toutes les tâches cron exécutant $SCRIPT_PATH ont été retirées."

    # Ajouter une tâche cron pour exécuter le script toutes les DURATION heures
    info "Planification du script toutes les $DURATION heures..."
    (crontab -l 2>/dev/null; echo "* */$DURATION * * * $SCRIPT_PATH") | crontab -
    info "Le script sera exécuté toutes les $DURATION heures."
    
    crontab -l

fi

