
; zp vars

;sfx_phase_next_counter		
; counters to mask other channel audio
;sfx_pu1_counter	
;sfx_pu2_counter	
;sfx_noi_counter	
; table offsets for update subroutines
;sfx_pu2_update_type	
;sfx_noi_update_type	

; these should only use Pulse 2 and Noise channels
; unless its a non-music moment (like player death)


sfx_init_table_lo:
	byte #<sfx_pewpew
	byte #<sfx_player_damage
	byte #<sfx_player_death
	byte #<sfx_enemy_damage
	byte #<sfx_enemy_death
	byte #<sfx_powerup_hit
	byte #<sfx_powerup_mask	
	byte #<sfx_powerup_1up	
	byte #<sfx_powerup_battery_25	
	byte #<sfx_powerup_battery_50	
	byte #<sfx_powerup_battery_100
	byte #<sfx_shoot_dart	
	byte #<sfx_shoot_bullet	
	byte #<sfx_rng_chord	
	byte #<sfx_phase_next	
	byte #<sfx_snare	
	byte #<sfx_hat	
	byte #<sfx_ghost_snare	
sfx_init_table_hi:
	byte #>sfx_pewpew
	byte #>sfx_player_damage
	byte #>sfx_player_death
	byte #>sfx_enemy_damage
	byte #>sfx_enemy_death
	byte #>sfx_powerup_hit
	byte #>sfx_powerup_mask	
	byte #>sfx_powerup_1up	
	byte #>sfx_powerup_battery_25	
	byte #>sfx_powerup_battery_50	
	byte #>sfx_powerup_battery_100
	byte #>sfx_shoot_dart	
	byte #>sfx_shoot_bullet	
	byte #>sfx_rng_chord	
	byte #>sfx_phase_next	
	byte #>sfx_snare	
	byte #>sfx_hat	
	byte #>sfx_ghost_snare	
        
sfx_update_table_lo:
	byte #<do_nothing                 ; 0
	byte #<sfx_player_death_update    ; 1
	byte #<sfx_enemy_death_update     ; 2
	byte #<sfx_powerup_battery_update ; 3
	byte #<sfx_powerup_1up_update     ; 
	byte #<sfx_phase_next_update      ; 
	byte #<sfx_tingler_update      ; 
	byte #<sfx_brush_up_update
	byte #<sfx_brush_down_update
sfx_update_table_hi:
	byte #>do_nothing                 ; 0
	byte #>sfx_player_death_update    ; 1
	byte #>sfx_enemy_death_update     ; 2
	byte #>sfx_powerup_battery_update ; 3
	byte #>sfx_powerup_1up_update     ; 
	byte #>sfx_phase_next_update      ; 
	byte #>sfx_tingler_update
	byte #>sfx_brush_up_update
	byte #>sfx_brush_down_update

sfx_tingler_id           equ $06
sfx_brush_up_id          equ $07
sfx_brush_down_id        equ $08
        
        
sfx_update_delegator: subroutine
	; a = sound effect id
	tay
	lda #sfx_update_table_lo,y
	sta temp00
	lda #sfx_update_table_hi,y
	sta temp01
	jmp (temp00)

sfx_pu2_update_stop: subroutine
	lda #$00
	sta sfx_pu2_update_type
	rts
sfx_noi_update_stop: subroutine
	lda #%00010000
	sta apu_cache+$c
	lda #$00
	sta sfx_noi_update_type
	rts
        
        
sfx_tingler_notes:
	;   E  B  D  A  C  G  D  A
	hex 4c 47 4a 45 48 43 4a 45
	;   E  B  D  A# C  G  D  A#
	hex 4c 47 4a 46 48 43 4a 46
	;   E  B  A  C# C  G  A  C#
	hex 4c 47 45 49 48 43 45 49
	;   E  B  G# C# C  G  G# C#
	hex 4c 47 44 49 48 43 44 49
