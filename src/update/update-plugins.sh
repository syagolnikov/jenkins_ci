#!/bin/bash

DATE=$(date +%m-%d-20%y)
SYSTEM_USER=$(ls -al ../../../jenkins | tail -n 1 | awk '{print $3}')
TOKEN=$2
USER=$1

function start_standby () {

	if [[ -z $1 ]] || [[ -z $2 ]]; then
		echo "please enter USERNAME and TOKEN value for blue_green test run"
		exit 0
	fi

	##copy all files to standby directory and launch standby
	mkdir -p ../../../jenkins_standby
	mkdir -p ../../../jenkins_backup_$DATE
	rm -rf ../../../jenkins_standby/*
	cp -R ../../../jenkins/* ../../../jenkins_standby/
	sudo chown $SYSTEM_USER -R ../../../jenkins_standby/
	cp -R ../../../jenkins/* ../../../jenkins_backup_$DATE
	sudo docker rm -f jenkins-master-standby
	sudo docker-compose -f docker-compose-standby.yml up -d
	sleep 120
}

function update_standby () {

	validate_standy=$(sudo docker ps --filter name="jenkins-master-standby" | sed -n '1!p')

	if [[ -z validte_standby ]]; then
		echo "standby master check failed, exiting"
		exit 0
	fi

	UPDATE_LIST=$(java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ -auth $USER:$TOKEN list-plugins | cut -d " " -f 1 )

	if [ ! -z "${UPDATE_LIST}" ]; then
    		echo Updating Jenkins Plugins: ${UPDATE_LIST};
    		java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ -auth $USER:$TOKEN install-plugin ${UPDATE_LIST};
    		java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ -auth $USER:$TOKEN safe-restart;
		sleep 90
	fi
}

function update_master () {

	TEST=$(java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ -auth $USER:$TOKEN build test -f | tail -n 1 | cut -d ":" -f 2 )

	if [[ "$TEST" -eq "SUCCESS" ]]; then
		sudo docker stop jenkins-master
		sudo docker stop jenkins-master-standby
		sudo rm -r ../../../jenkins/*
		cp -R ../../../jenkins_standby/* ../../../jenkins/
		sudo rm -rf ../../../jenkins_standby
		sudo chown $SYSTEM_USER -R ../../../jenkins/
		sudo docker start jenkins-master
	fi
}

function fail_over () {
	echo "update_master function failed"
}

start_standby $1 $2
update_standby $1 $2
update_master $1 $2
