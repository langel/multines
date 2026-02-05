
; ent_r0 state
;	0 idle/standing
;	1 walking
;	2 brushing
;	3 flossing
;	4 dying/dead
; ent_r1 animation frame
; ent_r2 animation counter
; ent_r3 direction
; ent_r4 up/down dir
; ent_r5 ?brush cell_id?

player_speed    eqm #$01

ent_player_init: subroutine
	; player always anet slot 00
	ldx #$00
	lda #ent_player_id
	sta ent_type,x
	lda #$20
	sta player_x
	lda #$90
	sta player_y
	; player direction
	lda #$00
	sta ent_r0,x
	sta ent_r1,x
	sta ent_r2,x
	sta ent_r3,x
	; xxx testing
	lda #$02
	sta ent_r0,x
	lda #$ff
	sta ent_r3,x
	rts


ent_player_update: subroutine

	; run state updater
	lda ent_r0,x
	bne .not_state_0_update
	jmp player_state_0_update
.not_state_0_update
	cmp #$01
	bne .not_state_1_update
	jmp player_state_1_update
.not_state_1_update
	cmp #$02
	bne .not_state_2_update
	jmp player_state_2_update
.not_state_2_update
	cmp #$03
	bne .not_state_3_update
	jmp player_state_3_update
.not_state_3_update
	jmp player_state_4_update
player_state_update_return:

	; set z position
	lda player_y
	clc
	adc #$20
	ent_z_calc_sort_vals

	; calc tooth position
	; (player_x / 16) 
	; +
	; ((player_y / 16) * 32)
	lda ent_x_hi,x
	lsr
	lda ent_x,x
	ror
	sta temp00
	; check left/right dir
	lda ent_r3,x
	bmi .tooth_cell_left
.tooth_cell_right
	lda temp00
	clc
	adc #$10
	jmp .tooth_cell_dir_done
.tooth_cell_left
	lda temp00
	sec
	sbc #$08
.tooth_cell_dir_done
	shift_r 3
	sta temp00
	lda ent_y,x
	sec
	sbc #$37
	clc
	adc #$18
	shift_r 4
	shift_l 5
	clc
	adc temp00
	sta ent_r5,x ; cell_id
	sta temp01
	; check tooth is present
	tax
	lda tooth_cell2tooth,x
	tax
	lda tooth_total_dmg,x
	bmi .skip_tooth_clean
	; decrease tooth damage
	; but not less than 0
	ldx temp01
	lda $600,x
	;cmp #$0f
	beq .skip_tooth_clean
	dec $600,x
	; add tooth cell to update queue
	txa
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
	; log tooth change
.skip_tooth_clean
	ldx ent_slot

	jmp ent_z_update_return


ent_player_render:
	; run state updater
	lda ent_r0,x
	bne .not_state_0
	jmp player_state_0_render
.not_state_0
	cmp #$01
	bne .not_state_1
	jmp player_state_1_render
.not_state_1
	cmp #$02
	bne .not_state_2
	jmp player_state_2_render
.not_state_2
	cmp #$03
	bne .not_state_3
	jmp player_state_3_render
.not_state_3
	jmp player_state_4_render
player_state_render_return:

	jmp ent_z_render_return



player_walk_right_spr:
	hex 80 82 a0 a2
	hex 84 86 a4 a6
	hex 88 8a a8 aa
	hex 8c 8e ac ae
	hex 90 92 b0 b2
	hex 94 96 b4 b6

player_walk_left_spr:
	hex 82 80 a2 a0
	hex 86 84 a6 a4
	hex 8a 88 aa a8
	hex 8e 8c ae ac
	hex 92 90 b2 b0
	hex 96 94 b6 b4

player_brush_right_spr:
	hex c0 c2
	hex c4 c6
	hex c8 ca
	hex c4 c6

player_brush_left_spr:
	hex c2 c0
	hex c6 c4
	hex ca c8
	hex c6 c4

player_brush_x_offset:
	hex 04 05 06 05


; UPDATES BY STATE

	; idle / standing
player_state_0_update: subroutine
	jmp player_state_update_return

	; walking
player_state_1_update: subroutine
	; player direction
	lda ent_r3,x
	bmi .go_left
.go_right
	clc
	lda player_x
	adc #player_speed
	sta player_x
	sta ent_x,x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	sta ent_x_hi,x
	; check right boundary
	lda player_x_hi
	beq .go_done
	lda player_x
	cmp #$e0
	bcc .go_done
	lda #$ff
	sta ent_r3,x
.go_left
	sec
	lda player_x
	sbc #player_speed
	sta player_x
	sta ent_x,x
	lda player_x_hi
	sbc #$00
	sta player_x_hi
	sta ent_x_hi,x
	; check right boundary
	lda player_x_hi
	bne .go_done
	lda player_x
	cmp #$0e
	bcs .go_done
	lda #$00
	sta ent_r3,x
.go_done
	lda player_x
	sta ent_x,x
	; move up/down
	lda ent_r4,x
	bne .go_up
.go_down
	inc player_y
	inc ent_y,x
	jmp .updown_move_done
.go_up
	dec player_y
	dec ent_y,x
.updown_move_done
	lda player_y
	cmp #$36
	bcc .updown_reverse
	cmp #$ae
	bcc .updown_checked
.updown_reverse
	lda ent_r4,x
	eor #$01
	sta ent_r4,x
