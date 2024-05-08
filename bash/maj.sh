#!/bin/bash

# Mettre à jour la liste des paquets
echo "Mise à jour de la liste des paquets..."
sudo apt update

# Effectuer la mise à jour du système
echo "Mise à jour du système..."
sudo apt upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get full-upgrade -y
sudo apt install build-essential -y

# Nettoyer les paquets obsolètes
echo "Nettoyage des paquets obsolètes..."
sudo apt autoremove -y
sudo apt autoclean -y

# Afficher un message de fin
echo "Mise à jour terminée."
