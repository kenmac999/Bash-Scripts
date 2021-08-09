#!/bin/bash
#----------------------------------------------------------------------------#
# File: rsyncdirectories.sh
# Last Update: Sun 08 Aug 2021 08:44:41 PM CDT 
# Designed to syncronize certain directories on my ThinkCentre and emachine 
# computers to external drives.
#----------------------------------------------------------------------------#
# Load predefined functions
. $HOME/Bash_Scripts/my_functions.sh
#----------------------------------------------------------------------------#
# this section for defining functions used only by this script
test_threads(){
	# Ref: https://www.krazyworks.com/making-rsync-faster/
	# Make sure the number of rsync threads running is below the threshold
	local numthreads=$(ps -ef | grep -c [r]sync )
	echo "testing number of threads running: $numthreads"
	while [ `ps -ef | grep -c [r]sync` -gt ${maxthreads} ]
	do
		echo "current number of threads:"
		ps -ef | grep -c [r]sync
		echo "Sleeping ${sleeptime} seconds"
		sleep ${sleeptime}
	done

}

parallel_rsync(){
	# Ref: https://www.krazyworks.com/making-rsync-faster/
	# call using following format: parallel_rsync "source" "target"
	# Define source, target, maxdepth and cd to source
	# rsync_ptions variable can be set in calling program
	local source="$1"
	local target="$2"
	local depth=1
	cd "${source}"
	echo "changed directory to ${source} "
	# pause_func "paused at line $LINENO in parallel_rsync function"
	# Set the maximum number of concurrent rsync threads
	local maxthreads=5
	# How long to wait before checking the number of rsync threads again
	local sleeptime=5
	local cnt=0
	# Find all folders in the source directory within the maxdepth level
	find . -maxdepth ${depth} -type d | while read dir
	do
		((cnt++))
		# Make sure to ignore the parent folder
		echo "line $LINENO - " "pass $cnt for directory ${dir}"
		# pause_func "paused at line $LINENO in parallel_rsync function"
		if [ `echo "${dir}" | awk -F'/' '{print NF}'` -gt ${depth} ]
		then
			# Strip leading dot slash
			local subfolder=$(echo "${dir}" | sed 's@^./@@g')
			echo "checking if ${target}/${subfolder} exists"
			# pause_func "paused at line $LINENO in parallel_rsync function"
			if [ ! -d "${target}/${subfolder}" ]
			then
				# Create destination folder and set ownership and permissions to match source if not already present
				echo "creating ${target}/${subfolder}"
				# pause_func "paused at line $LINENO in parallel_rsync function"
				mkdir -p "${target}/${subfolder}"
				chown --reference="${source}/${subfolder}" "${target}/${subfolder}"
				chmod --reference="${source}/${subfolder}" "${target}/${subfolder}"
			fi
			test_threads
			# Run rsync in background for the current subfolder and move on to the next one
			echo "nohup rsync $rsync_options ${source}/${subfolder}/ ${target}/${subfolder}/ 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" "
			echo "nohup rsync $rsync_options ${source}/${subfolder}/ ${target}/${subfolder}/ 2>&1 | /home/dad/Bash_Scripts/timestamp.sh "
			nohup rsync $rsync_options "${source}/${subfolder}/" "${target}/${subfolder}/" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" &
		fi
	done
# pause_func "paused at line $LINENO in parallel_rsync function"
# Find all files above the maxdepth level and rsync them as well
echo "line $LINENO - finding files in ${source}"
find . -maxdepth ${depth} -type f -print0
find . -maxdepth ${depth} -type f -print0 | rsync $rsync_options --files-from=- --from0 ./ "${target}/"
echo "end of  parallel_rsync function"
# pause_func "paused at line $LINENO in parallel_rsync function"
}
# end of local functions
#----------------------------------------------------------------------------#
# Beginning of main script
clear #screen
echo
echo
echo "--- Start of Script --- ( line $LINENO )"

# set up initial variables used by script
# rsync options: [r]ecursive; preserve modification [t]imes; [v]erbose; [u]pdate; [c]hecksum;     --modify-window=2 seconds;   --progress --dry-run
	rsync_options=" -rtvu --modify-window=2 --progress "
# Set the maximum number of concurrent rsync threads, used in function parallel_rsync
	maxthreads=5
# How long to wait before checking the number of rsync threads again, used in function parallel_rsync
	sleeptime=5

# use function FINDDRIVES to find drive(s) connected and create variables pointing to them
  drive_WIN10="$(FINDDRIVES "WIN10")"
  echo " drive $drive_WIN10 found" "( line $LINENO )"
  drive_homedata=$(FINDDRIVES "homedata")
  echo " drive $drive_homedata found" "( line $LINENO )"
  drive_PASSPORT="$(FINDDRIVES "My_Passport")"
  echo " drive $drive_PASSPORT found" "( line $LINENO )"
  drive_Seagate2TB="$(FINDDRIVES "Seagate2TB")"
  echo " drive $drive_Seagate2TB found" "( line $LINENO )"
  drive_Seagate3TBext4="$(FINDDRIVES "Seagate3TBext4")"
  echo " drive $drive_Seagate3TBext4 found" "( line $LINENO )"
  drive_Seagate3TBntfs="$(FINDDRIVES "Seagate3TBntfs")"
  echo " drive $drive_Seagate3TBntfs found" "( line $LINENO )"
  
