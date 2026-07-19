
   
apu_env_table_lo:
	byte #<apu_env_lin_long   ; 0
	byte #<apu_env_lin_tiny	  ; 2
	byte #<apu_env_exp_long	  ; 3
	byte #<apu_env_exp_short  ; 4
	byte #<apu_env_exp_tiny	  ; 5
	byte #<apu_env_exp_pico	  ; 6
apu_env_table_hi:
	byte #>apu_env_lin_long   ; 0
	byte #>apu_env_lin_tiny	  ; 2
	byte #>apu_env_exp_long	  ; 3
	byte #>apu_env_exp_short  ; 4
	byte #>apu_env_exp_tiny	  ; 5
	byte #>apu_env_exp_pico	  ; 6

apu_env_length:
	hex 40
	hex 10 ; 01
	hex 20 ; 02
	hex 20 ; 03
	hex 0e ; 04
	hex 06 ; 05
	
       
       
apu_env_run: subroutine
	; x = channel counter offset
	;     envelope type is byte after
	; #$00 = pu1
	; #$04 = pu2
	; #$07 = noise
	; returns 4-bit volume in a
	lda apu_pu1_env_id,x
	tay
	lda apu_env_table_lo,y
	sta temp00
	lda apu_env_table_hi,y
	sta temp01
	jmp (temp00)
        

apu_env_lin_long: subroutine
	; #$40 counter = 63 frames / 1 second
	lda apu_pu1_counter,x
	lsr
	lsr
	and #%00001111
	rts
	;apu_env_lin_short: subroutine
	; #$20 counter = 31 frames / 0.5 second
	;lda apu_pu1_counter,x
	;lsr
	;and #%00001111
	;rts

apu_env_lin_tiny: subroutine
	; #$10 counter = 15 frames / 0.25 second
	lda apu_pu1_counter,x
	and #%00001111
	rts

apu_env_exp_long: subroutine
	; #$40 counter =~ 54 frames / 1 second
	lda apu_pu1_env_id,x
	tay
	lda apu_env_length,y
	sec
	sbc apu_pu1_counter,x
	sec
	sbc #$01
	tay
	lda sine_table+$c0,y
	lsr
	lsr
	lsr
	rts

apu_env_exp_short: subroutine
	; #$20 counter =~ 28 frames / 0.5 second
	lda apu_pu1_env_id,x
	tay
	lda apu_env_length,y
	sec
	sbc apu_pu1_counter,x
	sec
	sbc #$01
	tay
	lda apu_env_exp_short_table,y
	lsr
	lsr
	rts
apu_env_exp_short_table:
	hex 1f 1f 1e 1d 1c 1b 1b 1a 19 18 18 17 16 15 15 14
	hex 13 12 12 11 10 10 0f 0e 0e 0d 0c 0c 0b 0b 0a 09

apu_env_exp_tiny: subroutine
	; #$10 counter =~ 15 frames / 0.25 second
	lda apu_pu1_env_id,x
	tay
	lda apu_env_length,y
	sec
	sbc apu_pu1_counter,x
	sec
	sbc #$01
	tay
	lda apu_env_exp_tiny_table,y
	rts
apu_env_exp_tiny_table:
	.byte $00,$01,$01,$01,$01,$01,$02,$02,
	.byte $03,$04,$05,$07,$0a,$0c,$0f

apu_env_exp_pico: subroutine
	; #$06 counter =~ 15 frames / 0.25 second
	lda apu_pu1_env_id,x
	tay
	lda apu_env_length,y
	sec
	sbc apu_pu1_counter,x
	sec
	sbc #$01
	tay
	lda apu_env_exp_pico_table,y
	rts
apu_env_exp_pico_table:
	.byte $00,$01,$04,$07,$0a,$0f
