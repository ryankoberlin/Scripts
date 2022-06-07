#!/bin/bash

#
# Test script to determine whether or not a login is occuring from within a GNU Screen session or not
#

export PROCS=()
SCREEN=0

for PID in $( ps -o ppid=$$ | sort -u ); do 
	PROCS+=("${PID}"); 
done

while [[ ${#PROCS[@]} > 1 ]];
	do
#	ps faux | grep ^$(whoami) |awk -v var=${PROCS[0]} '{ if (($2=var) && ($0 ~ /SCREEN/)) { print $0 } }'|sort -u
		if ps faux | grep -q ${PROCS[0]}.*SCREEN; then 
		echo "${PROCS[0]} SCREEN FOUND"
		SCREEN=1
		echo "$(date) Screen found; $0 PPID=$$" >> /home/$(whoami)/temp.out
		exit
		else PROCS=("${PROCS[@]:1}")
	fi
done
