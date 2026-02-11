
state_nextlevel_init: subroutine
	jsr render_disable
	
	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	jsr sprites_clear

	; write level name
	lda #$21
	sta PPU_ADDR
	lda #$08
	sta PPU_ADDR
	lda #$65 ; L
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$6f ; V
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$65 ; L
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$50
	sta PPU_DATA
	lda #$51
	sta PPU_DATA


	jsr palette_init

	ldx #state_nextlevel_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	jsr render_enable

	rts


state_nextlevel_update: subroutine
	jsr render_enable
	jmp nmi_update_done
