
; ent_r0 last x pos
; ent_r1 caboose dejitter
; ent_r2 caboose x offset


ent_car_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_car_id
	sta ent_type,x
.done
	lda #$7e
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
	sbc #$0f
	and #$1f
	tay
	lda $700,y
	clc
	adc #$0e
	cmp ent_x,x
	bcs .x_less
.x_more
	clc
	adc #$18
	cmp ent_x,x
	bcs .x_done
	sta ent_x,x
	jmp .x_done
.x_less
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

	; render (reload y?)
	ldy ent_spr_ptr

	lda #$00
	sta spr_p,y
	lda #$10
	sta spr_p+4,y
	lda #$01
	sta spr_a,y
	sta spr_a+4,y
	lda ent_x,x
	sta spr_x,y
	clc
	adc ent_r2,x
	sta spr_x+4,y
	lda ent_y,x
	sta spr_y,y
	clc
	adc #$08
	sta spr_y+4,y

	inc_y 8

	rts
