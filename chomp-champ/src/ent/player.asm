
; ent_r3 direction
player_speed    eqm #$01

ent_player_init: subroutine
	; player always anet slot 00
	ldx #$00
	lda #ent_player_id
	sta ent_type,x
	lda #$20
	sta player_x
	lda #$90
	sta player_y
	; player direction
	lda #$00
	sta ent_r3,x
	rts


ent_player_update: subroutine
	
	; player direction
	lda ent_r3,x
	bmi .go_left
.go_right
	clc
	lda player_x
	adc #player_speed
	sta player_x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	; check right boundary
	lda player_x_hi
	beq .go_done
	lda player_x
	cmp #$e2
	bcc .go_done
	lda #$ff
	sta ent_r3,x
.go_left
	sec
	lda player_x
	sbc #player_speed
	sta player_x
	lda player_x_hi
	sbc #$00
	sta player_x_hi
	; check right boundary
	lda player_x_hi
	bne .go_done
	lda player_x
	cmp #$0e
	bcs .go_done
	lda #$00
	sta ent_r3,x
.go_done
	lda player_x
	sta ent_x,x

	; set z position
	lda player_y
	clc
	adc #$20
	ent_z_calc_sort_vals

	jmp ent_z_update_return


ent_player_render:
	; render
	ldy ent_spr_ptr
	; pattern
	lda wtf
	shift_r 3
	and #$01
	asl
	sta temp00
	asl
	asl
	clc
	adc #$80
	sta spr_p,y
	adc #$02
	sta spr_p+4,y
	; (brush)
	adc #$02
	sta spr_p+8,y
	adc #$02
	sta spr_p+12,y
	; 2nd row
	adc #$1a
	;adc #$0f
	sta spr_p+16,y
	adc #$02
	sta spr_p+20,y
	; attr
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y
	sta spr_a+20,y
	; x
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	sta spr_x+8,y
	sta spr_x+16,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+20,y
	adc #$08
	sta spr_x+8,y
	adc #$08
	sta spr_x+12,y
	; y
	lda player_y
	sta spr_y,y
	sta spr_y+4,y
	clc
	adc #$10
	sta spr_y+16,y
	sta spr_y+20,y
	; (y brush)
	lda player_y
	clc
	adc temp00
	sta spr_y+8,y
	sta spr_y+12,y

	tya
	clc
	adc #$28
	tay

	jmp ent_z_render_return
