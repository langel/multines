; ent_r0 road type
;        0 collapse
;        1 expands

ent_sign_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_sign_id
	sta ent_type,x
.done

	ldy pg_ring
	iny
	cpy #road_ref_width
	bne .y_reset_done
	ldy #$00
.y_reset_done
	lda road_r_x_offset,y
	clc
	adc road_w_ring,y
	adc #$04
	sta ent_x,x

	lda player_wy
	sec
	sbc #$b8
	sta ent_y,x
	lda player_wy_hi
	sbc #$00
	sta ent_y_hi,x

	; collapse or expand
	ldy lane_step
	lda lane_schedule,y
	sta temp00
	tya
	clc
	adc #$03
	cmp #lane_sched_len
	bne .check_dir
	lda #$00
.check_dir
	tay
	lda lane_schedule,y
	cmp temp00
	bcc .expands
.collapse
	lda #$01
	jmp .dir_found
.expands
	lda #$00
.dir_found
	sta ent_r0,x

	rts



ent_sign_update: subroutine
	; update logic

	; screen pos temp00
	; camera - pos?
	sec 
	lda ent_y,x
	sbc camera_y
	sta temp00
	lda ent_y_hi,x
	sbc camera_y_hi
	sta temp01

	; despawn check
	lda temp01
	cmp #$01
	bne .despawn_check_done
	ent_despawn
	rts
.despawn_check_done

	; render check
	lda temp01
	bmi .check_above_screen
.check_below_screen
	lda temp00
	cmp #$f0
	bcc .render_check_done
	rts
.check_above_screen
	lda temp00
	cmp #$f0
	bcs .render_check_done
	rts
.render_check_done
	
	; render
	ldy ent_spr_ptr
	
	; sprite 0
	lda ent_x,x
	sta spr_x,y
	lda temp00
	sta spr_y,y
	lda #$8e
	sta spr_p,y
	lda #$02
	sta spr_a,y
	inc_y 4
	; sprite 2
	lda ent_x,x
	sta spr_x,y
	lda temp00
	clc
	adc #$08
	sta spr_y,y
	lda #$8e
	sta spr_p,y
	lda #$82
	sta spr_a,y
	inc_y 4

	lda ent_r0,x
	bne .road_expands
.road_collapse
	; sprite 1
	lda ent_x,x
	clc
	adc #$08
	sta spr_x,y
	lda temp00
	sta spr_y,y
	lda #$8f
	sta spr_p,y
	lda #$02
	sta spr_a,y
	inc_y 4
	; sprite 3
	lda ent_x,x
	clc
	adc #$08
	sta spr_x,y
	lda temp00
	clc
	adc #$08
	sta spr_y,y
	lda #$8e
	sta spr_p,y
	lda #$c2
	sta spr_a,y
	inc_y 4
	rts 

.road_expands
	; sprite 1
	lda ent_x,x
	clc
	adc #$08
	sta spr_x,y
	lda temp00
	sta spr_y,y
	lda #$8e
	sta spr_p,y
	lda #$42
	sta spr_a,y
	inc_y 4
	; sprite 3
	lda ent_x,x
	clc
	adc #$08
	sta spr_x,y
	lda temp00
	clc
	adc #$08
	sta spr_y,y
	lda #$8f
	sta spr_p,y
	lda #$82
	sta spr_a,y
	inc_y 4
	rts
