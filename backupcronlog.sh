#!/bin/bash
#----------------------------------------------------------------------------#
# File: backupcronlog.sh
# Last Update: Sun 16 Aug 2020 10:40:55 AM CDT 
# Designed to backup current cron.log before beginning of new day
#----------------------------------------------------------------------------#
# Load predefined functions
. $HOME/Bash_Scripts/my_functions.sh
#----------------------------------------------------------------------------#
# get today's date
CURRDATE

# generate backup log file name
BKLOG='/home/dad/.log/cron/'
BKLOG+="$YEAR$MONTH$DAY.log"
echo "---------------------------- End of Current Log ----------------------------" >> '/home/dad/.log/cron/cron.log'
cp -v '/home/dad/.log/cron/cron.log' "$BKLOG"
echo "-------------------------- Begnning of Current Log --------------------------" > '/home/dad/.log/cron/cron.log'


