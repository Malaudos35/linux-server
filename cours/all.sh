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
./ntp.sh 10.200.24.254
./rsyslog-client-linux.sh 
./server_web.sh 
./server_web_conf.sh
./maj.sh 

./test_install.sh