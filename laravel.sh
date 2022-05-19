#!/bin/bash
. ~/.nvm/nvm.sh



if [ $php_ver == "false" ]; then
		echo "What is your PHP version?"
		read php_ver
		#echo "What is your composer version?"
		#read composer_ver

fi


cd /var/websites/$domain
cp .env.example .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE='$domain_name'/g' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME='$domain_usr'/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD='$password'/g' .env

 if [ $php_ver == "8" ]; then
	cd /var/websites/$domain
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	#php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
 	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	php8 composer.phar install
	php8 artisan migrate:fresh --seed
	php8 artisan storage:link
	php8 artisan key:generate
	php8 artisan jwt:secret
	
		
 fi

  if [ "$php_ver" == "7.4" ]; then
	

	cd /var/websites/$domain
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        #php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        php composer.phar install
        php artisan migrate:fresh --seed
        php artisan storage:link
        php artisan key:generate
        php artisan jwt:secret



  fi

 	if [ $node_ver == "false"  ]; then
		echo what is your node version
	    while true; do
        	read node_version
        	nvm install $node_version

			if [ $? -ne 0 ]; then
        			echo try again
			else
        			break;
			fi

	    done

	else 
		nvm install $node_version
	       while [ $? -ne 0 ]; do
                	echo "Invalid version, try again."
			read node_version
			nvm install $node_version

        	    done

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
        echo Project deployment successfull. Proceed to the following link $domain
else 
	echo There are problems in apache virtualhost configuration
	exit 1 
fi







