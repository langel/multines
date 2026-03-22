

nextlevel_palette:
	hex 0f 15 25 14

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

	; clear ent ram
	lda #$00
	tax
.clear_ent_ram
	sta $300,x
	sta $400,x
	sta $500,x
	inx
	bne .clear_ent_ram


	; draw next level screen
	
	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	jsr sprites_clear

	; write level name
	lda #$21
	sta PPU_ADDR
	lda #$08
	sta PPU_ADDR
	lda #$65 ; L
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$6f ; V
	sta PPU_DATA
	lda #$5e ; E
	sta PPU_DATA
	lda #$65 ; L
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	lda #$08 ; space
	sta PPU_DATA
	; current level integers
	ldx game_level
	lda zero_pad_10s_table,x
	clc
	adc #$50
	sta PPU_DATA
	ldx game_level
	lda zero_pad_01s_table,x
	clc
	adc #$50
	sta PPU_DATA

	ldx #state_nextlevel_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine

	lda #$00
	sta state04
	sta state05

	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	jsr render_enable

	rts


state_nextlevel_update: subroutine
	jsr render_enable
	jsr controller_read
	
	clc
	lda state04
	adc #$01
	sta state04
	lda state05
	adc #$00
	sta state05
	cmp #$01
	beq .start_a_game

	lda controller1_d
	beq .dont_start
.start_a_game
	jsr state_game_init
.dont_start

	jmp nmi_update_done



