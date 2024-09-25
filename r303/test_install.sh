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
aide "verifie les services"
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
# check_service_status "ntp"
check_service_status "rsyslog"
check_service_status "apache2"


aide "port web"

check_port() {
    local host=$1
    local port=$2
    nc -z -w 2 "$host" "$port" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        info "Le port $port sur l'hôte $host est accessible."
    else
        erreur "Le port $port sur l'hôte $host n'est pas accessible."
    fi
}

# Ports à vérifier
ports=(80)

# Vérifier la connectivité pour chaque port
for port in "${ports[@]}"; do
    check_port "127.0.0.1" "$port"
done



aide "test dns"

if sudo named-checkzone b9.lan /etc/bind/db.b9.lan; then
    info "La configuration de la zone est correcte."
else
    error "Erreur dans la configuration de la zone."
    exit 1
fi

# Définition des hôtes à pinguer avec leurs adresses IP
hosts=("serveur.b9.lan" 
"mail.b9.lan" 
"graylog.b9.lan" 
"ns.lan" 
"google.fr")

# Fonction pour tester le ping vers un hôte
test_ping() {
    local host=$1
    if ping -c 3 "$host" >/dev/null; then
        info "Ping vers $host : Réussi."
    else
        error "Ping vers $host : Échoué."
    fi
}

# Effectuer le ping pour chaque hôte
for host in "${hosts[@]}"; do
    test_ping "$host"
done


# aide "test ntp"

#!/bin/bash

# Fonction pour tester si la synchronisation NTP est établie
# test_ntp() {
#     if ntpq -p | grep -q '^*'; then
#         return 0  # Synchronisation NTP établie
#     else
#         return 1  # Synchronisation NTP non établie
#     fi
# }

# Tester la synchronisation NTP
# if test_ntp; then
#     info "La synchronisation NTP est établie."
# else
#     error "La synchronisation NTP n'est pas établie."
# fi


aide "On sais pas comment tester en detail"
aide "le dhcp et les log depuis cette machine"