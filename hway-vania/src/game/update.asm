
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

	jsr controller_read
	; the first input hands the bike to the player
	lda controller1
	ora player_manual
	sta player_manual
	beq .accelerate
	lda controller1
	and #BUTTON_UP
	beq .up_done
.accelerate
	; up the road is negative, top speed once speed_hi reaches $fb
	lda speed_hi
	cmp #$fb
	beq .up_done
	sec
	lda speed_lo
	sbc #$03
	sta speed_lo
	lda speed_hi
	sbc #$00
	sta speed_hi
.up_done
	lda player_manual
	beq .done_accel
	lda controller1
	and #BUTTON_DOWN
	beq .done_accel
	; slow down, never past 0
	clc
	lda speed_lo
	adc #$03
	sta speed_lo
	lda speed_hi
	adc #$00
	sta speed_hi
	bmi .done_accel
	lda #$00
	sta speed_lo
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
	
	; player first, its collision box is used by the ents
	; traffic last, it drops sprites once the page is full
	jsr player_update
	jsr game_hud_update
	sty ent_spr_ptr
	jsr baddies_update
	jsr traffic_update

	DEBUG_VIS_OFF

	jmp nmi_update_done
