
player_init: subroutine
	lda #$20
	sta player_x
	lda #$90
	sta player_y
	; player direction
	lda #$00
	sta state00
	rts


player_update: subroutine
	
	; player direction
	lda state00
	bmi .go_left
.go_right
	clc
	lda player_x
	adc #$03
	sta player_x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	; check right boundary
	lda player_x_hi
	beq .go_done
	lda player_x
	cmp #$ec
	bcc .go_done
	lda #$ff
	sta state00
.go_left
	sec
	lda player_x
	sbc #$03
	sta player_x
	lda player_x_hi
	sbc #$00
	sta player_x_hi
	; check right boundary
	lda player_x_hi
	bne .go_done
	lda player_x
	cmp #$04
	bcs .go_done
	lda #$00
	sta state00
.go_done

	; render
	ldy ent_spr_ptr
	; pattern
	lda wtf
	shift_r 3
	and #$01
	asl
	clc
	adc #$c0
	sta spr_p,y
	adc #$01
	sta spr_p+4,y
	adc #$0f
	sta spr_p+8,y
	adc #$01
	sta spr_p+12,y
	adc #$0f
	sta spr_p+16,y
	adc #$01
	sta spr_p+20,y
	adc #$0f
	sta spr_p+24,y
	adc #$01
	sta spr_p+28,y
	; attr
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y
	sta spr_a+20,y
	sta spr_a+24,y
	sta spr_a+28,y
	; x
	sec
	lda player_x
	sbc scroll_x
	sta spr_x,y
	sta spr_x+8,y
	sta spr_x+16,y
	sta spr_x+24,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	sta spr_x+20,y
	sta spr_x+28,y
	; y
	lda #$90
	sta spr_y,y
	sta spr_y+4,y
	clc
	adc #$08
	sta spr_y+8,y
	sta spr_y+12,y
	adc #$08
	sta spr_y+16,y
	sta spr_y+20,y
	adc #$08
	sta spr_y+24,y
	sta spr_y+28,y

	rts
