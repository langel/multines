
palette_game_over:
	; bg
	hex 0f
	; tiles
	hex 02 21 0f
	hex 15 16 14
	hex 0f 27 0f



state_gameover_init: subroutine

	jsr render_disable
	jsr sprites_clear
	
	ldx #state_gameover_update_id
	jsr state_set_update_routine
	ldx #render_do_nothing_id
	jsr state_set_render_routine

	; load palette
	ldx #$00
.pal_loop
	lda palette_game_over,x
	sta palette_cache,x
	inx
	cpx #$0a
	bne .pal_loop

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	
	; player head render
	lda #$08
	sta temp04
	lda #$09
	sta temp05
	lda #$0a
	sta temp06
	lda #$0b
	sta temp07
	; meta pattern 
	lda #$b8
	sta temp00
	lda #$00
	sta temp01
	lda #$25
	sta temp02
	lda #$21
	sta temp03
	jsr metapattern_to_nametable_8x16

	; attri
	lda #$23
	sta PPU_ADDR
	lda #$c8
	sta PPU_ADDR
	lda #%10101010
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA

	; write lifes dead
	lda player_lives
	bpl .not_lifes_dead
	lda #<chomp_champ_passage_03
	sta temp00
	lda #>chomp_champ_passage_03
	sta temp01
	lda #$83
	sta temp02
	lda #$20
	sta temp03
	lda #%00001010
	sta temp04
	jsr dict_text_plot
	jmp .lost_why_done
.not_lifes_dead

	; write all tooths lost
	lda #<chomp_champ_passage_02
	sta temp00
	lda #>chomp_champ_passage_02
	sta temp01
	lda #$83
	sta temp02
	lda #$20
	sta temp03
	lda #%00001010
	sta temp04
	jsr dict_text_plot
.lost_why_done
	
	; vertical texts
	lda #CTRL_INC_32
	sta PPU_CTRL

	; write game over
	lda #<chomp_champ_passage_01
	sta temp00
	lda #>chomp_champ_passage_01
	sta temp01
	lda #$3a
	sta temp02
	lda #$21
	sta temp03
	lda #%00001110
	sta temp04
	jsr dict_text_plot

	; attr
	lda #$23
	sta PPU_ADDR
	lda #$d6
	sta PPU_ADDR
	ldx #%01010101
	stx PPU_DATA
	lda #$23
	sta PPU_ADDR
	lda #$de
	sta PPU_ADDR
	stx PPU_DATA
	lda #$23
	sta PPU_ADDR
	lda #$e6
	sta PPU_ADDR
	stx PPU_DATA
	lda #$23
	sta PPU_ADDR
	lda #$ee
	sta PPU_ADDR
	stx PPU_DATA
	lda #$23
	sta PPU_ADDR
	lda #$f6
	sta PPU_ADDR
	stx PPU_DATA


	lda #$00
	sta ppu_ctrl_ora
	sta scroll_nm
	sta scroll_x
	sta scroll_y
	jsr render_enable

	lda #$00
	sta state00
	sta state01

	rts


state_gameover_update: subroutine
	jsr render_enable
	jsr controller_read

	clc
	lda state00
	adc #$01
	sta state00
	lda state01
	adc #$00
	sta state01
	cmp #$02
	beq .goto_title_screen

	lda controller1_d
	beq .dont_start
.goto_title_screen
	jsr state_title_init
.dont_start

	jmp nmi_update_done
	

