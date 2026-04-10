

nextlevel_palette:
	hex 0f
	hex 07 26 20

nextlevel_text_left_margin:
	hex 03 07 07 04 06 05
	hex 04 05 03 04 05 0a
	hex 07 06 06 08 04 06
	hex 06 06 06 06 04 05
	hex 04 03 02 07

state_nextlevel_init: subroutine
	jsr render_disable

	; set up next level in ram
	inc game_level

	; setup pallete
	ldx #$00
.pal_loop
	lda nextlevel_palette,x
	sta palette_cache,x
	inx
	cpx #$04
	bne .pal_loop
	; text color
	lda #$35
	sta palette_cache+8
	
	jsr sprites_clear

	; draw next level screen
	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	
	; teeth owner head render
	lda #$08
	sta temp04
	lda #$09
	sta temp05
	lda #$0a
	sta temp06
	lda #$0b
	sta temp07
	; meta pattern 
	lda #$78
	sta temp00
	lda #$00
	sta temp01
	lda #$48
	sta temp02
	lda #$20
	sta temp03
	jsr metapattern_to_nametable_8x16

	; teeth
	ldy #$0c
	lda #$21
	sta PPU_ADDR
	lda #$ac
	sta PPU_ADDR
	ldx #$00
.teeth_loop
	lda tooth_total_dmg,x
	bmi .missing_tooth
.has_tooth
	sty PPU_DATA
	jmp .tooth_done
.missing_tooth
	lda #$08
	sta PPU_DATA
.tooth_done
	inx
	; check next row
	cpx #$08
	bne .more_loop
	ldy #$05
	lda #$21 
	sta PPU_ADDR
	lda #$cc
	sta PPU_ADDR
.more_loop
	cpx #$10
	bne .teeth_loop
	
	; dictionary text plotting
	clc
	lda game_level
;; xxxx test stuff
	;lda #$1c
	;sta game_level
;; xxxx done
	adc #$08
	tax
	lda chomp_champ_passage_ptr_lo,x
	sta temp00
	lda chomp_champ_passage_ptr_hi,x
	sta temp01
	lda #$a0
	ldy game_level
	dey
	clc
	adc nextlevel_text_left_margin,y
	sta temp02
	lda #$22
	sta temp03
	lda #%000000001
	sta temp04
	jsr dict_text_plot
	; text colors
	lda #$23
	sta PPU_ADDR
	lda #$e8
	sta PPU_ADDR
	lda #%10101010
	ldx #$10
.attr_loop
	sta PPU_DATA
	dex
	bne .attr_loop


	ldx #state_nextlevel_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine

	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	lda #$ea
	sta scroll_y
	NMI_ENABLE

	rts



state_nextlevel_update: subroutine
	jsr render_enable
	jsr controller_read
	
	lda controller1_d
	and #$f0
	beq .start_done
.start_a_game
	lda game_level
	cmp #$1c
	bne .next_level
	jsr state_congration_init
	jmp .start_done
.next_level
	jsr state_game_level_init
.start_done

	; rotate text color
	lda wtf
	and #$1f
	bne .color_fine
	inc palette_cache+8
	lda palette_cache+8
	cmp #$3d
	bne .color_fine
	lda #$31
	sta palette_cache+8
.color_fine

	jmp nmi_update_done



