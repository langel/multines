# NES Multicart Project
undetermined number of titles to be included

### Raid on Cave Dingle
clone/glowup of VIC20 Raid on Fort Knox

### Seven Eyes
platforming inspired by Apple2 Black Magic

### ???
twin-stick key/door action inspired by VIC20 Shamus

### GunTneR (demo)
an easy win!

### Chomp Champ
clone/glowup of VIC20 Tooth Invaders

### Quick Betty
single screen collect and advance Fast Eddie clone

### SKORB
4 single screens looped Gorf clone

### Ape King
4 screens Jungle Hunt/King clone

### Lemonade 2
4 generations of lemonade stands

### See Saw (or Teeter Totter)
circus/clowns clone - left/right speed controlled with buttons

other possible games to consider for glowups/inspirations: moon patrol, megamania (vcs), super bunny, lords of conquest, cities of gold, blue meanies, scare city motel, electrician (fds), hotdog stand (flash), simon, dragon fire, solar fox, cauldron, cauldron ii, frog bog, fast food

# Engine Structure (notes to self)

Individually games are 40k NROM-256 ROMs
Multicart is 256kb UNROM / GTROM hybrid plus mirroring register

`cart_start` is at `$8000`

`nmi_handler` is in common upper bank

state controllers have 64 slots
`$8080` = low address
`$80c0` = high address
`$8100` = `state_init` subroutine

# MultiCart Mapper

The plan is to have shared code between titles in the fixed upper 16kb bank of PRG. When loading a title the graphics will be copied from PRG ROM to CHR RAM and the bankable lower 16kb of PRG then selected. All vectors must maintain same addresses across banks.

### PRG Banks
Handled in the UNROM (or UOROM) tradition. Each 16kb bank could hold a full graphical pattern set for 2 separate titles. Repeated (shared) graphical patterns between titles could be stored in a single position to save space. 10 titles plus the multicart menu should easily fit on a 256kb ROM.

### CHR Banks
No plans for graphical bank switching on this project. The cheapest SRAM chips are 32kb in size. This leaves the full four nametables open if SRAM is schematically made available. Advanced mapper mirroring might not be necessary given any title could scroll in any direction.

### Mirroring
Would be nice to have control over mirroring. This could be achieved using an additional 74HC161 quad latch driving a 74HC4066 quad bilateral switch. Would only need 2 of those 4 channels, but would enable the options of horizontal mirror, vertical mirror, and single screen.
