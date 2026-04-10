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

ent_hitbox_x        eqm $500
ent_hitbox_y        eqm $520
ent_coll_w          eqm $540
ent_coll_h          eqm $560
ent_coll_x          eqm $580
ent_coll_y          eqm $5a0
ent_coll_visible    eqm $5c0

tooth_cell_dmg      eqm $600
tooth_total_dmg     eqm $700
tooth_needs_update  eqm $720
tooth_tile_cache    eqm $760
tooth_true_clean    eqm $780
tooth_hud_gone      eqm $7a0

game_level          eqm $1e0
continues           eqm $1e1
/*
hud_tooth_addr      eqm $1e2
hud_tooth_tile      eqm $1e3
*/

tooth_update_queue_size byte
tooth_index             byte
cell_sweep              byte

germ_attacked           byte
germ_attackee           byte
grub_converge_slot      byte

hud_tooth_addr          byte 
hud_tooth_tile          byte
hud_initted             byte
is_paused               byte

; used instead of ent registers
player_x_hi   byte
player_x      byte
player_x_lo   byte
player_y      byte
player_y_lo   byte

pl_vel_h_hi   byte
pl_vel_h_lo   byte
pl_vel_v_hi   byte
pl_vel_v_lo   byte

player_lives    byte
player_moving   byte
player_is_dead  byte
player_iframes  byte

floss_length    byte
floss_status    byte
; N bit = increasing or decreasing
; bit 6 = target locked
; bit 0 = floss animating

; collision detection
player_hit_x    byte
player_hit_y    byte
brush_hit_x     byte
brush_hit_y     byte
floss_hit_x     byte
floss_hit_y     byte


