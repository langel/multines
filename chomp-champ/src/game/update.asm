
state_game_update: subroutine

	jsr render_enable

	jsr controller_read

	; camera
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
	and #$01
	sta scroll_nm
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
	sta scroll_nm
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
	and #$01
	sta scroll_nm
.cam_done

	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
;	lda #%00011000 ; diable left 8 pixels row
;	sta PPU_MASK

	; xxx need to check level status
	; game over all teeth gone
	; next level all teeth clean or gone

	jsr ent_z_update

	jsr teeth_update

	jsr state_game_prerender

	; debug visualization off
;	lda #%00011110
;	sta PPU_MASK

	jmp nmi_update_done
