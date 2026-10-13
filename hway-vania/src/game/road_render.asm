
; road row generator
; rows are made in pairs, odd nametable row first, then the even row above it
; a pair is one quadrant row, so trees and attributes line up
; 4 tile slots hold the current pair and the previous pair
; one row per frame goes to the ppu, see game_road_render
; speed is capped near 5 px per frame so a pair is queued at most every 2 frames

; right road left edge in tiles when the sine is at 0
road_right_base eqm $06

road_3lanes_stripes:
	hex 10 0d 02 0a 1f 00
	hex 11 0e 02 0b 02 18
	hex 12 0f 02 0c 02 19
	hex 13 02 08 0d 02 1a
	hex 14 02 09 0e 02 1b
	hex 15 02 0a 0f 02 1c
	hex 16 02 0b 02 08 1d
	hex 17 02 0c 02 09 1e
; asphalt must follow stripes, offset is 48
road_3lanes_asphalt:
	hex 10 02 02 02 1f 00
	hex 11 02 02 02 02 18
	hex 12 02 02 02 02 19
	hex 13 02 02 02 02 1a
	hex 14 02 02 02 02 1b
	hex 15 02 02 02 02 1c
	hex 16 02 02 02 02 1d
	hex 17 02 02 02 02 1e

road_phase_offset_lut:
	hex 00 06 0c 12 18 1e 24 2a

; palette 3 bits per quadrant: tl tr bl br
quad_pal3_lut:
	hex 03 0c 30 c0

; tree tiles tl tr bl br, by neighbors
; index 0 none, 4 left, 8 below, 12 both, all the same until art exists
; the old tree_row_cache is gone, trees go straight into the tile rows
tree_tiles_lut:
	hex 26 27 36 37
	hex 46 47 56 57
	hex 46 47 56 57
	hex 46 47 56 57


; called every frame after scroll
game_road_prerender: subroutine
	jsr road_row_detect
	lda road_row_advanced
	beq .step
	lda state02
	sec
	sbc #$01
	and #$1f
	sta state02
	; odd row starts a pair, even row is already made
	lda road_row_idx
	lsr
	bcc .step
	; finish the last pair first if it is still running
	jsr road_gen_flush
	lda road_row_idx
	sta pg_row
	lda road_row_nm
	sta pg_nm
	lda state02
	sta pg_ring
	lda #$01
	sta road_gen_stage
.step
	jmp road_gen_step


; sets road_row_advanced, road_row_idx, road_row_nm, state01
road_row_detect: subroutine
	sec
	lda scroll_y
	sbc #$07
	php
	bcs .y_within_screen
	sbc #$10
.y_within_screen
	and #$f8
	sta temp00
	ldx #$00
	stx road_row_advanced
	cmp state01
	beq .same_row
	inc road_row_advanced
	sta state01
.same_row
	; row index and nametable of the row
	lda temp00
	shift_r 3
	sta road_row_idx
	plp
	lda #$00
	bcs .nm_same
	; borrow, row is in the other nametable
	lda #$02
	; row 29 of the other nametable
	ldx #$1d
	stx road_row_idx
.nm_same
	eor scroll_nm
	and #$02
	sta road_row_nm
	; generate road_lead_rows above the visible top
	lda road_row_idx
	sec
	sbc #road_lead_rows
	bcs .lead_ok
	adc #$1e
	sta road_row_idx
	lda road_row_nm
	eor #$02
	sta road_row_nm
	rts
.lead_ok
	sta road_row_idx
	rts


; a pair takes 3 frames, one stage per frame
; stage 1 rows, stage 2 trees and attributes, stage 3 class map and queue
road_gen_step: subroutine
	lda road_gen_stage
	beq .done
	cmp #$01
	beq .rows
	cmp #$02
	beq .quads
	jsr road_gen_class_pair
	; queue both rows and flip the pair slot
	lda road_slot_wr
	eor #$02
	sta road_slot_wr
	inc road_pending
	inc road_pending
	lda #$00
	sta road_gen_stage
	rts
.rows
	jsr road_gen_rows
	lda #$02
	sta road_gen_stage
	rts
.quads
	jsr road_gen_quads
	lda #$03
	sta road_gen_stage
.done
	rts


; runs the remaining stages now
road_gen_flush: subroutine
	lda road_gen_stage
	beq .done
	jsr road_gen_step
	jmp road_gen_flush
.done
	rts


; both rows of a pair, odd row first, then the row above it
road_gen_rows: subroutine
	lda #$00
	sta rg_flags_acc
	lda road_slot_wr
	sta rg_slot
	lda pg_row
	sta rg_row
	lda pg_ring
	sta rg_ring
	jsr road_gen_row
	lda road_slot_wr
	clc
	adc #$01
	sta rg_slot
	dec rg_row
	lda pg_ring
	sec
	sbc #$01
	and #$1f
	sta rg_ring
	jmp road_gen_row


; in: rg_slot, rg_row, rg_ring, pg_nm
road_gen_row: subroutine
	jsr road_row_advance
	jsr road_row_params
	; stripes when (row + nm) & 3 == 0
	lda rg_row
	clc
	adc pg_nm
	and #$03
	beq .stripes
	lda #$30
	bne .set_lut
