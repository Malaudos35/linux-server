#!/bin/bash

info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}

aide() {
    echo -e "\e[33m[aide] $1\e[0m"
}

# Fonction pour vérifier l'état d'un service
check_service_status() {
    local service_name="$1"
    if systemctl is-active --quiet "$service_name"; then
        info "Le service $service_name est actif."
    else
        error "Le service $service_name n'est pas actif."
    fi
}

# Appeler la fonction pour vérifier l'état de chaque service
check_service_status "bind9"
check_service_status "isc-dhcp-server"
check_service_status "ntp"
check_service_status "rsyslog"
check_service_status "apache2"
