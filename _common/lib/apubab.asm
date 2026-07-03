/*
	APUBAB is a tiny song playroutine
*/


apubab_song:
	hex 06 ; tempo
	hex 28 10 ; pu1 note
	hex 14 ; wait 4 16ths
	hex 28 15 ; pu1 note
	hex 14 ; wait 4 16ths
	hex f0 ; restart song
	

apubab_start: subroutine
	; put song data addr into
	; apubab_head_ptr_(lo/hi)
	lda <#apubab_song
	sta apubab_head_ptr_lo
	sta apubab_song_ptr_lo
	lda >#apubab_song
	sta apubab_head_ptr_hi
	sta apubab_song_ptr_hi

	; xxx reset some variables?
	lda #$00
	sta audio_song_id
	rts



apubab_update: subroutine
	dec apubab_btu_counter
	bmi .read
	jmp .done
.read
	lda apubab_btu_length
	sta apubab_btu_counter
	lda apubab_delay_counter
	beq .delay_done
	dec apubab_delay_counter
	jmp .done
.delay_done
	ldy #$00
	lda (apubab_head_ptr_lo),y
	sta temp00
	apubab_head_advance
	jsr apubab_command_trampoline
.done
	rts


apubab_commands_lo:
	byte <#apubab_command_0
	byte <#apubab_command_1
	byte <#apubab_command_2
	byte <#apubab_command_3
	byte <#apubab_command_4
	byte <#apubab_command_5
	byte <#apubab_command_6
	byte <#apubab_command_7
	byte <#apubab_command_8
	byte <#apubab_command_9
	byte <#apubab_command_a
	byte <#apubab_command_b
	byte <#apubab_command_c
	byte <#apubab_command_d
	byte <#apubab_command_e
	byte <#apubab_command_f
apubab_commands_hi:
	byte >#apubab_command_0
	byte >#apubab_command_1
	byte >#apubab_command_2
	byte >#apubab_command_3
	byte >#apubab_command_4
	byte >#apubab_command_5
	byte >#apubab_command_6
	byte >#apubab_command_7
	byte >#apubab_command_8
	byte >#apubab_command_9
	byte >#apubab_command_a
	byte >#apubab_command_b
	byte >#apubab_command_c
	byte >#apubab_command_d
	byte >#apubab_command_e
	byte >#apubab_command_f


apubab_command_trampoline:
	; temp00 has command byte
	lda temp00
	shift_r 4
	tax
	lda temp00
	and #$0f
	tay
	lda apubab_commands_lo,x
	sta temp00
	lda apubab_commands_hi,x
	sta temp01
	jmp (temp00)


	; set Base Temporal Unit
apubab_command_0:
	sty apubab_btu_length
	rts

	; set BTUs delay until next
apubab_command_1:
	sty apubab_delay_counter
	rts

	; channel(s) trigger note id
apubab_command_2: subroutine
	; command bits indicate which channels
	; for each bit read channel note id
	sty temp00
	ldy #$00
.noise
	lsr temp00
	bcc .triangle
.triangle
	lsr temp00
	bcc .pulse2
.pulse2
	lsr temp00
	bcc .pulse1
.pulse1
	lsr temp00
	bcc .done
	lda (apubab_head_ptr_lo),y
	tax
	apubab_head_advance
	lda apu_period_lo,x
	sta apu_cache+$2
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$3
	sta apu_pu1_last_hi
	ldx apu_pu1_env_id
	lda apu_env_length,x
	sta apu_pu1_counter
.done
	rts

	; percussion macro trigger
apubab_command_3:
	rts

	; pu1 set envelope id
apubab_command_4:
	rts
	
	; pu2 set envelope id
apubab_command_5:
	rts

	; tri set BTU length
apubab_command_6:
	rts

	; noi set envelope id
apubab_command_7:
	rts

	; pu1/pu2 set duty cycle
apubab_command_8:
	; each pu has 2 bits
	rts

	; ??
apubab_command_9:
	rts

	; loop1 set point and count
apubab_command_a:
	lda apubab_head_ptr_lo
	sta apubab_lop1_ptr_lo
	lda apubab_head_ptr_hi
	sta apubab_lop1_ptr_hi
	rts
	
	; loop2 set point and count
apubab_command_b:
	lda apubab_head_ptr_lo
	sta apubab_lop2_ptr_lo
	lda apubab_head_ptr_hi
	sta apubab_lop2_ptr_hi
	rts

	; ??
apubab_command_c:
	rts

	; ??
apubab_command_d:
	rts

	; channel(s) halt
apubab_command_e:
	; command bits indicate which channels
	rts

	; song controls
apubab_command_f:
	; trampoline from value
	lda apubab_controls_lo,y
	sta temp00
	lda apubab_controls_hi,y
	sta temp01
	jmp (temp00)
	rts

apubab_controls_lo:
	byte <#apubab_controls_0
	byte <#apubab_controls_1
	byte <#apubab_controls_2
	byte <#apubab_controls_3
	byte <#apubab_controls_4
	byte <#apubab_controls_5
	byte <#apubab_controls_6
	byte <#apubab_controls_7
	byte <#apubab_controls_8
	byte <#apubab_controls_9
	byte <#apubab_controls_a
	byte <#apubab_controls_b
	byte <#apubab_controls_c
	byte <#apubab_controls_d
	byte <#apubab_controls_e
	byte <#apubab_controls_f
apubab_controls_hi:
	byte >#apubab_controls_0
	byte >#apubab_controls_1
	byte >#apubab_controls_2
	byte >#apubab_controls_3
	byte >#apubab_controls_4
	byte >#apubab_controls_5
	byte >#apubab_controls_6
	byte >#apubab_controls_7
	byte >#apubab_controls_8
	byte >#apubab_controls_9
	byte >#apubab_controls_a
	byte >#apubab_controls_b
	byte >#apubab_controls_c
	byte >#apubab_controls_d
	byte >#apubab_controls_e
	byte >#apubab_controls_f

	; reset song pointer to beginning
apubab_controls_0:
	lda apubab_song_ptr_lo
	sta apubab_head_ptr_lo
	lda apubab_song_ptr_hi
	sta apubab_head_ptr_hi
	rts

	; loop back to loop1 point
apubab_controls_1:
	lda apubab_lop1_counter
	bne .next_lop1
	rts
.next_lop1
	dec apubab_lop1_counter
	lda apubab_lop1_ptr_lo
	sta apubab_head_ptr_lo
	lda apubab_lop1_ptr_hi
	sta apubab_head_ptr_hi
	rts

	; loop back to loop2 point
apubab_controls_2:
	lda apubab_lop2_counter
	bne .next_lop2
	rts
.next_lop2
	dec apubab_lop2_counter
	lda apubab_lop2_ptr_lo
	sta apubab_head_ptr_lo
	lda apubab_lop2_ptr_hi
	sta apubab_head_ptr_hi
	rts

apubab_controls_3:
	rts
apubab_controls_4:
	rts
apubab_controls_5:
	rts
apubab_controls_6:
	rts
apubab_controls_7:
	rts
apubab_controls_8:
	rts
apubab_controls_9:
	rts
apubab_controls_a:
	rts
apubab_controls_b:
	rts
apubab_controls_c:
	rts
apubab_controls_d:
	rts
apubab_controls_e:
	rts
	; stop song
apubab_controls_f:
	lda #$ff
	sta audio_song_id
	rts





