
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

player_speed    eqm #$01

ent_player_init: subroutine
	; player always anet slot 00
	ldx #$00
	lda #ent_player_id
	sta ent_type,x
	lda #$e0
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

/*
	demo mode
		player stops and cleans dirt detected
*/


player_velocities:
	hex 00 01 ; slow ordinal
	hex b5 00 ; slow diagonal
	hex d4 02 ; fast ordinal
	hex 00 02 ; fast diagonal

ent_player_update: subroutine

	; handle direction
	lda #$00
	sta temp00
	lda controller1
	and #BUTTON_LEFT|BUTTON_RIGHT
	beq .not_left_or_right
	inc temp00
.not_left_or_right
	lda controller1
	and #BUTTON_UP|BUTTON_DOWN
	beq .not_up_or_down
	inc temp00
.not_up_or_down
	; set player_moving flag
	lda #$00
	sta player_moving
	lda temp00
	bne .is_moving
	jmp .not_moving
.is_moving
	inc player_moving
	; setup ordinal/diagonal offset
	lda temp00
	sec
	sbc #$01
	asl
	sta temp00
	; set velocity speeds
	lda controller1
	and #BUTTON_B|BUTTON_A
	bne .velocity_set
	lda #$04
	clc
	adc temp00
	sta temp00
.velocity_set
	ldx temp00
	; do add/sub for each axi
	lda controller1
	and #BUTTON_LEFT
	beq .not_left
	lda player_x_lo
	sec
	sbc player_velocities,x
	sta player_x_lo
	lda player_x
	sbc player_velocities+1,x
	sta player_x
	lda player_x_hi
	sbc #$00
	sta player_x_hi
	lda controller1
	and #BUTTON_B|BUTTON_A
	bne .not_left
	lda #$ff
	ldx ent_slot
	sta ent_r3,x
	ldx temp00
.not_left
	lda controller1
	and #BUTTON_RIGHT
	beq .not_right
	lda player_x_lo
	clc
	adc player_velocities,x
	sta player_x_lo
	lda player_x
	adc player_velocities+1,x
	sta player_x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	lda controller1
	and #BUTTON_B|BUTTON_A
	bne .not_right
	lda #$00
	ldx ent_slot
	sta ent_r3,x
	ldx temp00
.not_right
	lda controller1
	and #BUTTON_UP
	beq .not_up
	lda player_y_lo
	sec
	sbc player_velocities,x
	sta player_y_lo
	lda player_y
	sbc player_velocities+1,x
	sta player_y
.not_up
	lda controller1
	and #BUTTON_DOWN
	beq .not_down
	lda player_y_lo
	clc
	adc player_velocities,x
	sta player_y_lo
	lda player_y
	adc player_velocities+1,x
	sta player_y
.not_down
.not_moving
	ldx ent_slot

	; player playfield bound
	lda player_x_hi
	bne .screen_2
.screen_1
	lda player_x
	cmp #$0c
	bcs .bind_x_done
	lda #$0c
	sta player_x
	jmp .bind_x_done
.screen_2
	lda player_x
	cmp #$e0
	bcc .bind_x_done
	lda #$e0
	sta player_x
.bind_x_done
	; check y position
	lda player_y
	cmp #$34
	bcc .bound_top
	cmp #$ac
	bcs .bound_bottom
	jmp .bind_y_done
.bound_top
	lda #$34
	sta player_y
	jmp .bind_y_done	
.bound_bottom
	lda #$ac
	sta player_y
.bind_y_done

	
	; calc tooth position
	; (player_x / 16) 
	; +
	; ((player_y / 16) * 32)
	lda player_x_hi
	lsr
	lda player_x
	ror
	sta temp00
	; check left/right dir
	lda ent_r3,x
	bmi .tooth_cell_left
.tooth_cell_right
	lda temp00
	clc
	adc #$0c
	jmp .tooth_cell_dir_done
.tooth_cell_left
	lda temp00
	sec
	sbc #$04
.tooth_cell_dir_done
	shift_r 3
	sta temp00
	lda player_y
	sec
	sbc #$30
	shift_r 4
	shift_l 5
	clc
	adc temp00
	sta ent_r5,x ; cell_id

	; reset render state
	lda #$00
	sta ent_r0,x
	; check for movement
	lda player_moving
	beq .skip_movement
	lda #$01
	sta ent_r0,x
.skip_movement
	; check for brushing
	lda controller1
	and #BUTTON_B
	beq .skip_brushing
	lda #$02
	sta ent_r0,x
	; check cell tooth
	lda ent_r5,x
	sta temp00
	tax
	lda tooth_cell2tooth,x
	tax
	lda tooth_total_dmg,x
	bmi .cell_clean_done
	; check cell 
	ldx temp00
	lda $600,x
	beq .cell_clean_done
	lda wtf
	and #$03 ; frames to clean cell 1 dmg
	bne .cell_clean_done
	dec $600,x
	; add tooth cell to update queue
	txa
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
.cell_clean_done
	ldx ent_slot
.skip_brushing
	; check for flossing
	lda controller1
	and #BUTTON_A
	beq .skip_flossing
	; xxx todo
	; initially floss increases at length
	; if floss hits max length and no food
	;    then floss decreases
	; player must press button fresh to floss again
	; if floss hits tooth gap then it stays there
	;    releasing button then floss decreases
	; player can move
	;    up/down required to damage food
	;    food hp == 0 causes despawn (animated)
	;    player too far from gap then floss decreases
	; releasing A kills floss state
	lda controller1_d
	and #BUTTON_A
	beq .not_initial_press
	lda #$00
	sta floss_length
	lda #$01
	sta floss_status
.not_initial_press
	lda floss_status
	beq .skip_flossing
	bmi .floss_decrease
.floss_increase
	inc floss_length
	lda floss_length
	cmp #$18
	bcc .floss_done
	lda floss_status
	ora #$80
	sta floss_status
.floss_decrease
	dec floss_length
	bne .floss_done
	lda #$00
	sta floss_status
.floss_done
	lda #$03 ; render id
	sta ent_r0,x
.skip_flossing

	; set z position
	lda player_y
	clc
	adc #$20
	ent_z_calc_sort_vals

	jmp ent_z_update_return


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

ent_player_render:
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
	jmp ent_z_render_return


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
	jmp ent_z_render_return


player_render_brushing: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
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
	jmp ent_z_render_return


player_render_flossing: subroutine
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
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
	sbc scroll_x
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

	; FLOSS RETRY
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
	jmp .floss_dir_setup
.floss_right
	lda temp07
	clc
	adc #$10
	sta temp07
	lda #$08 ; unit
	sta temp01
	lda #$00 ; attr
	sta temp02
.floss_dir_setup
	lda temp00
	beq .floss_longs_done
	lda temp07
	sta spr_x,y
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
	jmp .floss_dir_setup
.floss_longs_done
.partial_floss_sprite
	lda temp07
	sta spr_x,y
	lda player_y
	sta spr_y,y
	lda temp02
	sta spr_a,y
	lda floss_length
	and #$06
	clc
	adc #$f0
	sta spr_p,y
	inc_y 4
	jmp ent_z_render_return

	


player_render_death: subroutine
	jmp ent_z_render_return


