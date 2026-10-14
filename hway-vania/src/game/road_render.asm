
; road row generator
; rows are made in pairs, odd nametable row first, then the even row above it
; a pair is one quadrant row, so trees and attributes line up
; 4 tile slots hold the current pair and the previous pair
; one row per frame goes to the ppu, see game_road_render
; speed is capped near 5 px per frame so a pair is queued at most every 2 frames

; right road left edge in tiles when the sine is at 0
road_right_base eqm $06

; road = 1 px border, lanes of 12 px, 1 px dividers, 1 px border
; width = 13 * lanes + 1
lane_pitch      eqm 13 ; px added by one lane, also transition rows
road_ref_width  eqm 40 ; 3 lanes, the left road gap is measured from this
lane_sched_len  eqm 12 ; bytes in lane_schedule

; width by lane count, index 0..4
lane_width_lut:
	hex 01 0e 1b 28 35

; steps: lanes, hold rows, transition rows to the next step
; the last step goes back to the first
; transition rows should stay 13, one px per row
lane_schedule:
	hex 02 40 0d
	hex 03 40 0d
	hex 04 40 0d
	hex 03 40 0d

; palette 3 bits per quadrant: tl tr bl br
quad_pal3_lut:
	hex 03 0c 30 c0

; tree tiles tl tr bl br, by neighbors
; index 0 none, 4 left, 8 below, 12 both, all the same until art exists
; the old tree_row_cache is gone, trees go straight into the tile rows
; new tree tile ids must be set to 2 in tile_class_lut
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
	; class ring row, 36 rows
	lda road_class_ring
	sec
	sbc #$01
	bcs .cring_store
	lda #road_class_rows-1
.cring_store
	sta road_class_ring
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
	lda road_class_ring
	sta pg_cring
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
	lda rc_width
	sta road_w_ring,y
	; right road then left road
	lda #$00
	sta temp05
	ldx rp_r_fine
	ldy rp_r_coarse
	jsr road_plot_road
	lda #$01
	sta temp05
	ldx rp_l_fine
	ldy rp_l_coarse
	jsr road_plot_road
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


; row command: rc_pos, rc_gap, rc_flags, rc_width, rc_div
; script rows are 4 bytes: pos, gap, flags, lanes
; lanes byte: bits 0-5 width in pixels, bits 6-7 dividers
; set road_script_lo/hi to start a script, hi 0 = procedural
road_row_command: subroutine
	lda road_script_hi
	beq .procedural
	jmp road_row_script
.procedural
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
	jmp road_lane_row


; width and dividers of the next row from lane_schedule
; hold rows, then transition rows one px each
road_lane_row: subroutine
	ldx lane_step
	lda lane_phase
	bne .transition
	; hold, full lanes
	lda lane_schedule,x
	tay
	lda lane_width_lut,y
	sta rc_width
	dey
	sty rc_div
	dec lane_rows
	bne .done
	; hold over, next row starts the transition
	lda #$01
	sta lane_phase
	lda #$00
	sta lane_t
	lda lane_schedule+2,x
	sta lane_rows
.done
	rts
.transition
	; temp00 lanes now, temp04 next step offset
	lda lane_schedule,x
	sta temp00
	txa
	clc
	adc #$03
	cmp #lane_sched_len
	bcc .have_next
	lda #$00
.have_next
	sta temp04
	; temp01 = t, clamped to one lane
	inc lane_t
	lda lane_t
	cmp #lane_pitch
	bcc .t_ok
	lda #lane_pitch
.t_ok
	sta temp01
	ldx temp04
	lda lane_schedule,x
	cmp temp00
	bcc .collapse
	; expanding, low = now, offset grows
	ldy temp00
	lda temp01
	jmp .width
.collapse
	; low = next, offset shrinks
	tay
	lda #lane_pitch
	sec
	sbc temp01
.width
	; y = low lanes, a = offset into the next lane
	sta temp02
	lda lane_width_lut,y
	clc
	adc temp02
	sta rc_width
	; dividers of low lanes, the new one only when the lane is whole
	dey
	lda temp02
	cmp #lane_pitch
	bne .div_set
	iny
.div_set
	sty rc_div
	dec lane_rows
	bne .done
	; transition over, next step holds
	lda temp04
	sta lane_step
	tax
	lda lane_schedule+1,x
	sta lane_rows
	lda #$00
	sta lane_phase
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
	iny
	lda (road_script_lo),y
	and #$3f
	sta rc_width
	lda (road_script_lo),y
	shift_r 6
	sta rc_div
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
	; left road right edge stays where it was at 3 lanes
	; so its left edge moves by the width difference
	lda rc_gap
	clc
	adc rc_width
	sec
	sbc #road_ref_width
	sta temp05
	and #$07
	sta temp07
	lda temp05
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


