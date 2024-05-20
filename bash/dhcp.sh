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

# Fonction pour afficher l'aide
#install/nom:/adress:/masque:/sous-masque:/petit ip:/grand ip:/bradcast ip:/exit:/

show_help() {
    echo "Installer le dhcp "
    aide "ex: ./dhcp.sh -i -n eth0 -a 192.168.1.12 -m 255.255.255.0 -s 192.168.1.0 -g 192.168.1.254"
    echo "Rajouter une conf de dhcp"
    aide "ex: ./dhcp.sh -i -n eth0 -a 192.168.1.12 -m 255.255.255.0 -s 192.168.1.0 -g 192.168.1.254"
    echo ""
    echo "Options: "
    echo "-i pour installer le dhcp et réecrire les fichier, sinon ajoute à la fin"
    echo "-n <nom interface> mettez le nom de l interface reseaux de sortie"
    echo "-a <addresse ip de la machine>"
    echo "-m <masque ip du reseaux> ex: 255.255.255.0"
    echo "-s <ip de sous-reseaux> ex: 192.168.1.0"
    echo "-p <la plus petite ip distribuée> ex: 192.168.1.1"
    echo "-g <la plus grand ip distribuée> ex: 192.168.1.254"
    echo "-b <l ip broadcast du reseaux> ex: 192.168.1.255"
    echo "-e <la gateway> exit, l ip de sortie du reseaux ex: 192.168.1.254"
    echo "-d <ip dns> ex; 8.8.4.4 ou 8.8.8.8, 8.8.4.4, 192.168.1.254"
    aide "Conseil: vous pouvez l install par default auto configurer avec dhcp.sh -i "
    aide "Conseil: vous pouvez rajouter un reseaux en ne maitent pas -i"
    aide "Conseil: vous pouvez reinntialliser le dhcp avec -i"
}
# Fonction pour convertir le préfixe de sous-réseau en notation masque
prefix_to_mask() {
    local prefix="$1"
    local mask=""
    for ((i = 1; i <= 4; i++)); do
        if ((prefix >= 8)); then
            mask+="255"
            prefix=$((prefix - 8))
        else
            mask+=$((256 - 2**(8 - prefix)))
            prefix=0
        fi
        if ((i < 4)); then
            mask+="."
        fi
    done
    echo "$mask"
}

# Récupérer le nom de la carte réseau
interface=$(ip route get 1 | awk '{print $5}')

# Récupérer l'adresse IP
ip_address=$(ip addr show dev "$interface" | awk '$1 == "inet" {print $2}')

# Récupérer le masque de sous-réseau
# netmask="255.255.255.0"
# Extraire le préfixe de sous-réseau (masque)
subnet_prefix=$(echo "$ip_address" | cut -d'/' -f2)

# Convertir le préfixe de sous-réseau en notation masque
netmask=$(prefix_to_mask "$subnet_prefix")

# Récupérer l'adresse IP de broadcast
broadcast=$(ip addr show dev "$interface" | awk '$1 == "inet" {print $4}')

# Calculer l'adresse IP la plus grande
IFS='/' read -r -a parts <<< "$broadcast"
IFS='.' read -r -a ip_parts <<< "${parts[0]}"
ip_parts[3]=$(( ${ip_parts[3]} - 1 ))
max_ip="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.${ip_parts[3]}"

# Calculer l'adresse IP la plus petite (en utilisant l'adresse réseau)
IFS='.' read -r -a network_address <<< "$broadcast"
network_address[3]="1" # Le dernier octet est toujours 1 pour l'adresse réseau

# Reconstruire l'adresse IP la plus petite
min_ip="${network_address[0]}.${network_address[1]}.${network_address[2]}.${network_address[3]}"

# Utiliser ip route pour obtenir la passerelle par défaut
gateway=$(ip route | grep default | awk '{print $3}')
# Si ip route ne fonctionne pas, essayer netstat
if [ -z "$gateway" ]; then
    gateway=$(netstat -rn | grep '^0.0.0.0' | awk '{print $2}')
fi
# echo "get: $gateway"

# Séparer l'adresse IP et le masque en octets
IFS='.' read -r -a ip_octets <<< "$ip_address"
IFS='.' read -r -a mask_octets <<< "$netmask"
# Calculer le sous-réseau octet par octet
for (( i=0; i<4; i++ )); do
    subnet_octet=$(( ${ip_octets[$i]} & ${mask_octets[$i]} ))
    subnet+="$subnet_octet."
done
# Supprimer le dernier point
subnet="${subnet%?}"
dns="8.8.4.4"
################################    options    ########################################################################
install=false
#install/nom:/adress:/masque:/sous-masque:/petit ip:/gran ip:/bradcast ip:/exit:/dns:/
# Analyser les options fournies par l'utilisateur
while getopts ":in:a:m:s:p:g:b:e:d:-:" option; do
    case "${option}" in
        i)
            install=true
            ;;
        n)
            interface=${OPTARG}
            ;;
        a)
            ip_address=${OPTARG}
            ;;
        m)
            netmask=${OPTARG}
            ;;
        s)
            subnet=true
            ;;
        p)
            min_ip=${OPTARG}
            ;;
        g)
            max_ip=${OPTARG}
            ;;
        b)
            broadcast=${OPTARG}
            ;;
        e)
            gateway=${OPTARG}
            ;;
        d)
            dns=${OPTARG}
            ;;
        -)
            case "${OPTARG}" in
                help)
                    show_help
                    exit 0
                    ;;
                *)
                    error "Option invalide: --${OPTARG}"
                    show_help
                    exit 1
                    ;;
            esac
            ;;
        *)
            error "Option invalide: -${OPTARG}"
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

# Afficher les résultats    ##################    fin des options   ##########################
info "Nom de la carte réseau : $interface"
info "Adresse IP : $ip_address"
info "Masque de sous-réseau : $netmask"
info "Le sous-reseaux est : $subnet"

info "Adresse IP la plus pettite : $min_ip"
info "Adresse IP la plus grande : $max_ip"
info "Adresse IP de broadcast : $broadcast"

info "La getway est : $gateway"
info "Le dns : $dns"
info "install: $install"

if [ "$install" = true ]; then
    # installation des paquets du dhcp
    sudo apt-get remove --purge udhcpd
    sudo apt-get install isc-dhcp-server -y

    # deplace le fichier d origine pour garder une trace
    mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.defaut
    
    #confiure le fichier
    echo "subnet $subnet netmask $netmask {
range $min_ip $max_ip;
option routers $gateway;
option broadcast-address $broadcast;
option domain-name-servers $dns;
default-lease-time 30;
max-lease-time 30;
}" > "/etc/dhcp/dhcpd.conf"

    echo "
INTERFACESv4=\"$interface\"
INTERFACESv6=\"\"
" > "/etc/default/isc-dhcp-server"

    sudo systemctl restart isc-dhcp-server.service
    sudo systemctl status isc-dhcp-server.service
else
    #confiure le fichier /etc/dhcp/dhcpd.conf pour ajouter la zone
    echo "subnet $subnet netmask $netmask {
range $min_ip $max_ip;
option routers $gateway;
option broadcast-address $broadcast;
option domain-name-servers $dns;
default-lease-time 30;
max-lease-time 30;
}" >> "/etc/dhcp/dhcpd.conf"

    sudo systemctl restart isc-dhcp-server.service
    sudo systemctl status isc-dhcp-server.service
fi




