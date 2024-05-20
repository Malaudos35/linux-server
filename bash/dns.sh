#!/bin/bash

# Fonction pour afficher l'aide
show_help() {
    echo -e "\e[33m[aide] Usage: $0 [-i] -d <domain> [-m <admin_email>] [-f <path>] [--help]\e[0m"
    echo -e "\e[33m[aide] Usage [-a] -p <ip_address> -u <url>\e[0m"
    echo
    echo "Options:"
    echo "  -i                  Installe le serveur DNS"
    echo "  -d <domain>         Spécifie le domaine"
    echo "  -m <admin_email>    (Optionnel) Spécifie l'email de l'administrateur"
    echo "  -f <path>           (Optionnel) Spécifie le dossier (par défaut /etc/bind/zones)"
    echo " ou "
    echo "  -a                  Ajoute une entrée DNS"
    echo "  -d <domain>         Spécifie le domaine"
    echo "  -p <ip_address>     (Requis avec -a) Spécifie l'adresse IP du site web"
    echo "  -u <url>            (Requis avec -a) Spécifie l'URL du site web"
    echo "  -c <comment>        (Optionnel avec -a) Ajoute un commentaire à l'entrée DNS"
    echo " "
    echo "  --help              Affiche cette aide"
    echo ""
    echo -e "\e[33m[aide] Conseil: Si vous utilisez -i pour installer le DNS, spécifiez -d <domain>, -m <mail> et -f <dossier> si nécessaire.\e[0m"
    echo ""
    echo -e "\e[33m[aide] Conseil: Si vous utilisez -a pour ajouter une entrée DNS, spécifiez -p, -u et -c si nécessaire.\e[0m"
    echo ""
    echo -e "\e[33m[aide] Ex install: ./dns.sh -i -d domain.com -m admin.domain.com -f /etc/bind/zones\e[0m"
    echo -e "\e[33m[aide] Ex add domain: ./dns.sh -a -d domain.com -p 192.168.1.1 -u monsite -f /etc/bind/zones\e[0m"
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

# Initialisation des variables par défaut
install=false
domain=""
admin_email="admin.example.local."
dossier="/etc/bind/zones"
add_entry=false
url=""
comment=""
yes=false
ip_address=$(hostname -I | awk '{print $1}')
if [ -z "$ip_address" ]; then
    error "Erreur : Impossible de récupérer l'adresse IP de la machine."
    exit 1
fi

# Analyser les options fournies par l'utilisateur
while getopts ":id:m:f:ap:u:c:y-:" option; do
    case "${option}" in
        i)
            install=true
            ;;
        d)
            domain=${OPTARG}
            ;;
        m)
            admin_email=${OPTARG}
            ;;
        f)
            dossier=${OPTARG}
            ;;
        a)
            add_entry=true
            ;;
        p)
            ip_address=${OPTARG}
            ;;
        u)
            url=${OPTARG}
            ;;
        c)
            comment=${OPTARG}
            ;;
        y)
            yes=true
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

