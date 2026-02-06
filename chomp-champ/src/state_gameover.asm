

state_gameover_init: subroutine
	jsr render_disable

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	jsr sprites_clear

	; write game over
	lda #$21
	sta PPU_ADDR
	lda #$08
	sta PPU_ADDR
	lda #$60 ; G
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$5a ; A
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$66 ; M
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$68 ; O
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$6f ; V
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$6b ; R
	sta PPU_DATA

	jsr palette_init

	ldx #state_gameover_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	jsr render_enable

	rts


state_gameover_update: subroutine
	jsr render_enable
	jmp nmi_update_done
