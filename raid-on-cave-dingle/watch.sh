#!/bin/bash
onchange -v -p 250 './*.asm' './src/*.asm' -- sh -c 'echo compiling && ./build.sh && echo launching && cmd.exe /C start rom.nes'
