;
; KERNEL


bootup: subroutine

	sei
	cld
	ldx #$ff
	txs
	inx
	stx PPU_CTRL
	stx PPU_MASK
	bit PPU_STATUS
	lda #$40
	sta APU_FRAME
	bit APU_CHAN_CTRL
	stx DMC_FREQ

	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait

	jsr ram_clear
	jsr sprites_clear

	; clear nametables
	lda #CTRL_INC_1
	sta PPU_CTRL
	lda #$00
	sta temp00
	sta temp01
	lda #$20
	jsr nameteable_fill
	lda #$24
	jsr nameteable_fill
	lda #$28
	jsr nameteable_fill
	lda #$2c
	jsr nameteable_fill

	; seed rng
	lda #$ff
	sta rng00
	sta rng01

	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL

.endless
	jmp .endless	; endless loop



kernel: subroutine
	rti
