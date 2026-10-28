

player_init: subroutine
	lda state02
	sec
	sbc #$0f-road_lead_rows
	and #$1f
	tay
	lda road_r_x_offset,y
	clc
	adc #$0e
	sta player_x
	lda #$90
	sta player_y
	lda #$00
	sta whip_counter
	sta whip_frame
	rts


player_update: subroutine
	; bound motorcycle to road
	lda state02
	sec
	sbc #$0f-road_lead_rows
	and #$1f
	tay
	; temp00 lower = left + 7, the car snaps 4 below it, 3 from the edge
	lda road_r_x_offset,y
	clc
	adc #$11
	sta temp00
	; temp01 upper = left + 38, or left + width - 2 on a narrow road
	lda road_w_ring,y
	sec
	sbc #$02
	cmp #$26
	bcc .high_ok
	lda #$26
.high_ok
	clc
	adc road_r_x_offset,y
	sta temp01
	lda temp00
	cmp player_x
	bcs .x_less
.x_more
	lda temp01
	cmp player_x
	bcs .x_done
	sta player_x
	jmp .x_done
.x_less
	lda temp00
	sec
	sbc #$04
	sta player_x
.x_done
	
	; upate collision
	lda player_x
	clc
	adc #$02
	sta collision_0_x
	lda player_y
	clc 
	adc #$03
	sta collision_0_y
	lda #$04
	sta collision_0_w
	lda #$0a
	sta collision_0_h

	; whip timer
	lda whip_frame
	bne .whip_timer_done
	; trigger whip animation
	; xxx should be controller eventually
	lda wtf
	shift_r 4
	and #$07
	bne .whip_timer_done
	; start whip animation
	inc whip_frame
	ldx whip_frame
	dex
	lda whip_frame_duration,x
	sta whip_counter
.whip_timer_done
	; whip animation
	dec whip_counter
	bne .whip_animation_done
	inc whip_frame
	lda whip_frame
	cmp #$06
	beq .whip_animation_stop
	ldx whip_frame
	dex
	lda whip_frame_duration,x
	sta whip_counter
	bne .whip_animation_done
.whip_animation_stop
	lda #$00
	sta whip_frame
.whip_animation_done

	; render main
	ldy ent_spr_ptr

	ldx whip_frame
	lda player_torso_frame,x
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda player_x
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4

	lda #$12
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda player_x
	;clc
	;adc ent_r2,x
	sta spr_x,y
	lda player_y
	clc
	adc #$08
	sta spr_y,y
	inc_y 4

	; render whip
	ldx whip_frame
	bne .render_whip_and_skull
	jmp .whip_done
.render_whip_and_skull
	dex
	; calc x,y pos
	clc
	lda player_x
	adc whip_x_offset,x
	sta temp00
	clc
	lda player_y
	adc whip_y_offset,x
	sta temp01
.render_whip_spr_0
	lda whip_spr_0,x
	beq .render_whip_spr_1
	sta spr_p,y
	lda #$02
	sta spr_a,y
	lda temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	clc
	adc #$08
	sta temp01
	inc_y 4
.render_whip_spr_1
	lda whip_spr_1,x
	sta spr_p,y
	lda #$02
	sta spr_a,y
	lda temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	clc
	adc #$08
	sta temp01
	inc_y 4
.render_whip_spr_2
	lda whip_spr_2,x
	sta spr_p,y
	lda #$02
	sta spr_a,y
	lda temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	inc_y 4
	; render skull
.render_skull
	lda #$13
	sta spr_p,y
	lda skull_attribute,x
	sta spr_a,y
	lda player_x
	clc
	adc skull_x_offset,x
	sta spr_x,y
	lda player_y
	clc
	adc skull_y_offset,x
	sta spr_y,y
	inc_y 4
.whip_done
	sty ent_spr_ptr

	rts

skull_x_offset:
	hex 05 09 08 06 00
skull_y_offset:
	hex 09 16 17 0c ea
skull_attribute:
	hex 00 80 80 80 00


player_torso_frame:
	hex 02 03 03 04 05 05

whip_frame_duration:
	hex 06 05 04 03 0f
whip_spr_0:
	hex 00 35 34 00 32
whip_spr_1:
	hex 52 45 44 33 42
whip_spr_2:
	hex 53 55 54 43 42
whip_x_offset:
	hex 04 05 05 03 00
whip_y_offset:
	hex 04 01 00 fd ec

