
state_game_camera: subroutine

	lda player_x_hi
	bne .not_left
	lda player_x
	cmp #$7f
	bcs .not_far_end
	; handle far left
	lda #$ff
	sta camera_x
	lda #$ff
	sta camera_x_hi
	and #$01
	sta camera_nm
	jmp .cam_done
.not_left
	lda player_x_hi
	beq .not_right
	lda player_x
	cmp #$81
	bcc .not_far_end
	; handle far right
	lda #$01
	sta camera_x
	sta camera_x_hi
	sta camera_nm
	jmp .cam_done
.not_right
.not_far_end
	lda player_x
	sec
	sbc #$80
	sta camera_x
	lda player_x_hi
	sbc #$00
	sta camera_x_hi
	and #$01
	sta camera_nm
.cam_done

	rts
