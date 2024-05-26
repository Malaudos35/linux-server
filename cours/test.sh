echo "installation des sites web"
echo "
<VirtualHost *:80>
        ServerName site1.mon.lan
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/site1
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:80>
        ServerName site2.mon.lan
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/site2
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

" >> /etc/apache2/sites-enabled/000-default.conf


# Créer le répertoire et le fichier index.html
mkdir -p /var/www/site1
mkdir -p /var/www/site2

touch /var/www/site1/index.html
echo "
<html>
 <body>
 <h1>Serveur web site1</h1>
 <p>Bienvenue sur le site web du site1.</p>
 </body>
 </html>site1
" > /var/www/site1/index.html

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
<html>
 <body>
 <h1>Serveur web default</h1>
 <p>Bienvenue sur le site web par default.</p>
 </body>
 </html>default
" > /var/www/html/index.html
# Vérifier l'état d'Apache
sudo systemctl restart apache2
sudo systemctl status apache2