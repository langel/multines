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
Multicart is 256kb UNROM or something like that

`cart_start` is at `$8000`

`nmi_handler` is in common upper bank

state controllers have 64 slots
`$8080` = low address
`$80c0` = high address
`$8100` = `state_init` subroutine
