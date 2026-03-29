
palette_game_over:
	; bg
	hex 0f
	; tiles
	hex 02 21 0f
	hex 15 16 14
	hex 0f 27 0f

text_game_over:
	hex 60 08 5a 08 66 08 5e 08 
	hex 08 68 08 6f 08 5e 08 6b

text_all_tooths_lost:
	hex 5a 08 65 08 65 08 08
	hex 6d 08 68 08 68 08 6d 08 61 08 6c 08 08
	hex 65 08 68 08 6c 08 6d

text_lifes_dead:
	hex 65 08 62 08 
	hex 5f 08 5e 08 
	hex 6c 08 08
	hex 5d 08 5e 08 5a 08 5d
	hex 08 08


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

	; write all tooths lost
	lda #$20
	sta PPU_ADDR
	lda #$83
	sta PPU_ADDR
	ldx #$00
.all_tooths_lost_loop
	lda text_all_tooths_lost,x
	sta PPU_DATA
	inx
	cpx #$1b
	bne .all_tooths_lost_loop
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
	lda #$20
	sta PPU_ADDR
	lda #$8a
	sta PPU_ADDR
	ldx #$00
.lifes_dead_loop
	lda text_lifes_dead,x
	sta PPU_DATA
	inx
	cpx #$14
	bne .lifes_dead_loop
.not_lifes_dead

	; vertical texts
	lda #CTRL_INC_32
	sta PPU_CTRL

	; write game over
	lda #$21
	sta PPU_ADDR
	lda #$3a
	sta PPU_ADDR
	ldx #$00
.game_over_loop
	lda text_game_over,x
	sta PPU_DATA
	inx
	cpx #$10
	bne .game_over_loop
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
	

