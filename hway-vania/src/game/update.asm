
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
	

	; player world y, camera, scroll position
	jsr player_move

	; scroll_nm single source of truth
	lda scroll_y_hi
	and #$01
	asl
	sta scroll_nm

	; spawn new ghost
	lda wtf
	and #$7f
	bne .ghost_spawn_done
	jsr ent_ghost_spawn
.ghost_spawn_done
	
	; spawn new witch
	lda wtf
	and #$7f
	bne .witch_spawn_done
	;jsr ent_witch_spawn
.witch_spawn_done

	DEBUG_VIS_ON

	jsr game_road_prerender

	jsr sprites_clear
	ldy #$00
	sty ent_spr_ptr
	
	jsr controller_read
	; player first, its collision box is used by the ents
	; traffic last, it drops sprites once the page is full
	jsr player_update
	jsr game_hud_update
	sty ent_spr_ptr
	jsr baddies_update
	jsr traffic_update

	DEBUG_VIS_OFF

	jmp nmi_update_done
