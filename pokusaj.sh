#!/bin/bash
vals=($(seq 1 1 7))

read tech
re='^[1-7]+$'



while true; do
	if [[ $tech != 1 && $tech != 2 && $tech != 3 && $tech != 4 && $tech != 5 && $tech != 6 && $tech != 7 ]]; then
 	echo -e "$blueback Wrong fkin value, Amazing work. Try again.$resetvid"
	read tech
	fi
done

        case $tech in

        1)
                node_ver="1234"
               # bash /home/stevan/skripte/laravel.sh
	       echo radi
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

