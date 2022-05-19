#!/bin/bash
set -e
echo "Koja baza?"
read baza
echo "Koji user?"
read user
mysql -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$user'@'localhost';"
mysql -e "DROP USER '$user'@'localhost';"
mysql -e "drop database $baza;"

echo "obrisano"

sudo rm -r /var/websites/hajde.amplitudo.me
sudo rm /etc/apache2/sites-available/hajde.amplitudo.me.conf
