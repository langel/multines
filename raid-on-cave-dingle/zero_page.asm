;;;;; VARIABLES

	seg.u ZEROPAGE
        org $0
        
wtf                    byte
nmi_lockout            byte
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
controls               byte
controls_d             byte
state_render_id        byte
state_update_id        byte
state_interq_id        byte
state_hook_init        byte
ppu_mask_emph          byte


wave_phase     byte ; might be vestigial
moon_phase     byte

scroll_x       byte
scroll_y       byte
scroll_ms 	   byte ; map screen
scroll_ns	   byte ; nametable select
cam_col_targ	byte ; camera column target
cam_col_offset	byte ; col right or left of screen
cam_direction	byte ; camera movement by pixel
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
map_coll_lo		byte
map_coll_hi		byte
map_coll_bank	byte
tile_addr_lo 	byte
tile_addr_hi 	byte
attr_addr_hi 	byte
attr_addr_lo 	byte
bg_anim_hi	   byte ; bg animation counter
bg_anim_lo	   byte

player_char	   byte
player_relic1	byte
player_relic2	byte
player_relic3	byte
player_hp      byte
player_mp      byte
player_x_hi    byte
player_x       byte
player_x_lo		byte
player_y       byte
player_y_lo		byte
player_lr		byte ; dir left or right
player_ud		byte ; dir up or down
player_ground	byte ; status: on ground
player_ladder  byte ; status: on ladder
player_hor_hi	byte ; horizontal velocity
player_hor_lo	byte
player_ver_hi	byte ; vertical velocity
player_ver_lo	byte

time_of_day    byte
time_of_day_hi	byte
time_of_day_lo	byte
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
