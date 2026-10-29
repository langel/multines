; zero page variables and other definitions


speed_hi       byte
speed_lo       byte
mph            byte
scroll_y_lo    byte ; sub pixels
player_x       byte
player_y       byte
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

; road x offset rings, 32 rows each, index 0..31 only
; stack page, not cleared at boot, cleared in state_game_init
; $0160 and up is shared audio state
road_r_x_offset   eqm $0120
road_l_x_offset   eqm $0140

; road width per row, 32, same index as the x offsets
; $0500-$051f is ent_r500, the first tier 2 entity register
; claimed here, ent_despawn_2 clears ent_r500,x so do not despawn tier 2 ents
road_w_ring       eqm $0500

; road row slots, 4 rows = current pair and previous pair
; $0600 is wiped by ents_clear, this game never calls it
; $0500 is ent framework ram, only $0500-$051f is claimed, see road_w_ring
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
