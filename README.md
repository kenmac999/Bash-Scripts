# Bash-Scripts
repository containing Bash scripts I have written to automate daily work routines

This repository is created to share the various bash files I have written over the years to automate my workflow for various computer relataed activities.  Some are simple batch files to open a group of applications used for performing certain tasks. Some are used to create a graphical menu to select between different tasks to perform.  Others are to automate certain maintenance actions needed to maintain my computer system. Here is an alphabetical list of the files with their purpose(s)

  file name # function
	backupcronlog.sh  # Designed to backup current cron.log before beginning of new day
	bu_Money.sh       # Purpose: Backup compressed money.tar.gz file and keepassXC databases to google drive using rclone. Also backs up to other local hard drive(s)
	googledrive.sh    # dependant on google-drive-ocamlfuse to create mount point for accessing my google drive. alternates between creating or removing mount point.
	my_functions.sh   # a collection of various functions used regularly in my bash scripts.
	my_zenity-menu.sh # Dependant on my_functions.sh. Provides a zenity based GUI menu of common tasks, to include launching applications used for:
	                  # balancing checkbook or paying bills
										# backup my financial files
										# managing ebooks
										# Managing Audio files and editing MP3 tags
										# Rip Music from my vinyl records and CDs
rsyncdirectories.sh # Dependant on my_functions.sh.  Designed to syncronize certain directories between various internal and external drives.
timestamp.sh				# puts the date and time in front of any text piped to it. example: echo " hello goodby" | ./timestamp.sh