sfx_tingler: subroutine
	lda sfx_pu2_counter
	bne .done
	lda #$00
	sta sfx_temp00
	sta sfx_temp01
	sta sfx_temp02
	sta sfx_temp03
	lda #sfx_tingler_id
	sta sfx_pu2_update_type
.done
	rts
sfx_tingler_update: subroutine
	lda sfx_temp00
	cmp #$05
	bne .not_next
	lda #$00
	sta sfx_temp00
	; pulse 2
	lda sfx_temp02
	shift_l 3
	sta temp00
	jsr rng_update
	lda rng_val0
	and #$07
	clc
	adc temp00
	tay
	lda sfx_tingler_notes,y
	tax
	lda #%10000011
	sta $4004
	lda #$00
	sta $4005
	lda periodTableLo,x
	sta $4006
	lda periodTableHi,x
   ora #%01000000
	sta $4007
	; next note
	inc sfx_temp01
	lda sfx_temp01
	cmp #$10
	bne .not_next
	lda #$00
	sta sfx_temp01
	inc sfx_temp02
	lda sfx_temp02
	cmp #$04
	bne .not_next
	lda #$00
	sta sfx_temp02
.not_next
	inc sfx_temp00
	rts


sfx_brush_up: subroutine
	lda #$00
	sta sfx_temp00
	lda #$0a
	sta sfx_temp01
	lda #sfx_brush_up_id
	sta sfx_noi_update_type
	rts
sfx_brush_up_update: subroutine
	inc sfx_temp00
	lda sfx_temp00
	and #$03
	bne .not_next
	dec sfx_temp01
	lda sfx_temp01
	cmp #$08
	bne .not_next
	jmp sfx_noi_update_clear 
.not_next
	lda #%00011010
	sta apu_cache+$c
	lda sfx_temp01
	sta apu_cache+$e
	rts
sfx_brush_down: subroutine
	lda #$00
	sta sfx_temp00
	lda #$04
	sta sfx_temp01
	lda #sfx_brush_down_id
	sta sfx_noi_update_type
	rts
sfx_brush_down_update: subroutine
	inc sfx_temp00
	lda sfx_temp00
	and #$03
	bne .not_next
	inc sfx_temp01
	lda sfx_temp01
	cmp #$06
	bne .not_next
	jmp sfx_noi_update_clear 
.not_next
	lda #%00011010
	sta apu_cache+$c
	lda sfx_temp01
	sta apu_cache+$e
	rts

; sound test 00
sfx_pewpew: subroutine
	lda sfx_pu2_counter
        bne .no
	; pulse 2
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda rng00
        and #$3f
        ora #$08
        sta $4006
        lda #%00010000
        sta $4007
        lda #0
        sta apu_pu2_counter
        sta sfx_pu2_update_type
.no
	rts

; sound test 01
sfx_player_damage: subroutine
	; noise
        lda rng00
        and #$8f
        ora #$0c
        sta apu_cache+$e
        lda #$10
        sta apu_noi_counter
        lda #$01
        sta apu_noi_envelope
        lda #$10
        sta sfx_noi_counter
        rts
        
; sound test 02
sfx_player_death: subroutine
        ; setup pulse 1
	lda #%10001111
        sta $4000
        lda #%10000111
        sta $4001
        lda #$fc
        sta $4002
        lda #%00001010
        sta $4003
        ; setup pulse 2
	lda #%10001111
        sta $4004
        lda #%10000111
        sta $4005
        lda #$fb
        sta $4006
        lda #%00001001
        sta $4007
        ; setup noise handler
	lda #$01
        sta sfx_noi_update_type
	lda #$00
        sta sfx_pu2_update_type
        lda #$00
        sta sfx_temp00 ; volume
        lda #$80
        sta sfx_temp01 ; pitch
        ;sta sfx_noi_counter
	rts
        
