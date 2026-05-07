

game_ent_collision: subroutine
	; calculate ent screen position
	; calculate ent collisions
	; with player, brush, floss

	; reset status
	lda #$00
	sta ent_visible
	sta ent_damaged

	; check y position
	lda ent_y,x
	sta collision_0_y
	sta ent_pos_y
	sta ent_coll_y,x
	cmp #240 ; screen height
	bcc .y_safe
	cmp #$f0
	bcs .y_safe
	rts
.y_safe

	; check x columns
	sec
	lda ent_x,x
	sbc camera_x
	sta collision_0_x
	sta ent_pos_x
	sta ent_coll_x,x
	lda ent_x_hi,x
	sbc camera_x_hi
	beq .left_visible
	cmp #$ff
	bne .visibility_done
	lda collision_0_x
	cmp #$f8
	bcs .right_visible
	bcc .visibility_done
.left_visible
	lda ent_visible
	ora #$01
	sta ent_visible
	lda collision_0_x
	cmp #$f8
	bcc .right_visible
	bcs .visibility_done
.right_visible
	lda ent_visible
	ora #$02
	sta ent_visible
.visibility_done
	lda ent_visible
	beq .collision_box_done
	cmp #$03
	beq .collision_box_full
	cmp #$01
	bne .set_right_only
.set_left_only
	sec
	lda #$ff
	sbc collision_0_x
	sta collision_0_w
	sta ent_coll_w,x
	jmp .collision_box_done
.set_right_only
	clc
	lda #$08
	adc collision_0_x
	sta collision_0_x
	sta ent_coll_x,x
	lda #$08
	sta collision_0_w
	sta ent_coll_w,x
	jmp .collision_box_done
.collision_box_full
	lda collision_0_x
	cmp #$f0
	bcc .not_in_right_edge
	; Clamp width so collision_0_x + collision_0_w never wraps.
	lda #$ff
	sec
	sbc collision_0_x
	jmp .collision_box_full_width_clamped
.not_in_right_edge
	lda #$10
.collision_box_full_width_clamped
	sta collision_0_w
	sta ent_coll_w,x
.collision_box_done

	; check ent is visible
	lda ent_visible
	bne .ent_is_visible
	rts
.ent_is_visible

	; player collision
	lda ent_type,x
	cmp #ent_food_id
	beq .player_collision_done
	lda player_is_dead
	bne .player_collision_done
	lda player_iframes
	bne .player_collision_done
	clc
	lda collision_0_x
	adc collision_0_w
	cmp player_hit_x
	bcc .player_collision_done
	clc
	lda collision_0_x
	cmp player_hit_x
	bcs .player_collision_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp player_hit_y
	bcc .player_collision_done
	clc
	lda collision_0_y
	cmp player_hit_y
	bcs .player_collision_done
.player_collides
	lda #player_death_timer
	sta player_is_dead
	lda #$04
	sta ent_r0
	lda #$ff
	sta ent_hp,x
	rts
.player_collision_done

	; brush collision
	lda brush_status
	beq .brushing_done
	clc
	lda collision_0_x
	adc collision_0_w
	cmp brush_hit_x
	bcc .brushing_done
	clc
	lda collision_0_x
	cmp brush_hit_x
	bcs .brushing_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp brush_hit_y
	bcc .brushing_done
	clc
	lda collision_0_y
	cmp brush_hit_y
	bcs .brushing_done
.brush_collision
	; take hit points
	dec ent_hp,x
	inc ent_damaged
.brushing_done

	; floss collision
	lda floss_status
	and #$40
	beq .flossing_done
	; x overlap: food [collision_0_x, +collision_0_w] vs floss [floss_box_left_x, floss_box_right_x]
	clc
	lda collision_0_x
	adc collision_0_w
	cmp floss_box_left_x
	bcc .flossing_done
	lda floss_box_right_x
	cmp collision_0_x
	bcc .flossing_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp floss_hit_y
	bcc .flossing_done
	lda floss_hit_y
	cmp collision_0_y
	bcc .flossing_done
.floss_collision
	lda wtf
	and #$01
	bne .flossing_done
	; halve hit points
	lsr ent_hp,x
	bne .dont_subtract
	dec ent_hp,x
.dont_subtract
	lda ent_damaged
	ora #$02
	sta ent_damaged
.flossing_done

	rts
