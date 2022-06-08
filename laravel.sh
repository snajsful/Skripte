#!/bin/bash
inversvid="\0033[7m"
resetvid="\0033[0m"
greenback="\0033[1;37;42m"
blueback="\0033[1;37;44m"

. ~/.nvm/nvm.sh



#Creating database code:
set +e #Turning off the exit upon error function
result=`sudo mysql -e "show databases" |grep -w  $domain_name`

if [ "$result" == "$domain_name" ]; then

        echo -e "$inversvid The database already exists!$resetvid"
else

        sudo mysql -e "create database $domain_name;"

        sudo mysql -e "create user '$domain_usr'@'localhost' identified by '$password';"

        sudo mysql -e "grant all on $domain_name.* to '$domain_usr'@'localhost';"

        sudo mysql -e "flush privileges;"

        printf 'Database creation in progress: '
        spinner &

        sleep 4  # sleeping for 10 seconds is important work

        kill "$!" # kill the spinner
        printf '\n'

        echo "DATABASE has been created under the name of : $domain_name"
        echo "The Database USER is : $domain_usr"
        echo "The database PASSWORD is: $password"
fi
###################################################################################################

 	sudo chown -R stevan:www-data /var/websites/$domain   #####Change user 'stevan' with your local user
        sudo find /var/websites/$domain -type f -exec chmod 0644 {} \;
	sudo find /var/websites/$domain -type d -exec chmod 755 {} \;


sudo chmod -R 775 /var/websites/$domain/storage /var/websites/$domain/bootstrap

grep_phpver=`ls /usr/bin | grep "php[0-9].*" | cut -c 4-`
if [ $php_ver == "false" ]; then
		echo -e "$blueback What is your PHP version? Current available versions are:$resetvid"
		echo -e "$inversvid$grep_phpver$resetvid"
		read php_ver
		while true; do
		if [[ $php_ver == [0-9].[0-9] ]];then
			break
		else
        		echo -e "$blueback Wrong php version/format.Current Available versions are:$resetvid"
			echo -e "$greenback$grep_phpver$resetvid"
			read php_ver
		fi
	done


else 
	while true; do
                if [[ $php_ver == [0-9].[0-9] ]];then
                        break
                else
			echo -e "$blueback Wrong php version/format.Current Available versions are:"
                        echo -e "$greenback$grep_phpver$resetvid"

                        read php_ver
                fi
        done

fi




cd /var/websites/$domain
cp .env.example .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE='$domain_name'/g' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME='$domain_usr'/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD='$password'/g' .env

grepko=`ls /usr/bin/ | grep -o "php$php_ver"`
if [[ "php$php_ver" == "$grepko" ]]; then
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        #php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        php$php_ver composer.phar install
        php$php_ver artisan migrate:fresh --seed
        php$php_ver artisan storage:link
        php$php_ver artisan key:generate
        php$php_ver artisan jwt:secret
	
else
        sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php

        sudo apt-get install php$php_ver php$php_ver-fpm php$php_ver-mysql libapache2-mod-php$php_ver php$php_ver-cli php$php_ver-common php$php_ver-imap php$php_ver-redis php$php_ver-snmp php$php_ver-xml php$php_ver-curl

			while [ $? -ne 0 ];do
				echo -e "$blueback The PHP version you entered does not exists you malnourished peasant.AGAIN!$resetvid"
				read php_ver
				sudo apt-get install php$php_ver php$php_ver-fpm php$php_ver-mysql libapache2-mod-php$php_ver php$php_ver-cli php$php_ver-common php$php_ver-imap php$php_ver-redis php$php_ver-snmp php$php_ver-xml php$php_ver-curl
			done
		


sudo a2enmod actions alias proxy_fcgi
sudo a2dismod php$php_ver
sudo systemctl start php$php_ver-fpm
sudo update-alternatives --set php /usr/bin/php7.4
sudo systemctl reload apache2

