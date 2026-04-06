
congration_palette:
	hex 0f 15 25 14

state_congration_init: subroutine

	jsr render_disable

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	jsr sprites_clear
	
	; setup pallete
	ldx #$00
.pal_loop
	lda congration_palette,x
	sta palette_cache,x
	inx
	cpx #$04
	bne .pal_loop

	; pattern 2 nametable
	; setup color tiles
	lda #$08
	sta temp04
	lda #$09
	sta temp05
	lda #$0a
	sta temp06
	lda #$0b
	sta temp07
	; pattern 1
	lda #$68
	sta temp00
	lda #$00
	sta temp01
	lda #$68
	sta temp02
	lda #$20
	sta temp03
	jsr metapattern_to_nametable_8x16

	ldx #state_congration_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	sta scroll_y

	jsr apu_init
	
	NMI_ENABLE

	rts




state_congration_update: subroutine
	jsr render_enable

	jsr apu_update


	lda wtf
	cmp #$20
	bne .no_sound
	jsr sfx_brush_down
.no_sound

	jmp nmi_update_done



