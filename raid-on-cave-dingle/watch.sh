#!/bin/bash
onchange -v -p 250 './*.asm' './states/*.asm' -- sh -c 'echo compiling && dasm raid-on-cave-dingle.asm -Iassets -orom.nes -f3 -v2 -sromsym.txt && echo launching && cmd.exe /C start rom.nes'