# Vérifier que les options requises sont fournies
if $install; then
    info "-i"
    if [ -z "$domain" ]; then
        error "L'option -d (domain) est obligatoire avec -i."
        show_help
        exit 1
    else
        # Afficher les valeurs des options pour vérification
        info "Installation du serveur DNS avec les paramètres suivants:"
        info "Domaine: $domain"
        info "Email de l'administrateur: $admin_email"
        info "Dossier: $dossier"
        info "Fichier: $dossier/db.$domain"
        
        sudo rm -f /etc/bind/zones/*

        sudo apt install -y bind9 bind9utils bind9-doc
        
        # Configuration de named.conf.local
        info "Configuration de named.conf.local..."
        echo "
zone \"$domain\" {
    type master;
    file \"$dossier/db.$domain\";
};" | sudo tee /etc/bind/named.conf.local > /dev/null
        
        # Créer le répertoire pour les fichiers de zone si nécessaire
        info "Création du répertoire des zones..."
        sudo mkdir -p "$dossier"
        
        # Créer le fichier de zone directe
        info "Création du fichier de zone directe..."
        echo "
;
; BIND data file for '$domain'
;
; $comment
;
\$TTL    604800
@ IN SOA  $HOSTNAME.$domain. $admin_email (
2         ; Serial
6H         ; Refresh
1H         ; Retry
5D         ; Expire
1D )       ; Negative Cache TTL
;
@ IN NS ns.$domain
@ IN MX 10 mail.$domain
ns A 10.200.24.1
; name server RR for the domain
           IN      NS      ns1.$domain.
; URL IN A IP
" | sudo tee "$dossier/db.$domain" > /dev/null
    fi
elif $add_entry && [ -n "$domain" ]; then
    info "-a"
    if [ -z "$ip_address" ] || [ -z "$url" ]; then
        error "Les options -p (ip_address) et -u (url) sont obligatoires avec -a."
        show_help
        exit 1
    else
        if [[ "$url" == *"."* || "$url" == *"/"* ]]; then
            error "Les caractères '.' et '/' sont interdits dans l'URL du sous-domaine, veuillez spécifier uniquement le sous-domaine."
            aide "Essayez 'sous_domaine' au lieu de 'sous_domaine.domain.com'."
            sous_domaine=$(echo "$url" | cut -d'.' -f1)
            aide "Sous-domaine possible: $sous_domaine de $url"
            exit 1
        fi
        # Afficher les valeurs des options pour vérification
        info "Ajout d'une entrée DNS avec les paramètres suivants:"
        info "Domaine: $domain"
        info "Adresse IP: $ip_address"
        info "URL: $url"
        info "Commentaire: $comment"
    
        if [[ -f "$dossier/db.$domain" && ! -s "$dossier/db.$domain" ]]; then
            # Ajouter l'URL au fichier de domaine
            echo "
$url IN A $ip_address    ; $comment
" | sudo tee -a "$dossier/db.$domain" > /dev/null
            info "$dossier/db.$domain"
        else
            error "Le domaine $domain avec le chemin $dossier n'existe pas ou n'est pas accessible."
            error "Fichier: $dossier/db.$domain"
            # Demande à l'utilisateur de saisir une valeur
            val=""

            while true; do
                if [ "$yes" = "true" ] || [ "$val" = "y" ]; then
                    break
                elif [ "$val" = "n" ]; then
                    echo "Opération annulée."
                    exit 1
                fi
                
                echo "Voulez-vous créer le domaine $domain ? (y/n): "
                read -r val
            done
            if [[ "$val" = "y" || "$yes" = true ]]; then
                sudo mkdir -p "$dossier"
                # Configuration de named.conf.local
                info "Configuration de named.conf.local..."
                mkdir -p "$dossier"
                echo " " > "/etc/bind/named.conf.local"
                echo "
zone \"$domain\" {
    type master;
    file \"$dossier/db.$domain\";
};" | sudo tee /etc/bind/named.conf.local > /dev/null
                
                # Créer le répertoire pour les fichiers de zone si nécessaire
                info "Création du répertoire des zones..."
                sudo mkdir -p "$dossier"
                
                # Créer le fichier de zone directe
                info "Création du fichier de zone directe..."
                echo "
;
; BIND data file for '$domain'
;
; $comment
;
\$TTL    604800
@ IN SOA  $HOSTNAME.$domain. $admin_email (
2         ; Serial
6H         ; Refresh
1H         ; Retry
5D         ; Expire
1D )       ; Negative Cache TTL
;
; name server RR for the domain
           IN      NS      ns1.$domain.
; URL IN A IP

$url IN A $ip_address    ; $comment
" | sudo tee "$dossier/db.$domain" > /dev/null
            else
                error "Création du domaine annulée."
                exit 1
            fi
        fi
    fi
    # Vérifier la configuration
    info "Vérification de la configuration de BIND..."
    sudo named-checkconf
    # sudo named-checkzone $domain 
    # sudo named-checkzone 

    sudo systemctl restart bind9
    sudo systemctl status bind9
    info "Configuration du serveur DNS terminée. Configurez vos clients pour utiliser $IP comme serveur DNS."

else
    show_help
    exit 1
fi
