
player_death_timer    eqm #$40
player_iframes_timer  eqm #$40


game_player_update: subroutine

	lda player_is_dead
	beq .not_dead
	cmp #$01
	bne .death_timer_running
.next_life
	dec player_lives	
	lda #player_iframes_timer
	sta player_iframes
	lda #$00
	sta ent_r0
	sta player_is_dead
	rts
.death_timer_running
	dec player_is_dead
	rts
.not_dead

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
	lda controller1
	and #BUTTON_LEFT|BUTTON_RIGHT|BUTTON_UP|BUTTON_DOWN
	sta temp01
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
	lda floss_status
	beq .floss_move_cleared
	jmp .bf_rightleft_done
.floss_move_cleared
	; left/right if not flossing
	lda temp01
	and #BUTTON_RIGHT
	beq .bf_not_right
	lda player_slow_velocities,y
	sta pl_vel_h_lo
	lda player_slow_velocities+1,y
	sta pl_vel_h_hi
	jmp .bf_rightleft_done
.bf_not_right
	lda temp01
	and #BUTTON_LEFT
	beq .bf_rightleft_done
	lda player_slow_velocities+4,y
	sta pl_vel_h_lo
	lda player_slow_velocities+5,y
	sta pl_vel_h_hi
.bf_rightleft_done
	; up/down in both cases
	lda temp01
	and #BUTTON_DOWN
	beq .bf_not_down
	lda player_slow_velocities,y
	sta pl_vel_v_lo
	lda player_slow_velocities+1,y
	sta pl_vel_v_hi
	jmp .bf_move_done
.bf_not_down
	lda temp01
	and #BUTTON_UP
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
	; horizontal axis: only one direction accelerates
	lda temp01
	and #BUTTON_LEFT|BUTTON_RIGHT
	cmp #BUTTON_LEFT
	beq .do_left
	cmp #BUTTON_RIGHT
	beq .do_right
	lda #$00
	sta pl_vel_h_lo
	sta pl_vel_h_hi
	jmp .left_move_done
.do_left
	sec
	lda pl_vel_h_lo
	sbc #$40
	sta pl_vel_h_lo
	lda pl_vel_h_hi
	sbc #$00
	sta pl_vel_h_hi
	lda #$ff
	sta ent_r3
	lda pl_vel_h_hi
	cmp player_fast_velocities+5,y
	bcc .left_clamp
	bne .left_move_done
	lda pl_vel_h_lo
	cmp player_fast_velocities+4,y
	bcs .left_move_done
.left_clamp
	lda player_fast_velocities+4,y
	sta pl_vel_h_lo
	lda player_fast_velocities+5,y
	sta pl_vel_h_hi
.left_move_done
	; right
.do_right
	lda temp01
	and #BUTTON_LEFT|BUTTON_RIGHT
	cmp #BUTTON_RIGHT
	bne .right_move_done
	clc
	lda pl_vel_h_lo
	adc #$40
	sta pl_vel_h_lo
	lda pl_vel_h_hi
	adc #$00
	sta pl_vel_h_hi
	lda #$00
	sta ent_r3
	lda pl_vel_h_hi
	cmp player_fast_velocities+1,y
	bcc .right_move_done
	bne .right_clamp
	lda pl_vel_h_lo
	cmp player_fast_velocities,y
	bcc .right_move_done
	beq .right_move_done
.right_clamp
	lda player_fast_velocities,y
	sta pl_vel_h_lo
	lda player_fast_velocities+1,y
	sta pl_vel_h_hi
.right_move_done
	; vertical axis: only one direction accelerates
	lda temp01
	and #BUTTON_UP|BUTTON_DOWN
	cmp #BUTTON_UP
	beq .do_up
	cmp #BUTTON_DOWN
	beq .do_down
	lda #$00
	sta pl_vel_v_lo
	sta pl_vel_v_hi
	jmp .up_move_done
.do_up
	sec
	lda pl_vel_v_lo
	sbc #$40
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
	lda player_fast_velocities+4,y
	sta pl_vel_v_lo
	lda player_fast_velocities+5,y
	sta pl_vel_v_hi
