#!/bin/bash

# Designed for Memory analysis!
# Ensure Python 2 is set up
# Ensure that you have Volatility 2 installed and configured in the set directory.
# Ensure that in image_info variable, you have set the correct File Path of volatility 2
# Ensure that after you input the raw memory file, avoid pressing "Enter" as read function will register this as an input entry and will create an error
# This code is used for the sole purpose of education
# Created at 06/19/2024 by @bsail

echo ' [+] Creating Directory vol2_text'


mkdir -p ~/Documents/vol2_text

#Create Volatility Imageinfo, include (Volatility2 - Location - Raw Image location - command - imageinfo)

echo ' [+] Please Enter raw memory file: '
read raw_filename 
image_info=$(python2 ~/Documents/vol2/vol.py -f $raw_filename imageinfo  2>/dev/null > imageinfo.txt)

echo ' [+]  Grab suggested profile'
cat imageinfo.txt | grep "Suggested Profile(s)" 

#Enter memory profile


echo ' [+] Please Eneter memory Profile to be used: '
read profile_name



# Run the pslist command with the provided profile
echo " [+] Running pslist with profile $profile_name on $raw_filename..."

python2 ~/Documents/vol2/vol.py -f $raw_filename --profile=$profile_name pslist > ~/Documents/vol2_text/vol2_pslist
python2 ~/Documents/vol2/vol.py -f $raw_filename --profile=$profile_name pstree > ~/Documents/vol2_text/vol2_pstree
python2 ~/Documents/vol2/vol.py -f $raw_filename --profile=$profile_name malfind > ~/Documents/vol2_text/vol2_malfind
python2 ~/Documents/vol2/vol.py -f $raw_filename --profile=$profile_name svcscan > ~/Documents/vol2_text/vol2_svcscan
python2 ~/Documents/vol2/vol.py -f $raw_filename --profile=$profile_name netscan > ~/Documents/vol2_text/vol2_netscan



echo ' [+] Please check the directory vol2_text to review the text files'
echo ' [+] Best of luck on your hunt!'
