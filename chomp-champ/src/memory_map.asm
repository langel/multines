; teeth ram
/*
	TEETH RAM

	16 teeth total
	8*8 tiles main tooth
	8*1 tiles gumline
	72 tiles total per tooth
	
	Tracking every tile requires over 1024 bytes of ram.

	we could track 2x2 tile blocks
	and show total tooth health in the gumline?
	16 blocks per tooth
	Tracking blocks requires 256 bytes of ram.
	Tracking gumline requires 64 bytes of ram.



*/
tooth_cell_dmg      eqm $600
tooth_total_dmg     eqm $700
tooth_needs_update  eqm $720
tooth_tile_cache    eqm $760

tooth_update_queue_size byte
tooth_index             byte

; xxx probably delete these
player_x_hi   byte
player_x      byte
player_x_lo   byte
player_y      byte
player_y_lo   byte

; collision detection
player_hit_x    byte
player_hit_y    byte
brush_hit_x     byte
brush_hit_y     byte

