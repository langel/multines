# NES Multicart Project
undetermined number of titles to be included

# Engine Structure (notes to self)

Individually games are 40k NROM-256/AxROM ROMs
Multicart is 256kb UNROM / AxROM anti-mirror mutant.

# MultiCart Mapper

The plan is to have shared code between titles in the fixed upper 16kb bank of PRG. When loading a title the graphics will be copied from PRG ROM to CHR RAM and the bankable lower 16kb of PRG then selected. All vectors must maintain same addresses across banks meaning the fixed upper bank routes everything to the lower bank.

### PRG Banks
Handled in the UNROM (or UOROM) tradition. Each 16kb bank could hold a full graphical pattern set for 2 separate titles. Repeated (shared) graphical patterns between titles could be stored in a single position to save space. 10 titles plus the multicart menu should easily fit on a 256kb ROM.

### CHR Banks
No plans for graphical bank switching on this project. The cheapest SRAM chips are 32kb in size. Despite this extra space, replacing the NES's internal CIRAM for additional nametable space is not necessary.

### Mirroring
While most games are NROM with H or V mirroring, AxROM style single screen mirroring will also be available. Using a 74xx377 octal latch chip could allow for control of both PRG and nametable mirroring. The octal latch could drive a 74HC4066 quad bilateral switch to control CIRAM flow. Regardless, the final multicart needs to allow for four modes.

## Potential Mapper Register Spec
Write to $8000
```
7  bit  0
---- ----
HVRL PPPP
|||| ||||
|||| ++++- Select lower PRG 16k bank
|||+------ Single nametable $2000
||+------- Single nametalbe $2400
|+-------- Vertical mirroring
+--------- Horizontal mirroring
```

## For Review
...these are old notes. not sure why these addresses start at $8000 when the upper bank will be fixed and starts at $C000

`cart_start` is at `$8000`

`nmi_handler` is in common upper bank

state controllers have 64 slots
`$8080` = low address
`$80c0` = high address
`$8100` = `state_init` subroutine

## Bus Conflicts
More research is required to make sure bus conflicts are not an issue in both emulation and hardware.
