#!/bin/bash

# Install vsftpd and UFW
sudo apt-get install vsftpd ufw -y

# Backup original vsftpd configuration file
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Secure vsftpd configuration
sudo bash -c 'cat > /etc/vsftpd.conf <<EOF
# Allow local users to log in and write to their home directories
local_enable=YES
write_enable=YES
local_umask=022

# Set up FTP passive mode and define port range
pasv_enable=YES
pasv_min_port=60000
pasv_max_port=60100

# Allow vsftpd to listen only on IPv4
listen=YES
listen_ipv6=NO

# Chroot users to their home directories
chroot_local_user=NO
chroot_list_enable=YES
allow_writeable_chroot=YES
chroot_list_file=/etc/vsftpd/chroot_list

# Enable SSL for secure FTP (FTPS)
ssl_enable=YES
force_local_data_ssl=YES
force_local_logins_ssl=YES
rsa_cert_file=/etc/vsftpd/vsftpd.pem

# Log transfer activities
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=YES

# Disable ASCII mode to prevent certain attacks
ascii_upload_enable=NO
ascii_download_enable=NO

# Ensure anonymous FTP is disabled
anonymous_enable=NO
EOF'

# Generate SSL certificate for vsftpd
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem -subj "/C=XX/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

# Restart vsftpd to apply the changes
sudo systemctl restart vsftpd

# Enable vsftpd and UFW to start on boot
sudo systemctl enable vsftpd
sudo systemctl enable ufw

# Configure UFW to allow FTP and SSH connections
sudo ufw allow OpenSSH
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 60000:60100/tcp
sudo ufw --force enable

# Display vsftpd and UFW status
sudo systemctl status vsftpd
sudo ufw status
