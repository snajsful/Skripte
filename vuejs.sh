#!/bin/bash
inversvid="\0033[7m"
resetvid="\0033[0m"
greenback="\0033[1;37;42m"
blueback="\0033[1;37;44m"
. ~/.nvm/nvm.sh
cd /var/websites/$domain

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

npm install


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

 DocumentRoot "/var/websites/app-academy-back.amplitudo.me/dist"

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


