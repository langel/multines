
ent_dingle_update: subroutine
	lda wtf
	and #$07
	sta temp07
	bne .ent_move_done
	lda ent_x_grid,x
	sta temp00
	lda ent_y_grid,x
	sta temp01
	; move ent
	lda ent_direction,x
	beq .ent_right
	cmp #$01
	beq .ent_up
	cmp #$02
	beq .ent_left
	bne .ent_down
.ent_right
	jsr level_get_block_right
	bne .ent_new_direction
	inc ent_x_grid,x
	jmp .ent_move_done
.ent_up
	jsr level_get_block_up
	bne .ent_new_direction
	dec ent_y_grid,x
	jmp .ent_move_done
.ent_left
	jsr level_get_block_left
	bne .ent_new_direction
	dec ent_x_grid,x
	jmp .ent_move_done
.ent_down
	jsr level_get_block_down
	bne .ent_new_direction
	inc ent_y_grid,x
	jmp .ent_move_done
.ent_new_direction
	jsr level_ent_new_direction
.ent_move_done

	;render ent
	ldx spr_offset
	ldy ent_offset
	lda ent_x_grid,y
	asl
	asl
	asl
	sta spr_x,x
	lda ent_y_grid,y
	asl
	asl
	asl
	sta spr_y,x
	dec spr_y,x
	; animate ent movement
	lda ent_direction,y
	beq .ent_anim_right
	cmp #$01
	beq .ent_anim_up
	cmp #$02
	beq .ent_anim_left
	bne .ent_anim_down
.ent_anim_right
	lda temp07
	eor #$07
	sta temp06
	lda spr_x,x
	sec
	sbc temp06
	sta spr_x,x
	rts
.ent_anim_up
	lda temp07
	eor #$07
	sta temp06
	lda spr_y,x
	clc
	adc temp06
	sta spr_y,x
	rts
.ent_anim_left
	lda temp07
	eor #$07
	sta temp06
	lda spr_x,x
	clc
	adc temp06
	sta spr_x,x
	rts
.ent_anim_down
	lda temp07
	eor #$07
	sta temp06
	lda spr_y,x
	sec
	sbc temp06
	sta spr_y,x
	rts

ent_reverse_table:
	hex 02 03 00 01

level_ent_new_direction: subroutine
	ldx ent_offset
	jsr rand
	jsr rand
	lsr
	lsr
	and #$01
	asl
	clc
	adc #$01
	adc ent_direction,x
	and #$03
	sta temp02
	sta temp04
	lda ent_x_grid,x
	sta temp00
	lda ent_y_grid,x
	sta temp01
	jsr level_get_block_dir
	bne .next_dir
	lda temp04
	sta ent_direction,x
	jmp .update_position
.next_dir
	lda temp04
	clc
	adc #$02
	and #$03
	sta temp02
	sta temp04
	lda ent_x_grid,x
	sta temp00
	lda ent_y_grid,x
	sta temp01
	jsr level_get_block_dir
	bne .turn_around
	lda temp04
	sta ent_direction,x
	jmp .update_position
.turn_around
	ldy ent_direction,x
	lda ent_reverse_table,y
	sta ent_direction,x
.update_position
	; move ent
	beq .ent_right
	cmp #$01
	beq .ent_up
	cmp #$02
	beq .ent_left
	bne .ent_down
.ent_right
	inc ent_x_grid,x
	jmp .ent_move_done
.ent_up
	dec ent_y_grid,x
	jmp .ent_move_done
.ent_left
	dec ent_x_grid,x
	jmp .ent_move_done
.ent_down
	inc ent_y_grid,x
	jmp .ent_move_done
.ent_move_done
	rts
