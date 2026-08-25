
; 
;	CHOMP CHAMP NSF


	processor 6502

	seg.u ZEROPAGE
	org $0000
	include "./_common/definitions.asm"
	include "./_common/zero_page.asm"
	include "src/memory_map.asm"
	
	seg NSF_HEADER
	; start 128 bytes before data
	; set byte fill to #$00
	org $df80, $00

	; header id "NESM⌁"
	hex 4e 45 53 4d 1a 
	; nsf version
	hex 01 
	; total songs
	byte 32
	; starting song
	byte 01 
	; load address of data
	word $e000
	; init address of data
	word nsf_init
	; play address of data
	word nsf_play

	org $df8e
	; meta tag fields
	; 31 bytes null terminated
	; title
	byte "Chomp Champ"
	org $dfad
	hex 00
	; composer
	byte "b-knox"
	org $dfcd
	hex 00
	; copyright
	byte "LoBlast MMXXVI"
	org $dfed
	hex 00

	; play speed ntsc
	hex 1a 41 
	; bankswitch init values
	hex 00 00 00 00 00 00 00 00
	; play speed pal
	hex 20 4e
	; pal/ntsc bits
	; bit0 clear = ntsc
	; bit1 set = pal
	; bit1 set = dual pal/ntsc
	hex 02 ; dual tunage
	; extra sound chips
	hex 00 ; none
	; reserved for nsf2
	hex 00 
	; 24 bit length of data
	; 0 = load all data
	hex 00 00 00 


	seg SONG_DATA
	org $e000
	
	; dpcm samples
	incbin "./chomp-champ/assets/chomp.dmc"

	include "./_common/lib/apu_defs.asm"
	include "./_common/lib/apu_engine.asm"
	include "./_common/lib/apu_env.asm"
	include "./_common/lib/apu_sfx.asm"
	include "./_common/lib/apu_song.asm"
	include "./_common/lib/babapu.asm"
	include "./_common/assets/song_data.asm"

	include "./_common/lib/rng.asm"
	include "./_common/lib/sine_tables.asm"


updater_lo     eqm $40
updater_hi     eqm $41
counter_lo     eqm $42
counter_hi     eqm $43

sfx_end_frame  eqm $d7


do_nothing: subroutine
	rts


nsf_play: subroutine
	jsr apu_update
	jmp ($40)
	rts


nsf_init: subroutine
	sta $07ff
	jsr apu_init
	; default updater pointer
	lda #<do_nothing
	sta updater_lo
	lda #>do_nothing
	sta updater_hi
	; track init trampoline
	ldx $07ff
	lda nsf_track_start_lo,x
	sta temp00
	lda nsf_track_start_hi,x
	sta temp01
	jmp (temp00)
	rts


nsf_track_start_lo:
	byte #<sfx_3_chomps
	byte #<song_game_new
	byte #<song_player_spawn
	byte #<sfx_cretin_walk_start
	byte #<sfx_brushing_start
	byte #<sfx_floss_tingler
	byte #<sfx_food_falls1
	byte #<sfx_food_falls2
	byte #<sfx_powerup_battery_100
	byte #<song_level_clear
	byte #<sfx_germ_step_start
	byte #<sfx_germ_poops1
	byte #<sfx_germ_poops2
	byte #<sfx_germ_poops3
	byte #<sfx_germ_poops4
	byte #<song_player_death
	byte #<sfx_hud_life_lost
	byte #<sfx_2_chomps
	byte #<sfx_gnat_buzz_far
	byte #<sfx_gnat_buzz_near
	byte #<sfx_egg_hatching
	byte #<sfx_grub_sliding
	byte #<sfx_grub_converge
	byte #<sfx_cc_enemy_death
	byte #<sfx_tooth_lost1
	byte #<sfx_tooth_lost2
	byte #<sfx_tooth_lost3
	byte #<sfx_tooth_lost4
	byte #<song_game_over
	byte #<sfx_1_chomps
	byte #<song_game_clear
	byte #<song_congration

