#!/bin/bash

QUEUE_FILE="command_queue.txt"
LOCK_FILE="command_queue.lock"

# Ajouter une commande à la file d'attente
add_command() {
    local cmd="$1"
    echo "$cmd" >> "$QUEUE_FILE"
    echo "Commande ajoutée à la file d'attente : $cmd"
}

# Traiter les commandes de la file d'attente
process_queue() {
    # Créer un fichier de verrouillage pour éviter les exécutions simultanées
    if [ -f "$LOCK_FILE" ]; then
        echo "Une autre instance du script est déjà en cours d'exécution."
        exit 1
    fi
    touch "$LOCK_FILE"

    while IFS= read -r cmd || [ -n "$cmd" ]; do
        echo "Exécution de la commande : $cmd"
        eval "$cmd"
    done < "$QUEUE_FILE"

    # Vider le fichier de la file d'attente après traitement
    > "$QUEUE_FILE"

    # Supprimer le fichier de verrouillage
    rm -f "$LOCK_FILE"
}

# Afficher l'aide
show_help() {
    echo "Usage : $0 {add|process} [commande]"
    echo "  add [commande]    Ajouter une commande à la file d'attente"
    echo "  process           Traiter les commandes de la file d'attente"
}

# Vérifier les arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Exécuter l'action appropriée en fonction du premier argument
case "$1" in
    add)
        if [ $# -lt 2 ]; then
            echo "Erreur : vous devez spécifier une commande à ajouter."
            exit 1
        fi
        shift
        add_command "$@"
        ;;
    process)
        process_queue
        ;;
    *)
        show_help
        exit 1
        ;;
esac
