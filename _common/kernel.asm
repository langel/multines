;
; KERNEL

bootup: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait
	jsr ram_clear

	; ppu setup
	lda #CTRL_INC_1
	sta PPU_CTRL

; clear nametables
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

	jsr sprites_clear

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
