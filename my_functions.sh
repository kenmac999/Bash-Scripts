#!/bin/bash
#----------------------------------------------------------------------------#
# File: my_functions.sh
# Last Update: Sun 08 Aug 2021 08:48:00 PM CDT 
# Purpose: various functions used regularly in my bash scripts
#----------------------------------------------------------------------------#
# include $HOME/Bash_Scripts/my_functions.sh by copying following line and 
# removing hash tag (un-remark)
# . $HOME/Bash_Scripts/my_functions.sh
#----------------------------------------------------------------------------#
# this file contains various functions that can be used to save typing
# following will include (source) this file
# [[ -f $HOME/Bash_Scripts/my_functions.sh ]] && . $HOME/Bash_Scripts/my_functions.sh || VARIABLE="No file found"
# init functions

#----------------------------------------------------------------------------#
#empty function declaration that will print empty line to screen
empty_func(){
	#empty function.  can copy & past when creating new functions.
	echo "This is an empty function"
}

#----------------------------------------------------------------------------#
# function designed to emulate dos pause command
# can pass any prompt to display
# example pause 'Press [Ctrl]+[C] to cancel or [Enter] key to continue...'

function pause(){
   read -p "$*"
 echo ""
}

#----------------------------------------------------------------------------#
# function designed to get directory of currently running file, create symlink 
# called Backup in user's home directory pointing to this directory that can be
# used in a backup script
# if located on, and run from backup drive
backup_func(){
	# This function creates symlink in user's home directory to the external drive this file is run from
	# first check if "${HOME}/Backup" symlink/directory exists and remove so we can create link to correct location
	if [ -d "${HOME}/Backup" ] ; then
		echo "${HOME}/Backup exists..."
		echo "Removing.."
		rm "${HOME}/Backup"
	fi
	# now we get this files current location so we know where the external drive is
	# connnected.  This will become the backupdrive location that symlink Backup
	# points to.
	curfile="$0"
	curfilelength=${#curfile}
	COUNTER=0
	# while loop that works backward from end of path/filename to find "/"
	# and then drop filename so that we have the current path
	while [  $COUNTER -lt ${#curfile} ]; do
		let COUNTER=COUNTER+1
		if [ "${curfile:(-$COUNTER):1}" == "/" ] ; then
			rundir=${curfile:0:curfilelength-($COUNTER-0)}
			echo $rundir
			break
		fi
	done
	backupdrive="$rundir"

	# test to make sure not removed while script is running
	if [ -d "$rundir" ] ; then
	    ## since exists create link
		echo "$backupdrive exists"
		echo "Creating link in Home directory"
		ln -s "$rundir" "${HOME}/Backup"
	else
		## not attached, check & remove symlink if exists
		echo "$backupdrive does not exist"
	fi
}

#----------------------------------------------------------------------------#
# connect_func is designed to mount remote file system(s) from a remote system
# and notify you if connection sucessful or failed. May want to redesign so 
# that remote path, local mount points are passed instead of hardcoded 
# as they are here. 
function connect_func(){
	#open secure shell filesystem to files on emachine's /home directory and mapping it to local /home/dad/el1200 
	sshfs -o idmap=user dad@192.168.1.99:/home /media/dad/el1200
	sshfs -o idmap=user dad@192.168.1.99:/media /media/dad/remote_media
	
	# test if connection worked by looking for a specific file on the remote
	# system
	if [ ! -f /media/dad/el1200/dad/Desktop/htop.sh ]; then
		notify-send -t 5000 -u low "Connection Failed"
		echo "Connection Failed"
	else
		notify-send -t 5000 -u low "Connected el1200 & remote_media"
		echo "connected el1200 & remote_media"
		zenity \
			--info \
			--timeout=2 \
			--text="Connected" \
			--title="Connection Status" \;
		cp ~/Pictures/em_header.gif ~/Desktop/em_header.gif
	fi

}

#----------------------------------------------------------------------------#
# testconnect_func hardcoded to test if have already opened secure shell
# filesystem to files on emachine's /home directory by looking for a specific
# file and mapping it to local /media/dad/el1200, if not open, calls connect_func
# may want to redesign so that file or directory can be passed for testing
function testconnect_func(){
	if [ -f /media/dad/el1200/dad/Desktop/htop.sh ]; then
    	# already connected
    	echo "already connected"
	else
       	zenity \
 			    --info \
			    --timeout=2 \
			    --text="eMachine curently disconnected, connecting" \
			    --title="Connection Status" \;
	    connect_func
    fi

}

#----------------------------------------------------------------------------#
# disconnect_func hardcoded to unmount remote drives/directories located on
# emachine. May want to redesign so that remote path, local mount points are
# passed instead of hardcoded as they are here. 
function disconnect_func(){
	#disconnect or unmount remote connection
	fusermount -u /media/dad/el1200
	fusermount -u /media/dad/remote_media
	notify-send -t 5000 -u low "Disconnected el1200 & remote_media"
	echo "disconnected el1200 & remote_media"
	if [ -f ~/Desktop/em_header.gif ]; then 	
		rm ~/Desktop/em_header.gif
	fi
	zenity \
			--info \
			--timeout=2 \
			--text="Disconnected" \
			--title="Connection Status" \;
}

#----------------------------------------------------------------------------#
# finance_func designed to launch all applications used when updating gnucash and balancing checkbooks
function finance_func(){
    #testconnect_func # uncomment if need to test if connected to remote server
	# open calculator
	gnome-calculator &

	# open gnucash
	gnucash &

	# open My custom web page for various finance sites in firefox
	firefox http://k-mcdonald.epizy.com/My_List_of_Sites.htm &

	# open my home folder in nautilus
	nautilus /home/dad/Documents/MONEY &

}

#----------------------------------------------------------------------------#
# GOOGLEDRIVE function acts as a toggle to mount or unmount google drive to
# local file system, giving user ability to copy files to from his google
# drive, then when done to disconnect instead of having permanently mounted
# requires google-drive-ocamlfuse installed to use
GOOGLEDRIVE(){
	# requires google-drive-ocamlfuse installed to use
	googledrive="${HOME}/googledrive"

	if [ -d "$googledrive" ] ; then
		## unmout googledrive & remove mount point
		fusermount -u "$googledrive"
		rmdir "$googledrive"
	else
	## create google drive mount point & mount
		mkdir "$googledrive"
		google-drive-ocamlfuse "$googledrive"
	fi
}

#----------------------------------------------------------------------------#
# I use managebooks_func to start all applications I use when managing my calibre
# ebook library in linux
managebooks_func(){
    # testconnect_func # if library on remote machine
	# launch nautilus
	nautilus &

	#Open calibre with Master Library
	calibre --with-library "/home/Public/Calibre Libraries/Master Library" &

	#Open AF Library, Pioneer Library and Bookbub urls in google chrome
	/usr/bin/google-chrome-stable https://dod.overdrive.com https://pioneerok.overdrive.com/ http://pioneerlibrarysystem.org/ https://www.bookbub.com/launch &
}

#----------------------------------------------------------------------------#
# used to prompt to quit
function quit_func(){
    echo "Enter number of option wanted:"
    OPTIONS="Quit"
    select opt in $OPTIONS; do
	if [ "$opt" = "Quit" ]; then
	  # Quit bash scrip
	  echo "done"
	  notify-send -t 5000 -u low "Done"
          exit
    fi
    done
}

#----------------------------------------------------------------------------#
# I use thunderbird_func to start thunderbird from within my zenity menu
thunderbird_func(){
    testconnect_func
	thunderbird &
}

#----------------------------------------------------------------------------#
# This function checks for the following  drives and assigns their 
# locations to associated variables
#    Western Digital 4TB My Passport drive assigned to = PASSPORT
#    Seagate 2TB (NTFS) drive assigned to = SEAGATE2TB
#    Seagate 4TB (NTFS)drive assigned to = Seagate3TBntfs
#    Seagate 3.9TB drive assigned to = Seagate3TBext4
#    homedata partition on 2nd internal hard driver to = HOMEDATA
#    sftp file mapping to emachine = EL1200
old_FINDDRIVES(){
	# this function tests what expected drives are connected and assigns their
	# location to variables.
	if [ "$HOSTNAME" == "dad-ThinkCentre-A63" ]; then # if running on ThinkCentre
		# test for exernal drive labeled "WIN10" (Windows 10 partition on primary internal drive)
        if lsblk | grep -q "WIN10"; then
            echo "-- WIN10 connected"
            if mount -l | grep -q "WIN10"; then
                # echo "and mounted"
                mntpoint=$(mount -l -t fuseblk | grep "WIN10")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                WIN10=${mntpoint:13:varlength-14-($COUNTER-0)}
		                WIN10+="/"
		                # echo $WIN10
		                break
	                fi
                done
                echo "and mounted at " $WIN10
            else 
                echo "   but not mounted"
                WIN10=''   
            fi

        else 
            echo "-- not connected" 
            WIN10=''   
        fi
	
		# test for homedata
        if lsblk | grep -q "homedata"; then
            echo "-- homedata connected"
            if mount -l | grep -q "homedata"; then
                # echo "and mounted"
                mntpoint=$(mount -l | grep "homedata")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                HOMEDATA=${mntpoint:13:varlength-14-($COUNTER-0)}
		                HOMEDATA+="/"
		                # echo $HOMEDATA
		                break
	                fi
                done
                echo "and mounted at " $HOMEDATA
            else 
                echo "   but not mounted"
                HOMEDATA=''   
            fi

        else 
            echo "-- not connected" 
            HOMEDATA=''   
        fi

		# test for exernal drive labeled "My Passport"
        if lsblk | grep -q "My Passport"; then
            echo "-- My Passport connected"
            if mount -l | grep -q "My Passport"; then
                # echo "and mounted"
                mntpoint=$(mount -l -t fuseblk | grep "My Passport")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                PASSPORT=${mntpoint:13:varlength-14-($COUNTER-0)}
		                PASSPORT+="/"
		                # echo $PASSPORT
		                break
	                fi
                done
                echo "and mounted at " $PASSPORT
            else 
                echo "   but not mounted"
                PASSPORT=''   
            fi

        else 
            echo "-- not connected" 
            PASSPORT=''   
        fi

		# test for Seagate2TB (NTFS format)
        if lsblk | grep -q "Seagate2TB"; then
            echo "-- Seagate2TB connected"
            if mount -l | grep -q "Seagate2TB"; then
                # echo "and mounted"
                mntpoint=$(mount -l | grep "Seagate2TB")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
	            COUNTER=0
	            while [  $COUNTER -lt ${#mntpoint} ]; do
		            # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
		            # echo ${mntpoint:(-$COUNTER):4}
		            let COUNTER=COUNTER+1
		            if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
			            SEAGATE2TB=${mntpoint:13:varlength-14-($COUNTER-0)}
			            SEAGATE2TB+="/"
			            # echo $SEAGATE2TB
			            break
		            fi
	            done
                echo "and mounted at " $SEAGATE2TB
            else 
                echo "   but not mounted"
                SEAGATE2TB=''   
            fi

        else 
                echo "-- not connected"
                SEAGATE2TB=''
        fi

		# test for Seagate3TBntfs (NTFS format 4TB partition)
        if lsblk | grep -q "Seagate3TBntfs"; then
            echo "-- Seagate3TBntfs connected"
            if mount -l | grep -q "Seagate3TBntfs"; then
                # echo "and mounted"
                mntpoint=$(mount -l | grep "Seagate3TBntfs")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                Seagate3TBntfs=${mntpoint:13:varlength-14-($COUNTER-0)}
		                Seagate3TBntfs+="/"
		                # echo $Seagate3TBntfs
		                break
	                fi
                done
                echo "and mounted at " $Seagate3TBntfs
            else 
                echo "   but not mounted"
                Seagate3TBntfs=''   
            fi

        else 
            echo "-- not connected" 
            Seagate3TBntfs=''   
        fi

		# test for Seagate3TBext4
        if lsblk | grep -q "Seagate3TBext4"; then
            echo "-- Seagate3TBext4 connected"
            if mount -l | grep -q "Seagate3TBext4"; then
                # echo "and mounted"
                mntpoint=$(mount -l | grep "Seagate3TBext4")
                # TESTOUPUT "$mntpoint"
                varlength=${#mntpoint}
                # TESTOUPUT "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                # echo COUNTER $COUNTER ${mntpoint:(-$COUNTER)}
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                Seagate3TBext4=${mntpoint:13:varlength-14-($COUNTER-0)}
		                Seagate3TBext4+="/"
		                # echo $Seagate3TBext4
		                break
	                fi
                done
                echo "and mounted at " $Seagate3TBext4
            else 
                echo "   but not mounted"
                Seagate3TBext4=''   
            fi

        else 
            echo "-- not connected" 
            Seagate3TBext4=''   
        fi

		# test for sftp file mapping to remote computer
		if [ -f /media/dad/el1200/dad/Desktop/htop.sh ]; then
			echo " el1200 is connected"
			EL1200='/media/dad/el1200/dad/'
		else
			echo "el1200 is not connected"
			EL1200=''
		fi
	fi
	
	if [ "$HOSTNAME" == "dad-EL1200-07w" ]; then
		echo "I am running on host: $HOSTNAME"
		# heres where drive detection logic for emachine goes
	fi
	
	echo "drives found: $WIN10; $HOMEDATA; $PASSPORT; $SEAGATE2TB; $Seagate3TBntfs; $Seagate3TBext4"
	if [ -z "$PASSPORT" ]  || [ -z "$SEAGATE2TB" ] || [ -z "$HOMEDATA" ] || [ -z "$Seagate3TBntfs" ] || [ -z "$Seagate3TBext4" ];  then # if any var is empty exit
		echo "One or more drives not connected.  "
		echo "exiting"
		
	fi
	# end of FINDDRIVES function
}

#----------------------------------------------------------------------------#
# this function creates variables that can then be used when the day of week,
# day of the month, or year numerical values are needed
CURRDATE(){
	# function to assign/update current time
	DOW=$(date +%u) # assigns day of week
	DAY=$(date +%d) # assigns day of the month
	MONTH=$(date +%m) # assigns month
	YEAR=$(date +%Y) # assigns year
}

#----------------------------------------------------------------------------#
# this function creates variables that can then be used when the current time
# is needed
CURRTIME(){
	# function to assign/update current time
	TIME=$(date +%T)
	NANO=$(date +%N)
}

#----------------------------------------------------------------------------#
# this function can be used to send output to screen when testing scripts
TESTOUPUT(){
	# simple function to aid in troubleshooting scripts
	# instead of writing 2 echo statements use TESTOUPUT function to separate 
	# screen output for clarity
	echo
	echo $1 $2 $3 $4 $5 $6 $7 $8 $9
}

#----------------------------------------------------------------------------#
# I use REVIEW_LOGS to open my cron log in gedit and nautilus file manager
# pointing to location of logs created by rsyncdirectories.sh script
# from within my zenity menu
REVIEW_LOGS(){
	gedit '/home/dad/.log/cron/cron.log' &
	nautilus '/media/dad/Seagate3TBext4/home' &
}

#----------------------------------------------------------------------------#
# RIPRECORDS_func launches applications from within my zenity menu that are
# used when ripping vinyl albums to mp3 
RIPRECORDS_func(){
	
	qasmixer & 
	/usr/bin/qjackctl &
	pavucontrol &
	gedit "/media/dad/homedata/dad/My_Computer_Notes/LInux Config Notes/AudioRecordNotes.txt"&
	/usr/bin/google-chrome-stable http://manual.audacityteam.org/man/sample_workflow_for_lp_digitization.html &
	nautilus "/media/dad/homedata/Public/Audio_Files/Albums"&
	sleep 2
	audacity &

}

#----------------------------------------------------------------------------#
# MANAGE_RECORDS_func launches applications from within my zenity menu that are
# used to manage, edit audio files ripped from CD or vinyl to mp3/flac 
MANAGE_RECORDS_func(){
	nautilus "/media/dad/homedata/Public/Audio_Files/Albums" &
	# python2 /usr/bin/puddletag &
	picard &
	k3b &
}

#----------------------------------------------------------------------------#
# MANAGE_AUDIOBOOKS_func launches applications from within my zenity menu that
# are used to manage, edit audio book files downloaded from internet or ripped from CD
MANAGE_AUDIOBOOKS_func(){
	nautilus "/home/dad/Public/VM_Share/My Media/MP3 Audiobooks" &
	puddletag &
	gedit "/home/dad/Public/VM_Share/My Media/MP3 Audiobooks/AudiobookNotes.txt" &
	#Open AF Library, Pioneer Library and Bookbub urls in google chrome
	/usr/bin/google-chrome-stable https://dod.overdrive.com/dod-airforce/content/ https://pioneerok.overdrive.com/ &
	
}

#----------------------------------------------------------------------------#
#this function opens Visual Studio and nautilus for writing COBOL programs
COBOL_func(){
	/usr/share/code/code --no-sandbox --unity-launch %F &
	nautilus "/home/dad/COBOL" &
}

#----------------------------------------------------------------------------#
# this function tests passed drive(s) are connected and can assign their mounted
# location to a variable. If not mounted an empty variable ('') is created.
# Usage: var=$(FINDDRIVES_alt "drive_label")
	
FINDDRIVES(){
		# test for passed drive label
		#echo "testing for $1"
		local drive="$1"
		local drivelabel
		#echo "drive = $drive"
        if lsblk | grep -q $1; then
            #echo "-- $1 connected"
            if mount -l | grep -q $1; then
                # echo "and mounted"
                mntpoint=$(mount -l | grep $1)
                #echo "$mntpoint"
                varlength=${#mntpoint}
                #echo  "$varlength"
                COUNTER=0
                while [  $COUNTER -lt ${#mntpoint} ]; do
	                #echo "COUNTER $COUNTER ${mntpoint:(-$COUNTER)}"
	                # echo ${mntpoint:(-$COUNTER):4}
	                let COUNTER=COUNTER+1
	                if [ "${mntpoint:(-$COUNTER):4}" == "type" ] ; then
		                drivelabel="${mntpoint:13:varlength-14-($COUNTER-0)}"
		                drivelabel+="/"
		                # echo $drivelabel
		                break
	                fi
                done
                # echo "and mounted at $drivelabel"
            else 
                # echo "   but not mounted"
                drivelabel=''   
            fi

        else 
            # echo "-- not connected" 
            drivelabel=''   
        fi
        echo "$drivelabel"
}

#----------------------------------------------------------------------------#

echo
echo
echo "--- functions loaded ---"

#################################################
# begin your script after this point
#################################################


