
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
	; reset velocity
	lda #$00
	sta pl_vel_h_hi
	sta pl_vel_h_lo
	sta pl_vel_v_hi
	sta pl_vel_v_lo
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

ent_player_update: subroutine

	; handle directional inputs
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
	; setup ordinal/diagonal offset
	lda temp00
	and #$02
	tay
	; set player_moving flag
	lda #$00
	sta player_moving
	lda temp00
	bne .is_moving
	jmp .not_moving
.is_moving
	inc player_moving
	; action buttons impact
	lda controller1
	and #BRUSH_BUTTON|FLOSS_BUTTON
	beq .not_brush_or_floss
	lda #$00
	sta pl_vel_h_lo
	sta pl_vel_h_hi
	sta pl_vel_v_lo
	sta pl_vel_v_hi
	; no acceleration with actions
	lda #FLOSS_BUTTON
	beq .floss_move_cleared
	lda floss_status
	beq .floss_move_cleared
	jmp .bf_rightleft_done
.floss_move_cleared
	; left/right if not flossing
	lda controller1
	cmp #BUTTON_RIGHT
	beq .bf_not_right
	lda player_slow_velocities,y
	sta pl_vel_h_lo
	lda player_slow_velocities+1,y
	sta pl_vel_h_hi
	jmp .bf_rightleft_done
.bf_not_right
	lda controller1
	cmp #BUTTON_LEFT
	beq .bf_rightleft_done
	lda player_slow_velocities+4,y
	sta pl_vel_h_lo
	lda player_slow_velocities+5,y
	sta pl_vel_h_hi
.bf_rightleft_done
	; up/down in both cases
	lda controller1
	cmp #BUTTON_DOWN
	beq .bf_not_right
	lda player_slow_velocities,y
	sta pl_vel_v_lo
	lda player_slow_velocities+1,y
	sta pl_vel_v_hi
	jmp .bf_move_done
.bf_not_down
	lda controller1
	cmp #BUTTON_UP
	beq .bf_move_done
	lda player_slow_velocities+4,y
	sta pl_vel_v_lo
	lda player_slow_velocities+5,y
	sta pl_vel_v_hi
.bf_move_done
	jmp .moving_done
.not_brush_or_floss
	; normal movement with
	; acceleration handling
	; left
	lda controller1
	cmp #BUTTON_LEFT
	beq .left_move_done
	sec
	lda #$40
	sbc pl_vel_h_lo
	sta pl_vel_h_lo
	lda pl_vel_h_hi
	sbc #$00
	sta pl_vel_h_hi
	cmp player_fast_velocities+5,y
	bcc .left_clamp
	bne .left_move_done
	lda pl_vel_h_lo
	cmp player_fast_velocities+4,y
	bcs .left_move_done
.left_clamp
	lda player_slow_velocities+4,y
	sta pl_vel_h_lo
	lda player_slow_velocities+5,y
	sta pl_vel_h_hi
.left_move_done
	; right
	lda controller1
	cmp #BUTTON_RIGHT
	beq .right_move_done
	clc
	lda #$40
	adc pl_vel_h_lo
	sta pl_vel_h_lo
	lda pl_vel_h_hi
	adc #$00
	sta pl_vel_h_hi
	cmp player_fast_velocities+5,y
	bcc .right_move_done
	bne .right_clamp
	lda pl_vel_h_lo
	cmp player_fast_velocities+4,y
	bcc .right_move_done
	beq .right_move_done
.right_clamp
	lda player_slow_velocities+4,y
	sta pl_vel_h_lo
	lda player_slow_velocities+5,y
	sta pl_vel_h_hi
.right_move_done
	; up
	lda controller1
	cmp #BUTTON_UP
	beq .up_move_done
	sec
	lda #$40
	sbc pl_vel_v_lo
	sta pl_vel_v_lo
	lda pl_vel_v_hi
	sbc #$00
	sta pl_vel_v_hi
	cmp player_fast_velocities+5,y
	bcc .up_clamp
	bne .up_move_done
	lda pl_vel_v_lo
	cmp player_fast_velocities+4,y
	bcs .up_move_done
.up_clamp
	lda player_slow_velocities+4,y
	sta pl_vel_v_lo
	lda player_slow_velocities+5,y
	sta pl_vel_v_hi
.up_move_done
	; down
	lda controller1
	cmp #BUTTON_DOWN
	beq .down_move_done
	clc
	lda #$40
	adc pl_vel_v_lo
	sta pl_vel_v_lo
	lda pl_vel_v_hi
	adc #$00
	sta pl_vel_v_hi
	cmp player_fast_velocities+5,y
	bcc .down_move_done
	bne .down_clamp
	lda pl_vel_v_lo
	cmp player_fast_velocities+4,y
	bcc .down_move_done
	beq .down_move_done
.down_clamp
	lda player_slow_velocities+4,y
	sta pl_vel_v_lo
	lda player_slow_velocities+5,y
	sta pl_vel_v_hi
.down_move_done
	jmp .moving_done

.not_moving
	lda #$00
	sta pl_vel_h_hi
	sta pl_vel_h_lo
	sta pl_vel_v_hi
	sta pl_vel_v_lo
