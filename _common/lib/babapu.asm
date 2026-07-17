/*
	BABAPU is a tiny song playroutine
	(aka BABy APU controller)
*/




babapu_song:

	hex 06
	hex 43 53 ; set ppu env
	hex 64 ; tri length
	hex f6 ; mend2 begin

	; pattern0
	hex f3 ; mend1 begin
	; bar1
	hex 27 ; chord
	byte 36, 40, 22
	hex 12
	hex a3 ; set 4 loop1s
	hex 23 ; chord
	byte 36, 40
	hex 12
	hex f1 ; loop1 back
	; bar2
	hex 27 ; chord
	byte 34, 38, 22
	hex 12
	hex a3 ; set 4 loop1s
	hex 23 ; chord
	byte 34, 38
	hex 12
	hex f1 ; loop1 back
	hex f4 ; mend1 end
	; bar3
	hex 27 ; chord
	byte 38, 41, 29
	hex 14
	hex 23
	byte 33, 36
	hex 14
	; bar4
	hex 27
	byte 29, 21, 17
	hex 18
	hex f5 ; mend1 next
	; bar1-2 repeat
	; bar7
	hex 27 ; chord
	byte 38, 41, 29
	hex 13
	hex 23
	byte 38, 41
	hex 11
	hex 23
	byte 33, 36
	hex 14
	; bar8
	hex 27
	byte 29, 21, 17
	hex 18

	hex f7 ; mend2 end
	; pattern2
	; bar1
	hex 27
	byte 29, 33, 17
	hex 14
	hex a2 ; set loop1
	hex 23
	byte 29, 33
	hex 12
	hex f1 ; loop1
	; bar2
	hex 27
	byte 31, 34, 19
	hex 16
	hex 23
	byte 31, 34
	hex 12
	; bar3
	hex 27 
	byte 33, 36, 21
	hex 14
	hex a2 ; set loop1
	hex 23
	byte 33, 36
	hex 12
	hex f1 ; loop1
	; bar4
	hex 27 
	byte 29, 34, 17
	hex 18
	; bar5
	hex 61 ; tri length
	hex a3 ; set loop1
	hex 27
	byte 29, 33, 17
	hex 12
	hex f1
	hex 62 ; tri length
	hex 27
	byte 29, 33, 17
	hex 12
	; bar6
	hex 27
	byte 33, 36, 21
	hex 12
	hex 61 ; tri length
	hex 27
	byte 31, 34, 19
	hex 16
	; bar7
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 12
	hex 61 ; tri length
	hex a2 ; set loop1
	hex 27
	byte 31, 34, 19
	hex 12
	hex f1 ; loop1
	hex 27
	byte 29, 33, 17
	hex 12
	; bar8
	hex 64 ; set tri
	hex 27
	byte 29, 33, 17
	hex 18

	; pattern1 repeat
	hex f8 ; mend2 next

	; pattern3
	; bar1
	hex 27
	byte 33, 36, 21
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 33, 36
	hex 12
	hex f1 ; loop1
	; bar2
	hex 27
	byte 34, 38, 22
	hex 12
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 16
	; bar3
	hex 64 ; tri length
	hex 27
	byte 34, 38, 22
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 34, 38
	hex 12
	hex f1 ; loop1
	; bar4
	hex 27
	byte 38, 41, 26
	hex 12
	hex 62 ; tri length
	hex 27
	byte 34, 38, 22
	hex 16
	; bar5
	hex 68 ; tri length
	hex 27
	byte 36, 40, 24
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 36, 40
	hex 12
	hex f1
	; bar6
	hex 27
	byte 34, 38, 22
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 34, 38
	hex 12
	hex f1
	; bar7
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 12
	hex 27
	byte 31, 34, 19
	hex 14
	hex 27
	byte 29, 33, 17
	hex 1a

	hex f0 ; restart song


