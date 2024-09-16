#!/bin/bash

# help if argument absent
if [ $# -ne 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

count=$(ls -1q $1/exports/ | wc -l)
padding_length=4
padded_count=$(printf "%0${padding_length}d" "$count")
new_name="$1__$padded_count.nes"	
	
echo $new_name 
cp $1/rom.nes $1/exports/$new_name
