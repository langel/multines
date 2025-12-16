
state_game_render: subroutine

	ldx tooth_update_queue_size
.queue_loop
	lda #$21
	sta PPU_ADDR
	lda tooth_needs_update,x
	sta PPU_ADDR
	tay
	lda tooth_cell_dmg,y
	shift_r 4
	clc
	adc #$a0
	sta PPU_DATA
	dex
	bpl .queue_loop
	ldx #$00
	stx tooth_update_queue_size

	jmp nmi_render_done