.moving_done
	; velocity movement
	clc
	lda player_x_lo
	adc pl_vel_h_lo
	sta player_x_lo
	lda player_x
	adc pl_vel_h_hi
	sta player_x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	clc
	lda player_y_lo
	adc pl_vel_v_lo
	sta player_y_lo
	lda player_y
	adc pl_vel_v_hi
	sta player_y

	; CAMERA UPDATE
	jsr state_game_camera

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

	

	; reset render state
	lda #$00
	sta ent_r0,x
	; check for movement
	lda player_moving
	beq .skip_movement
	lda #$01
	sta ent_r0,x
.skip_movement


	; BRUSHING
	lda controller1
	and #BRUSH_BUTTON
	bne .do_brushing
	jmp .skip_brushing
.do_brushing
	; set render index
	lda #$02
	sta ent_r0,x
	; set hit position
	sec
	lda player_x
	sbc camera_x
	sta temp00
	lda ent_r3,x
	bmi .brush_left
.brush_right
	lda temp00
	clc
	adc #$16
	jmp .brush_x_found
.brush_left
	lda temp00
	sec
	sbc #$0a
.brush_x_found
	sta brush_hit_x
	clc
	lda player_y,x
	adc #$10
	sta brush_hit_y
	; check cell tooth
	; calc tooth position of brush
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
	; check for cell dirt
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


	; FLOSSING
	lda controller1
	and #FLOSS_BUTTON
	bne .floss_button_pressed
	lda #$00
	sta floss_status
	jmp .skip_flossing
	; xxx todo
	; if floss hits max length and no tooth gap
	;    then floss decreases
	; if floss hits tooth gap then it stays there
	;    releasing button then floss decreases
	; releasing A kills floss state
	; xxx done
	; initially floss increases at length
	; player must press button fresh to floss again
	; player can only move up/down while flossing
	; food hp == 0 causes despawn (animated)
.floss_button_pressed
	lda controller1_d
	and #FLOSS_BUTTON
	beq .not_initial_press
	lda #$00
	sta floss_length
	lda #$01
	sta floss_status
.not_initial_press
	lda floss_status
	sta $188
	bne .keep_flossing
	jmp .skip_flossing
.keep_flossing
	bmi .floss_decrease
	cmp #$40
	beq .floss_state_done
.floss_increase
	inc floss_length
	; check on top of living tooth
	; calc tooth id
	; (player_x / 64) +
	; (player_y > 100) * 8
	lda player_x_hi
	lsr
	lda player_x
	ror
	shift_r 5
	sta temp00
	lda player_y
	cmp #$70
	bcc .flossing_top_row
.flossing_bottom_row
	lda #$08
	clc
	adc temp00
	sta temp00
.flossing_top_row
	ldx temp00
	lda tooth_total_dmg,x
	bmi .floss_no_gap
	bpl .floss_check_for_gap
	; if tooth dead can't find gap
.floss_no_gap
	ldx ent_slot
	jmp .no_gap
.floss_check_for_gap
	ldx ent_slot
	; check for tooth gap
	lda ent_r3,x
	bpl .floss_right_gap_check
.floss_left_gap_check
	sec
	lda player_x
	sbc floss_length
	and #$3f
	cmp #$01
	bne .no_gap
	lda #$40
	sta floss_status
	jmp .floss_state_done
.floss_right_gap_check
	clc
	adc player_x
	adc #$10
	adc floss_length
	and #$3f
	cmp #$3f
	bne .no_gap
	lda #$40
	sta floss_status
	jmp .floss_state_done
.no_gap
	; if max length then start decrease
	lda floss_length
	cmp #$18
	bcc .floss_state_done
	lda floss_status
	lda #$81
	sta floss_status
.floss_decrease
	dec floss_length
	bne .floss_state_done
	lda #$00
	sta floss_status
	jmp .skip_flossing
.floss_state_done
	; check for tooth row gap if has target
	lda floss_status
	and #$40
	beq .flooth_not_row_gap
	lda player_y
	cmp #$6f
	bcc .flooth_not_row_gap
	cmp #$73
	bcs .flooth_not_row_gap
.flooth_stop
	lda #$00
	sta floss_status
.flooth_not_row_gap
	; set state/render index
	lda #$03 
	sta ent_r0,x
	; set floss hit position
	sec
	lda player_x
	sbc camera_x
	sta temp00
	lda ent_r3,x
	bmi .floss_left
.floss_right
	lda temp00
	clc
	adc #$10
	adc floss_length
	jmp .floss_x_found
.floss_left
	lda temp00
	sec
	sbc floss_length
.floss_x_found
	sta floss_hit_x
	clc
	lda player_y,x
	adc #$10
	sta floss_hit_y
.skip_flossing

	; set z position
	lda player_x
	sta ent_x,x
	lda player_x_hi
	sta ent_x_hi,x
	lda player_y
	clc
	adc #$20
	ent_z_calc_sort_vals_9bit

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
	jmp ent_z_render_return

	


player_render_death: subroutine
	jmp ent_z_render_return