# if external drive(s) not connected end script
if [ -z "$drive_Seagate3TBntfs" ]  || [ -z "$drive_Seagate3TBext4" ] || [ -z "$drive_Seagate2TB" ];  then # if either var is empty exit
	echo "One or more drives not connected.  Connect and rerun"  "( line $LINENO )"
	echo "exiting"
	CURRDATE; CURRTIME; echo "ended $MONTH/$DAY/$YEAR, $TIME.$NANO" 
	exit
	# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
fi
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

# echo "creating date and time variables" using functions CURRDATE; CURRTIME
CURRDATE; CURRTIME

# generating backup log file name that will be saved to backup drive
BKLOG=$drive_Seagate3TBext4
BKLOG+="home/$HOSTNAME"
BKLOG+="_$YEAR$MONTH$DAY.log"
CURRTIME; echo " -- started $MONTH/$DAY/$YEAR, $TIME.$NANO -- " >> "$BKLOG"
echo " -- started $MONTH/$DAY/$YEAR, $TIME.$NANO -- " "( line $LINENO )"
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
#----------------------------------------------------------------------------#
# this section contains rsync commands that will be run from ThinkCentre computer

#----------------------------------------------------------------------------#
# rsync from Seagate3TBext4 to My_Passport if My_Passport is connected

# test if My_Passport is connected; if connected backup Seagate3TBext4/Backup, Public to My_Passport
if [ -z "$drive_PASSPORT" ];  then # My_Passport not connected
	echo "My_Passport not connected."  "( line $LINENO )"
	# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
else # My_Passport is connected
	SRC="$drive_Seagate3TBext4" # new source directory
	DEST1="$drive_PASSPORT" 
	echo "source: $SRC  destination: $DEST1" "( line $LINENO )"
	for i in Backup Public
	do
		echo "line $LINENO - " "Passing $SRC$i , $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
		echo "line $LINENO - " "Passing $SRC$i $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		parallel_rsync "$SRC$i" "$DEST1$i"
	done

fi


# if Host computer is ThinkCentre then copy to ThinkCentre external drives
if [ "$HOSTNAME" == "dad-ThinkCentre-A63" ]; then
	# this 
	echo "-----rsync commands for $HOSTNAME" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	echo "-----rsync commands for $HOSTNAME" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh 

	# rsync from  dad@dad-ThinkCentre-A63 home directories to /media/dad/homedata/dad
	echo "-----rsync from  dad@dad-ThinkCentre-A63 home directories" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	echo "-----rsync from  dad@dad-ThinkCentre-A63 home directories" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
	SRC="/home/dad/"
# destinations
	DEST1="$drive_homedata" 
	DEST1+="dad/" # first destination directory is on homedata/dad
	echo "source: $SRC  destination: $DEST1" "( line $LINENO )"
	for i in Ardour Audacity Bash_Scripts COBOL Documents lmms Pictures Pimlico Public Untitled_Linux_Show .thunderbird 
	do
		# for DEST1
		echo "rsync $rsync_options $SRC$i/ $DEST1$i/" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		echo "rsync $rsync_options $SRC$i/ $DEST1$i/" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
		nohup rsync $rsync_options "$SRC$i/" "$DEST1$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" &
		test_threads

	done
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
## Now to copy Calibre Libraries to homedata/public; Seagate2tb/Public and drive_Seagate3TBntfs/public
	SRC="/home/Public/"
# destinations
	DEST1="$drive_homedata" 
	DEST1+="Public/" # first destination directory is on homedata/dad
	DEST2="$drive_Seagate3TBntfs"
	DEST2+="Public/" # 2nd destination directory on drive_Seagate3TBntfs
	DEST3="$drive_Seagate2TB"
	echo "line $LINENO - 3rd destination: $DEST3"
	DEST3+="Public/" # 3rd destination directory on SEAGATE2TB
	echo "line $LINENO - 3rd destination: $DEST3"

	for i in "Calibre Libraries"
	do
		# rsync to DEST1
		echo "line $LINENO - " 
		echo "line $LINENO - " "Passing $SRC$i , $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
		echo "line $LINENO - " "Passing $SRC$i $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		parallel_rsync "$SRC$i" "$DEST1$i"
		# to destination 2
		echo "Passing $SRC$i $DEST2$i to function parallel_rsync" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
		echo "Passing $SRC$i $DEST2$i to function parallel_rsync" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		parallel_rsync "$SRC$i" "$DEST2$i"
		# to destination 3
		echo "Passing $SRC$i $DEST3$i to function parallel_rsync" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
		echo "Passing $SRC$i $DEST3$i to function parallel_rsync" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		parallel_rsync "$SRC$i" "$DEST3$i"
	done
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
	
