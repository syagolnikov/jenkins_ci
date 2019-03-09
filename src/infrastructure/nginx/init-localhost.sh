#!/bin/bash

function setup_hosts () {
	if [[ -z $1 ]]; then
		echo "please enter a valid URL to route traffic locally"
		exit 0
	fi

	echo "127.0.0.1       $1" | sudo tee -a /etc/hosts
}

setup_hosts $1