babapu_song_old:
	hex 06 ; tempo
	hex 63 ; tri 3 btu long
	hex 23 10 17 ; pu1 tri note
	hex 30 ; kick
	hex 12 ; wait 4 16ths
	hex 30 ; kick
	hex 12 ; wait 4 16ths
	hex 25 15 1b; pu1 pu2 note
	hex 31 ; snare
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

	lda #$01
	sta babapu_btu_length
	sta babapu_btu_counter
	sta babapu_tri_btu_mult
	sta song_tri_frame_count
	lda #$00
	sta babapu_delay_counter
	sta babapu_lop1_counter
	sta babapu_lop2_counter
	sta song_tri_btu_count
	sta song_perc_update_id
	sta babapu_mnd1_begin_ptr_lo
	sta babapu_mnd1_begin_ptr_hi
	sta babapu_mnd1_end_ptr_lo
	sta babapu_mnd1_end_ptr_hi
	sta babapu_mnd1_next_ptr_lo
	sta babapu_mnd1_next_ptr_hi
	sta babapu_mnd2_begin_ptr_lo
	sta babapu_mnd2_begin_ptr_hi
	sta babapu_mnd2_end_ptr_lo
	sta babapu_mnd2_end_ptr_hi
	sta babapu_mnd2_next_ptr_lo
	sta babapu_mnd2_next_ptr_hi

	lda #$00
	sta audio_song_id
	rts


babapu_update: subroutine
	jsr babapu_song_tri_tick
	dec babapu_btu_counter
	bmi .read
	jmp .done
.read
	lda babapu_btu_length
	sta babapu_btu_counter
	lda babapu_delay_counter
	beq .process
	dec babapu_delay_counter
	beq .process
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
	lda sfx_pu2_counter
	ora sfx_pu2_update_id
	bne .triangle
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
	stx song_tri_note_id
	lda babapu_tri_btu_mult
	bne .tri_have_mult
	lda #$01
.tri_have_mult
	sta song_tri_btu_count
	lda babapu_btu_length
	bne .tri_have_btu
	lda #$01
.tri_have_btu
	sta song_tri_frame_count
	lda #PRIO_SONG_MUSIC
	cmp ch_prio_tri
	bcc .noise
	lda apu_period_lo,x
	sta apu_cache+$a
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$b
	lda #$02
	sta apu_tri_counter
.noise
	lsr temp00
	bcc .done
	lda (babapu_head_ptr_lo),y
	tax
	babapu_head_advance
	lda sfx_noi_counter
	ora sfx_noi_update_id
	bne .done
	lda apu_period_lo,x
	sta apu_cache+$e
	ldx apu_noi_env_id
	lda apu_env_length,x
	sta apu_noi_counter
.done
	rts

	; percussion macro trigger
babapu_command_3:
	lda babapu_song_perc_lo,y
	sta song_perc_ptr_lo
	lda babapu_song_perc_hi,y
	sta song_perc_ptr_hi
	lda #$01
	sta song_perc_update_id
	rts

	; pu1 set envelope id
babapu_command_4:
	sty apu_pu1_env_id
	rts
	
	; pu2 set envelope id
babapu_command_5:
	sty apu_pu2_env_id
	rts

	; tri set BTU length multiplier
babapu_command_6:
	tya
	bne .tri_mult_ok
	lda #$01
.tri_mult_ok
	sta babapu_tri_btu_mult
	rts

	; noi set envelope id
babapu_command_7:
	sty apu_noi_env_id
	rts

	; pu1/pu2 set duty cycle
babapu_command_8:
	tya
	and #%00000011
	shift_l 6
	sta temp00
	lda apu_cache+$0
	and #%00111111
	ora temp00
	sta apu_cache+$0
	tya
	and #%00001100
	shift_l 4
	sta temp00
	lda apu_cache+$4
	and #%00111111
	ora temp00
	sta apu_cache+$4
	rts

	; reserved
babapu_command_9:
	rts

	; loop1 set point and count
babapu_command_a:
	lda babapu_head_ptr_lo
	sta babapu_lop1_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_lop1_ptr_hi
	tya
	beq .loop1_store
	dey
.loop1_store
	sty babapu_lop1_counter
	rts
	
	; loop2 set point and count
babapu_command_b:
	lda babapu_head_ptr_lo
	sta babapu_lop2_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_lop2_ptr_hi
	tya
	beq .loop2_store
	dey
.loop2_store
	sty babapu_lop2_counter
	rts

	; reserved
babapu_command_c:
	rts

	; reserved
