
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

	; spawn new ghost
	lda wtf
	and #$3f
	bne .ghost_spawn_done
	jsr ent_ghost_spawn
.ghost_spawn_done
	
	; spawn new witch
	lda wtf
	and #$7f
	bne .witch_spawn_done
	jsr ent_witch_spawn
.witch_spawn_done

	;DEBUG_VIS_ON

	jsr game_road_prerender

	jsr controller_read
	jsr sprites_clear
	jsr ents_update

	jsr game_hud_update

	DEBUG_VIS_OFF

	jmp nmi_update_done
