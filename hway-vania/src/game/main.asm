

game_palette:
	; bg
	hex 07
	; tiles
	hex 0f 00 27
	hex 0c 3c 37
	hex 0b 1b 28
	hex 0f 0a 1b
	; sprites
	hex 2d 00 20 ; greys
	hex 03 13 24 ; purples
	hex 05 16 27 ; oranges
	hex 09 19 29 ; greens

road_x_pos     eqm #$0c

road_row_stripes:
	hex 01 02 03 04 05
road_row_asphalt:
	hex 01 03 03 03 05

state_game_init: subroutine

	jsr render_disable
	jsr sprites_clear
	jsr registers_clear

	ldx #render_do_nothing_id
	jsr state_set_render_routine
	ldx #state_game_update_id
	jsr state_set_update_routine

	; setup state
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #$19
	bne .pal_loop

	; draw some road
	lda #$20
	sta temp00 ; hi ppu addr
	lda #road_x_pos
	sta temp01 ; lo ppu addr
	lda #$00
	sta state00
	ldx #$00
.road_row_loop
	lda temp00
	sta PPU_ADDR
	lda temp01
	sta PPU_ADDR
	lda state00
	beq .plot_stripes
.plot_asphalt
	ldy #$00
.plot_asphalt_loop
	lda road_row_asphalt,y
	sta PPU_DATA
	iny
	cpy #$05
	bne .plot_asphalt_loop
	jmp .plot_row_done
.plot_stripes
	ldy #$00
.plot_stripes_loop
	lda road_row_stripes,y
	sta PPU_DATA
	iny
	cpy #$05
	bne .plot_stripes_loop
.plot_row_done
	lda state00
	clc
	adc #$01
	cmp #$04
	bcc .phase_ok
	lda #$00
.phase_ok
	sta state00
	lda temp01
	clc
	adc #$20
	sta temp01
	lda temp00
	adc #$00
	sta temp00
	inx
	cpx #$1e
	bne .road_row_loop

	lda #$00
	sta scroll_nm

	jsr ent_car_spawn
	jsr render_enable

	rts


state_game_update: subroutine

	; setup next nametable row
	lda #$00
	sta temp01
	sec
	lda scroll_y
	sbc #$07
	php ; push status
	bcs .y_within_screen
	sbc #$10
.y_within_screen
	and #$f8
	asl
	rol temp01
	asl
	rol temp01
	sta temp00
	; addr hi
	lda scroll_nm
	plp ; pull status
	bcs .nm_off_screen
	eor #$02
.nm_off_screen
	shift_l 2
	clc
	adc #$20
	adc temp01
	sta PPU_ADDR
	lda temp00
	clc
	adc #$04
	sta PPU_ADDR
	; road
	lda scroll_y_hi
	lda wtf
	lda scroll_y
	shift_r 2
	and #$03
	sta temp00
	tax
	inx
	ldy #$01
	lda wtf
	tay
.road_loop
	sty PPU_DATA
	iny
	dex
	bpl .road_loop
	; dirt
	lda temp00
	eor #$03
	tax
	lda #$00
.dirt_loop
	sta PPU_DATA
	dex
	bpl .dirt_loop

	

	; set scroll position
	lda #$00
	sta PPU_SCROLL
	lda scroll_y
	sta PPU_SCROLL
	lda scroll_y_hi
	and #$01
	asl
	sta scroll_nm

	jsr render_enable


	; acceleration
	lda speed_hi
	cmp #$fb
	beq .done_accel
	sec
	lda speed_lo
	sbc #$03
	sta speed_lo
	lda speed_hi
	sbc #$00
	sta speed_hi
.done_accel
/*
	; decelerate
	lda speed_hi
	cmp #$03
	beq .done_decel
	clc
	lda speed_lo
	adc #$03
	sta speed_lo
	lda speed_hi
	adc #$00
	sta speed_hi
.done_decel
*/

	; update scroll position
	clc
	lda scroll_y_lo
	adc speed_lo
	sta scroll_y_lo
	lda scroll_y
	adc speed_hi
	sta scroll_y
	cmp #240
	bcc .scroll_done
	lda speed_hi
	bpl .reverse
.forward
	lda scroll_y
	sec
	sbc #16
	sta scroll_y
	dec scroll_y_hi
	jmp .scroll_done
.reverse
	lda scroll_y
	sec
	sbc #240
	sta scroll_y
	inc scroll_y_hi
.scroll_done




	jsr ents_update
	jsr game_hud_update

	jmp nmi_update_done
