
state_game_update: subroutine

	jsr render_enable

	lda player_x_hi
	bne .not_left
	lda player_x
	cmp #$7f
	bcs .not_far_end
	; handle far left
	lda #$ff
	sta scroll_x
	lda #$ff
	sta scroll_x_hi
	jmp .cam_done
.not_left
	lda player_x_hi
	beq .not_right
	lda player_x
	cmp #$81
	bcc .not_far_end
	; handle far right
	lda #$01
	sta scroll_x
	sta scroll_x_hi
	jmp .cam_done
.not_right
.not_far_end
	lda player_x
	sec
	sbc #$80
	sta scroll_x
	lda player_x_hi
	sbc #$00
	sta scroll_x_hi
.cam_done

	jsr ent_z_update

	jmp nmi_update_done
