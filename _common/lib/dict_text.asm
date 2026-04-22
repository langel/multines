;
; Dictionary-backed text plotting
;
; Inputs:
;   temp00..temp01 = passage pointer
;   temp02..temp03 = nametable target address
;   temp04         = options bits %xxxx3210
;                    bit3: two consecutive spaces become three spaces (overrides bit1)
;                    bit2: PPU increment (0=1, 1=32)
;                    bit1: put a space between every character
;                    bit0: add blank line between lines
;   alphabet_table_lo/alphabet_table_hi = pointer to game alphabet table
;                                          (ASCII $20-$5f -> tile id)
;
; Scratch:
;   temp05 bit0 = previous emitted char was space
;   temp05 bit6 = previous non-space emitted a bit1-injected space
;   temp06      = saved X register inside dict_emit_tile
;
; Clobbers:
;   dict_emit_offset_char / dict_emit_tile clobber X and Y
;

dict_text_plot: subroutine
	lda #$00
	sta temp05

	; set PPU increment mode from bit2 only
	lda temp04
	and #%00000100
	beq .inc_1
	lda #CTRL_INC_32
	bne .set_ctrl
.inc_1
	lda #CTRL_INC_1
.set_ctrl
	sta PPU_CTRL

	; set initial PPU address from temp02/temp03
	lda temp03
	sta PPU_ADDR
	lda temp02
	sta PPU_ADDR

.next_byte
	ldy #$00
	lda (temp00),y
	cmp #DICT_END_OF_PASSAGE_BYTE
	bne .not_end_of_passage
	jmp .done
.not_end_of_passage
	cmp #DICT_NEWLINE_BYTE
	bne .not_newline
	jmp .handle_newline
.not_newline
	cmp #DICT_TOKEN_HI_MIN
	bcs .handle_token
	cmp #$40
	bcs .handle_char_with_space

	; literal char in range $00-$3f (ASCII offset)
	jsr dict_emit_offset_char
	jsr dict_advance_passage_ptr
	jmp .next_byte

.handle_char_with_space
	; packed char+space in range $40-$7f
	sec
	sbc #$40
	jsr dict_emit_offset_char
	lda #$00 ; ASCII offset for space
	jsr dict_emit_offset_char
	jsr dict_advance_passage_ptr
	jmp .next_byte

.handle_token
	; token class + dict pointer lo byte
	tax                     ; token hi
	lda temp02
	pha
	lda temp03
	pha
	txa
	pha                     ; save token hi for suffix decode

	; move to token lo byte in passage stream
	jsr dict_advance_passage_ptr
	ldy #$00
	lda (temp00),y
	sta temp02              ; dictionary pointer lo
	pla                     ; token hi
	and #$0f
	clc
	adc #>DICT_BASE_ADDR
	sta temp03              ; dictionary pointer hi
	txa
	pha                     ; keep token hi for suffix after word emit

	; emit dictionary entry: [length][ASCII bytes...]
	ldy #$00
	lda (temp02),y
	tax                     ; length
	beq .token_suffix
	jsr dict_advance_dict_ptr
.token_char_loop
	ldy #$00
	lda (temp02),y
	jsr dict_emit_ascii_char
	jsr dict_advance_dict_ptr
	dex
	bne .token_char_loop

.token_suffix
	pla
	sec
	sbc #DICT_TOKEN_HI_MIN
	lsr
	lsr
	lsr
	lsr                     ; token class 0..6
	beq .token_done
	cmp #$01
	beq .suffix_space
	cmp #$02
	beq .suffix_period
	cmp #$03
	beq .suffix_exclaim
	cmp #$04
	beq .suffix_question
	cmp #$05
	beq .suffix_s
	cmp #$06
	beq .suffix_r
	jmp .token_done

.suffix_space
	lda #$20
	jsr dict_emit_ascii_char
	jmp .token_done
.suffix_period
	lda #$2e
	jsr dict_emit_ascii_char
	jmp .token_done
