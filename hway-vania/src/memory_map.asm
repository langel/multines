; zero page variables and other definitions


speed_hi       byte
speed_lo       byte
mph            byte
player_x       byte
player_y       byte ; screen y, the camera keeps the player here
; player world y, up the road is negative, camera_y = world - player_y
player_wy_lo   byte ; sub pixels
player_wy      byte
player_wy_hi   byte
whip_counter   byte
whip_frame     byte
helmet_type    byte

road_r_x         byte
road_l_x         byte
road_l_sine_hi   byte
road_l_sine_lo   byte
median_w         byte

; road row pipeline, see road_render.asm
road_row_advanced  byte ; 1 when a new nametable row started this frame
road_row_idx       byte ; nametable row 0..29 of the current row
road_row_nm        byte ; nametable parity of current row, 0 or 2
road_slot_wr       byte ; next tile slot to generate into, 0 or 2
road_slot_rd       byte ; next tile slot to upload, 0..3
road_pending       byte ; rows waiting for ppu upload

; pair being generated, kept while its stages run
pg_row             byte ; odd row of the pair
pg_nm              byte ; nametable parity, 0 or 2
pg_ring            byte ; ring index of the odd row
pg_cring           byte ; class ring row of the odd row

; class map ring row of the newest row, 0..37
road_class_ring    byte
cm_ptr_lo          byte ; pointer to a class map row, lo then hi
cm_ptr_hi          byte
road_gen_stage     byte ; 0 idle, 1 rows, 2 trees, 3 class map

; row being generated
rg_dst_lo          byte ; pointer to its tile row, lo then hi
rg_dst_hi          byte
rg_slot            byte ; tile slot
rg_row             byte ; nametable row
rg_ring            byte ; x offset ring index
rg_asphalt         byte ; 0 stripe row, non zero asphalt only row

; road x position of the row being generated
rp_r_coarse        byte
rp_r_fine          byte
rp_l_coarse        byte ; signed
rp_l_fine          byte

; row command, from the procedural default or a script
road_world_row_lo  byte ; rows generated so far
road_world_row_hi  byte
road_script_lo     byte ; script pointer lo then hi, hi 0 = procedural
road_script_hi     byte
rc_pos             byte ; right road left edge, pixels
rc_gap             byte ; pixels from right road back to left road
rc_flags           byte ; bit0 asphalt only, bit1 no trees, bit7 last script row
rg_flags_acc       byte ; flags of both rows of a pair
rc_width           byte ; road width in pixels, both roads
rc_div             byte ; divider stripes to draw, full lanes only

; lane schedule state, see road_render.asm
lane_step          byte ; offset of the current step in lane_schedule
lane_rows          byte ; rows left in the current hold or transition
lane_phase         byte ; 0 hold, 1 transition to the next step
lane_t             byte ; transition row, 1..13

player_is_dead       byte

; tree masks, 16 bits per pair, bit c = quadrant column c has a tree
; new = newest pair, prev = the pair being finalized, old = the one below
tm_new_lo          byte
tm_new_hi          byte
tm_prev_lo         byte
tm_prev_hi         byte
tm_old_lo          byte
tm_old_hi          byte
pg_has_prev        byte ; 1 when a finished pair waits to be finalized
fin_lo             byte ; working mask, lo then hi
fin_hi             byte
fin_in_lo          byte ; interior forest mask, kept for the corner pass
fin_in_hi          byte
fin_off            byte ; tile offset of the pair being finalized
fin_col            byte ; quadrant column

; rows generated above the visible top, must be even
road_lead_rows    eqm $06

; road rings, one entry per generated row, index 0..road_ring_rows-1
; the newest row is road_lead_rows above the visible top, so 40 rows cover
; the lead rows, 30 visible rows and 4 rows below the screen
; the whole $0500 page is tier 2 ent registers in the framework, unused here
; never call ent_despawn_2 or ent_z_despawn, they clear $0500-$05ff
; cleared in state_game_init
road_ring_rows    eqm 40
road_r_x_offset   eqm $0500 ; right road left edge, pixels
road_l_x_offset   eqm $0540 ; left road left edge, pixels, >= $c0 is off the left edge
road_w_ring       eqm $0580 ; road width, both roads

