#!/bin/bash
set -e
echo "which database?"
read baza
echo "Koji DB user?"
read user
mysql -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$user'@'localhost';"
mysql -e "DROP USER '$user'@'localhost';"
mysql -e "drop database $baza;"

echo which project name?
read project
sudo rm -r /var/websites/$project
sudo rm /etc/apache2/sites-available/$project.conf

figlet -f slant ONE SHOTTED!
