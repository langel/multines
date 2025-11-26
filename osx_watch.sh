#!/bin/bash

# help if argument absent
if [ $# -ne 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

echo "WATCHING $1"

# setup watch
onchange -v -p 250 "./$1/**/*.asm" "./$1/**/*.chr" "./$1/**/*.bin" -- sh -c "echo compiling && dasm $1/main.asm -I$1 -o$1/rom.nes -f3 -v2 -l$1/listing.txt && echo reload in emulator"
# dasm -sromsym.txt will export symbol file
# https://www.npmjs.com/package/onchange
