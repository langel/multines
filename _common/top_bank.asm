;
; COMMON SUBROUTINES


	include "./_common/src/input.asm"
	include "./_common/src/math.asm"
	include "./_common/src/nametable.asm"
	include "./_common/src/nmi.asm"
	include "./_common/src/rng.asm"
	include "./_common/src/sprite.asm"
	include "./_common/src/state.asm"



bootup_clean: subroutine
	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait

	;jsr ram_clear
	jsr sprites_clear

	; clear nametables
	lda #$00
	sta PPU_CTRL
	sta temp00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill
	lda #$28
	jsr nametable_fill
	lda #$2c
	jsr nametable_fill

	; seed rng
	lda #$ff
	sta rng00
	sta rng01

	ldx #render_do_nothing_id
	jsr state_set_render_routine
	ldx #update_do_nothing_id
	jsr state_set_update_routine

	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	rts



do_nothing: subroutine
	rts




registers_clear: subroutine
	lda #$00
	sta temp00
	sta temp01
	sta temp02
	sta temp03
	sta temp04
	sta temp05
	sta state00
	sta state01
	sta state02
	sta state03
	sta state04
	sta state05
	sta state06
	sta state07
	rts

        
        
ram_clear: subroutine
	lda #0	; A = 0
	tax		; X = 0
.loop
	sta $000,x	; clear $0-$ff
	; skip stack page
	sta $200,x	; clear $200-$2ff
	sta $300,x	; clear $300-$3ff
	sta $400,x	; clear $400-$4ff
	sta $500,x	; clear $500-$5ff
	sta $600,x	; clear $600-$6ff
	sta $700,x	; clear $700-$7ff
	inx		; X = X + 1
	bne .loop	; loop 256 times
	rts


render_enable:
	lda #CTRL_NMI|CTRL_BG_1000
	sta PPU_CTRL	; enable NMI
	lda ppu_mask_emph
	ora #MASK_BG|MASK_SPR|MASK_SPR_CLIP|MASK_BG_CLIP
	sta PPU_MASK	; enable rendering
	rts


render_disable:
	lda #$00
	sta PPU_MASK	
	sta PPU_CTRL	
	rts


vsync_wait:
	bit PPU_STATUS
	bpl vsync_wait
	rts


collision_detect: subroutine
	; returns true/false in a
	clc
	lda collision_0_x
	adc collision_0_w
	bcs .no_collision ; make sure x+w is not less than x
	cmp collision_1_x
	bcc .no_collision
	clc
	lda collision_1_x
	adc collision_1_w
	cmp collision_0_x
	bcc .no_collision
	clc
	lda collision_0_y
	adc collision_0_h
	cmp collision_1_y
	bcc .no_collision
	clc 
	lda collision_1_y
	adc collision_1_h
	cmp collision_0_y
	bcc .no_collision
.collision
	lda #$ff
	rts
.no_collision
	lda #$00
	rts


                

sine_table:
	hex 808386898c8f9295
	hex 989b9ea2a5a7aaad
	hex b0b3b6b9bcbec1c4
	hex c6c9cbced0d3d5d7
	hex dadcdee0e2e4e6e8
	hex eaebedeef0f1f3f4
	hex f5f6f8f9fafafbfc
	hex fdfdfefefeffffff
	hex fffffffffefefefd
	hex fdfcfbfafaf9f8f6
	hex f5f4f3f1f0eeedeb
	hex eae8e6e4e2e0dedc
	hex dad7d5d3d0cecbc9
	hex c6c4c1bebcb9b6b3
	hex b0adaaa7a5a29e9b
	hex 9895928f8c898683
	hex 807c797673706d6a
	hex 6764615d5a585552
	hex 4f4c494643413e3b
	hex 393634312f2c2a28
	hex 2523211f1d1b1917
	hex 151412110f0e0c0b
	hex 0a09070605050403
	hex 0202010101000000
	hex 0000000001010102
	hex 0203040505060709
	hex 0a0b0c0e0f111214
	hex 1517191b1d1f2123
	hex 25282a2c2f313436
	hex 393b3e414346494c
	hex 4f5255585a5d6164
	hex 676a6d707376797c
        
        
        
decimal_99_text_offset_80:
	hex 0080008100820083008400850086008700880089
	hex 8180818181828183818481858186818781888189
	hex 8280828182828283828482858286828782888289
	hex 8380838183828383838483858386838783888389
	hex 8480848184828483848484858486848784888489
	hex 8580858185828583858485858586858785888589
	hex 8680868186828683868486858686868786888689
	hex 8780878187828783878487858786878787888789
	hex 8880888188828883888488858886888788888889
	hex 8980898189828983898489858986898789888989

