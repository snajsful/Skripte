#!/bin/bash
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

if [ $php_ver == "false" ]; then
	echo -e "$blueback Which project is this? 1.Laravel  2.Wue(front).$resetvid"
	while true; do
		read is_laravel
		if [ $is_laravel == "1" ]; then
		bash /home/stevan/skripte/laravel.sh
			break
		elif [ $is_laravel == "2" ]; then
			#bash frontendskriptu
			break
		else 
			echo "$blueback Try again homo$resetvid"
		fi
	done
fi






































