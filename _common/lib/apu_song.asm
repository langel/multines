song_rng_chord    EQM $00
song_sick_dingle  EQM $01
song_in_game      EQM $02
song_boss_intro   EQM $03
song_boss_fight   EQM $04
song_game_over    EQM $05
song_end_bad      EQM $06
song_end_ok       EQM $07
song_end_good     EQM $08


song_table_lo:
	byte <#apubab_update
song_table_hi:
	byte >#apubab_update


song_update: subroutine
	lda audio_song_id
	bpl .song_running
	rts
.song_running
	; setup song data pointer
	ldx audio_song_id
	lda song_table_lo,x
	sta temp00
	lda song_table_hi,x
	sta temp01
	jmp (temp00)

/*

song_start: subroutine
	; a = song id
	sta audio_song_id
	bne .not_rng_chords
	jsr sfx_rng_chord
	rts
.not_rng_chords
	lda #$01
	sta options_music_on
	cmp audio_song_id
	bne .normal
	; sick dingle music init
	lda #$70
	sta audio_frame_counter
	lda #$02
	;sta audio_root_tone
	lda #$04
	sta audio_pattern_pos
	lda #$30
	sta apu_rng1
	lda #$44
	sta apu_rng0
	rts
.normal
	lda #0
	sta audio_frame_counter
	;sta audio_root_tone
	sta audio_pattern_pos
	jsr apu_rng_reset
	rts

song_stop: subroutine
	lda #$00
	sta options_music_on
	rts

song_unstop: subroutine
	lda #$01
	sta options_music_on
	rts



song_01_lda_note: subroutine
; x = note offset
; returns note id in a
	lda apu_temp
	beq .octoscale
.majorpentscale
	lda majpentscale,x
	rts
.octoscale
	lda octoscale,x
	rts

*/
