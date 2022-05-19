#!/bin/bash
. ~/.nvm/nvm.sh




nvm --version


while true; do
	read node_version
	nvm install $node_version

if [ $? -ne 0 ]; then
	echo try again
else 
	break;
fi

done
