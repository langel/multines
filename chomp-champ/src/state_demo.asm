
state_demo_init: subroutine
	jsr render_disable
	jsr sprites_clear
	rts

state_demo_update: subroutine
	jsr render_enable
	jmp nmi_update_done
	


	; demo mode
;player_state_5_update: subroutine
	; player direction
	lda ent_r3,x
	bmi .go_left
.go_right
	clc
	lda player_x
	adc #player_speed
	sta player_x
	sta ent_x,x
	lda player_x_hi
	adc #$00
	sta player_x_hi
	sta ent_x_hi,x
	; check right boundary
	lda player_x_hi
	beq .go_done
	lda player_x
	cmp #$e0
	bcc .go_done
	lda #$ff
	sta ent_r3,x
.go_left
	sec
	lda player_x
	sbc #player_speed
	sta player_x
	sta ent_x,x
	lda player_x_hi
	sbc #$00
	sta player_x_hi
	sta ent_x_hi,x
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
	; move up/down
	lda ent_r4,x
	bne .go_up
.go_down
	inc player_y
	inc ent_y,x
	jmp .updown_move_done
.go_up
	dec player_y
	dec ent_y,x
.updown_move_done
	lda player_y
	cmp #$36
	bcc .updown_reverse
	cmp #$ae
	bcc .updown_checked
.updown_reverse
	lda ent_r4,x
	eor #$01
	sta ent_r4,x
.updown_checked
	; animation frames
	inc ent_r2,x
	lda ent_r2,x
	cmp #$05
	bne .not_next_frame
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$06
	bne .not_next_frame
	lda #$00
	sta ent_r1,x
.not_next_frame
	;jmp player_state_update_return
