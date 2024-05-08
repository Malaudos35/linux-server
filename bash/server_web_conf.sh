#!/bin/bash

# Initialiser les variables avec des valeurs par défaut
nom=""
fichier=""
add=false
port=80

# Afficher l'aide
show_help() {
    echo "Usage: $0 -n <nom> -f <fichier> [-a] [-p <port>] [--help]"
    echo "Options:"
    echo "  -n <nom>: spécifie le nom du site, ex: www.example.com ."
    echo "  -f <fichier>: spécifie le fichier /var/www/ + xxx."
    echo "  -a: optionnelle, ajoute le site aux fichiers, sinon réécrit le fichier."
    echo "  -p <port>: optionnelle, spécifie le port, par défaut 80."
    echo "  --help: affiche l'aide."
}

# Analyser les options fournies par l'utilisateur
while getopts ":n:f:ap:-:" option; do
    case "${option}" in
        n)
            nom=${OPTARG}
            ;;
        f)
            fichier=${OPTARG}
            ;;
        a)
            add=true
            ;;
        p)
            port=${OPTARG}
            ;;
        -)
            case "${OPTARG}" in
                help)
                    show_help
                    exit 0
                    ;;
                *)
                    echo "Option invalide: --${OPTARG}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Usage: $0 -n <nom> -f <fichier> [-a] [-p <port>] [--help]"
            exit 1
            ;;
    esac
done

# Vérifier si les options obligatoires Malaudos35 ont été fournies
if [ -z "$nom" ] || [ -z "$fichier" ]; then
    echo "Les options -n (nom) et -f (fichier) sont obligatoires."
    exit 1
fi

# Afficher les valeurs fournies par l'utilisateur
echo "Nom: $nom"
echo "Fichier: $fichier"
echo "Port: $port"
if [ "$add" = true ]; then
    echo "Add: activé"
    echo "<VirtualHost *:$port>
        ServerName $nom
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/$fichier
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" >> /etc/apache2/sites-enabled/000-default.conf
else
    echo "Add: désactivé"
echo "<VirtualHost *:$port>
        ServerName $nom
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/$fichier
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-enabled/000-default.conf


fi

# Créer le répertoire et le fichier index.html
mkdir -p /var/www/$fichier
touch /var/www/$fichier/index.html
echo "
<html>
 <body>
 <h1>Serveur web $nom</h1>
 <p>Bienvenue sur le site web du $nom.</p>
 </body>
 </html>$nom
" > /var/www/$fichier/index.html

# Vérifier l'état d'Apache
sudo systemctl restart apache2
sudo systemctl status apache2

# Afficher un message de confirmation
echo "Site $nom installé dans le fichier /var/www/$fichier."
