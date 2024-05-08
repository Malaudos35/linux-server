#!/bin/bash

# Update package list
sudo apt-get update

# Install vsftpd
sudo apt-get install vsftpd

# Start vsftpd
sudo systemctl start vsftpd

# Enable vsftpd to start on boot
sudo systemctl enable vsftpd
sudo apt-get install ufw -y
# Set up firewall rules (if applicable)
sudo ufw allow 21/tcp