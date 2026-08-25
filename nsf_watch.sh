#!/bin/bash

# help if argument absent
if [ $# -ne 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

echo "WATCHING $1"

# setup watch
onchange -v -p 250 "./$1/nsf.asm" -- sh -c "echo nsf compiling && dasm $1/nsf.asm -I$1 -o$1/rom.nsf -f3 -v2 "
# && echo launching && cmd.exe /C start $1/rom.nes"
# https://www.npmjs.com/package/onchange
