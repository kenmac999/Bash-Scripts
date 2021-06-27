#!/bin/bash
#----------------------------------------------------------------------------#
# File: bu_Money.sh
# Last Update: Sun 07 Mar 2021 01:03:19 PM CST 
# Purpose: Backup compressed money.tar.gz file and keepassXC databases to google
# drive using rclone. Also backs up to other local hard drive(s)
#----------------------------------------------------------------------------#
# include $HOME/Bash_Scripts/my_functions.sh
. $HOME/Bash_Scripts/my_functions.sh
#################################################
# begin your script after this point
#################################################

CURRDATE; CURRTIME; echo "started $MONTH/$DAY/$YEAR, $TIME.$NANO" 

echo
echo
echo "--- Compressing Money directory into Money.zip ---"

# change directory to /home/dad/Documents
cd /home/dad/Documents

#now to compress MONEY/ directory and its subdirectories into tar file since smaller size
# zip -ruTv MONEY.zip MONEY 
tar -cvzf MONEY.tar.gz MONEY

GOOGLEDRIVE # call function to mount googledrive
if [ ! -d "$googledrive" ] ; then
	echo "Google drive not mounted.  Mounting..."
	GOOGLEDRIVE
fi

# now to syncing with Google Drive
# echo "cp -v MONEY.zip /home/dad/googledrive/My Files/Documents/MONEY.zip"
# cp -v MONEY.zip "/home/dad/googledrive/My Files/Documents/MONEY.zip"
echo "rclone copy /home/dad/Documents/MONEY.tar.gz googledrive:"My Files"/Documents --progress"
rclone copy /home/dad/Documents/MONEY.tar.gz googledrive:"My Files"/Documents --progress

#syncs my keepass databases
echo "rclone copy /home/dad/Documents/MyKeePass2Data.kdbx googledrive:"My Files" --progress"
rclone copy /home/dad/Documents/MyKeePass2Data.kdbx googledrive:"My Files" --progress 
echo "rclone copy /home/dad/Documents/GooglePasswords.kdbx googledrive:"My Files" --progress"
rclone copy /home/dad/Documents/GooglePasswords.kdbx googledrive:"My Files" --progress 

GOOGLEDRIVE # call function to unmount googledrive

# also backup to homedata drive
echo "rsync -rtvu --modify-window=2 --progress  MONEY.tar.gz /media/dad/homedata/dad/Documents/MONEY.tar.gz"
rsync -rtvu --modify-window=2 --progress  MONEY.tar.gz "/media/dad/homedata/dad/Documents/MONEY.tar.gz"
echo "rsync -rtvu --modify-window=2 --progress '/home/dad/Documents/MyKeePass2Data.kdbx' '/media/dad/homedata/dad/Documents/MyKeePass2Data.kdbx'"
rsync -rtvu --modify-window=2 --progress '/home/dad/Documents/MyKeePass2Data.kdbx' '/media/dad/homedata/dad/Documents/MyKeePass2Data.kdbx' 
echo "rsync -rtvu --modify-window=2 --progress '/home/dad/Documents/GooglePasswords.kdbx' '/media/dad/homedata/dad/Documents/GooglePasswords.kdbx'"
rsync -rtvu --modify-window=2 --progress '/home/dad/Documents/MyKeePass2Data.kdbx' '/media/dad/homedata/dad/Documents/GooglePasswords.kdbx' 
CURRDATE; CURRTIME; echo "ended $MONTH/$DAY/$YEAR, $TIME.$NANO" 