.stripes
	lda #$00
.set_lut
	sta rg_asphalt
	; flags: bit0 asphalt only, bit1 no trees
	lda rc_flags
	ora rg_flags_acc
	sta rg_flags_acc
	lda rc_flags
	and #$01
	beq .flags_done
	lda #$30
	sta rg_asphalt
.flags_done
	; tile row pointer
	lda rg_slot
	shift_l 5
	sta rg_dst_lo
	lda #$06
	sta rg_dst_hi
	; dirt
	lda #$00
	ldy #$1f
.dirt_loop
	sta (rg_dst_lo),y
	dey
	bpl .dirt_loop
	; x offset ring entries
	lda rp_r_coarse
	shift_l 3
	clc
	adc rp_r_fine
	sta road_r_x
	ldy rg_ring
	sta road_r_x_offset,y
	lda rp_l_coarse
	shift_l 3
	clc
	adc rp_l_fine
	sta road_l_x
	sta road_l_x_offset,y
	; right road then left road
	ldx rp_r_fine
	lda road_phase_offset_lut,x
	clc
	adc rg_asphalt
	tax
	ldy rp_r_coarse
	jsr road_plot_segment
	ldx rp_l_fine
	lda road_phase_offset_lut,x
	clc
	adc rg_asphalt
	tax
	ldy rp_l_coarse
	jsr road_plot_segment
	jmp road_set_slot_ptrs


; ppu addresses of the row in rg_slot
road_set_slot_ptrs: subroutine
	ldx rg_slot
	; $20 or $28
	lda pg_nm
	shift_l 2
	clc
	adc #$20
	sta temp00
	lda rg_row
	shift_r 3
	clc
	adc temp00
	sta road_slot_tile_hi,x
	lda rg_row
	shift_l 5
	sta road_slot_tile_lo,x
	; attributes $23c0 or $2bc0, 8 bytes per 4 rows
	lda temp00
	clc
	adc #$03
	sta road_slot_attr_hi,x
	lda rg_row
	and #$1c
	asl
	clc
	adc #$c0
	sta road_slot_attr_lo,x
	rts


road_row_advance: subroutine
	inc road_world_row_lo
	bne .counted
	inc road_world_row_hi
.counted
	clc
	lda road_l_sine_lo
	adc #$63
	sta road_l_sine_lo
	lda road_l_sine_hi
	adc #$00
	sta road_l_sine_hi
	rts


; row command: rc_pos, rc_gap, rc_flags
; script rows are 4 bytes: pos, gap, flags, spare
; set road_script_lo/hi to start a script, hi 0 = procedural
road_row_command: subroutine
	lda road_script_hi
	bne road_row_script
	; procedural default, right road from the world row
	ldx road_world_row_lo
	lda sine_table,x
	shift_r 1
	clc
	adc #road_right_base*8
	sta rc_pos
	; left road gap from its own sine
	ldx road_l_sine_hi
	lda sine_table,x
	shift_r 3
	clc
	adc #$30
	sta rc_gap
	lda #$00
	sta rc_flags
	rts


road_row_script: subroutine
	ldy #$00
	lda (road_script_lo),y
	sta rc_pos
	iny
	lda (road_script_lo),y
	sta rc_gap
	iny
	lda (road_script_lo),y
	sta rc_flags
	clc
	lda road_script_lo
	adc #$04
	sta road_script_lo
	bcc .no_carry
	inc road_script_hi
.no_carry
	; bit 7 ends the script after this row
	lda rc_flags
	bpl .done
	lda #$00
	sta road_script_hi
.done
	rts


; pixel positions to coarse and fine, left road = right road minus gap
road_row_params: subroutine
	jsr road_row_command
	lda rc_pos
	and #$07
	sta rp_r_fine
	lda rc_pos
	shift_r 3
	sta rp_r_coarse
	lda rc_gap
	and #$07
	sta temp07
	lda rc_gap
	shift_r 3
	sta temp06
	; subtract gap, carry passes from fine to coarse
	lda rp_r_fine
	sec
	sbc temp07
	and #$07
	sta rp_l_fine
	lda rp_r_coarse
	sbc temp06
	sta rp_l_coarse
	rts


; in: x = lut index, y = start column, may be offscreen
road_plot_segment: subroutine
	lda #$06
	sta temp04
.loop
	cpy #$20
	bcs .skip
	lda road_3lanes_stripes,x
	sta (rg_dst_lo),y
.skip
	inx
	iny
	dec temp04
	bne .loop
	rts


; trees and attributes for the pair in road_slot_wr
; row a is the lower row at slot wr, row b the upper row at slot wr + 1
road_gen_quads: subroutine
	; new attr band at row 29 or row & 3 == 3
	lda pg_row
	cmp #$1d
	beq .band_clear
	and #$03
	cmp #$03
	bne .band_keep
.band_clear
	lda #$00
	ldx #$07
