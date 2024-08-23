#!/bin/bash

# help if argument absent
if [ $# -ne 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

echo "WATCHING $1"

# setup watch
onchange -v -p 250 "./$1/*.asm" "./$1/src/*.asm" -- sh -c "echo compiling && dasm $1/main.asm -o$1/rom.nes -f3 -v2 -I$1 -s$1/romsym.txt && echo launching && cmd.exe /C start $1/rom.nes"
