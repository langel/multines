
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
; ent_r5 brush/floss target cell_id
; ent_r6 z sort up
; ent_r7 z sort down

player_speed    eqm #$01
BRUSH_BUTTON    eqm BUTTON_A
FLOSS_BUTTON    eqm BUTTON_B

ent_player_init: subroutine
	; player always anet slot 00
	ldx #$00
	lda #ent_player_id
	sta ent_type,x
	lda #$f7
	sta player_x
	lda #$7b
	sta player_y
	; reset registers
	lda #$00
	sta ent_r0,x
	sta ent_r1,x
	sta ent_r2,x
	; player direction
	lda #$ff
	sta ent_r3,x
	; reset velocity
	lda #$00
	sta pl_vel_h_hi
	sta pl_vel_h_lo
	sta pl_vel_v_hi
	sta pl_vel_v_lo
	; escape baddies quickly
	lda #$40
	sta player_iframes
	rts

/*
	demo mode
		player stops and cleans dirt detected
*/


player_slow_velocities:
	hex 00 01 ; ordinal
	hex b5 00 ; diagonal
	hex 00 ff ; ordinal
	hex 4b ff ; diagonal
	
player_fast_velocities:
	hex d4 02 ; ordinal
	hex 00 02 ; diagonal
	hex 2c fd ; ordinal
	hex 00 fe ; diagonal


	; RENDER HANDLER
ent_player_render_lo:
	byte <player_render_idle
	byte <player_render_running
	byte <player_render_brushing
	byte <player_render_flossing
	byte <player_render_death
ent_player_render_hi:
	byte >player_render_idle
	byte >player_render_running
	byte >player_render_brushing
	byte >player_render_flossing
	byte >player_render_death


ent_player_update: subroutine
	lda player_iframes
	beq ent_player_render
	lda player_iframes
	dec player_iframes
	shift_r 1
	and #$01
	beq ent_player_render

	jmp ent_z_update_return


ent_player_render:
	ldy ent_spr_ptr
	; run state updater
	lda ent_r0,x
	tax
	lda ent_player_render_lo,x
	sta temp00
	lda ent_player_render_hi,x
	sta temp01
	ldx ent_slot
	jmp (temp00)



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

; check on top of living tooth

player_brush_x_offset:
	hex 04 05 06 05

player_floss_spr:
	hex f0 f2 f4 f6

player_floss_right_spr:
	hex cc ce
	hex d0 d2
	hex d4 d6
	hex d0 d2

player_floss_left_spr:
	hex ce cc
	hex d2 d0
	hex d6 d4
	hex d2 d0

; RENDERS BY STATE

player_render_idle: subroutine
	lda player_x
	sec
	sbc camera_x
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
	jmp ent_z_update_return


player_render_running: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
	bcc .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$06
	bcc .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
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
	sbc camera_x
	clc
	adc #$08
	sta spr_x,y
	lda player_y
	clc
	adc #$10
	sta spr_y,y
	inc_y 4
.walking_done
	jmp ent_z_update_return


player_render_brushing: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$03
	bcc .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$04
	bcc .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
	; bound frame counter
	lda ent_r1,x
	cmp #$04
	bcc .frame_bounded
	lda #$00
	sta ent_r1,x
.frame_bounded
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
	sbc camera_x
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
	lda #$ec
	sta spr_p+16,y
	lda #$ee
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
	lda #$ee
	sta spr_p+16,y
	lda #$ec
	sta spr_p+20,y
.facing_done
	ldx ent_slot
	; check for walk cycle
	lda player_moving
	beq .not_moving
	lda wtf
	shift_r 2
	and #$03
	sta temp00
	and #$01
	beq .not_moving
	lda temp00
	and #$02
	bne .right_leg_up
.left_leg_up
	lda #$e4
	sta spr_p+8,y
	lda #$e6
	sta spr_p+12,y
	lda #$00
	sta spr_a+8,y
	sta spr_a+12,y
	jmp .not_moving
.right_leg_up
	lda #$e6
	sta spr_p+8,y
	lda #$e4
	sta spr_p+12,y
	lda #$40
	sta spr_a+8,y
	sta spr_a+12,y
