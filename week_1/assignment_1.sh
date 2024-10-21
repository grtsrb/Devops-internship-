#!/bin/bash

while [ true ]; do

	echo "Welcome to the first intership bash script! Please choose your option: "
	echo "1. List files and directories."
	echo "2. Display disk usage"
	echo "3. Show running processes"
	echo "4. Show network information"
	echo "5. Exit the scripts"

	read -p "Enter your option: " option

	if [ $option -eq 1 ]; then
		ls -lha
	elif [ $option -eq 2  ]; then
		df -h
	elif [ $option -eq 3 ]; then
		ps -a
	elif [ $option -eq 4 ]; then
		ifconfig
	elif [ $option -eq 5 ]; then
		exit 1
	else
		echo "Wrong option, please enter the correct one!"
	fi
done