alias_test=`cat ~/.bashrc | grep -o "/usr/bin/php$php_ver"`
        if ! [[ "$alias_test" == "/usr/bin/php$php_ver" ]]; then
        echo "alias php$php_ver="/usr/bin/php$php_ver"" >> ~/.bashrc
        echo -e "$greenback Alias imported successfuly$resetvid"
        fi

        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        #php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        php$php_ver composer.phar install
        php$php_ver artisan migrate:fresh --seed
        php$php_ver artisan storage:link
        php$php_ver artisan key:generate
        php$php_ver artisan jwt:secret

fi



if [ $node_ver != "1234" ];then
 	if [ $node_ver == "false" ];then
		echo -e "$blueback What is your node version?$resetvid"
	    while true; do
        	read node_ver
        	nvm install $node_ver

			if [ $? -ne 0 ]; then
        			echo -e "$blueback try again$resetvid"
			else
        			break;
			fi

	    done
    	

	else  
		nvm install $node_ver
	       while [ $? -ne 0 ]; do
                	echo -e "$blueback Invalid version, try again.$resetvid"
			read node_ver
			nvm install $node_ver

        	    done

	fi
fi
####################################################################################################
	#Now its time to configure APACHE BOI
		sudo touch /etc/apache2/sites-available/$domain.conf
	sudo bash -c 'cat <<EOT >> /etc/apache2/sites-available/'$domain'.conf
		<VirtualHost *:80>
    ServerName app-academy-back.amplitudo.me
    ServerAlias www.app-academy-back.amplitudo.me
    Redirect permanent "/" "https://app-academy-back.amplitudo.me/"
</VirtualHost>


<VirtualHost _default_:443>

    ServerName app-academy-back.amplitudo.me:443
    ServerAlias www.app-academy-back.amplitudo.me

 DocumentRoot "/var/websites/app-academy-back.amplitudo.me/public"

    <Directory "/var/websites/app-academy-back.amplitudo.me">
        Options FollowSymLinks
        AllowOverride all
        Require all granted
    </Directory>


    DirectoryIndex index.php index.html


    ### Certificates | Default server SSL certs
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key


     ### Let’s Encrypt Certificates
        SSLCertificateFile /etc/letsencrypt/live/app-academy-back.amplitudo.me/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/app-academy-back.amplitudo.me/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/app-academy-back.amplitudo.me/chain.pem



    ###
    ### Security settings
    ###

    FileETag None

    #Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
    Header always append X-Frame-Options SAMEORIGIN
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options nosniff
    #Header always set X-Frame-Options DENY
    Header always set X-Frame-Options SAMEORIGIN
    #Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

 #Header set Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval'"

    SSLCompression off

    SSLEngine on

    ### Samo TLSv1.2 ili veci
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384

    SSLHonorCipherOrder on
    SSLInsecureRenegotiation off

    ### Websocket proxy
#  ProxyPass /wss wss://127.0.0.1:6001 retry=0 keepalive=On
#  ProxyPassReverse /wss wss://127.0.0.1:6001 retry=0

 <FilesMatch \.php$>
      # For Apache version 2.4.10 and above, use SetHandler to run PHP as a fastCGI process server
      SetHandler "proxy:unix:/run/php/php8.0-fpm.sock|fcgi://localhost"
    </FilesMatch>

</VirtualHost>


EOT'
#Just a default virtual host conf file for our Apacheboi to serve
	sudo sed -i 's/app-academy-back.amplitudo.me/'$domain'/g' /etc/apache2/sites-available/$domain.conf
#sudo certbot --apache certonly -m support@amplitudo.me --agree-tos --no-eff-email --preferred-challenges http-01 -d $domain
sudo a2ensite $domain.conf
myvar=`sudo apachectl configtest 2>&1 >/dev/null |grep 'Syntax OK'`
echo $myvar
if [ "$myvar" == "Syntax OK" ]; then
        sudo systemctl reload apache2
        echo -e "$greenback Project deployment successfull. Proceed to the following link $domain $resetvid"
else 
	echo -e "$inversvid There are problems in apache virtualhost configuration$resetvid"
	exit 1 
fi







