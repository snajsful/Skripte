#!/bin/bash
#MANPATH /usr/local/man/lamp1
php_ver="false"
composer_ver="false"
node_ver="false"
domain_name="false"
git_branch="false"
git_link="false"
tech="false"
k=0
inversvid="\0033[7m"
resetvid="\0033[0m"
greenback="\0033[1;37;42m"
blueback="\0033[1;37;44m"



figlet -f slant "WELCOME TO THE I RARELY WORK SCRIPT"
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

while getopts ":t:d:g:b:p:c:n:" options; do
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
		t)	
			tech=${OPTARG}
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
#Code for creating project-repo and cloning project via git



if [ $git_link == "false"  ]; then

	cd /var/websites
	echo -e "$blueback Please provide a link for git clone:$resetvid"
	while true; do
		read git_link
        	git ls-remote $git_link 2>/dev/null 1>/dev/null
       		 if [ $? -eq 0 ];then
                	git clone $git_link $domain 
               		 break
       		 else
                	echo -e "$blueback Try again$resetvid"

       		 fi

	done


else

        cd /var/websites
        git clone "$git_link" $domain

fi


	
if [ $git_branch == "false" ];then
	echo -e "$blueback Please provide the branch name for cloned Git project:$resetvid"
	cd /var/websites/$domain
	git pull
        while true; do
                read git_branch
                #true_branch=`git branch -r |grep -o "$git_branch" `

                git switch $git_branch #1>/dev/null 2>/dev/null

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

else
        cd /var/websites/$domain
	git pull
        git switch $git_branch
	while [ $? -ne 0 ]; do
                        echo -e "$blueback Branch-o Trash-o, try again$resetvid"
                        read git_branch
                        git switch $git_branch

        done
        echo -e "$greenback Good boi.$resetvid"
	espeak-ng "Good Boi"





fi

export domain_name
export domain_usr
export password
export php_ver
export composer_ver
export node_ver
export domain
export -f spinner

		

if [ $tech == "false" ]; then
echo -e "$blueback Which technology do you wish to be deployed(Type the number in) 1.Laravel 2.Wue 3.Laravel + Wue 4.React 5.Next. 6.Strapi 7.Spring$resetvid"
read tech
fi

while true; do
        if [[ $tech != 1 && $tech != 2 && $tech != 3 && $tech != 4 && $tech != 5 && $tech != 6 && $tech != 7 ]]; then
        echo -e "$blueback Wrong fkin value, Amazing work. Try again.$resetvid"
        read tech
else 
	break
        fi
done

	case $tech in 

	1)	
		node_ver="1234"
		bash /home/stevan/skripte/laravel.sh
		;;

	2)
		#bash /home/stevan/skripte/
		;;

	3)	
		bash /home/stevan/skripte/laravel.sh
		;;
	4)
		#bash /home/stevan/skripte/
		;;
	5)
		#bash /home/stevan/skripte/
		;;
	6)
		#bash /home/stevan/skripte/
		;;
	7)
		#bash /home/stevan/skripte/
		;;
	*)	
		echo "Good job. You even managed to miss a simple number. Try again."
		;;	
esac

