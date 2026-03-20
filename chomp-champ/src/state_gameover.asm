
text_game_over:
	hex 60 08 5a 08 66 08 5e 08 
	hex 08 68 08 6f 08 5e 08 6b

text_all_tooths_lost:
	hex 5a 08 65 08 65 08 08
	hex 6d 08 68 08 68 08 6d 08 61 08 6c 08 08
	hex 65 08 68 08 6c 08 6d


state_gameover_init: subroutine
	jsr render_disable

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	jsr sprites_clear
	jsr palette_init

	
	; player head render
	lda #$08
	sta temp04
	lda #$09
	sta temp05
	lda #$0a
	sta temp06
	lda #$0b
	sta temp07
	; meta pattern 
	lda #$b8
	sta temp00
	lda #$00
	sta temp01
	lda #$25
	sta temp02
	lda #$21
	sta temp03
	jsr metapattern_to_nametable_8x16


	lda #$20
	sta PPU_ADDR
	lda #$83
	sta PPU_ADDR
	; write all tooths lost
	ldx #$00
.all_tooths_lost_loop
	lda text_all_tooths_lost,x
	sta PPU_DATA
	inx
	cpx #$1b
	bne .all_tooths_lost_loop


	; vertical texts
	lda #CTRL_INC_32
	sta PPU_CTRL

	lda #$21
	sta PPU_ADDR
	lda #$3a
	sta PPU_ADDR
	; write game over
	ldx #$00
.game_over_loop
	lda text_game_over,x
	sta PPU_DATA
	inx
	cpx #$10
	bne .game_over_loop


	ldx #state_gameover_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	jsr render_enable

	lda #$00
	sta state00
	sta state01

	rts


state_gameover_update: subroutine
	jsr render_enable

	inc state00
	lda state00
	cmp #$00
	bne .not_reset
	jsr state_game_init
.not_reset

	jmp nmi_update_done
	

