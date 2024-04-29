
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
	; move ent
	lda ent_d
	beq .ent_right
	cmp #$01
	beq .ent_up
	cmp #$02
	beq .ent_left
	bne .ent_down
.ent_right
	ldx ent_x
	inx
	stx temp00
	ldx ent_y
	stx temp01
	jsr level_get_block
	sta $0308
	bne .ent_new_direction
	inc ent_x
	jmp .ent_move_done
.ent_up
	ldx ent_x
	stx temp00
	ldx ent_y
	dex 
	stx temp01
	jsr level_get_block
	bne .ent_new_direction
	dec ent_y
	jmp .ent_move_done
.ent_left
	ldx ent_x
	dex 
	stx temp00
	ldx ent_y
	stx temp01
	jsr level_get_block
	bne .ent_new_direction
	dec ent_x
	jmp .ent_move_done
.ent_down
	ldx ent_x
	stx temp00
	ldx ent_y
	inx 
	stx temp01
	jsr level_get_block
	bne .ent_new_direction
	inc ent_y
	jmp .ent_move_done
.ent_new_direction
	jsr rand
	jsr rand
	lsr
	and #$03
	sta ent_d
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
	rts



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
