



state_chomp_init:
	
	jsr render_disable
	jsr sprites_clear

	jsr teeth_init_playfield
	; clear undesired tiles
	lda #$0a
	sta temp00
	lda #$0a
	sta temp02
	lda #$00
	sta temp03
	lda #$22
	jsr nametable_fill_rows
	lda #$c0
	sta temp03
	lda #$24
	jsr nametable_fill_rows
	; set nametable palettes
	lda #$ff
	sta temp00
	lda #$01
	sta temp02
	lda #$e0
	sta temp03
	lda #$23
	jsr nametable_fill_rows
	lda #$c0
	sta temp03
	lda #$27
	jsr nametable_fill_rows

	lda #$00
	sta scroll_x
	sta scroll_y
	sta scroll_nm
	lda #$01
	sta state01 ; chomp_teeth_open_dir
	lda #$38
	sta state00 ; chomp_teeth_open

	; how many chomps?
	lda continues
	sta state04
	
	; setup sprite0
	lda #$20
	sta spr_a
	lda #$10
	sta spr_p
	lda #$c8
	sta spr_x
	lda #$77
	sta spr_y

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop

	
	ldx #state_chomp_render_id
	jsr state_set_render_routine
	ldx #state_chomp_update_id
	jsr state_set_update_routine

	jsr apu_init
	
	NMI_ENABLE

	rts



state_chomp_render:
	lda state00
	sta scroll_y
	jmp nmi_render_done



state_chomp_update:
	
	jsr render_enable
	jsr state_chomp_teeth_animate

	lda state01
	bne .chomp_count_done
	lda state00
	cmp #$04
	bne .chomp_count_done
	dec state04 
	bpl .chomp_count_done
	jsr chompchamp_reset_game
	jsr state_game_level_init
	jmp nmi_update_done
.chomp_count_done

	jsr apu_update
	jsr controller_read

	lda controller1_d
	and #BUTTON_B
	beq .no_b_butt
	jsr sfx_pewpew
.no_b_butt

	jsr state_chomp_sprite0_split
	
	jmp nmi_update_done



state_chomp_teeth_animate: subroutine
	lda state01 ; chomp_teeth_open_dir
	beq .opening
.closing
	lda state00 ; chomp_teeth_open
	beq .flip_open
	cmp #$28
	bne .chomp_sample_done
	lda #$0f
	sta $4010
	lda #$80
	sta $4012
	lda #$2d
	sta $4013
	lda #%00001111
	sta $4015
	lda #%00011111
	sta $4015
.chomp_sample_done
	lda state00
	sec
	sbc #$04
	sta state00
	cmp #$e6
	bcc .openness_done
.flip_open
	lda #$00
	sta state01
	jmp .openness_done
.opening
	lda state00
	clc
	adc #$04
	sta state00
	cmp #$28
	bcc .openness_done
	lda #$01
	sta state01
.openness_done
	; set bottom scroll_y
	lda #$80
	sec 
	sbc state00
	clc
	adc #$08
	sta state03
	rts



state_chomp_sprite0_split: subroutine

	; fine scrolling cache
	lda #$22 ; camera_nm
	lsr
	lda #$00
	rol
	shift_l 2
	sta temp04
	;lda #$20 ; y offset
	lda state03
	sta temp05
	and #%11111000
	shift_l 2
	sta temp04 ; temp
	ldx camera_x
	stx temp06
	txa
	shift_r 3
	ora temp04 
	sta temp07

	ldx temp05
	ldy temp06

.wait0
	bit PPU_STATUS
	bvs .wait0
	lda #$c0
.wait1
	bit PPU_STATUS
	beq .wait1

	; freeze output while scroll target is switched
	lda #$00
	sta PPU_CTRL
	sta PPU_MASK

	; switch to bottom-teeth view with adjustable openness
	; fine scrolling write
	lda temp04
	sta PPU_ADDR
	stx PPU_SCROLL
	sty PPU_SCROLL
	lda temp07
	sta PPU_ADDR

	ldx #$0f
.scan_wait
	dex
	bne .scan_wait
	nop

	lda #CTRL_NMI|CTRL_BG_1000|$01
	sta PPU_CTRL
	lda #%00011110
	sta PPU_MASK

	rts
