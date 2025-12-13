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
tooth_cell_dmg    eqm $6ee
tooth_total_dmg   eqm $7ee


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

; tooth health top row
tooth_health_0  byte
tooth_health_1  byte
tooth_health_2  byte
tooth_health_3  byte
tooth_health_4  byte
tooth_health_5  byte
tooth_health_6  byte
tooth_health_7  byte
; tooth health bottom row
tooth_health_8  byte
tooth_health_9  byte
tooth_health_a  byte
tooth_health_b  byte
tooth_health_c  byte
tooth_health_d  byte
tooth_health_e  byte
tooth_health_f  byte
