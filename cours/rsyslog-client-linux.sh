sudo apt-get install rsyslog
echo "
*.*@10.200.24.252:5141  " >> /etc/rsyslog.conf
systemctl restart rsyslog
# systemctl status rsyslog
