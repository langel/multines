
ent_tester_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_tester_id
	sta ent_type,x
	lda #$40
	sta ent_x,x
	lda #$c0
	sta ent_y,x
.done
	rts


ent_tester_update: subroutine
	; horizontal, opposite inputs cancel
	lda controller1
	and #BUTTON_LEFT|BUTTON_RIGHT
	cmp #BUTTON_LEFT
	beq .move_left
	cmp #BUTTON_RIGHT
	bne .vertical
.move_right
	inc ent_x,x
	jmp .vertical
.move_left
	dec ent_x,x

.vertical
	lda controller1
	and #BUTTON_UP|BUTTON_DOWN
	cmp #BUTTON_UP
	beq .move_up
	cmp #BUTTON_DOWN
	bne .render
.move_down
	lda ent_y,x
	cmp #$e8
	bne .down_inc
	lda #$00
	sta ent_y,x
	beq .render
.down_inc
	inc ent_y,x
	jmp .render
.move_up
	lda ent_y,x
	bne .up_dec
	lda #$e8
	sta ent_y,x
	bne .render
.up_dec
	dec ent_y,x

.render
	; class under the sprite center
	lda ent_y,x
	clc
	adc #$04
	tay
	lda ent_x,x
	clc
	adc #$04
	jsr road_class_lookup_screen
	clc
	adc #$f0
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	sta spr_a,y
	ldx ent_slot
	lda ent_x,x
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	inc_y 4
	rts