sfx_player_death_update: subroutine
        lda sfx_temp00 ; vol
        lsr
        lsr
        lsr
        lsr
        and #%00010000
        sta apu_cache+$c
        lda sfx_temp01 ; pitch
        lsr
        lsr
        lsr
        sta apu_cache+$e
        inc sfx_temp01 ; pitch
        inc sfx_temp00 ; vol
        inc sfx_temp00 ; vol
        bne .dont_kill_player_death_sound
        lda #$10
        sta apu_cache+$c
        lda #$00
        sta sfx_noi_update_type
.dont_kill_player_death_sound
	rts
        
        
        
; sound test 03
sfx_kick:
sfx_enemy_damage: subroutine
	lda sfx_pu2_counter
        bne .no
	; pulse 2
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda rng00
        sta $4006
        lda #%00010001
        sta $4007
        lda #$08
        sta sfx_pu2_counter
        lda #0
        sta sfx_pu2_update_type
.no
	rts
        
        
; sound test 04
sfx_enemy_death: subroutine
	lda #%00011111
        sta apu_cache+$c
        lda #$0f
        sta apu_cache+$e
	lda #$01
        sta apu_noi_envelope
        lda #$02
        sta sfx_noi_update_type
        lda #$10
        sta apu_noi_counter
        sta sfx_noi_counter
        rts
        
sfx_enemy_death_update: subroutine
	lda apu_cache+$c
        sta apu_cache+$e
        and #%00001111
        beq sfx_noi_update_clear
        rts

sfx_noi_update_clear: subroutine
	lda #%00010000
        sta apu_cache+$c
	lda #$00
        sta sfx_noi_update_type
        rts


        
        
; sound test 05
sfx_powerup_hit: subroutine
        lda #$82
        sta apu_cache+$e
        lda #$20
        sta apu_noi_counter
        lda #$03
        sta apu_noi_envelope
        lda #$16
        sta sfx_noi_counter
        rts
        



; sound test 08
sfx_powerup_mask: subroutine
	; fast pu2 sweep up
	lda #%10001111
        sta $4004
        lda #%11111001
        sta $4005
        lda rng00
        and #$3f
        ora #$08
        sta $4006
        lda #%00010100
        sta $4007
        lda #$10
        sta sfx_pu2_counter
	rts
        
; sound test 09
sfx_powerup_1up: subroutine
	; imperial jingle
        ; root note -- x - x x X
        lda #$00
        sta sfx_temp00
        lda #$05
        sta sfx_pu2_update_type
        rts
sfx_powerup_1up_update: subroutine
	lda sfx_temp00
        beq .trigger_lower_note
        cmp #$10
        beq .trigger_lower_note
        cmp #$18
        beq .trigger_lower_note
        cmp #$20
        beq .trigger_higher_note
        bne .done
.trigger_lower_note
	lda audio_root_tone
        clc
        adc #$18
        bne .trigger_note
.trigger_higher_note
        lda #$00
        sta sfx_pu2_update_type
	lda audio_root_tone
        clc
        adc #$24
.trigger_note
        tax
	lda #%10000011
        sta $4004
        lda #$00
        sta $4005
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        lda #$10
        sta sfx_pu2_counter
.done
	inc sfx_temp00
	rts
       
        
; sound test 0a
sfx_powerup_battery_25: subroutine
        lda #$08
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0b
sfx_powerup_battery_50: subroutine
        lda #$04
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0c
sfx_powerup_battery_100: subroutine
        lda #$00
        sta sfx_temp00 ; counter
sfx_powerup_battery_set_update_type:
	lda #$03
        sta sfx_pu2_update_type
        rts
        
sfx_powerup_battery_arp:
 .byte	#$18, #$1c, #$1f, #$24

sfx_powerup_battery_update: subroutine
	lda sfx_temp00
        and #%00000011
        bne .dont_trigger
        lda sfx_temp00
        lsr
        lsr
        cmp #$04
        beq .end_sound
        tax
        lda audio_root_tone
        clc
        adc sfx_powerup_battery_arp,x
        tax
	lda #%10000011
        sta $4004
        lda #$00
        sta $4005
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        lda #$10
        sta sfx_pu2_counter
