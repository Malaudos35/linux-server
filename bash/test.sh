#!/bin/bash

# Chemin du script à analyser
script_path="votre_script.sh"

# Vérification de l'option -y dans le script
if grep -q '\b-y\b' "$script_path"; then
    echo "L'option -y est présente dans le script."
else
    echo "L'option -y n'est pas présente dans le script."
fi
