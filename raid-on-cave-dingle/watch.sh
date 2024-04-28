#!/bin/bash
onchange -v -p 250 './*.asm' './states/*.asm' -- sh -c 'echo compiling && dasm orange_island.asm -Ibin -Ichr -orom.nes -f3 -v2 -sromsym.txt && echo launching && cmd.exe /C start rom.nes'
