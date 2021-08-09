#!/bin/bash
#----------------------------------------------------------------------------#
# File: timeestamp.sh
# Last Update: Sun 08 Aug 2021 09:04:57 PM CDT 
# Purpose: inserts date, time before any text passed to it.
# Example:
# echo "This is a test" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
#----------------------------------------------------------------------------#
while read x; do
	echo -n `date +%Y-%m-%d\ %H:%M:%S`;
	echo -n " - ";
	echo $x;
done
