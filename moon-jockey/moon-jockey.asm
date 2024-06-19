
	processor 6502

	include "../_common/definitions.asm"
	include "zero_page.asm"

	; HEADER
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER_NROM_128 0,1,1,NES_MIRR_VERT 

grid_nam:
	incbin "assets/grid.nam"

	include "../_common/util.asm"

grid_pal:
	hex 0f 01 11 21
	hex 0f 05 15 25
	hex 0f 07 17 27
	hex 0f 09 19 29
	hex 0f 01 11 21
	hex 0f 05 15 25
	hex 0f 07 17 27
	hex 0f 09 19 29

cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait
	jsr ram_clear
;	jsr sprites_clear

	; ppu setup
	lda #CTRL_INC_1
	sta PPU_CTRL

	; nametable	1
	lda #$00
	sta temp00
	lda #$80
	sta temp01
	lda #$20
	jsr nametable_load
	; nametable	2
	lda #$00
	sta temp00
	lda #$80
	sta temp01
	lda #$24
	jsr nametable_load

	; palette
	PPU_ADDR_SET $3f00
	ldx #$00
.pal_loop
	lda grid_pal,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .pal_loop

	; clear sprites
	lda #$ff
	ldx #$00
.sprite_clear
	sta $0200,x
	inx
	bne .sprite_clear

	; setup vert split luts
;	yyy NN YYYYY XXXXX
;	||| || ||||| +++++-- coarse X scroll
;	||| || +++++-------- coarse Y scroll
;	||| ++-------------- nametable select
;	+++----------------- fine Y scroll
;  lo byte YYYXXXXX
	ldx #$00
.split_lut_lo_loop_40
	txa
	SHIFT_L 5
	ora #$08
	sta $0400,x
	inx
	bne .split_lut_lo_loop_40
.split_lut_lo_loop_80
	txa
	SHIFT_L 5
	ora #$10
	sta $0500,x
	inx
	bne .split_lut_lo_loop_80
.split_lut_lo_loop_c0
	txa
	SHIFT_L 5
	ora #$18
	sta $0600,x
	inx
	bne .split_lut_lo_loop_c0
;  hi byte 0yyyNNYY
.split_lut_hi_loop
	txa
	SHIFT_R 6
	sta temp00
	txa
	SHIFT_L 4
	ora temp00
	and #%01110011
	sta $0700,x
	inx 
	bne .split_lut_hi_loop


	; good stuff
	lda #$ff
	sta rng0

	;jsr state_level_init

	jsr render_enable
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL

.endless
	jmp .endless	; endless loop

SLEEP_CYCLES EQM 8054

nmi_handler: subroutine
	inc wtf
	lda #$02
	sta $4014
	;jsr state_level_update
	IF 0
	;; HORIZONTAL PARALLAX
	ldx $80
	ldy #$00
	stx PPU_SCROLL
	sty PPU_SCROLL
	SLEEP 3700
	ldx $81
	stx PPU_SCROLL
	sty PPU_SCROLL
	SLEEP 5400
	ldx $82
	stx PPU_SCROLL
	sty PPU_SCROLL
	SLEEP 5400
	ldx $83
	stx PPU_SCROLL
	sty PPU_SCROLL
	SLEEP 5400
	ldx $84
	stx PPU_SCROLL
	sty PPU_SCROLL
	SLEEP 5400
	ldx $85
	stx PPU_SCROLL
	sty PPU_SCROLL
	ENDIF
	;; VERTICAL TAKE ][
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	tay
	SLEEP 4658
.vert_line_loop
	; col 1
	tya
	clc
	adc $40
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0400,x
	sta PPU_ADDR
	; col 2
	tya
	clc
	adc $41
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0500,x
	sta PPU_ADDR
	; col 3
	tya
	clc
	adc $42
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0600,x
	sta PPU_ADDR
	; col x
	tya
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0400,x
	sta PPU_ADDR
	;inc $40
	;inc $41
	SLEEP 12
	; loop
	iny
	; col 1
	tya
	clc
	adc $40
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0400,x
	sta PPU_ADDR
	; col 2
	tya
	clc
	adc $41
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0500,x
	sta PPU_ADDR
	; col 3
	tya
	clc
	adc $42
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0600,x
	sta PPU_ADDR
	; col x
	tya
	tax
	lda $0700,x
	sta PPU_ADDR
	lda $0400,x
	sta PPU_ADDR
	;inc $40
	;inc $41
	lda $00
	SLEEP 12
	; loop
	iny
	cpy #200
	beq .vert_lines_done
	jmp .vert_line_loop
.vert_lines_done
	IF 0
	;; VERTICAL PARALLAX
	ldy #$00
	ldx #$00
	stx PPU_SCROLL
	stx PPU_SCROLL
	SLEEP 4786
.vert_line_loop
	; col 1
	lda $80
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a0
	sta PPU_ADDR
	inc $a0
	; col 2
	lda $81
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a1
	sta PPU_ADDR
	; col 3
	lda $82
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a2
	sta PPU_ADDR
	; 0,0 border
	lda $83
	stx PPU_ADDR
	stx PPU_SCROLL
	stx PPU_SCROLL
	stx PPU_ADDR
; DO IT TWICE
	;lda $00
	SLEEP 20
	; col 1
	lda $80
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a0
	sta PPU_ADDR
	inc $a1
	; col 2
	lda $81
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a1
	sta PPU_ADDR
	; col 3
	lda $82
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	lda $a2
	sta PPU_ADDR
	; 0,0 border
	lda $83
	stx PPU_ADDR
	sta PPU_SCROLL
	stx PPU_SCROLL
	stx PPU_ADDR
;	SLEEP 8
;	lda $84
;	stx PPU_SCROLL
;	sta PPU_SCROLL
;	SLEEP 8
;	lda $85
;	stx PPU_SCROLL
;	sta PPU_SCROLL
	lda #$00
	SLEEP 12
	lda $00
	iny
	cpy #80
	beq .vert_lines_done
	jmp .vert_line_loop
.vert_lines_done
	ENDIF

	; row 1
	lda $90
	clc
	adc #17
	sta $90
	lda #$0
	adc $80
	sta $80
	and #%00111000
	asl
	asl
	sta $a0
	; row 2
	lda $91
	clc
	adc #47
	sta $91
	lda $81
	adc #$0
	sta $81
	and #%00111000
	asl
	asl
	sta $a1
	; row 3
	lda $92
	clc
	adc #83
	sta $92
	lda $82
	adc #$0
	sta $82
	sta $40
	and #%00111000
	asl
	asl
	sta $a2
	; row 4
	lda $92
	clc
	adc #151
	sta $93
	lda $83
	adc #$0
	sta $83
	sta $41
	; row 5
	lda $94
	clc
	adc #211
	sta $94
	lda $84
	adc #$0
	sta $84
	sta $42
	;row 6
	lda $95
	clc
	adc #7
	sta $95
	lda $85
	adc #$0
	sta $85
	inc $85
	rti

	
	;;;;; CPU VECTORS
	seg VECTORS
	org $fffa ; start at address $fffa
	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word cart_start	; $fffe irq / brk


	;;;;; GRAPHX
	org $010000
	incbin "assets/patterns.chr"
	incbin "assets/patterns.chr"
