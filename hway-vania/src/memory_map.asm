; zero page variables and other definitions


speed_hi       byte
speed_lo       byte
mph            byte
scroll_y_lo    byte ; sub pixels

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
road_gen_stage     byte ; 0 idle, 1 rows, 2 trees, 3 class map

; row being generated
rg_dst_lo          byte ; pointer to its tile row, lo then hi
rg_dst_hi          byte
rg_slot            byte ; tile slot
rg_row             byte ; nametable row
rg_ring            byte ; x offset ring index
rg_asphalt         byte ; lut offset, 0 stripes or $30 asphalt

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

player_is_dead       byte


; rows generated above the visible top, must be even
road_lead_rows    eqm $04

; road x offset rings, 32 rows each, index 0..31 only
; stack page, not cleared at boot, cleared in state_game_init
; $0160 and up is shared audio state
road_r_x_offset   eqm $0120
road_l_x_offset   eqm $0140

; road row slots, 4 rows = current pair and previous pair
; $0600 is wiped by ents_clear, this game never calls it
; $0500 is ent framework ram, leave alone
road_tile_rows    eqm $0600 ; 4 x 32 tiles
road_attr_rows    eqm $0680 ; 4 x 8 attribute bytes
road_attr_band    eqm $06a0 ; 8 bytes, running attributes of the band
road_slot_tile_lo eqm $06a8 ; 4 ppu tile addresses
road_slot_tile_hi eqm $06ac
road_slot_attr_lo eqm $06b0 ; 4 ppu attribute addresses
road_slot_attr_hi eqm $06b4

; class map, 32 rows x 8 bytes, same ring index as the x offsets
; 2 bits per tile, first tile in the low bits
; 0 road, 1 dirt, 2 wall, 3 trip
road_class_map    eqm $0700
