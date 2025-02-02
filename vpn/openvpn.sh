#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y curl

mkdir /script
cd /script || exit 

curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh

sudo chmod +x openvpn-install.sh

sudo /script/openvpn-install.sh


