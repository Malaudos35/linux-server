
sudo apt update 
sudo apt upgrade
sudo apt install openssh-server -y

sudo systemctl status ssh

sudo apt-get install ufw -y
sudo ufw allow ssh
sudo systemctl enable --now ssh

#sudo nano /etc/ssh/sshd_config   puis ajouter    # permet de se conncter en root
#PermitRootLogin yes
