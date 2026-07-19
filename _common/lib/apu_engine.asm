  
apu_init_register_values:
	byte $30,$08,$00,$00
	byte $30,$08,$00,$00
	byte $80,$00,$00,$00
	byte $30,$00,$00,$00
	byte $00,$00,$00,$00
        
apu_init: subroutine
	; Init $4000-4013
	ldy #$13
.loop  
	lda apu_init_register_values,y
	sta apu_cache,y
	sta $4000,y
	dey
	bpl .loop
	; We have to skip over $4014 (OAMDMA)
	lda #$0f
	sta $4015
	lda #$40
	sta $4017

	; clear registers
	lda #$ff
	sta audio_rng
	sta audio_song_id
	lda #$00
	sta sfx_pu2_update_id
	sta sfx_noi_update_id
	rts
        
        
        
        
	; xxx in use? commented out line?
apu_set_pitch: subroutine
	; x = pitch table offset
	; y = channel low byte offset
	lda apu_period_lo,x
	sta apu_cache+0,y
	lda apu_period_hi,x
	ora #%11111000
	sta apu_cache+1,y
	; make sure counter resets in engine
	lda #$ff
	;sta apu_pu1_last_hi-2,y
	; this makes "sick dingle" work
	sta apu_pu1_last_hi
	sta apu_pu2_last_hi
	rts


	; xxx in use?
apu_bend_down: subroutine
	inc $142
	inc $146
	inc $14a
	rts
       


apu_update: subroutine

	; priority defaults
	lda #PRIO_SONG_MUSIC
	sta ch_prio_pu1
	sta ch_prio_pu2
	sta ch_prio_tri
	sta ch_prio_noi
	; song percussion currently owns tri/noi when active
	lda song_perc_update_id
	beq .prio_song_perc_done
	lda #PRIO_SONG_PERC
	sta ch_prio_tri
	sta ch_prio_noi
.prio_song_perc_done
	; sfx state owns channel priority when active
	lda sfx_pu2_update_id
	ora sfx_pu2_counter
	beq .prio_sfx_pu2_done
	lda #PRIO_SFX_SOUND
	sta ch_prio_pu2
.prio_sfx_pu2_done
	lda sfx_noi_update_id
	ora sfx_noi_counter
	beq .prio_sfx_noi_done
	lda #PRIO_SFX_SOUND
	sta ch_prio_noi
.prio_sfx_noi_done

	; MUSIC
	jsr song_update
	; song percussion step
	jsr babapu_song_perc_update
	; SFX Pulse 2
	; SFX Noise
	; MIX and Write to APU

	; SFX Update Delegator
	lda sfx_pu2_update_id
	jsr sfx_update_delegator
	lda sfx_noi_update_id
	jsr sfx_update_delegator


	; Pulse Channels Counter / Envelope
	ldx #$00
.pulse_channels_loop
	lda apu_pu1_counter,x
	beq .pulse_skip
	dec apu_pu1_counter,x
	bne .pulse_enabled
.pulse_disabled
	lda #$30
	sta $4000,x
	jmp .pulse_skip
.pulse_enabled
	jsr apu_env_run
	ora #%10110000
	sta $4000,x
	lda #$08
	sta $4001,x
	lda apu_cache+2,x
	sta $4002,x
	lda apu_cache+3,x
	cmp apu_pu1_last_hi,x
	beq .pulse_skip
	sta $4003,x
	sta apu_pu1_last_hi,x
.pulse_skip
	cpx #$00
	bne .pulse_channels_done
	ldx #$04
	bne .pulse_channels_loop
.pulse_channels_done
	; Triangle Counter
	lda apu_tri_counter
	beq .triangle_skip
	dec apu_tri_counter
	bne .triangle_enabled
.triangle_disabled
	lda #$00
	sta $4008
	jmp .triangle_skip
.triangle_enabled
	lda #$7f
	sta $4008
	lda apu_cache+$a
	sta $400a
.triangle_skip
	; Noise Counter
	lda apu_noi_counter
	beq .noise_skip
	dec apu_noi_counter
	bne .noise_enabled
.noise_disabled
	lda #%00010000
	sta apu_cache+12
	jmp .noise_skip
.noise_enabled
	lda ch_prio_noi
	cmp #PRIO_SONG_PERC
	beq .noise_skip_env
	ldx #$07
	jsr apu_env_run
	ora #%00010000
	sta apu_cache+12
.noise_skip_env
.noise_skip
	; copy cache to apu
	ldy #$04
.cache_to_apu_loop
	lda apu_cache+$b,y
	sta $4000+$b,y
	dey
	bpl .cache_to_apu_loop

	; RNG updates
	lda audio_rng
	jsr rng_next
	sta audio_rng

	; SFX counter updates
	lda sfx_pu2_counter
	beq .sfx_pu2_counter_done
	dec sfx_pu2_counter
.sfx_pu2_counter_done
	lda sfx_noi_counter
	beq .sfx_noi_counter_done
	dec sfx_noi_counter
.sfx_noi_counter_done

	rts








;$400C	--LC VVVV	Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$400D	---- ----	Unused
;$400E	L--- PPPP	Loop noise (L), noise period (P)
;$400F	LLLL L---	Length counter load (L)


;$4000 / $4004	DDLC VVVV	Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$4001 / $4005	EPPP NSSS	Sweep unit: enabled (E), period (P), negate (N), shift (S)
;$4002 / $4006	TTTT TTTT	Timer low (T)
;$4003 / $4007	LLLL LTTT	Length counter load (L), timer high (T)


; envelope lengths
;     |  0   1   2   3   4   5   6   7    8   9   A   B   C   D   E   F
;-----+----------------------------------------------------------------
;00-0F  10,254, 20,  2, 40,  4, 80,  6, 160,  8, 60, 10, 14, 12, 26, 14,
;10-1F  12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30

; envelope length table again
; column order:
; 	id from table above
;	duration in ticks
;	actual register value
; 00  10  00
; 01 254  08
; 02  20  10
; 03   2  18
; 04  40  20
; 05   4  28
; 06  80  30
; 07   6  38
; 08 160  40
; 09   8  48
; 0a  60  50
; 0b  10  58
; 0c  14  60
; 0d  12  68
; 0e  26  70
; 0f  14  78
; 10  12  80
; 11  16  88
; 12  24  90
; 13  18  98
; 14  48  a0
; 15  20  a8
; 16  96  b0
; 17  22  b8
; 18 192  c0
; 19  24  c8
; 1a  72  d0
; 1b  26  d8
; 1c  16  e0
; 1d  28  e8
; 1e  32  f0
; 1f  30  f8

