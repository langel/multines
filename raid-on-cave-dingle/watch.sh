#!/bin/bash
onchange -v -p 250 './*.asm' './states/*.asm' -- sh -c 'echo compiling && ./build.sh && echo launching && cmd.exe /C start rom.nes'
