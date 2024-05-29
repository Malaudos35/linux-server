#!/bin/bash


echo "
<VirtualHost *:81>
    ServerName site1.mon.lan
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/site1
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:82>
    ServerName site2.mon.lan
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/site2
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-enabled/000-default.conf


# Créer le répertoire et le fichier index.html
mkdir -p /var/www/site1
touch /var/www/site1/index.html
echo "
<html>
<body>
<h1>Serveur web site1</h1>
<p>Bienvenue sur le site web du site1.</p>
</body>
</html>site1
" > /var/www/site1/index.html

mkdir -p /var/www/site2
touch /var/www/site2/index.html
echo "
<html>
<body>
<h1>Serveur web site2</h1>
<p>Bienvenue sur le site web du site2.</p>
</body>
</html>site2
" > /var/www/site2/index.html

echo "
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80
Listen 81
Listen 82

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

" > "/etc/apache2/ports.conf"

sudo apt-get install afw
sudo ufw allow 81/tcp
sudo ufw allow 82/tcp
sudo ufw allow 81/udp
sudo ufw allow 82/udp

sudo ufw enable -y

# Vérifier l'état d'Apache
sudo systemctl restart apache2
sudo systemctl status apache2

# Afficher un message de confirmation
echo "Site installé "
