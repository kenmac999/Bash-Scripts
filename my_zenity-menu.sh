#!/bin/bash
#------------------------------------------------------------------------------#
# File: my_zenity-menu.sh
# Last Update: Sun 08 Aug 2021 08:43:08 PM CDT 
# Purpose: provide a zenity based GUI menu of common tasks, to include:
#   launching applications used for:
#       balancing checkbook or paying bills
#       managing ebooks
#       checking email
#------------------------------------------------------------------------------#
# include $HOME/Bash_Scripts/my_functions.sh
. $HOME/Bash_Scripts/my_functions.sh
#------------------------------------------------------------------------------#
clear #screen
echo
echo
echo "--- Start of $0 Script ---"

# next line sets up array of options to select from.  Enter in quotes
# old options=( "  1-Connect to eMachine" "  2-Disconnect from eMachine" "  3-Backup financial files" "  4-Cobol Programming" "  5-load finance applications" "  6-Manage Audio Books" "  7-Manage Audio Files" "  8-Manage your ebooks" "  9-Review Logs" " 10-Rip Audio Records" " 11-ThunderBird Mail" "     Exits in 30 seconds" )
options=( "  1-Backup financial files" "  2-Cobol Programming" "  3-load finance applications" "  4-Manage Audio Books" "  5-Manage Audio Files" "  6-Manage your ebooks" "  7-Review Logs" "  8-Rip Audio Records" "  9-ThunderBird Mail" "     Exits in 30 seconds" )

# set up array of actions to take
# old action=( connect_func disconnect_func /home/dad/Bash_Scripts/bu_Money.sh COBOL_func finance_func MANAGE_AUDIOBOOKS_func MANAGE_RECORDS_func managebooks_func REVIEW_LOGS RIPRECORDS_func thunderbird_func ) 
action=( /home/dad/Bash_Scripts/bu_Money.sh COBOL_func finance_func MANAGE_AUDIOBOOKS_func MANAGE_RECORDS_func managebooks_func REVIEW_LOGS RIPRECORDS_func thunderbird_func ) 

# now we set up the while do case 
# while is set up to read zenity list display and return item selected with mouse
# may need to adjust width, height if change list

title="My Zenity Menu" # sets title of window
prompt="Select Option"
while opt=$(zenity --title="$title" --text="$prompt" --list --width=400 --height=420 --timeout=30 \
                   --column="Options" "${options[@]}"); 
do
    case "$opt" in
    "${options[0]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[0]}" ;;
    "${options[1]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[1]}" ;;
    "${options[2]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[2]}" ;;
    "${options[3]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[3]}" ;;
    "${options[4]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[4]}" ;;
    "${options[5]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[5]}" ;;
    "${options[6]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[6]}" ;;
    "${options[7]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[7]}" ;;
    "${options[8]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[8]}" ;;
    "${options[9]}" ) zenity --info --timeout=2 --text="$opt picked"; "${action[9]}" ;;
    "${options[10]}" ) zenity --info --timeout=2 --text="$opt picked"; exit ;;
    *) zenity --error --text="Invalid option. Try another one.";;
    esac

done
exit

#----------------------------------------------------------------------------#
#       Options                             Actions
# old "  1-Connect to eMachine"              connect_func 
# old "  2-Disconnect from eMachine"         disconnect_func 
#"  1-Backup financial files"           /home/dad/Bash_Scripts/bu_Money.sh 
#"  2-Cobol Programming"                COBOL_func
#"  3-load finance applications"        finance_func 
#"  4-Manage Audio Books"               MANAGE_AUDIOBOOKS_func
#"  5-Manage Audio Files"               MANAGE_RECORDS_func 
#"  6-Manage your ebooks"               managebooks_func 
#"  7-Review Logs"                      REVIEW_LOGS 
#"  8-Rip Audio Records"                RIPRECORDS_func 
#"  9-ThunderBird Mail"                 thunderbird_func 
#"     Exits in 30 seconds")
#----------------------------------------------------------------------------#
# next line sets up array of options to select from.  Enter in quotes
# options=( "  1-Connect to eMachine" "  2-Disconnect from eMachine" "  3-Backup financial files" "  4-Cobol Programming" "  5-load finance applications" "  6-Manage Audio Books" "  7-Manage Audio Files" "  8-Manage your ebooks" "  9-Review Logs" " 10-Rip Audio Records" " 11-ThunderBird Mail" "     Exits in 30 seconds" )

# action=( connect_func disconnect_func /home/dad/Bash_Scripts/bu_Money.sh COBOL_func finance_func MANAGE_AUDIOBOOKS_func MANAGE_RECORDS_func managebooks_func REVIEW_LOGS RIPRECORDS_func thunderbird_func ) 

