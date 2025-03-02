#!/bin/bash

# grep -r 'enterprise.proxmox.com' /etc/apt/


# commante les depot payant
echo "# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
" > /etc/apt/sources.list.d/pve-enterprise.list

echo "# deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
" > /etc/apt/sources.list.d/ceph.list

# ajout des depot proxmo gratuit

echo "
# ajout des depot proxmo gratuit

deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
" >> /etc/apt/sources.list

sudo apt-get update
sudo apt-get dist-upgrade