.not_moving
	tya
	clc
	adc #$18
	tay
	jmp ent_z_update_return


player_render_flossing: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$04
	bcc .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$04
	bcc .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
	; bound frame counter
	lda ent_r1,x
	cmp #$04
	bcc .frame_bounded
	lda #$00
	sta ent_r1,x
.frame_bounded
	; player x
	lda player_x
	sec
	sbc camera_x
	sta temp07
	sta spr_x,y
	sta spr_x+8,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	; player y
	lda player_y
	sta spr_y+0,y
	sta spr_y+4,y
	clc
	adc #$10
	sta spr_y+8,y
	sta spr_y+12,y
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
	lda player_floss_right_spr,x
	sta spr_p,y
	lda player_floss_right_spr+1,x
	sta spr_p+4,y
	lda #$e0
	sta spr_p+8,y
	lda #$e2
	sta spr_p+12,y
	jmp .facing_done
.facing_left
	ldx temp00
	lda #$40
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	lda player_floss_left_spr,x
	sta spr_p,y
	lda player_floss_left_spr+1,x
	sta spr_p+4,y
	lda #$e2
	sta spr_p+8,y
	lda #$e0
	sta spr_p+12,y
.facing_done
	ldx ent_slot
	; check for walk cycle
	lda player_moving
	beq .not_moving
	lda wtf
	shift_r 2
	and #$03
	sta temp00
	and #$01
	beq .not_moving
	lda temp00
	and #$02
	bne .right_leg_up
.left_leg_up
	lda #$e4
	sta spr_p+8,y
	lda #$e6
	sta spr_p+12,y
	lda #$00
	sta spr_a+8,y
	sta spr_a+12,y
	jmp .not_moving
.right_leg_up
	lda #$e6
	sta spr_p+8,y
	lda #$e4
	sta spr_p+12,y
	lda #$40
	sta spr_a+8,y
	sta spr_a+12,y
.not_moving
	tya
	clc
	adc #$10
	tay

	; FLOSS
	lda floss_length
	shift_r 3
	sta temp00
	lda ent_r3,x
	bpl .floss_right
.floss_left
	lda temp07
	sec
	sbc #$08
	sta temp07
	lda #$f8 ; unit
	sta temp01
	lda #$40 ; attr
	sta temp02
	jmp .floss_sprite_long_loop
.floss_right
	lda temp07
	clc
	adc #$10
	sta temp07
	lda #$08 ; unit
	sta temp01
	lda #$00 ; attr
	sta temp02
.floss_sprite_long_loop
	lda temp00
	beq .floss_longs_done
	lda temp01
	bpl .no_long_x_checks
.long_x_underflow_check
	lda temp07
	cmp #$f8
	bcc .no_long_x_checks
	lda #$00
	sta spr_x,y
	jmp .long_x_checks_done
.no_long_x_checks
	lda temp07
	sta spr_x,y
.long_x_checks_done
	lda temp07
	clc
	adc temp01
	sta temp07
	lda player_y
	sta spr_y,y
	lda temp02
	sta spr_a,y
	lda #$f6
	sta spr_p,y
	inc_y 4
	dec temp00
	jmp .floss_sprite_long_loop
.floss_longs_done
.partial_floss_sprite
	lda temp01
	bpl .no_partial_x_checks
.partial_x_underflow_check
	lda temp07
	cmp #$f8
	bcc .no_partial_x_checks
	lda #$00
	sta spr_x,y
	lda #$f6
	sta spr_p,y
	jmp .partial_x_checks_done
.no_partial_x_checks
	lda temp07
	sta spr_x,y
	lda floss_length
	and #$06
	clc
	adc #$f0
	sta spr_p,y
.partial_x_checks_done
	lda player_y
	sta spr_y,y
	lda temp02
	sta spr_a,y
	inc_y 4
	jmp ent_z_update_return

	


player_render_death: subroutine
	lda player_x
	sec
	sbc camera_x
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
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	lda #$d8
	sta spr_p,y
	lda #$da
	sta spr_p+4,y
	lda #$f8
	sta spr_p+8,y
	lda #$fa
	sta spr_p+12,y
	inc_y 16
	jmp ent_z_update_return


