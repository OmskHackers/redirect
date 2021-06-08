#!/bin/bash

if [ $USER != "root" ];then
        echo "Run script with root privileges"
        exit
fi

check_os=$(uname -v)
os=unknown
docker_version=$(docker -v)


if echo "$check_os" | grep -o "Ubuntu" > /dev/null ;then
	os=Ubuntu

elif echo "$check_os" | grep -o "Debian" > /dev/null;then
	os=Debian
else
	echo "Unknown OS"
        exit
fi

while :
do
  current_ls=$(ls -l | grep '^d')
  if [ "$current_ls" != "" ];then
  	while :
  	do
  	clear
  		echo "   1) Add a new service"
  		echo "   2) Manage"
  		echo "   3) Exit"
  		read -p "Select an option: " option
  		until [[ "$option" =~ ^[1-3]$ ]]; do
  			echo "$option: invalid selection."
  			read -p "Select an option: " option

  		done
  		case "$option" in
  			1)
  			clear
  			read -p "Service name : " name
  			until echo "$name" | egrep "^[a-z_]+$" ; do
  				echo "Str must be ^[a-z_]+$."
  				read -p "Service name: " name
  			done
  			clear

  			read -p "Port : " port
  			until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
  				echo "$port: invalid selection."
  				read -p "Port : " port
  			done
  			clear

  			read -p "IP : " ip
  			until echo "$ip" ; do
  				echo "$ip: invalid selection"
  				read -p "IP : " ip
  			done

  			mkdir $name
  			echo ":: $port $ip $port" > $name/rinetd.conf
  			echo "$port" > $name/port
        echo "$ip" > $name/ip

  			;;
  			2)
        while :
        do
          clear
    			counter=1
    			services=$(ls -d */)
    			for i in $services;do
    				check_docker=$(docker ps -q -f name=redirect_${i%%/})
            cat_port=$(cat ${i%%/}/port)
            cat_ip=$(cat ${i%%/}/ip)
    				if [ "$check_docker" != "" ];then
    					echo "$counter) ${i%%/} [$cat_port] - $(tput setaf 2)up $(tput sgr 0) | $cat_ip"
    				else
    					echo "$counter) ${i%%/} [$cat_port] - $(tput setaf 1)down $(tput sgr 0) | $cat_ip"
    				fi
    				counter=$((counter+1))
    			done
    			counter=$((counter-1))

    			read -p "Select an service: " service

          if [ "$service" == "" ];then
            continue
          fi

          if [ "$service" == "q" ];then
            break
          fi
          until [[ "$service" != "" && "$service" =~ ^[0-9]+$ && "$service" -le $counter && "$service" -gt 0 ]]; do
    				echo "$service: invalid selection."
    				read -p "Select an service: : " service
    			done

          counter=1
          for i in $services;do
            if [ $service -eq $counter ] ;then
              srv="${i%%/}"
            fi
            counter=$((counter+1))
          done

          clear
          echo "$(tput setaf 6)$srv $(tput sgr 0)"
          echo "1) Up"
          echo "2) Down"
          echo "3) Edit"


          read -p "Select an action  : " status
          until [[ "$status" =~ ^[1-3]$ ]]; do
            if [ "$status" == "" ];then
              break
            fi
            echo "$status: invalid selection."
      			read -p "Select an status: " status
          done

          if [ "$status" == "1" ];then
            cat_port=$(cat $srv/port)
            use_port=$(netstat -lnp | grep :$cat_port)
            if [ "$use_port" != "" ];then
              echo ""
              echo "$use_port"
              sleep 2
              continue
            fi
            docker run --name redirect_$srv -p $cat_port:$cat_port --net=host --restart always -v $(pwd)/$srv:/etc/rinetd -td swager
          elif [ "$status" == "2" ];then
           docker stop redirect_$srv
           docker rm redirect_$srv
         elif [ "$status" == "3" ];then
           cat_port=$(cat $srv/port)
           read -p "IP : " ip
     			 until echo "$ip" ; do
     				echo "$ip: invalid selection"
     				read -p "IP : " ip
     			 done
           echo ":: $cat_port $ip $cat_port" > $srv/rinetd.conf
           echo "$ip" > $srv/ip
         fi
        done
        ;;
  			3)
  			exit ;;
  		esac
  	done
  else
  	if echo "$docker_version" | grep 'version' > /dev/null;then
      check_image=$(docker images | grep swager)
      if [ "$check_image" == "" ];then
        echo "docker build -t swager ."
        exit
      fi

  		echo "   1) Add a new service"
  		echo "   2) Exit             "
  		read -p "Select an option: " option
  		until [[ "$option" =~ ^[1-2]$ ]]; do
  			echo "$option: invalid selection."
  			read -p "Select an option: " option
  		done
      case "$option" in
        1)
        clear
        read -p "Service name : " name
        until echo "$name" | egrep "^[a-z_]+$" ; do
          echo "Str must be ^[a-z_]+$."
          read -p "Service name: " name
        done
        clear

        read -p "Port : " port
        until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
          echo "$port: invalid selection."
          read -p "Port : " port
        done
        clear

        read -p "IP : " ip
        until echo "$ip" ; do
          echo "$ip: invalid selection"
          read -p "IP : " ip
        done

        mkdir $name
        echo ":: $port  $ip $port" > $name/rinetd.conf
        echo "$port" > $name/port
        echo "$ip" > $name/ip
        ;;
        2)
        exit ;;
      esac
  	else
  		echo "Docker is not installed on your system"
  		exit
  	fi
  fi
done