.band_clear_loop
	sta road_attr_band,x
	dex
	bpl .band_clear_loop
.band_keep
	; temp05 = quadrant row half, 0 top or 2 bottom
	lda pg_row
	and #$02
	sta temp05
	; temp00 = tile offset of row a, temp01 = quadrant column
	lda road_slot_wr
	shift_l 5
	sta temp00
	lda #$00
	sta temp01
.quad_loop
	jsr road_try_tree
	inc temp01
	lda temp01
	cmp #$10
	bne .quad_loop
	; snapshot band attributes for both rows
	lda road_slot_wr
	shift_l 3
	tax
	ldy #$00
.snap_loop
	lda road_attr_band,y
	sta road_attr_rows,x
	sta road_attr_rows+8,x
	inx
	iny
	cpy #$08
	bne .snap_loop
	rts


; class map rows, ring index * 8
road_gen_class_pair: subroutine
	lda road_slot_wr
	shift_l 5
	tax
	lda pg_ring
	shift_l 3
	sta temp03
	jsr road_gen_class
	; x carries on into row b
	lda pg_ring
	sec
	sbc #$01
	and #$1f
	shift_l 3
	sta temp03
	jmp road_gen_class


; packs one tile row into 8 class bytes
; in: x = tile row offset, temp03 = class map offset
road_gen_class: subroutine
	lda #$08
	sta temp06
.byte_loop
	lda #$04
	sta temp02
.tile_loop
	lda road_tile_rows,x
	beq .dirt
	cmp #$46
	bcs .wall
	ldy #$00
	beq .have_class
.dirt
	ldy #$01
	bne .have_class
.wall
	ldy #$02
.have_class
	lda temp04
	lsr
	lsr
	ora class_hi_lut,y
	sta temp04
	inx
	dec temp02
	bne .tile_loop
	ldy temp03
	lda temp04
	sta road_class_map,y
	inc temp03
	dec temp06
	bne .byte_loop
	rts

class_hi_lut:
	hex 00 40 80 c0


; in: a = ring row 0..31 (like state02), x = tile column 0..31
; out: a = class 0..3, clobbers x y temp00
road_class_lookup: subroutine
	asl
	asl
	asl
	sta temp00
	txa
	lsr
	lsr
	ora temp00
	tay
	txa
	and #$03
	tax
	lda road_class_map,y
	cpx #$00
	beq .done
.shift_loop
	lsr
	lsr
	dex
	bne .shift_loop
.done
	and #$03
	rts


; 2x2 tree in quadrant temp01 when all 4 of its tiles are dirt
road_try_tree: subroutine
	; script flag bit1, no trees on this pair
	lda rg_flags_acc
	and #$02
	bne .done
	lda temp01
	asl
	clc
	adc temp00
	tax
	lda road_tile_rows,x
	ora road_tile_rows+1,x
	ora road_tile_rows+32,x
	ora road_tile_rows+33,x
	bne .done
	jmp road_place_tree
.done
	rts


; in: x = tile offset of the quadrant in row a, temp01 = quadrant column
road_place_tree: subroutine
	; variant: +8 tree below, +4 tree to the left
	lda #$00
	sta temp07
	txa
	eor #$40
	tay
	lda road_tile_rows+32,y
	cmp #$46
	bcc .below_ok
	lda #$08
	sta temp07
.below_ok
	lda temp01
	beq .variant_done
	lda road_tile_rows-1,x
	cmp #$46
	bcc .variant_done
	lda temp07
	ora #$04
	sta temp07
.variant_done
	ldy temp07
	lda tree_tiles_lut,y
	sta road_tile_rows+32,x
	lda tree_tiles_lut+1,y
	sta road_tile_rows+33,x
	lda tree_tiles_lut+2,y
	sta road_tile_rows,x
	lda tree_tiles_lut+3,y
	sta road_tile_rows+1,x
	; palette 3 for this quadrant only
	lda temp01
	and #$01
	ora temp05
	tay
	lda quad_pal3_lut,y
	sta temp02
	lda temp01
	lsr
	tay
	lda road_attr_band,y
	ora temp02
	sta road_attr_band,y
	rts


; one queued row per frame, 32 tiles and 8 attribute bytes
game_road_render: subroutine
	lda road_pending
	beq .done
	ldx road_slot_rd
	stx temp00
	lda road_slot_tile_hi,x
	sta PPU_ADDR
	lda road_slot_tile_lo,x
	sta PPU_ADDR
	txa
	shift_l 5
	tax
	ldy #$20
.tile_loop
	lda road_tile_rows,x
	sta PPU_DATA
	inx
	dey
	bne .tile_loop
	ldx temp00
	lda road_slot_attr_hi,x
	sta PPU_ADDR
	lda road_slot_attr_lo,x
	sta PPU_ADDR
	txa
	shift_l 3
	tax
	ldy #$08
.attr_loop
	lda road_attr_rows,x
	sta PPU_DATA
	inx
	dey
	bne .attr_loop
	lda road_slot_rd
	clc
	adc #$01
	and #$03
	sta road_slot_rd
	dec road_pending
.done
	rts
