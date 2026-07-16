/*
	BABAPU is a tiny song playroutine
	(aka BABy APU controller)
*/


babapu_song:
	hex 06 ; tempo
	hex 23 10 17 ; pu1 note
	hex 14 ; wait 4 16ths
	hex 25 15 1b; pu1 note
	hex 14 ; wait 4 16ths
	hex f0 ; restart song
	

babapu_start: subroutine
	; put song data addr into
	; babapu_head_ptr_(lo/hi)
	lda <#babapu_song
	sta babapu_head_ptr_lo
	sta babapu_song_ptr_lo
	lda >#babapu_song
	sta babapu_head_ptr_hi
	sta babapu_song_ptr_hi

	; xxx reset some variables?
	lda #$00
	sta audio_song_id
	rts



babapu_update: subroutine
	dec babapu_btu_counter
	bmi .read
	jmp .done
.read
	lda babapu_btu_length
	sta babapu_btu_counter
	lda babapu_delay_counter
	beq .process
	dec babapu_delay_counter
	jmp .done
.process
	ldy #$00
	lda (babapu_head_ptr_lo),y
	sta temp00
	babapu_head_advance
	jsr babapu_command_trampoline
	lda babapu_delay_counter
	beq .process
.done
	rts


babapu_commands_lo:
	byte <#babapu_command_0
	byte <#babapu_command_1
	byte <#babapu_command_2
	byte <#babapu_command_3
	byte <#babapu_command_4
	byte <#babapu_command_5
	byte <#babapu_command_6
	byte <#babapu_command_7
	byte <#babapu_command_8
	byte <#babapu_command_9
	byte <#babapu_command_a
	byte <#babapu_command_b
	byte <#babapu_command_c
	byte <#babapu_command_d
	byte <#babapu_command_e
	byte <#babapu_command_f
babapu_commands_hi:
	byte >#babapu_command_0
	byte >#babapu_command_1
	byte >#babapu_command_2
	byte >#babapu_command_3
	byte >#babapu_command_4
	byte >#babapu_command_5
	byte >#babapu_command_6
	byte >#babapu_command_7
	byte >#babapu_command_8
	byte >#babapu_command_9
	byte >#babapu_command_a
	byte >#babapu_command_b
	byte >#babapu_command_c
	byte >#babapu_command_d
	byte >#babapu_command_e
	byte >#babapu_command_f


babapu_command_trampoline:
	; temp00 has command byte
	lda temp00
	shift_r 4
	tax
	lda temp00
	and #$0f
	tay
	lda babapu_commands_lo,x
	sta temp00
	lda babapu_commands_hi,x
	sta temp01
	jmp (temp00)


	; set Base Temporal Unit
babapu_command_0:
	sty babapu_btu_length
	rts

	; set BTUs delay until next
babapu_command_1:
	sty babapu_delay_counter
	rts

	; channel(s) trigger note id
babapu_command_2: subroutine
	; command bits indicate which channels
	; for each bit read channel note id
	sty temp00
	ldy #$00
.pulse1
	lsr temp00
	bcc .pulse2
	lda (babapu_head_ptr_lo),y
	tax
	babapu_head_advance
	lda apu_period_lo,x
	sta apu_cache+$2
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$3
	ldx apu_pu1_env_id
	lda apu_env_length,x
	sta apu_pu1_counter
.pulse2
	lsr temp00
	bcc .triangle
	lda (babapu_head_ptr_lo),y
	tax
	babapu_head_advance
	lda apu_period_lo,x
	sta apu_cache+$6
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$7
	ldx apu_pu2_env_id
	lda apu_env_length,x
	sta apu_pu2_counter
.triangle
	lsr temp00
	bcc .noise
	lda (babapu_head_ptr_lo),y
	tax
	babapu_head_advance
	lda apu_period_lo,x
	sta apu_cache+$a
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$b
	ldx apu_tri_env_id
	lda apu_env_length,x
	; XXX need some work here
	lda #$10
	sta apu_tri_counter
.noise
	lsr temp00
	bcc .done
.done
	rts

	; percussion macro trigger
babapu_command_3:
	rts

	; pu1 set envelope id
babapu_command_4:
	rts
	
	; pu2 set envelope id
babapu_command_5:
	rts

	; tri set BTU length
babapu_command_6:
	rts

	; noi set envelope id
babapu_command_7:
	rts

	; pu1/pu2 set duty cycle
babapu_command_8:
	; each pu has 2 bits
	rts

	; ??
babapu_command_9:
	rts

	; loop1 set point and count
babapu_command_a:
	lda babapu_head_ptr_lo
	sta babapu_lop1_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_lop1_ptr_hi
	rts
	
	; loop2 set point and count
babapu_command_b:
	lda babapu_head_ptr_lo
	sta babapu_lop2_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_lop2_ptr_hi
	rts

	; ??
babapu_command_c:
	rts

	; ??
babapu_command_d:
	rts

	; channel(s) halt
babapu_command_e:
	; command bits indicate which channels
	rts

	; song controls
babapu_command_f:
	; trampoline from value
	lda babapu_controls_lo,y
	sta temp00
	lda babapu_controls_hi,y
	sta temp01
	jmp (temp00)
	rts

babapu_controls_lo:
	byte <#babapu_controls_0
	byte <#babapu_controls_1
	byte <#babapu_controls_2
	byte <#babapu_controls_3
	byte <#babapu_controls_4
	byte <#babapu_controls_5
	byte <#babapu_controls_6
	byte <#babapu_controls_7
	byte <#babapu_controls_8
	byte <#babapu_controls_9
	byte <#babapu_controls_a
	byte <#babapu_controls_b
	byte <#babapu_controls_c
	byte <#babapu_controls_d
	byte <#babapu_controls_e
	byte <#babapu_controls_f
babapu_controls_hi:
	byte >#babapu_controls_0
	byte >#babapu_controls_1
	byte >#babapu_controls_2
	byte >#babapu_controls_3
	byte >#babapu_controls_4
	byte >#babapu_controls_5
	byte >#babapu_controls_6
	byte >#babapu_controls_7
	byte >#babapu_controls_8
	byte >#babapu_controls_9
	byte >#babapu_controls_a
	byte >#babapu_controls_b
	byte >#babapu_controls_c
	byte >#babapu_controls_d
	byte >#babapu_controls_e
	byte >#babapu_controls_f

	; reset song pointer to beginning
babapu_controls_0:
	lda babapu_song_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_song_ptr_hi
	sta babapu_head_ptr_hi
	rts

	; loop back to loop1 point
babapu_controls_1:
	lda babapu_lop1_counter
	bne .next_lop1
	rts
.next_lop1
	dec babapu_lop1_counter
	lda babapu_lop1_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_lop1_ptr_hi
	sta babapu_head_ptr_hi
	rts

	; loop back to loop2 point
babapu_controls_2:
	lda babapu_lop2_counter
	bne .next_lop2
	rts
.next_lop2
	dec babapu_lop2_counter
	lda babapu_lop2_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_lop2_ptr_hi
	sta babapu_head_ptr_hi
	rts

babapu_controls_3:
	rts
babapu_controls_4:
	rts
babapu_controls_5:
	rts
babapu_controls_6:
	rts
babapu_controls_7:
	rts
babapu_controls_8:
	rts
babapu_controls_9:
	rts
babapu_controls_a:
	rts
babapu_controls_b:
	rts
babapu_controls_c:
	rts
babapu_controls_d:
	rts
babapu_controls_e:
	rts
	; stop song
babapu_controls_f:
	lda #$ff
	sta audio_song_id
	rts





