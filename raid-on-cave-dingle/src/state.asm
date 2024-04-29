
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
	sta ent_x+8
	sta ent_x+16
	sta ent_x+24
	lda #$07
	sta ent_y
	sta ent_y+8
	sta ent_y+16
	sta ent_y+24
	lda #$01
	sta $0303
	;sta $030b
	;sta $0313
	;sta $031b
	rts


state_level_update: subroutine
	jsr ents_update
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