babapu_command_d:
	rts

	; channel(s) halt (reserved for now)
babapu_command_e:
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
	beq .done_lop1
	dec babapu_lop1_counter
	lda babapu_lop1_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_lop1_ptr_hi
	sta babapu_head_ptr_hi
.done_lop1
	rts

	; loop back to loop2 point
babapu_controls_2:
	lda babapu_lop2_counter
	beq .done_lop2
	dec babapu_lop2_counter
	lda babapu_lop2_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_lop2_ptr_hi
	sta babapu_head_ptr_hi
.done_lop2
	rts

	; mend1 set begin pointer
babapu_controls_3:
	lda babapu_head_ptr_lo
	sta babapu_mnd1_begin_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd1_begin_ptr_hi
	rts
	; mend1 set end pointer
babapu_controls_4:
	lda babapu_mnd1_end_ptr_hi
	beq .set_end_mnd1
	lda babapu_mnd1_next_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_mnd1_next_ptr_hi
	sta babapu_head_ptr_hi
	lda #$00
	sta babapu_mnd1_begin_ptr_lo
	sta babapu_mnd1_begin_ptr_hi
	sta babapu_mnd1_end_ptr_lo
	sta babapu_mnd1_end_ptr_hi
	sta babapu_mnd1_next_ptr_lo
	sta babapu_mnd1_next_ptr_hi
	rts
.set_end_mnd1
	lda babapu_head_ptr_lo
	sta babapu_mnd1_end_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd1_end_ptr_hi
	rts
	; mend1 set next pointer and jump to begin pointer
babapu_controls_5:
	lda babapu_head_ptr_lo
	sta babapu_mnd1_next_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd1_next_ptr_hi
	lda babapu_mnd1_begin_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_mnd1_begin_ptr_hi
	sta babapu_head_ptr_hi
	rts
	; mend2 set begin pointer
babapu_controls_6:
	lda babapu_head_ptr_lo
	sta babapu_mnd2_begin_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd2_begin_ptr_hi
	rts
	; mend2 set end pointer
babapu_controls_7:
	lda babapu_mnd2_end_ptr_hi
	beq .set_end_mnd2
	lda babapu_mnd2_next_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_mnd2_next_ptr_hi
	sta babapu_head_ptr_hi
	lda #$00
	sta babapu_mnd2_begin_ptr_lo
	sta babapu_mnd2_begin_ptr_hi
	sta babapu_mnd2_end_ptr_lo
	sta babapu_mnd2_end_ptr_hi
	sta babapu_mnd2_next_ptr_lo
	sta babapu_mnd2_next_ptr_hi
	rts
.set_end_mnd2
	lda babapu_head_ptr_lo
	sta babapu_mnd2_end_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd2_end_ptr_hi
	rts
	; mend2 set next pointer and jump to begin pointer
babapu_controls_8:
	lda babapu_head_ptr_lo
	sta babapu_mnd2_next_ptr_lo
	lda babapu_head_ptr_hi
	sta babapu_mnd2_next_ptr_hi
	lda babapu_mnd2_begin_ptr_lo
	sta babapu_head_ptr_lo
	lda babapu_mnd2_begin_ptr_hi
	sta babapu_head_ptr_hi
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


babapu_song_tri_tick: subroutine
	lda song_tri_btu_count
	beq .done
	lda #PRIO_SONG_MUSIC
	cmp ch_prio_tri
	bcc .done
	; keep triangle audible while song tri note is active
	lda #$02
	sta apu_tri_counter
	dec song_tri_frame_count
	bne .done
	lda babapu_btu_length
	bne .have_btu
	lda #$01
.have_btu
	sta song_tri_frame_count
	dec song_tri_btu_count
.done
	rts


babapu_song_tri_resume: subroutine
	lda song_tri_btu_count
	beq .done
	ldx song_tri_note_id
	lda apu_period_lo,x
	sta apu_cache+$a
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+$b
	lda #$02
	sta apu_tri_counter
.done
	rts


babapu_song_perc_update: subroutine
	lda song_perc_update_id
	bne .process
	rts
