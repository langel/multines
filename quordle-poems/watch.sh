#!/bin/bash
onchange -v -p 250 './*.asm' -- sh -c 'echo compiling && dasm quordle.asm -Ibin -Ichr -orom.nes -f3 -v2 -llisting.txt && echo launching && cmd.exe /C start rom.nes'
# dasm -sromsym.txt will export symbol file
