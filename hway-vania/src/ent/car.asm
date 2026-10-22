
; ent_r0 last x pos
; ent_r1 caboose dejitter
; ent_r2 caboose x offset


ent_car_spawn: subroutine
	jsr traffic_find_slot
	bmi .done
	lda #ent_car_id
	sta ent_type,x
.done
	; start in the left lane, where the update would push it
	lda state02
	sec
	sbc #$0f-road_lead_rows
	and #$1f
	tay
	lda road_r_x_offset,y
	clc
	adc #$03
	sta ent_x,x
	sta ent_r0,x
	lda #$80
	sta ent_y,x
	rts



ent_car_update: subroutine
	; update logic

	; bound car to road
	lda state02
	sec
	sbc #$0f-road_lead_rows
	and #$1f
	tay
	; temp00 lower = left + 7, the car snaps 4 below it, 3 from the edge
	lda road_r_x_offset,y
	clc
	adc #$07
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
	cmp ent_x,x
	bcs .x_less
.x_more
	lda temp01
	cmp ent_x,x
	bcs .x_done
	sta ent_x,x
	jmp .x_done
.x_less
	lda temp00
	sec
	sbc #$04
	sta ent_x,x
.x_done

	; setup caboose x offset
	lda ent_r1,x
	beq .caboose_update
	dec ent_r1,x
	bne .caboose_really_done
.caboose_update
	lda #$00
	sta ent_r2,x
	lda ent_x,x
	cmp ent_r0,x
	beq .caboose_done
	php
	lda #$07
	sta ent_r1,x
	plp
	bcs .caboose_left
.caboose_right
	inc ent_r2,x
	jmp .caboose_done
.caboose_left
	dec ent_r2,x
.caboose_done
	lda ent_x,x
	sta ent_r0,x
.caboose_really_done

	; setup collision
	lda ent_x,x
	sta collision_1_x
	lda ent_y,x
	sta collision_1_y
	lda #$08
	sta collision_1_w
	lda #$10
	sta collision_1_h

	; render (reload y?)
	ldy ent_spr_ptr

	lda #$00
	sta spr_p,y
	lda #$01
	sta spr_a,y
	lda ent_x,x
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	inc_y 4

	lda #$10
	sta spr_p,y
	lda #$01
	sta spr_a,y
	lda ent_x,x
	clc
	adc ent_r2,x
	sta spr_x,y
	lda ent_y,x
	clc
	adc #$08
	sta spr_y,y
	inc_y 4

	rts
