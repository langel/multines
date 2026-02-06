
title_copy_line:
	hex 65 68 5b 65 5a 6c 6d 78 75 78 66 66 71 71 6f


state_title_init: subroutine

	lda #CTRL_8x8
	sta ppu_ctrl_ora
	lda #$00
	sta scroll_nm
	sta scroll_x
	sta scroll_y
	jsr ent_big_teef_spawn

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
	jsr ents_update

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


	jmp nmi_update_done

