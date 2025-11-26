
player_update: subroutine

	lda wtf
	shift_r 2
	and #$01
	bne .frame1
.frame0
.frame1

	rts