.dont_trigger
        inc sfx_temp00 ; counter
	rts
.end_sound
	lda #$00
        sta sfx_pu2_update_type
        rts

; sound test 0d
sfx_shoot_dart: subroutine
	; pulse 1
	lda #%00001111
        sta $4000
        lda #%10000011
        sta $4001
        lda rng00
        and #$3f
        ora #$08
        sta $4002
        lda #%00001000
        sta $4003
        lda #$10
        sta sfx_pu1_counter
	rts
        
; sound test 0e
sfx_shoot_bullet: subroutine
	lda #%00011111
        sta apu_cache+$c
        lda wtf
        and #$03
        clc
        adc #$09
        sta apu_cache+$e
	lda #$03
        sta apu_noi_envelope
        lda #$20
        sta apu_noi_counter
        rts
        
        
; sound test 0f
sfx_rng_chord: subroutine
	; used hardware enevelope was 1 second
        ; ~ 64 frame fade
        ; triangle cuts off at 32 frames
        ; setup pulse 1 + 2
        lda #$40
        sta apu_pu1_counter
        sta apu_pu2_counter
        lda #$00
        sta apu_pu1_envelope
        sta apu_pu2_envelope
        ; pulse 1 pitch
        lda rng00
        and #%00001111
        clc
        adc #$10
        tax
        ldy #$02
        jsr apu_set_pitch
        ; pulse 2 pitch
        lda rng01
        and #%00001111
        clc
        adc #$08
        tax
        ldy #$06
        jsr apu_set_pitch
        ; setup triangle
        lda #$20
        sta apu_tri_counter
        lda rng_val1
        and #%00001111
        clc
        adc #$08
        tax
        ldy #$0a
        jsr apu_set_pitch
	rts
        
        
        
; sound test 10
sfx_phase_next: subroutine
        lda #$00
        sta sfx_phase_next_counter
        lda #$06
        sta sfx_pu2_update_type
        rts
        
sfx_phase_next_update: subroutine
	lda sfx_phase_next_counter
        beq .trigger_first
        cmp #$04
        beq .trigger_last
        bne .done
.trigger_first
        lda #$40
        sta apu_pu2_counter
        lda #$20
        sta sfx_pu2_counter
        lda #2
        sta apu_pu2_envelope
	lda audio_root_tone
        clc
        adc #24 ; two octaves
        tax
        ldy #6
        jsr apu_set_pitch
        bne .done
.trigger_last
        lda #$40
        sta apu_pu1_counter
        sta apu_pu2_counter
        lda #$20
        sta sfx_pu2_counter
        lda #2
        sta apu_pu1_envelope
        sta apu_pu2_envelope
	lda audio_root_tone
        clc
        adc #31 ; two octaves + 5th
        tax
        ldy #2
        jsr apu_set_pitch
        ldy #6
        jsr apu_set_pitch
        inc apu_cache+6
        inc apu_cache+6
        inc apu_cache+6
        ; trigger next phase and kill sfx
        lda #$00
        sta sfx_pu2_update_type
.done
	inc sfx_phase_next_counter
	rts
        
        
; sound test 11
sfx_snare: subroutine
        lda #$a
        sta apu_cache+$e
        lda #$06
        sta apu_noi_counter
        lda #$05
        sta apu_noi_envelope
        rts
        
; sound test 12
sfx_hat: subroutine
	lda sfx_noi_counter
        bne .no
        lda apu_rng1
        and #3
        sta apu_cache+$e
        lda #$e
        sta apu_noi_counter
        lda #$04
        sta apu_noi_envelope
.no
        rts
        
        
; sound test 13
sfx_ghost_snare: subroutine
	lda rng_val0
        and #$01
        adc #$0b
        sta apu_cache+$e
        lda #$04
        sta apu_noi_counter
        lda #$05
        sta apu_noi_envelope
        rts
