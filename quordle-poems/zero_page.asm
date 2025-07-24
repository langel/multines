;;;;; VARIABLES

	seg.u ZEROPAGE
	org $0
        
wtf                    byte
nmi_lockout            byte ; *
temp00                 byte
temp01                 byte
temp02                 byte
temp03                 byte
temp04                 byte
temp05                 byte
temp06                 byte
temp07                 byte
state00                byte
state01                byte
state02                byte
state03                byte
state04                byte
state05                byte
state06                byte
state07                byte
rng0                   byte
oam_disable            byte ; *
controls               byte
controls_d             byte
state_render_id        byte
state_update_id        byte
state_hook_init        byte
ppu_mask_emph          byte ; *

irq_ptr_lo             byte
irq_ptr_hi             byte


moon_phase     byte ; *

scroll_x       byte
scroll_y       byte
scroll_ms 	   byte ; map screen

hud_y_pos      byte
hud_y_next     byte

cam_x          byte
cam_ms         byte
cam_direction	byte ; * camera movement by pixel
                    ; positive = right	
                    ; negative = left

map_cur_id     byte ; current map id
map_cur_pos	   byte ; current map position
map_next_id	   byte ; for scene transitions
map_next_pos	byte
tileset_id     byte
map_cur_lo     byte ; map base addr lo
map_cur_hi     byte ; map base addr hi
map_ref_lo     byte ; map col addr lo
map_ref_hi     byte ; map col addr hi
map_ppu_lo     byte ; ppu col addr lo
map_ppu_hi     byte ; ppu col addr hi
map_attr_lo 	byte
map_attr_hi 	byte
map_coll_bank	byte ; *
tile_addr_lo 	byte
tile_addr_hi 	byte
attr_addr_lo 	byte
attr_addr_hi 	byte
bg1_anim_lo	   byte
bg1_anim_hi	   byte ; bg animation counter
bg2_anim_lo	   byte
bg2_anim_hi	   byte ; bg animation counter

player_char	   byte
player_relic1	byte
player_relic2	byte
player_relic3	byte
player_relic_e byte ; relic equipped
player_level   byte
player_leveld  byte ; double
player_levelh  byte ; half
player_hit     byte
player_hp      byte
player_mp      byte
player_hunger  byte
player_sleep   byte
player_damage  byte
player_gold_hi byte
player_gold_lo byte
player_x_abs   byte ; screen pos
player_x_hi    byte ; scene screen
player_x       byte ; integer
player_x_lo		byte ; decimal
player_y       byte ; integer
player_y_lo		byte ; decimal

player_status  byte 
player_dir     byte

player_hor_hi	byte ; horizontal velocity
player_hor_lo	byte
player_ver_hi	byte ; vertical velocity
player_ver_lo	byte
player_bank    byte ; base chr bank
player_hunslep byte ; counter for both
player_iframes byte

relic_equipped  byte

arcus_orbit_hi  byte
arcus_orbit_lo  byte
arcus_anim_hi   byte
arcus_anim_lo   byte
arcus_coll_x    byte
arcus_coll_y    byte
claw_coll_x     byte
claw_length     byte
claw_status     byte 
parasol_render  byte
saddle_riding   byte ; ent id

water_level     byte
bubble_timer    byte
screen_shake    byte
ent_drop_rng    byte

missile_x       byte
missile_x_lo    byte
missile_y       byte
missile_y_lo    byte
missile_dir     byte
missile_vel_hi  byte
missile_vel_lo  byte
missile_range   byte ; countdown to 0
missile_timer   byte ; misc uses
missile_step    byte ; animation counter?
missile_r0      byte
missile_r1      byte

woosh_ent_slot  byte
woosh_damage    byte

ent_slot            byte
ent_slot_start      byte
ent_spr_ptr         byte
ent_visible         byte ; *
ent_spawn_rts_bank  byte

time_of_day    byte ; *
time_of_day_hi	byte ; *
time_of_day_lo	byte ; *
palset_addr_lo	byte
palset_addr_hi	byte


collision_0_x	byte
collision_0_y	byte
collision_0_w	byte
collision_0_h	byte
collision_1_x	byte
collision_1_y	byte
collision_1_w	byte
collision_1_h	byte
collis_char_x  byte
collis_char_y  byte

arctang_velocity_lo  byte ; *
arctang_velocity_hi  byte ; *

rng_seed0  byte
rng_seed1  byte
rng_val0   byte
rng_val1   byte


	org $0400
ent_type  byte
	org $0420
ent_spawn byte
	org $0440
ent_x_hi  byte
	org $0460
ent_x     byte
	org $0480
ent_x_lo  byte
	org $04a0
ent_y     byte
	org $04c0
ent_y_lo  byte
	org $04e0
ent_h     byte
	org $0500
ent_h_lo  byte
	org $0520
ent_v     byte
	org $0540
ent_v_lo  byte
	org $0560
ent_dir   byte
	org $0580
ent_hp    byte
	org $05a0
ent_dmg   byte
	org $05c0
ent_hit   byte
	org $05e0
ent_r0    byte
	org $0600
ent_r1    byte
	org $0620
ent_r2    byte
	org $0640
ent_r3    byte
	org $0660
ent_r4    byte
	org $0680
ent_r5    byte
	org $06a0
ent_r6    byte
	org $06c0
ent_r7    byte
	org $06e0
ent_r8    byte
