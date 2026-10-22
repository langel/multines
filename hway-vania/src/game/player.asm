

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


	; render
	ldy ent_spr_ptr

	lda #$03
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda player_x
	sta spr_x,y
	lda player_y
	sta spr_y,y
	inc_y 4

	lda #$13
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda player_x
	clc
	adc ent_r2,x
	sta spr_x,y
	lda player_y
	clc
	adc #$08
	sta spr_y,y
	inc_y 4

	sty ent_spr_ptr

	rts


