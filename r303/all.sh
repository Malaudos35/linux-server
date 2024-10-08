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

sudo chmod +x *

./dhcp.sh 
./dns.sh 
# ./rsyslog-client-linux.sh 
./server_web.sh 
./server_web_conf.sh
./maj.sh 

# sudo apt-get install curl -y

./test_install.sh