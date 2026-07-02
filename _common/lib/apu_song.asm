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
song_table_hi:


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


; sick dingle
song_01: subroutine
	rts



; in game
song_02: subroutine
	rts



; boss intro 
song_03: subroutine
	rts



; boss fight
song_04: subroutine
	rts
song_04_pitch:
	byte 12,0,17,0,0,12,12,0,17,0,0,15,0,0,13,0,0,12
song_04_length:
	byte 18,0,10,0,0, 3,18,0,10,0,0, 8,0,0, 8,0,0, 3



; game over        
song_05: subroutine
	lda audio_frame_counter
	cmp #$ff
	bne .do_normal
	lda #$00
	sta ppu_mask_emph
	rts
.do_normal
	jsr apu_bend_down
	jsr apu_bend_down
	lda audio_frame_counter
	cmp #$70
	beq .do_chord
	cmp #$40
	beq .do_chord
	cmp #$30
	beq .do_chord
	cmp #$10
	beq .do_chord
	lda audio_frame_counter
	bne .done
	jsr sfx_snare
.do_chord
	jsr sfx_rng_chord
	jsr ppu_mess_emph
	inc ppu_mask_emph
.done
	inc audio_frame_counter
	rts


; ending bad
song_06: subroutine
	; rng chord about every 2 seconds (bends down)
	jsr apu_bend_down
	jsr apu_bend_down
	lda audio_frame_counter
	and #$7d
	bne .no_chord
	jsr sfx_rng_chord
.no_chord
	inc audio_frame_counter
	rts


; ending ok
song_07: subroutine
	; sick dingle but different seed and bends down
	jsr apu_bend_down
	jsr song_01
	rts


; ending good
song_08: subroutine
	inc apu_temp
	jsr song_01
	rts

*/