#----------------------------------------------------------------------------#
# rsync from homedata partition (partition containing old el1200 home directories)
	echo "-----rsync from homedata/dad home directories" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	echo "-----rsync from homedata/dad home directories" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
	SRC="/media/dad/homedata/dad/"
	DEST="$drive_Seagate3TBext4"
	DEST+="home/dad/"
	for i in Archives Ardour atari800 Audacity BackupCompaq BackupNook Bash_Scripts blender COBOL Developing Documents lmms "My_Computer_Notes" PalmBU Pictures Pimlico Public Untitled_Linux_Show webpages Web_Pages .thunderbird
	        
	do
		echo "rsync $rsync_options $SRC$i/ $DEST$i/" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
		echo "rsync $rsync_options $SRC$i/ $DEST$i/" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
		nohup rsync $rsync_options "$SRC$i/" "$DEST$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" &
		test_threads
	done
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

#----------------------------------------------------------------------------#
## rsync from homedata partition Public directories to drive_Seagate3TBntfs and SEAGATE2TB drives
	echo " $LINENO -----rsync from homedata Public directories to drive_Seagate3TBntfs and SEAGATE2TB drives"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	echo "-----rsync from homedata Public directories to drive_Seagate3TBntfs and SEAGATE2TB drives" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
	SRC="/media/dad/homedata/Public/" # new source directory
	DEST1="$drive_Seagate3TBntfs"
	DEST1+="Public/" # first destination directory on drive_Seagate3TBntfs
	echo "line $LINENO - 1st destination: $DEST1"
	DEST2="$drive_Seagate2TB"
	echo "line $LINENO - 2nd destination: $DEST2"
	DEST2+="Public/" # second destination directory on SEAGATE2TB
	echo "line $LINENO - 2nd destination: $DEST2"
	# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

	# list and order of subdirecties.  Audio_Files is last since largest
	for i in Documents MAME Pictures Audio_Files
	do
		space_used=$( du -s "$SRC$i/" | awk '{ print $1 }')
		if [ "$space_used" -gt 6000000 ]; then
			# rsync to DEST1 using parallel_rsync function
			echo "line $LINENO - " "Passing $SRC$i $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
			echo "line $LINENO - " "Passing $SRC$i $DEST1$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
			parallel_rsync "$SRC$i" "$DEST1$i"
			# to destination 2 using parallel_rsync function
			echo "line $LINENO - " "Passing $SRC$i $DEST2$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
			echo "line $LINENO - " "Passing $SRC$i $DEST2$i to function parallel_rsync" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
			parallel_rsync "$SRC$i" "$DEST2$i"
			# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

		else
			# rsync to DEST1 using rsync command
			echo "line $LINENO - " "rsync $rsync_options $SRC$i/ $DEST1$i/" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
			echo "line $LINENO - " "rsync $rsync_options $SRC$i/ $DEST1$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
		 	nohup rsync $rsync_options  "$SRC$i/" "$DEST1$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" &
			test_threads
			# to destination 2 using rsync command
			echo "line $LINENO - " "rsync $rsync_options $SRC$i/ $DEST2$i/" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
			echo "line $LINENO - " "rsync $rsync_options $SRC$i/ $DEST2$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
			nohup rsync $rsync_options "$SRC$i/" "$DEST2$i/"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" &
			test_threads
			# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

		fi
	done

#----------------------------------------------------------------------------#
# rsync Videos/MP4 from SEAGATE2TB to Seagate3TBntfs
	echo " $LINENO -----rsync Videos/MP4 from SEAGATE2TB to Seagate3TBntfs"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	echo " $LINENO -----rsync Videos/MP4 from SEAGATE2TB to Seagate3TBntfs"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
	SRC="$drive_Seagate2TB" # new source directory
	SRC+="Public/Videos/"
	DEST="$drive_Seagate3TBntfs"
	echo "line $LINENO - destination: $DEST"   2>&1 | /home/dad/Bash_Scripts/timestamp.sh
	echo "line $LINENO - destination: $DEST"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" started
	DEST+="Public/Videos/" # new destination directory
	echo "line $LINENO - destination: $DEST"   2>&1 | /home/dad/Bash_Scripts/timestamp.sh
	echo "line $LINENO - destination: $DEST"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" started
	echo "rsync $rsync_options $SRC $DEST" "( line $LINENO )" 2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
	echo "rsync $rsync_options $SRC $DEST" "( line $LINENO )"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
	 nohup rsync $rsync_options "$SRC" "$DEST"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG" 
	 # pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."

fi
# end of section for dad-ThinkCentre-A63
#----------------------------------------------------------------------------#
# log end of rsync script and exit
CURRTIME; echo "ended $MONTH/$DAY/$YEAR, $TIME.$NANO"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh 
echo "ended $MONTH/$DAY/$YEAR, $TIME.$NANO"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
echo "----------------------------------------------------------------------------"  2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
echo   2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
echo   2>&1 | /home/dad/Bash_Scripts/timestamp.sh >> "$BKLOG"
# pause_func "Paused at $LINENO . Press [Ctrl]+[C] to cancel or [Enter] key to continue..."
# exit
#----------------------------------------------------------------------------#
# end of script

