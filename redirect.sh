#!/bin/bash

if [ $USER != "root" ];then
        echo "Run script with root privileges"
        exit
fi

check_os=$(uname -v)
os=unknown
version=unknown
user=$USER

if echo "$check_os" | grep -o "Ubuntu" > /dev/null ;then
	os=Ubuntu

elif echo "$check_os" | grep -o "Debian" > /dev/null;then
	os=Debian
else
	echo "Unknown OS"
        exit
fi



if [ -e docker-compose.yml ]; then
	while :
	do
	clear
		echo "   1) Add a new service"
		echo "   2) Del an existing service"
		echo "   4) Exit"
		read -p "Select an option: " option
	done
else
	echo "   1) Add a new service"
	read -p "Select an option: " option
fi