.updown_checked
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
	bne .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$06
	bne .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
	jmp player_state_update_return

	; brushing
player_state_2_update: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
	bne .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$04
	bne .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
	jmp player_state_update_return

	; flossing
player_state_3_update: subroutine
	jmp player_state_update_return

	; dying/dead
player_state_4_update: subroutine
	jmp player_state_update_return



; RENDERS BY STATE

	; idle / standing
player_state_0_render: subroutine
	lda player_x
	sec
	sbc scroll_x
	sta spr_x,y
	sta spr_x+8,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	lda player_y
	sta spr_y+0,y
	sta spr_y+4,y
	clc
	adc #$10
	sta spr_y+8,y
	sta spr_y+12,y
	; get direction
	lda ent_r3,x
	bpl .facing_right
	jmp .facing_left
.facing_right
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	lda #$80
	sta spr_p,y
	lda #$82
	sta spr_p+4,y
	lda #$e8
	sta spr_p+8,y
	lda #$ea
	sta spr_p+12,y
	jmp .facing_done
.facing_left
	lda #$40
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	lda #$82
	sta spr_p,y
	lda #$80
	sta spr_p+4,y
	lda #$ea
	sta spr_p+8,y
	lda #$e8
	sta spr_p+12,y
.facing_done
	tya
	clc
	adc #$10
	tay

	jmp player_state_render_return

	; walking
player_state_1_render: subroutine
	; get direction
	lda ent_r3,x
	bpl .walking_right
	jmp .walking_left
.walking_right
	lda ent_r1,x
	shift_l 2
	tax
	; sprite 0
	lda player_walk_right_spr,x
	sta spr_p,y
	lda #$00
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4
	; sprite 1
	inx
	lda player_walk_right_spr,x
	sta spr_p,y
	lda #$00
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	clc
	adc #$08
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4
	; sprite 2
	inx
	lda player_walk_right_spr,x
	sta spr_p,y
	lda #$00
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	lda player_y
	clc
	adc #$10
	sta spr_y,y
	inc_y 4
	; sprite 3
	inx
	lda player_walk_right_spr,x
	sta spr_p,y
	lda #$00
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	clc
	adc #$08
	sta spr_x,y
	lda player_y
	clc
	adc #$10
	sta spr_y,y
	inc_y 4
	jmp .walking_done
.walking_left
	lda ent_r1,x
	shift_l 2
	tax
	; sprite 0
	lda player_walk_left_spr,x
	sta spr_p,y
	lda #$40
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4
	; sprite 1
	inx
	lda player_walk_left_spr,x
	sta spr_p,y
	lda #$40
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	clc
	adc #$08
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4
	; sprite 2
	inx
	lda player_walk_left_spr,x
	sta spr_p,y
	lda #$40
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	lda player_y
	clc
	adc #$10
	sta spr_y,y
	inc_y 4
	; sprite 3
	inx
	lda player_walk_left_spr,x
	sta spr_p,y
	lda #$40
	sta spr_a,y
	sec
	lda player_x
	sbc scroll_x
	clc
	adc #$08
	sta spr_x,y
	lda player_y
	clc
	adc #$10
	sta spr_y,y
	inc_y 4
.walking_done
	jmp player_state_render_return

	; brushing
player_state_2_render: subroutine
	; get brush offset
	lda ent_r1,x
	tax
	lda player_brush_x_offset,x
	sta temp00
	ldx ent_slot
	lda ent_r3,x
	bpl .brush_offset_done
	lda #$f0
	sec
	sbc temp00
	sta temp00
.brush_offset_done
	; player x
	lda player_x
	sec
	sbc scroll_x
	sta spr_x,y
	sta spr_x+8,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	; brush x
	adc temp00
	sta spr_x+16,y
	clc
	adc #$08
	sta spr_x+20,y
	; player y
	lda player_y
	sta spr_y+0,y
	sta spr_y+4,y
	clc
	adc #$10
	sta spr_y+8,y
	sta spr_y+12,y
	; brush y
	adc #$f6
	sta spr_y+16,y
	sta spr_y+20,y
	; get anim spr offset
	lda ent_r1,x
	asl
	sta temp00
	; get direction
	lda ent_r3,x
	bpl .facing_right
	jmp .facing_left
.facing_right
	; player
	ldx temp00
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y ; brush
	sta spr_a+20,y
	lda player_brush_right_spr,x
	sta spr_p,y
	lda player_brush_right_spr+1,x
	sta spr_p+4,y
	lda #$e0
	sta spr_p+8,y
	lda #$e2
	sta spr_p+12,y
	; brush
	lda #$e4
	sta spr_p+16,y
	lda #$e6
	sta spr_p+20,y
	jmp .facing_done
.facing_left
	ldx temp00
	lda #$40
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y ; brush
	sta spr_a+20,y
	lda player_brush_left_spr,x
	sta spr_p,y
	lda player_brush_left_spr+1,x
	sta spr_p+4,y
	lda #$e2
	sta spr_p+8,y
	lda #$e0
	sta spr_p+12,y
	; brush
	lda #$e6
	sta spr_p+16,y
	lda #$e4
	sta spr_p+20,y
.facing_done
	ldx ent_slot
	tya
	clc
	adc #$18
	tay
	jmp player_state_render_return

	; flossing
player_state_3_render: subroutine
	jmp player_state_render_return

	; dying/dead
player_state_4_render: subroutine
	jmp player_state_render_return
