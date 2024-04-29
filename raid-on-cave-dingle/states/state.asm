
sprite_y  eqm $0200
sprite_i  eqm $0201
sprite_a  eqm $0202
sprite_x  eqm $0203

ent_x eqm $0300
ent_y eqm $0301
ent_d eqm $0302

state_level_init: subroutine
	lda #$02
	sta $0201
	lda #$00
	sta $0202
	lda #$02
	sta ent_x
	lda #$07
	sta ent_y
	rts

state_level_update: subroutine
	lda wtf
	and #$07
	sta temp07
	bne .ent_move_done
	lda ent_x
	sta temp00
	lda ent_y
	sta temp01
	; move ent
	lda ent_d
	beq .ent_right
	cmp #$01
	beq .ent_up
	cmp #$02
	beq .ent_left
	bne .ent_down
.ent_right
	jsr level_get_block_right
	bne .ent_new_direction
	inc ent_x
	jmp .ent_move_done
.ent_up
	jsr level_get_block_up
	bne .ent_new_direction
	dec ent_y
	jmp .ent_move_done
.ent_left
	jsr level_get_block_left
	bne .ent_new_direction
	dec ent_x
	jmp .ent_move_done
.ent_down
	jsr level_get_block_down
	bne .ent_new_direction
	inc ent_y
	jmp .ent_move_done
.ent_new_direction
	jsr level_ent_new_direction
.ent_move_done

	;render ent
	lda ent_x
	asl
	asl
	asl
	sta $0203
	lda ent_y
	asl
	asl
	asl
	sta $0200
	dec $0200
	; animate ent movement
	lda ent_d
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
	lda $0203
	sec
	sbc temp06
	sta $0203
	rts
.ent_anim_up
	lda temp07
	eor #$07
	sta temp06
	lda $0200
	clc
	adc temp06
	sta $0200
	rts
.ent_anim_left
	lda temp07
	eor #$07
	sta temp06
	lda $0203
	clc
	adc temp06
	sta $0203
	rts
.ent_anim_down
	lda temp07
	eor #$07
	sta temp06
	lda $0200
	sec
	sbc temp06
	sta $0200
	rts

ent_reverse_table:
	hex 02 03 00 01

level_ent_new_direction: subroutine
	jsr rand
	jsr rand
	lsr
	lsr
	and #$01
	asl
	clc
	adc #$01
	adc ent_d
	and #$03
	sta temp02
	sta temp04
	lda ent_x
	sta temp00
	lda ent_y
	sta temp01
	jsr level_get_block_dir
	bne .next_dir
	lda temp04
	sta ent_d
	jmp .update_position
.next_dir
	lda temp04
	clc
	adc #$02
	and #$03
	sta temp02
	sta temp04
	lda ent_x
	sta temp00
	lda ent_y
	sta temp01
	jsr level_get_block_dir
	bne .turn_around
	lda temp04
	sta ent_d
	jmp .update_position
.turn_around
	ldx ent_d
	lda ent_reverse_table,x
	sta ent_d
.update_position
	; move ent
	beq .ent_right
	cmp #$01
	beq .ent_up
	cmp #$02
	beq .ent_left
	bne .ent_down
.ent_right
	inc ent_x
	jmp .ent_move_done
.ent_up
	dec ent_y
	jmp .ent_move_done
.ent_left
	dec ent_x
	jmp .ent_move_done
.ent_down
	inc ent_y
	jmp .ent_move_done
.ent_move_done
	rts

level_get_block_dir: subroutine
	; temp00 = x position
	; temp01 = y position
	; temp02 = direction
	lda temp02
	beq level_get_block_right
	cmp #$01
	beq level_get_block_up
	cmp #$02
	beq level_get_block_left
	bne level_get_block_down


level_get_block: subroutine
	; temp00 = x position
	; temp01 = y position
	; uses temp02 temp03
	; returns block id in A
	ldy #$00
	sty temp02
	sty temp03
	lda temp01
	asl
	asl
	asl
	asl
	rol temp03
	asl
	rol temp03
	clc
	adc temp00
	sta temp02
	lda #>level_nam
	clc
	adc temp03
	sta temp03
	lda (temp02),y
	rts

	; temp00 = x position
	; temp01 = y position
level_get_block_right: subroutine
	inc temp00
	jmp level_get_block
level_get_block_up: subroutine
	dec temp01
	jmp level_get_block
level_get_block_left: subroutine
	dec temp00
	jmp level_get_block
level_get_block_down: subroutine
	inc temp01
	jmp level_get_block