nsf_track_start_hi:
	byte #>sfx_3_chomps
	byte #>song_game_new
	byte #>song_player_spawn
	byte #>sfx_cretin_walk_start
	byte #>sfx_brushing_start
	byte #>sfx_floss_tingler
	byte #>sfx_food_falls1
	byte #>sfx_food_falls2
	byte #>sfx_powerup_battery_100
	byte #>song_level_clear
	byte #>sfx_germ_step_start
	byte #>sfx_germ_poops1
	byte #>sfx_germ_poops2
	byte #>sfx_germ_poops3
	byte #>sfx_germ_poops4
	byte #>song_player_death
	byte #>sfx_hud_life_lost
	byte #>sfx_2_chomps
	byte #>sfx_gnat_buzz_far
	byte #>sfx_gnat_buzz_near
	byte #>sfx_egg_hatching
	byte #>sfx_grub_sliding
	byte #>sfx_grub_converge
	byte #>sfx_cc_enemy_death
	byte #>sfx_tooth_lost1
	byte #>sfx_tooth_lost2
	byte #>sfx_tooth_lost3
	byte #>sfx_tooth_lost4
	byte #>song_game_over
	byte #>sfx_1_chomps
	byte #>song_game_clear
	byte #>song_congration


song_game_new:
	ldx #<song_cc_game_new
	ldy #>song_cc_game_new
	jsr babapu_start
	rts
	
song_player_spawn:
	ldx #<song_cc_level_start
	ldy #>song_cc_level_start
	jsr babapu_start
	rts

song_player_death:
	ldx #<song_cc_player_death
	ldy #>song_cc_player_death
	jsr babapu_start
	rts

song_level_clear:
	ldx #<song_cc_level_clear
	ldy #>song_cc_level_clear
	jsr babapu_start
	rts
	
song_game_over:
	ldx #<song_cc_game_over
	ldy #>song_cc_game_over
	jsr babapu_start
	rts

song_game_clear:
	ldx #<song_cc_game_clear
	ldy #>song_cc_game_clear
	jsr babapu_start
	rts
	
song_congration:
	ldx #<song_cc_congration
	ldy #>song_cc_congration
	jsr babapu_start
	rts


sfx_cretin_walk_start:
	lda #<sfx_cretin_walk_update
	sta $40
	lda #>sfx_cretin_walk_update
	sta $41
	rts
sfx_cretin_walk_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	; wait to step
	inc state02
	lda state02
	cmp #$05
	bcc .done
	lda #$00
	sta state02
	inc state01
	; sfx
	lda state01
	cmp #$02
	beq .sfx_go
	cmp #$05
	beq .sfx_go
	cmp #$06
	bne .done
	lda #$00
	sta state01
	jmp .done
.sfx_go
	jsr sfx_cretin_walk
.done
	rts

sfx_brushing_start:
	lda #<sfx_brushing_update
	sta $40
	lda #>sfx_brushing_update
	sta $41
	rts
sfx_brushing_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	; check for next sound
	inc state02
	lda state02
	cmp #$03
	bcc .done
	lda #$00
	sta state02
	inc state01
	lda state01
	cmp #$04
	bcc .wrap_done
	lda #$00
	sta state01
.wrap_done
	bne .not_upward
	jsr sfx_brush_up
	jmp .done
.not_upward
	cmp #$02
	bne .done
	jsr sfx_brush_down
.done
	rts

sfx_floss_tingler:
	jsr sfx_tingler
	lda #<sfx_floss_update
	sta $40
	lda #>sfx_floss_update
	sta $41
	rts
sfx_floss_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .disable
	inc $07f0
	jmp .done
.disable
	lda #$00
	sta sfx_pu2_update_id
.done
	rts


sfx_germ_step_start:
	lda #<sfx_germ_step_update
	sta $40
	lda #>sfx_germ_step_update
	sta $41
	rts
sfx_germ_step_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	; wait to step
	inc state00
	lda state00
	cmp #$06
	bcc .done
	lda #$00
	sta state00
	inc state01
	lda state01
	and #$03
	sta state01
	and #$01
	beq .done
	jsr sfx_germ_step
.done
	rts


sfx_germ_poops1:
	lda #$20
	sta audio_rng
	jsr sfx_germ_poops
	rts

sfx_germ_poops2:
	lda #$60
	sta audio_rng
	jsr sfx_germ_poops
	rts

sfx_germ_poops3:
	lda #$a0
	sta audio_rng
	jsr sfx_germ_poops
	rts

