#!/bin/bash

DATE=$(date +%m-%d-20%y)

function upgrade_jenkins () {

	##backup home, stop jenkins, upgrade with today's date for name
  mkdir -p ../../jenkins_upgrade_backup_$DATE
	cp -R ../../jenkins/* ../../jenkins_backup_$DATE
  sudo docker stop -f $(sudo docker ps -a -q)
  sudo sed -i -e "s/DATE/$DATE/g" ./docker-compose-upgrade.yml
	sudo docker-compose -f docker-compose-upgrade.yml up -d
}

function complete_upgrade () {

  #delete old image except for the one running
  if [[ $1 == "complete"]]; then
      validate_master=$(sudo docker ps --filter name="jenkins-master" | sed -n '1!p')

      if [[ ! -z $validate_master ]]; then
        #won't remove current running container
        sudo docker rm $(sudo docker ps -a -q)
      fi
  fi
}


upgrade_jenkins
complete_upgrade $1

#this script needs to be ran twice, once without params and another with "complete" as a pram
