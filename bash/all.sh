
echo "installation general "
sudo chmox +x maj.sh
sudo chmox +x ssh.sh
sudo chmox +x ftp.sh
sudo chmox +x server_web.sh
sudo chmox +x un_server_web.sh
sudo chmox +x ssl.sh
sudo chmod +x command_generales.sh

sudo ./maj.sh 
sudo ./ssh.sh
sudo ./ftp.sh
sudo ./server_web.sh
sudo ./ssl.sh
sudo ./command_generales.sh
echo "Installation des dépendances terminees "