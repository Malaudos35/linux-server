# Utiliser une image Debian comme base
FROM debian:latest
# FROM apache/airflow


# Variables d'environnement
ENV APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid

# Installer Apache2 et les utilitaires nécessaires
RUN apt update && apt install -y apache2 apache2-utils && rm -rf /var/lib/apt/lists/*

# Copier les fichiers de configuration personnalisés
# Vous pouvez décommenter les lignes ci-dessous et adapter les fichiers selon vos besoins
# COPY ./conf/apache2.conf /etc/apache2/apache2.conf
# COPY ./conf/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

# Activer les modules Apache nécessaires
RUN a2enmod rewrite headers ssl

# Créer des répertoires de travail et ajuster les permissions
RUN mkdir -p /var/www/html /etc/apache2/ssl && \
    chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/html

# Exposer les ports pour HTTP et HTTPS
EXPOSE 80:80 443:443

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY apache2.conf /etc/apache2/apache2.conf
COPY default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
COPY security.conf /etc/apache2/conf-available/security.conf

# Ajouter un certificat SSL auto-signé (pour les tests uniquement, utiliser Let’s Encrypt en production)
RUN mkdir -p /etc/apache2/ssl && cd /etc/apache2/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout apache-selfsigned.key \
    -out apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost" \
    > /var/log/openssl_output.log 2>/var/log/openssl_error.log


# Activer le site SSL par défaut
# RUN a2ensite default-ssl

# Nettoyage des fichiers temporaires
RUN apt clean && rm -rf /tmp/* /var/tmp/*

# Ajouter un fichier index.html de test
# RUN echo '<!DOCTYPE html><html><body><h1>Apache2 est en cours d execution 1</h1></body></html>' > /var/www/html/index.html
# RUN echo '<!DOCTYPE html><html><body><h1>Apache2 est en cours d execution 2</h1></body></html>' > /var/www/html/index2.html

# Démarrer Apache2 en mode premier plan
CMD ["apache2ctl", "-D", "FOREGROUND"]
