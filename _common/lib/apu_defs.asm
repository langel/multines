

apu_cache          EQM $0160

apu_pu1_env_id     EQM $0170
apu_pu1_counter    EQM $0171
apu_pu1_last_hi    EQM $0172
sfx_pu1_counter    EQM $0173

apu_pu2_env_id     EQM $0174
apu_pu2_counter    EQM $0175
apu_pu2_last_hi    EQM $0176
sfx_pu2_counter    EQM $0177

apu_tri_env_id     EQM $0178
apu_tri_counter    EQM $0179
apu_tri_last_hi    EQM $017a
sfx_tri_counter    EQM $017b

apu_noi_env_id     EQM $017c
apu_noi_counter    EQM $017d
apu_noi_last_hi    EQM $017e
sfx_noi_counter    EQM $017f

sfx_pu1_update_id  EQM $0180
sfx_pu2_update_id  EQM $0181
sfx_tri_update_id  EQM $0182
sfx_noi_update_id  EQM $0183

song_pu1_note_id   EQM $0184
song_pu2_note_id   EQM $0185
song_tri_note_id   EQM $0186
audio_rng          eqm $0187

apu_sfx_temp00     EQM $0188
apu_sfx_temp01     EQM $0189
apu_sfx_temp02     EQM $018a
apu_sfx_temp03     EQM $018b

audio_song_id      EQM $018f

; defined in zero page:
; babapu_head_ptr_(lo/hi)
babapu_song_ptr_lo    eqm $0190
babapu_song_ptr_hi    eqm $0191

babapu_lop1_ptr_lo    eqm $0192
babapu_lop1_ptr_hi    eqm $0193
babapu_lop2_ptr_lo    eqm $0194
babapu_lop2_ptr_hi    eqm $0195
babapu_btu_length     eqm $0196
babapu_btu_counter    eqm $0197
babapu_delay_counter  eqm $0198

babapu_lop1_counter   eqm $019a
babapu_lop2_counter   eqm $019b

	MAC babapu_head_advance
	clc
	lda babapu_head_ptr_lo
	adc #$01
	sta babapu_head_ptr_lo
	lda babapu_head_ptr_hi
	adc #$00
	sta babapu_head_ptr_hi
	ENDM




  
octoscale:
	byte $00,$02,$03,$05,$06,$08,$09,$0b
	byte $0c,$0e,$0f,$11,$12,$14,$15,$17
	byte $18,$1a; ,$1b,$1d,$1e,$20,$21,$23
        
majpentscale:
	byte  #0, #2, #4, #7, #9
	byte #12,#14,#16,#19,#21
	byte #24,#26,#28,#31,#33
	byte #36,#38,#40,#43,#45
	byte #38,#40,#19
   
apu_period_lo:
	;     A   A#  B   C   C#  D   D#  E   F   F#  G   G#
	byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34 ; 12
	byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a ; 24
	byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c ; 36
	byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86 ; 48
	byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42 ; 60
	byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21 ; 72
	byte $1f,$1d,$1b,$1a,$18,$17,$15,$14
apu_period_hi:
	byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
	byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
	byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byte $00,$00,$00,$00,$00,$00,$00,$00
