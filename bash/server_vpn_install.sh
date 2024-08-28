#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt-get install curl -y
mkdir -p /etc/vpn
cd "/etc/vpn" || exit
sudo curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
sudo chmod +x openvpn-install.sh
sudo ./openvpn-install.sh