.up_move_done
	; down
.do_down
	lda temp01
	and #BUTTON_UP|BUTTON_DOWN
	cmp #BUTTON_DOWN
	bne .down_move_done
	clc
	lda pl_vel_v_lo
	adc #$40
	sta pl_vel_v_lo
	lda pl_vel_v_hi
	adc #$00
	sta pl_vel_v_hi
	cmp player_fast_velocities+1,y
	bcc .down_move_done
	bne .down_clamp
	cmp player_fast_velocities,y
	bcc .down_move_done
	beq .down_move_done
.down_clamp
	lda player_fast_velocities,y
	sta pl_vel_v_lo
	lda player_fast_velocities+1,y
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
	lda #$00
	bit pl_vel_h_hi
	bpl .pl_vel_h_sign_done
	lda #$ff
.pl_vel_h_sign_done
	adc player_x_hi
	sta player_x_hi
	clc
	lda player_y_lo
	adc pl_vel_v_lo
	sta player_y_lo
	lda player_y
	adc pl_vel_v_hi
	sta player_y

	; player playfield bound
	lda player_x_hi
	bne .screen_2
.screen_1
	lda player_x
	cmp #$0c
	bcs .bind_x_done
	lda #$0c
	sta player_x
	lda #$00
	sta player_x_hi
	sta player_x_lo
	jmp .bind_x_done
.screen_2
	lda player_x
	cmp #$e8
	bcc .bind_x_done
	lda #$e7
	sta player_x
	lda #$01
	sta player_x_hi
	lda #$00
	sta player_x_lo
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
	; CAMERA UPDATE
	jsr state_game_camera

	

	; reset render state
	lda #$00
	sta ent_r0
	; check for movement
	lda player_moving
	beq .skip_movement
	lda #$01
	sta ent_r0
.skip_movement


	; BRUSHING
	lda controller1
	and #BRUSH_BUTTON
	bne .do_brushing
	jmp .brushing_done
.do_brushing
	; set render index
	lda #$02
	sta ent_r0
	; set hit position
	sec
	lda player_x
	sbc camera_x
	sta temp00
	lda ent_r3
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
	lda player_y
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
	lda ent_r3
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
	sta ent_r5 ; cell_id
	; check for cell dirt
	lda ent_r5
	sta temp00
	tax
	lda tooth_cell2tooth,x
	tax
	lda tooth_total_dmg,x
	bmi .brushing_done
	; check cell 
	ldx temp00
	lda $600,x
	beq .brushing_done
	lda wtf
	and #$03 ; frames to clean cell 1 dmg
	bne .brushing_done
	dec $600,x
	; add tooth cell to update queue
	txa
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
.brushing_done


	; FLOSSING
	lda controller1
	and #FLOSS_BUTTON
	bne .floss_button_pressed
	lda #$00
	sta floss_status
	jmp .skip_flossing
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
	bmi .no_gap
	bpl .floss_check_for_gap
	; if tooth dead can't find gap
.floss_check_for_gap
	ldx ent_slot
	; check for tooth gap
	lda ent_r3
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
	sta ent_r0
	; set floss hit position
	sec
	lda player_x
	sbc camera_x
	sta temp00
	lda ent_r3
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
	lda player_y
	adc #$10
	sta floss_hit_y
.skip_flossing

	; set arctang position
	lda player_x_hi
	lsr
	lda player_x
	ror
	sta collision_1_w
	clc
	lda player_y
	adc #$10
	lsr
	sta collision_1_h

	; set hit spot
	lda player_x
	sec
	sbc camera_x
	clc
	adc #$08
	sta player_hit_x
	lda player_y
	clc
	adc #$18
	sta player_hit_y

	; set z position
	lda player_x
	sta ent_x
	lda player_x_hi
	sta ent_x_hi
	lda player_y
	clc
	adc #$20
	ldx #$00
	ent_z_calc_sort_vals_9bit
	
	rts