sfx_germ_poops4:
	lda #$e0
	sta audio_rng
	jsr sfx_germ_poops
	rts



sfx_gnat_buzz_far:
	lda #<sfx_gnat_buzz_far_update
	sta $40
	lda #>sfx_gnat_buzz_far_update
	sta $41
	rts
sfx_gnat_buzz_far_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	jsr sfx_gnat_buzz
	rts
.done
	jsr apu_init
	rts

sfx_gnat_buzz_near:
	inc ent_visible
	lda #<sfx_gnat_buzz_near_update
	sta $40
	lda #>sfx_gnat_buzz_near_update
	sta $41
	lda #$37
	sta audio_rng
	rts
sfx_gnat_buzz_near_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	jsr sfx_gnat_buzz
	rts
.done
	jsr apu_init
	rts


sfx_egg_hatching:
	lda #<sfx_egg_hatching_update
	sta $40
	lda #>sfx_egg_hatching_update
	sta $41
	rts
sfx_egg_hatching_update: subroutine
	lda state07
	bne .done
	dec state00
	bne .dont_hatch
	jsr sfx_egg_hatch
	inc state07
	jmp .done
.dont_hatch
	sec
	lda #$ff
	sbc state00
	shift_r 2
	clc
	adc state03
	sta state03
	tay
	bcc .done
	jsr sfx_egg_shake
.done
	rts


sfx_grub_sliding:
	lda #$02
	sta state01
	lda #<sfx_grub_sliding_update
	sta $40
	lda #>sfx_grub_sliding_update
	sta $41
	rts
sfx_grub_sliding_update: subroutine
	lda $07f0
	cmp #sfx_end_frame
	beq .done
	inc $07f0
	; sfx
	dec state01
	bne .done
	lda #$07
	sta state01
	jsr sfx_grub_slide
.done 
	rts


sfx_tooth_lost1:
	lda #$02
	sta audio_rng
	jsr sfx_tooth_lost
	rts
sfx_tooth_lost2:
	lda #$16
	sta audio_rng
	jsr sfx_tooth_lost
	rts
sfx_tooth_lost3:
	lda #$2a
	sta audio_rng
	jsr sfx_tooth_lost
	rts
sfx_tooth_lost4:
	lda #$3e
	sta audio_rng
	jsr sfx_tooth_lost
	rts

sfx_food_falls1:
	lda #$04
	sta audio_rng
	jsr sfx_food_fall
	rts
sfx_food_falls2:
	lda #$1c
	sta audio_rng
	jsr sfx_food_fall
	rts



sfx_3_chomps:
	lda #$03
	sta continues
	jmp sfx_set_chomps_update
sfx_2_chomps:
	lda #$02
	sta continues
	jmp sfx_set_chomps_update
sfx_1_chomps:
	lda #$01
	sta continues
sfx_set_chomps_update:
	; setup ptr
	lda #<sfx_chomps_update
	sta $40
	lda #>sfx_chomps_update
	sta $41
	; setup sfx
	lda continues
	sec
	sbc #$01
	sta state04
	lda #$01
	sta state01 ; chomp_teeth_open_dir
	lda #$38
	sta state00 ; chomp_teeth_open
	rts

sfx_chomps_update:
	lda state07
	bne .chomp_count_done
	jsr state_chomp_teeth_animate
	lda state01
	bne .chomp_count_done
	lda state00
	cmp #$04
	bne .chomp_count_done
	dec state04 
	bpl .chomp_count_done
	inc state07
.chomp_count_done
	rts
state_chomp_teeth_animate: subroutine
	lda state01 ; chomp_teeth_open_dir
	beq .opening
.closing
	lda state00 ; chomp_teeth_open
	beq .flip_open
	cmp #$28
	bne .chomp_sample_done
	jsr sfx_dpcm_chomp
.chomp_sample_done
	lda state00
	sec
	sbc #$04
	sta state00
	cmp #$e6
	bcc .openness_done
.flip_open
	lda #$00
	sta state01
	jmp .openness_done
.opening
	lda state00
	clc
	adc #$04
	sta state00
	cmp #$28
	bcc .openness_done
	lda #$01
	sta state01
.openness_done
	; set bottom scroll_y
	lda #$80
	sec 
	sbc state00
	clc
	adc #$08
	sta state03
	rts
