
spr_y  eqm $0200
spr_i  eqm $0201
spr_a  eqm $0202
spr_x  eqm $0203

ent_x_tab:
	hex 02 03 04 05 
	hex 02 03 04 05 06 07 08 09 10 11
	hex 02 03 04 05 06 07 08 09 10 11
ent_y_tab:
	hex 07 07 07 07
	hex 0b 0b 0b 0b 0b 0b 0b 0b 0b 0b
	hex 0d 0d 0d 0d 0d 0d 0d 0d 0d 0d

state_level_init: subroutine
	ldx #$00
.loop
	txa
	asl
	asl
	asl
	tay
	lda #$01
	sta ent_type,y
	lda ent_x_tab,x
	sta ent_x_grid,y
	lda ent_y_tab,x
	sta ent_y_grid,y
	tya
	lsr
	tay
	lda #$02
	sta spr_i,y
	lda #$00
	sta spr_a,y
	inx
	cpx #24
	bne .loop
	rts

	lda #$02
	sta spr_i
	sta spr_i+4
	sta spr_i+8
	sta spr_i+12
	lda #$00
	sta spr_a
	sta spr_a+4
	sta spr_a+8
	sta spr_a+12
	lda #$02
	sta ent_x_grid
	lda #$03
	sta ent_x_grid+8
	lda #$04
	sta ent_x_grid+16
	lda #$05
	sta ent_x_grid+24
	lda #$07
	sta ent_y_grid
	sta ent_y_grid+8
	sta ent_y_grid+16
	sta ent_y_grid+24
	lda #$01
	sta ent_type
	sta ent_type+8
	sta ent_type+16
	sta ent_type+24
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