; one road into the tile row at rg_dst
; in: x = fine x 0..7, y = start column, may be offscreen
;     temp05 = 0 right road, dividers counted from its left edge
;              1 left road, dividers counted from its right edge
;     rc_width, rc_div, rg_asphalt
; tiles are built in road_seg_buf, then copied on screen only
road_plot_road: subroutine
	stx temp00 ; fine x
	sty temp01 ; start column
	; temp02 = last pixel, the right border
	txa
	clc
	adc rc_width
	sec
	sbc #$01
	sta temp02
	shift_r 3
	sta temp03 ; last tile
	; asphalt across the road
	tax
	lda #$02
.fill
	sta road_seg_buf,x
	dex
	bpl .fill
	; left border
	lda temp00
	clc
	adc #$10
	sta road_seg_buf
	; right border
	lda temp02
	and #$07
	clc
	adc #$18
	ldx temp03
	sta road_seg_buf,x
	; dividers only on stripe rows
	lda rg_asphalt
	bne .plot
	ldy rc_div
	beq .plot
	lda temp05
	bne .from_right
	lda temp00
	ldx #lane_pitch
	bne .div_start
.from_right
	lda temp02
	ldx #$100-lane_pitch
.div_start
	stx temp06 ; step
.div_loop
	clc
	adc temp06
	sta temp04
	shift_r 3
	tax
	lda temp04
	and #$07
	clc
	adc #$08
	sta road_seg_buf,x
	lda temp04
	dey
	bne .div_loop
.plot
	; copy to the row, columns past the screen are skipped
	ldx temp03
	inx
	stx temp04 ; tile count
	ldy temp01
	ldx #$00
.copy
	cpy #$20
	bcs .skip
	lda road_seg_buf,x
	sta (rg_dst_lo),y
.skip
	iny
	inx
	cpx temp04
	bne .copy
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


; class map rows of the pair
road_gen_class_pair: subroutine
	; temp05 = tile row offset, road_class_ptr clobbers x
	lda road_slot_wr
	shift_l 5
	sta temp05
	lda pg_cring
	jsr road_class_ptr
	ldx temp05
	jsr road_gen_class
	; x carries on into row b, which is one row newer
	stx temp05
	lda pg_cring
	sec
	sbc #$01
	bcs .b_ring
	lda #road_class_rows-1
.b_ring
	jsr road_class_ptr
	ldx temp05
	jmp road_gen_class


; cm_ptr = address of class map row a, 0..35
; clobbers x
road_class_ptr: subroutine
	ldx #>road_class_map
	cmp #$20
	bcc .first_page
	; rows 32..35 are on the next page
	sbc #$20
	inx
.first_page
	shift_l 3
	clc
	adc #<road_class_map
	sta cm_ptr_lo
	bcc .no_carry
	inx
.no_carry
	stx cm_ptr_hi
	rts


; packs one tile row into 8 class bytes at cm_ptr
; in: x = tile row offset
road_gen_class: subroutine
	lda #$00
	sta temp03
	lda #$08
	sta temp06
.byte_loop
	lda #$04
	sta temp02
.tile_loop
	lda road_tile_rows,x
	tay
	lda tile_class_lut,y
	tay
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
	sta (cm_ptr_lo),y
	inc temp03
	dec temp06
	bne .byte_loop
	rts

class_hi_lut:
	hex 00 40 80 c0

; tile_class_lut is in tile_class.asm


; in: a = class ring row 0..35 (like road_class_ring), x = tile column 0..31
; out: a = class 0..3, clobbers x y temp00
road_class_lookup: subroutine
	stx temp00
	jsr road_class_ptr
	lda temp00
	lsr
	lsr
	tay
	lda temp00
	and #$03
	tax
	lda (cm_ptr_lo),y
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


; in: a = screen x, y = screen y
; out: a = class 0..3, clobbers x y temp00..temp02
road_class_lookup_screen: subroutine
	; tile column
	shift_r 3
	sta temp01
	; rows below the generated edge
	lda scroll_y
	and #$07
	sta temp02
	tya
	clc
	adc temp02
	shift_r 3
	clc
	adc #road_lead_rows
	ldx temp02
	cpx #$07
	beq .phase_done
	clc
	adc #$01
.phase_done
	clc
	adc road_class_ring
	; wrap into 36 rows, the sum is under 72
	cmp #road_class_rows
	bcc .ring_ok
	sbc #road_class_rows
.ring_ok
	ldx temp01
	jmp road_class_lookup


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
	tay
	lda tile_class_lut,y
	cmp #$02
	bne .below_ok
	lda #$08
	sta temp07
.below_ok
	lda temp01
	beq .variant_done
	lda road_tile_rows-1,x
	tay
	lda tile_class_lut,y
	cmp #$02
	bne .variant_done
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
