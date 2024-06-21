#!/bin/bash

# Designed for Memory analysis!
# Ensure Python 2 is set up
# Ensure that you have Volatility 2 installed and configured in the set directory.
# Ensure that in image_info variable, you have set the correct File Path of volatility 2
# Ensure that after you input the raw memory file, avoid pressing "Enter" as read function will register this as an input entry and will create an error
# This code is used for the sole purpose of education
# Created at 06/19/2024 by @bsail

echo ' [+] Creating Directory vol2_text'
echo ' [+] '
echo ' [+] '
echo ' [+] '

# Prompt for the directory path
echo ' [+] Directory path you would like to use:'
read dir_path

# Create the directory
mkdir -p "$dir_path/vol2_text"

# Prompt for the raw memory file
echo ' [+] Please enter raw memory file: '
read raw_filename

# Check if the raw memory file exists
if [ ! -f "$raw_filename" ]; then
    echo " [!] Error: File '$raw_filename' not found!"
    exit 1
fi

# Run Volatility imageinfo
python2 ~/Documents/vol2/vol.py -f "$raw_filename" imageinfo 2>/dev/null > "$dir_path/vol2_text/imageinfo.txt"

echo ' [+] Grab suggested profile'
grep "Suggested Profile(s)" "$dir_path/vol2_text/imageinfo.txt"

# Prompt for the memory profile
echo ' [+] Please enter memory profile to be used: '
read profile_name

# Run Volatility commands with the provided profile
echo " [+] Running Volatility 2 with profile $profile_name on $raw_filename, saving to $dir_path/vol2_text..."

python2 ~/Documents/vol2/vol.py -f "$raw_filename" --profile="$profile_name" pslist > "$dir_path/vol2_text/pslist"
python2 ~/Documents/vol2/vol.py -f "$raw_filename" --profile="$profile_name" pstree > "$dir_path/vol2_text/pstree"
python2 ~/Documents/vol2/vol.py -f "$raw_filename" --profile="$profile_name" malfind > "$dir_path/vol2_text/malfind"
python2 ~/Documents/vol2/vol.py -f "$raw_filename" --profile="$profile_name" svcscan > "$dir_path/vol2_text/svcscan"
python2 ~/Documents/vol2/vol.py -f "$raw_filename" --profile="$profile_name" netscan > "$dir_path/vol2_text/netscan"

echo ' [+] Please check the directory vol2_text to review the text files'
echo ' [+] Best of luck on your hunt!'