.suffix_exclaim
	lda #$21
	jsr dict_emit_ascii_char
	jmp .token_done
.suffix_question
	lda #$3f
	jsr dict_emit_ascii_char
	jmp .token_done
.suffix_s
	lda #$53
	jsr dict_emit_ascii_char
	jmp .token_done
.suffix_r
	lda #$52
	jsr dict_emit_ascii_char

.token_done
	; restore nametable target pointer
	pla
	sta temp03
	pla
	sta temp02

	; consume token lo byte and continue
	jsr dict_advance_passage_ptr
	jmp .next_byte

.handle_newline
	; newline address delta truth table:
	;            bit0=0   bit0=1
	; bit2=0      #$20     #$40
	; bit2=1      #$01     #$02
	lda temp04
	and #%00000100
	beq .newline_inc1

	lda temp04
	and #%00000001
	beq .newline_add_01
	lda #$02
	bne .newline_add
.newline_add_01
	lda #$01
	bne .newline_add

.newline_inc1
	lda temp04
	and #%00000001
	beq .newline_add_20
	lda #$40
	bne .newline_add
.newline_add_20
	lda #$20

.newline_add
	clc
	adc temp02
	sta temp02
	lda temp03
	adc #$00
	sta temp03

	; reload updated PPU address
	lda temp03
	sta PPU_ADDR
	lda temp02
	sta PPU_ADDR

	; line break resets consecutive-space tracking
	lda #$00
	sta temp05
	jsr dict_advance_passage_ptr
	jmp .next_byte

.done
	rts


dict_advance_passage_ptr: subroutine
	inc temp00
	bne .done
	inc temp01
.done
	rts


dict_advance_dict_ptr: subroutine
	inc temp02
	bne .done
	inc temp03
.done
	rts


dict_emit_ascii_char: subroutine
	; A = ASCII char in $20-$5f
	sec
	sbc #$20
	; fall through

dict_emit_offset_char: subroutine
	; A = ASCII offset in $00-$3f
	tay
	lda (alphabet_table_lo),y
	; fall through

dict_emit_tile: subroutine
	; A = tile id to emit with spacing options
	stx temp06
	sta PPU_DATA

	; detect whether emitted char is a space tile (alphabet offset 0)
	ldy #$00
	cmp (alphabet_table_lo),y
	beq .space_char

	; not a source space: clear spacing state
	lda #$00
	sta temp05
	jmp .maybe_bit1_spacing

.space_char
	lda temp05
	and #$01
	beq .first_space
	; consecutive source spaces
	lda temp04
	and #%00001000
	beq .mark_space_only
	; bit3 enabled:
	; - bit1 off: add one extra space on second consecutive space (2 -> 3)
	; - bit1 on : do NOT add bit1 spacing for second space (4 -> 3)
	lda temp04
	and #%00000010
	bne .bit3_consecutive_done
	lda (alphabet_table_lo),y
	sta PPU_DATA
.bit3_consecutive_done
	lda #$01
	sta temp05
	jmp .done

.mark_space_only
	lda #$01
	sta temp05
	jmp .maybe_bit1_spacing

.first_space
	lda temp05
	and #%01000000
	pha
	lda #$01
	sta temp05
	pla
	beq .maybe_bit1_spacing
	; if previous non-space already injected one space, and bit1+bit3 are set,
	; suppress bit1 on this first source space so one-space and two-space cases
	; can both land on the requested totals.
	lda temp04
	and #%00001010
	cmp #%00001010
	bne .maybe_bit1_spacing
	jmp .done

.maybe_bit1_spacing
	lda temp04
	and #%00000010
	beq .done

.emit_bit1_space
	ldy #$00
	lda (alphabet_table_lo),y
	sta PPU_DATA
	lda temp05
	and #$01
	bne .emit_from_space
	lda #%01000000
	sta temp05
	jmp .done
.emit_from_space
	lda #$01
	sta temp05

.done
	ldx temp06
	rts
