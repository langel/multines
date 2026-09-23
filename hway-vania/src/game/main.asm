
; state00 road sine pos
; state01 last frame nm row
; state02 road x offset per nm row

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

road_x_pos     eqm #$05

road_row_stripes:
	hex 0a 0b 0c 0d 0e 0f
road_row_asphalt:
	hex 8a 8b 8c 8d 8e 8f

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

	lda #$00
	sta scroll_nm

	; render road to screen
	lda #$ef
	sta scroll_y
	lda #$1d
	sta temp07
.road_row_loop
	jsr game_road_prerender
	jsr game_road_render
	inc state01
	lda scroll_y
	sec
	sbc #$08
	sta scroll_y
	dec temp07
	bne .road_row_loop
	

	; setup tree attributes
	lda #$23
	sta temp00
	lda #$c0
	sta temp01
	lda #$8c
	sta temp02
.nm1_loop
	lda temp00
	sta PPU_ADDR
	lda temp01
	sta PPU_ADDR
	lda temp02
	sta PPU_DATA
	clc
	lda temp01
	adc #$08
	sta temp01
	cmp #$00
	bne .nm1_loop
	; nametable 2
	lda #$2b
	sta temp00
	lda #$c0
	sta temp01
	lda #$c8
	sta temp02
.nm2_loop
	lda temp00
	sta PPU_ADDR
	lda temp01
	sta PPU_ADDR
	lda temp02
	sta PPU_DATA
	clc
	lda temp01
	adc #$08
	sta temp01
	cmp #$00
	bne .nm2_loop

	jsr game_road_prerender
	jsr ent_car_spawn
	jsr render_enable

	rts


state_game_update: subroutine

	jsr game_road_render

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

	; scroll_nm single source of truth
	lda scroll_y_hi
	and #$01
	asl
	sta scroll_nm



	jsr game_road_prerender

	jsr ents_update
	jsr game_hud_update

	jmp nmi_update_done
