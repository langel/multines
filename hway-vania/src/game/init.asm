
; state00 unused, road rows count in road_world_row
; state01 last frame nm row, in pixels
; state02 road x offset ring index

game_palette:
	; bg
	hex 07
	; tiles
	hex 0f 00 27
	hex 0c 3c 37
	hex 0b 1b 28
	hex 0f 0a 1b
	; sprites
	hex 0c 1c 20 ; greys
	hex 03 13 24 ; purples
	hex 05 16 27 ; oranges
	hex 09 19 29 ; greens

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

	; clear road x offset rings, r then l
	ldx #$00
.ring_clear_loop
	sta road_r_x_offset,x
	inx
	cpx #$40
	bne .ring_clear_loop

	; reset row pipeline, a is 0
	sta road_slot_wr
	sta road_slot_rd
	sta road_pending
	sta road_gen_stage
	sta road_class_ring
	sta state01
	sta road_world_row_lo
	sta road_world_row_hi

	; no pairs yet, tree masks empty
	sta pg_has_prev
	sta tm_new_lo
	sta tm_new_hi
	sta tm_prev_lo
	sta tm_prev_hi
	sta tm_old_lo
	sta tm_old_hi

	; lane schedule starts at step 0, holding
	sta lane_step
	sta lane_phase
	sta lane_t
	lda lane_schedule+1
	sta lane_rows

	; fill nametable 0 from the bottom row up, same path as gameplay
	; start on the other nametable so the first target is nt 0 row 29
	; 30 rows plus the lead rows spill into the other nametable
	lda #$01
	sta scroll_y_hi
	lda #$02
	sta scroll_nm
	lda #road_lead_rows*8-1
	sta scroll_y
	lda #30+road_lead_rows
	sta state07 ; temp
.road_row_loop
	jsr game_road_prerender
	jsr road_gen_flush
	jsr game_road_render
	; up one row, wrap into the other nametable like gameplay
	lda scroll_y
	sec
	sbc #$08
	cmp #240
	bcc .scroll_ok
	sbc #$10
	dec scroll_y_hi
.scroll_ok
	sta scroll_y
	lda scroll_y_hi
	and #$01
	asl
	sta scroll_nm
	dec state07
	bne .road_row_loop

	; start on nametable 0 line 0
	lda #$00
	sta scroll_y
	sta scroll_y_hi
	sta scroll_nm

	jsr player_init

	jsr ent_car_spawn
	jsr ent_tester_spawn
	jsr ent_gorilla_spawn
	jsr ent_witch_spawn

	jsr render_enable

	rts


