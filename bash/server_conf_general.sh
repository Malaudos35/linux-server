


# met les authorisation d executiona tous les fichiers
sudo chmod +x *

# Configurer les mises à jour automatiques
# sudo apt install unattended-upgrades -y
# sudo dpkg-reconfigure --priority=low unattended-upgrades

# Configurer les paramètres de veille et d'économie d'énergie

mv /etc/systemd/logind.conf /etc/systemd/logind-old.conf

echo "[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandlePowerKey=poweroff
IdleAction=ignore
" > "/etc/systemd/logind.conf"

sudo systemctl restart systemd-logind

# Configurer les paramètres du noyau (sysctl)

mv /etc/sysctl.conf /etc/sysctl-old.conf

echo "# Désactiver l'IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Désactiver l'acceptation des redirections ICMP
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Désactiver l'acceptation des paquets source-routed
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Activer la protection contre les SYN flood
net.ipv4.tcp_syncookies = 1

# Activer la protection contre les IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Masquer les informations de la pile TCP
net.ipv4.tcp_timestamps = 0

# Désactiver le support pour les paquets ICMP broadcast (Smurf attack)
net.ipv4.icmp_echo_ignore_broadcasts = 1
" > "/etc/sysctl.conf"

sudo sysctl -p

# Configurer le pare-feu

sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Configurer des limites d'utilisateur

echo "* hard nofile 4096
* soft nofile 1024
* hard nproc 1024
* soft nproc 512
" > "/etc/security/limits.conf"

# dessactiver l interface graphique

sudo systemctl set-default multi-user.target
# sudo apt-get remove --purge gnome-shell

# installation des connexion ssh et ftp
sudo ./ssh.sh
sudo ./ftp.sh

# installation du serverweb
sudo ./server_web.sh


# met a jour le serveur et supprime les paquet qui ne sont plus necessaires
sudo ./maj.sh
sudo apt-get autoremove
