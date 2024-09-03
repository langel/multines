
; XXX need 2nd controller
; potentially zapper and others?

; CONTROLLER READING

controller_poller: subroutine
	ldx #$01
	stx JOYPAD1
	dex
	stx JOYPAD1
	ldx #$08
.read_loop
	lda JOYPAD1
	lsr
	rol temp00
	lsr
	rol temp01
	dex
	bne .read_loop
	lda temp00
	ora temp01
	sta temp00
	rts

controller_read: subroutine
	jsr controller_poller
.checksum_loop
	ldy temp00
	jsr controller_poller
	cpy temp00
	bne .checksum_loop
	lda temp00
	tay
	eor controls
	and temp00
	sta controls_d
	sty controls
	rts