; traffic and player state, $05c0-$05ff
traffic_spawn_timer eqm $05c0 ; frames to the next spawn, 0 = try every frame
traffic_rot         eqm $05c1 ; update start index, rotates for sprite flicker
traffic_idx         eqm $05c2
traffic_count       eqm $05c3
traffic_oam_full    eqm $05c4 ; non zero once the sprite page wrapped this frame
player_lane_mask    eqm $05c5 ; right road lane bit under the player
player_last_x       eqm $05c6
player_lean         eqm $05c7
player_lean_timer   eqm $05c8
player_units        eqm $05c9 ; player speed, 1/32 px per frame
player_last_edge    eqm $05ca ; right road left edge under the bike last frame
player_trail        eqm $05cb ; lower sprite x offset from the torso
player_manual       eqm $05cc ; 0 until the first controller input, then the player drives

; car scratch, only valid during one car update
car_sy_lo           eqm $05d0 ; screen y of the car top
car_sy_hi           eqm $05d1
car_tx_lo           eqm $05d2 ; target x of the target lane
car_tx_hi           eqm $05d3
car_len_a           eqm $05d4 ; length of the car being updated
car_lanes           eqm $05d5 ; full lanes at the car's front row
car_gap             eqm $05d6 ; gap to the car ahead, $ff = none
car_gap_speed       eqm $05d7
car_cand            eqm $05d8
car_ring            eqm $05d9 ; ring index of the front row, $ff when not looked up this frame
car_chk_y_lo        eqm $05da ; box test input, see traffic_box_clear
car_chk_y_hi        eqm $05db
car_chk_len         eqm $05dc
car_chk_mask        eqm $05dd
car_chk_margin      eqm $05de
car_chk_self        eqm $05df
car_new_slot        eqm $05e0 ; spawn candidate
car_new_info        eqm $05e1
car_new_speed       eqm $05e2
car_new_lane        eqm $05e3
car_slope           eqm $05e4 ; road edge change over car_slope_rows rows
car_ideal           eqm $05e5 ; road offset of the sprite, 1/8 px
car_off_base        eqm $05ee ; (slot & 15) * 4, the car's entry in car_off_cache

; sprite x offsets kept between frames, 4 per traffic slot, top sprite first
; refreshed every 4th frame by car_offsets
car_off_cache       eqm $0120 ; to $015f
car_k               eqm $05e8 ; ring row of the top sprite, from the top of the ring
car_ref             eqm $05e9 ; road edge x at the leader's row
car_prev            eqm $05ea ; offset of the sprite just placed
car_want            eqm $05eb
car_j               eqm $05ec ; sprite index from the leader
car_seg             eqm $05ed ; sprite index from the top

; road row slots, 4 rows = current pair and previous pair
; $0600 is wiped by ents_clear, this game never calls it
road_tile_rows    eqm $0600 ; 4 x 32 tiles
road_attr_rows    eqm $0680 ; 4 x 8 attribute bytes
road_attr_band    eqm $06a0 ; 8 bytes, running attributes of the band
road_slot_tile_lo eqm $06a8 ; 4 ppu tile addresses
road_slot_tile_hi eqm $06ac
road_slot_attr_lo eqm $06b0 ; 4 ppu attribute addresses
road_slot_attr_hi eqm $06b4

; class map ring, 38 rows x 8 bytes, to the end of ram
; own ring index, road_class_ring, because it must cover the
; visible rows plus the lead rows: 31 + lead + 1 <= 38
; 2 bits per tile, first tile in the low bits
; 0 road, 1 dirt, 2 wall, 3 trip
; $06b8-$06cf road row scratch, $06c0-$06cf free
road_seg_buf      eqm $06b8 ; 8 tiles of one road row
road_class_rows   eqm 38
road_class_map    eqm $06d0
