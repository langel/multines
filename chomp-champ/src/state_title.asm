
title_copy_line:
	hex 65 68 5b 65 5a 6c 6d 78 75 78 66 66 71 71 6f


state_title_init: subroutine

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	; load title graphic
	; chomp
	lda #$20
	sta PPU_ADDR
	lda #$60
	sta PPU_ADDR
	lda #<title_screen_nam
	sta temp00
	lda #>title_screen_nam
	sta temp01
	ldy #$00
.load_chomp
	lda (temp00),y
	sta PPU_DATA
	iny
	cpy #$c0
	bne .load_chomp
	; champ
	lda #$21
	sta PPU_ADDR
	lda #$60
	sta PPU_ADDR
	lda #<(title_screen_nam+$c0)
	sta temp00
	lda #>(title_screen_nam+$c0)
	sta temp01
	ldy #$00
.load_champ
	lda (temp00),y
	sta PPU_DATA
	iny
	cpy #$c0
	bne .load_champ
	; load copy line
	lda #$23
	sta PPU_ADDR
	lda #$68
	sta PPU_ADDR
	lda #<title_copy_line
	sta temp00
	lda #>title_copy_line
	sta temp01
	ldy #$00
.load_copy
	lda (temp00),y
	sta PPU_DATA
	iny
	cpy #$0f
	bne .load_copy

	; setup big teef
	lda #$68
	sta state02 ; x pos
	lda #$a0
	sta state03 ; y pos


	jsr palette_init
	ldx #state_title_update_id
	jsr state_set_update_routine
	jsr render_enable

	rts
	

	
state_title_update: subroutine
	jsr render_enable
.palette_cycle
	lda wtf
	bne .not_next
	inc state01
.not_next
	lda state01
	and #$02
	beq .throb_asym
.throb_symm
	lda state00
	clc
	adc #$07
	sta state00
	jmp .throb_done
.throb_asym
	lda wtf
	SHIFT_R 4
	clc
	adc state00
	sta state00
.throb_done
	tax
	; color 3
	lda sine_table,x
	SHIFT_R 6
	SHIFT_L 4
	clc
	adc #title_screen_line_pal_base
	sta palette_cache+3
	; color 1
	lda state00
	clc
	adc #$20
	tax
	lda sine_table,x
	SHIFT_R 7
	SHIFT_L 4
	tay
	clc
	adc #$05
	sta palette_cache+1
	; color 2
	lda state00
	clc
	adc #$40
	tax
	lda sine_table,x
	SHIFT_R 7
	SHIFT_L 4
	tay
	clc
	clc
	adc #$15
	sta palette_cache+2
; throb canclel
	lda state01
	and #$03
	cmp #$03
	beq .throb_cancel
	and #$03
	bne .throb_dont_cancel
.throb_cancel
	lda #$15
	sta palette_cache+1
	lda #$25
	sta palette_cache+2
.throb_dont_cancel




	; big teef
	lda #$16
	sta palette_cache+13
	lda #$14
	sta palette_cache+14
	lda #$27
	sta palette_cache+15


	ldx #$00
	ldy #$00
.big_teef_sprites_attrs
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	INC_Y 4
	inx
	cpx #26
	bne .big_teef_sprites_attrs

	; upper mandible
	; x pos
	ldy #$00
	clc
	lda state02 ; x origin
.big_teef_uppers_x
	sta spr_x,y
	sta spr_x+24,y
	adc #$08
	INC_Y 4
	cpy #24
	bne .big_teef_uppers_x
	; y pos
	clc
	lda state03 ; y origin
	sta spr_y
	sta spr_y+4
	sta spr_y+8
	sta spr_y+12
	sta spr_y+16
	sta spr_y+20
	adc #$08
	sta spr_y+24
	sta spr_y+28
	sta spr_y+32
	sta spr_y+36
	sta spr_y+40
	sta spr_y+44

	; lower mandible
	ldy #48
	; x pos
	clc
	lda state02 ; x origin
.big_teef_lowers_x
	sta spr_x,y
	sta spr_x+24,y
	adc #$08
	INC_Y 4
	cpy #72
	bne .big_teef_lowers_x
	; y pos
	ldy #48
	clc
	ldx state04
	lda sine_table,x
	SHIFT_R 5
	adc state03 ; y origin
	adc #$08
	sta spr_y,y
	sta spr_y+4,y
	sta spr_y+8,y
	sta spr_y+12,y
	sta spr_y+16,y
	sta spr_y+20,y
	adc #$08
	sta spr_y+24,y
	sta spr_y+28,y
	sta spr_y+32,y
	sta spr_y+36,y
	sta spr_y+40,y
	sta spr_y+44,y

	; connective tissue
	ldy #96
	; x pos
	lda state02
	sta spr_x,y
	sta spr_x+4,y
	; y pos
	ldx state04
	lda sine_table,x
	SHIFT_R 6
	adc #$04
	adc state03
	sta spr_y,y
	clc
	adc #$08
	sta spr_y+4,y

	; forward the animation counter
	inc state02
	lda state04
	tax
	lda sine_table,x
	shift_r 5
	clc
	adc #$a0
	sta state03
	inc state04
	inc state04
	inc state04

	inc scroll_x

	jmp nmi_update_done


big_teef_sprites:
	; upper mandible
	hex 0b 0c 0d 0d 0e 0f
	hex 1b 1c 1d 1d 1e 1f
	; lower mandible
	hex 2b 2c 2d 2d 2e 2f
	hex 3b 3c 3d 3d 3e 3f
	; connective tissue
	hex 0a 1a

big_teef_attrs:
	; upper mandible
	hex 00 00 00 40 00 00
	hex 00 00 00 40 00 00
	; lower mandible
	hex 00 00 40 00 00 00
	hex 00 00 40 00 00 00
	; connective tissue
	hex 00 00

