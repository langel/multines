


bootup_clean: subroutine
	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait

	jsr ram_clear
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

