#!/bin/bash
#for testing functions, loops or other code
clear #screen
echo
echo
echo "--- Start of Script ---"

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

