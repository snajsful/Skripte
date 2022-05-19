#!/bin/bash
set -e
php_ver="false"
composer_ver="false"
node_ver="false"
domain_name="false"
git_branch="false"
git_link="false"
k=0
inversvid="\0033[7m"
resetvid="\0033[0m"
greenback="\0033[1;37;42m"
blueback="\0033[1;37;44m"





spinner() {
    local i sp n
    sp='/-\|'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        printf "%s\b" "${sp:i++%n:1}"
    done
        }

###############################################################################################

while getopts ":d:g:b:p:c:n:" options; do
	case "$options" in 
		
		d)	
			domain_name=${OPTARG}
			;;
		g)
			git_link=${OPTARG}
			;;
		b)	
			git_branch=${OPTARG}
			;;
		p)
			php_ver=${OPTARG}	
			;;
		c)
			composer_ver=${OPTARG}
			;;
		n)
			node_ver=${OPTARG}
			;;
	esac
done
##############################################################################################

#Kod koji pravi naziv za bazu tako sto mice domain extension i nakon toga pretvara sve '.' i '-' karaktere u '_'



if [[ $domain_name == "false" ]]; then
	echo -e "$blueback Koji je naziv domena?:$resetvid"
	read domain_name
	domain=$domain_name
	domain_name=${domain_name%.*.*};
	domain_name=${domain_name//[-.]/_}
	echo $domain_name
else 
	domain=$domain_name
        domain_name=${domain_name%.*.*};
        domain_name=${domain_name//[-.]/_}
        echo $domain_name
fi








password=`date | md5sum`           					##Kreiranje passworda za bazu
password=${password//[ -]/}
password="$password+!=ABC"

domain_usr="${domain_name}_usr"
############################################################################
#kod za kreiranje baze:
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

###########################################
#Code for creating project-repo and cloning project via git



if [ $git_link == "false"  ]; then

	cd /var/websites
	echo -e "$blueback Please provide a link for git clone:$resetvid"
	while true; do
		read git_link
        	git ls-remote $git_link 2>/dev/null 1>/dev/null
       		 if [ $? -eq 0 ];then
                	git clone $git_link
               		 break
       		 else
                	echo -e "$blueback Try again$resetvid"

       		 fi

	done

	git clone "$git_link"
	git_repo=`ls -1t | head -1`
	mv /var/websites/$git_repo /var/websites/$domain
else

        cd /var/websites
        git clone "$git_link"
        git_repo=`ls -1t | head -1`
        mv /var/websites/$git_repo /var/websites/$domain

fi


	
if [ $git_branch == "false" ];then
	echo -e "$blueback Please provide the branch name for cloned Git project:$resetvid"
	cd /var/websites/hajde.amplitudo.me
        while true; do
                read git_branch
                #true_branch=`git branch -r |grep -o "$git_branch" `

                git switch $git_branch 1>/dev/null 2>/dev/null

       if [ $? -eq 128 ]; then
                        let "k+=1"
                if [ $k -eq 2 ]; then
                        echo -e "$blueback Just FKIN GET THE LINK RIGHT or imma delete this whole server i have fucking sudo privileges $resetvid"
                elif [ $k -gt 2 ]; then
                        espeak-ng -m  "Time to fuck this server up Goodbye"
                        echo AGAIN

                else
                       echo -e "$blueback Whopsie wrong branch, try again trash $resetvid"
                fi


        else
                echo -e "$greenback Good boi.$resetvid"
                espeak-ng "Good Boi"
                git switch $git_branch 1>/dev/null 2>/dev/null
                break;
        fi


        done

	#git switch $git_branch
	sudo chown -R stevan:www-data /var/websites/$domain   #####Change user 'stevan' with your local user
	sudo find /var/websites/$domain -type f -exec chmod 0644 {} \;
	sudo find /var/websites/$domain -type d -exec chmod 755 {} \;

else
        cd /var/websites/$domain
        git switch $git_branch
        sudo chown -R stevan:www-data /var/websites/$domain   #####Change user 'stevan' with your local user
        sudo find /var/websites/$domain -type f -exec chmod 0644 {} \;
        sudo find /var/websites/$domain -type d -exec chmod 755 {} \;



fi

export domain_name
export domain_usr
export password
export php_ver
export composer_ver
export node_ver
export domain

if [ "$node_ver" == "false" ]; then
	if [ "$php_version" == "false" ] || [ "$composer_ver" == "false" ]; then

		sudo chmod -R 775 /var/websites/$domain/storage /var/websites/$domain/bootstrap
		bash /home/stevan/skripte/laravel.sh
	else

		sudo chmod -R 775 /var/websites/$domain/storage /var/websites/$domain/bootstrap
                bash /home/stevan/skripte/laravel.sh


	fi
	

fi



