.process
	ldy #$00
	lda (song_perc_ptr_lo),y
	cmp #$ff
	beq .end
	sta temp00
	iny
	lda (song_perc_ptr_lo),y
	sta temp01
	iny
	lda (song_perc_ptr_lo),y
	sta temp02
	iny
	lda (song_perc_ptr_lo),y
	sta temp03

	lda temp00
	cmp #$fe
	beq .tri_skip
	lda #PRIO_SONG_PERC
	cmp ch_prio_tri
	bcc .tri_skip
	sta ch_prio_tri
	ldx temp00
	lda apu_period_lo,x
	clc
	adc temp01
	sta apu_cache+$a
	lda apu_period_hi,x
	adc #$00
	ora #%11111000
	sta apu_cache+$b
	lda #$02
	sta apu_tri_counter
.tri_skip
	lda #PRIO_SONG_PERC
	cmp ch_prio_noi
	bcc .advance
	sta ch_prio_noi
	; song percussion treats this byte as a direct noise volume (0-15)
	lda temp02
	and #%00001111
	ora #%00010000
	sta apu_cache+$c
	lda temp03
	sta apu_cache+$e
	lda #$02
	sta apu_noi_counter
.advance
	clc
	lda song_perc_ptr_lo
	adc #$04
	sta song_perc_ptr_lo
	lda song_perc_ptr_hi
	adc #$00
	sta song_perc_ptr_hi
	rts
.end
	lda #$00
	sta song_perc_update_id
	sta song_perc_ptr_lo
	sta song_perc_ptr_hi
	lda #%00010000
	sta apu_cache+$c
	lda #PRIO_SONG_MUSIC
	sta ch_prio_tri
	sta ch_prio_noi
	jsr babapu_song_tri_resume
	rts


babapu_song_perc_lo:
	byte <#babapu_song_perc_00
	byte <#babapu_song_perc_01
	byte <#babapu_song_perc_02
	byte <#babapu_song_perc_03
	byte <#babapu_song_perc_04
	byte <#babapu_song_perc_05
	byte <#babapu_song_perc_06
	byte <#babapu_song_perc_07
	byte <#babapu_song_perc_08
	byte <#babapu_song_perc_09
	byte <#babapu_song_perc_0a
	byte <#babapu_song_perc_0b
	byte <#babapu_song_perc_0c
	byte <#babapu_song_perc_0d
	byte <#babapu_song_perc_0e
	byte <#babapu_song_perc_0f
babapu_song_perc_hi:
	byte >#babapu_song_perc_00
	byte >#babapu_song_perc_01
	byte >#babapu_song_perc_02
	byte >#babapu_song_perc_03
	byte >#babapu_song_perc_04
	byte >#babapu_song_perc_05
	byte >#babapu_song_perc_06
	byte >#babapu_song_perc_07
	byte >#babapu_song_perc_08
	byte >#babapu_song_perc_09
	byte >#babapu_song_perc_0a
	byte >#babapu_song_perc_0b
	byte >#babapu_song_perc_0c
	byte >#babapu_song_perc_0d
	byte >#babapu_song_perc_0e
	byte >#babapu_song_perc_0f


; tri_note, tri_period_add, noi_env, noi_pitch
babapu_song_perc_00:
	byte $18, $20, $07, $0f
	byte $18, $40, $0b, $00
	byte $fe, $00, $07, $00
	byte $fe, $00, $03, $00
	byte $ff
babapu_song_perc_01:
	byte $24, $00, $09, $00
	byte $fe, $00, $0a, $04
	byte $fe, $00, $07, $05
	byte $fe, $00, $03, $06
	byte $ff
babapu_song_perc_02:
	byte $ff
babapu_song_perc_03:
	byte $ff
babapu_song_perc_04:
	byte $ff
babapu_song_perc_05:
	byte $ff
babapu_song_perc_06:
	byte $ff
babapu_song_perc_07:
	byte $ff
babapu_song_perc_08:
	byte $ff
babapu_song_perc_09:
	byte $ff
babapu_song_perc_0a:
	byte $ff
babapu_song_perc_0b:
	byte $ff
babapu_song_perc_0c:
	byte $ff
babapu_song_perc_0d:
	byte $ff
babapu_song_perc_0e:
	byte $ff
babapu_song_perc_0f:
	byte $ff
