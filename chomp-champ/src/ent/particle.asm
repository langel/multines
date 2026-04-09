; ent_r0
;	0 = standard
;	1 = eggshells
; ent_r1 spr2 x hi
; ent_r2 spr2 x
; ent_r6 vel y 
; ent_r7 vel y lo


ent_particle_spawn_from_tooth_indicator: subroutine
	jsr ent_find_slot
	bmi .done
	; x pos
	lda tooth_index
	and #$07
	shift_l 3
	clc
	adc #$a4
	jsr ent_particle_spawn_hud_cam_x
	; y pos
	lda tooth_index
	shift_r 3
	shift_l 3
	clc
	adc #$0f
	sta ent_y,x
.done
	rts

ent_particle_spawn_from_lives: subroutine
	jsr ent_find_slot
	bmi .done
	; x pos
	lda player_lives
	shift_l 4
	clc
	adc #$18
	jsr ent_particle_spawn_hud_cam_x
	; y pos
	lda #$12
	sta ent_y,x
.done
	rts

ent_particle_spawn_hud_cam_x:
	; x
	adc camera_x
	sta ent_x,x
	lda camera_x_hi
	adc #$00
	sta ent_x_hi,x
	jsr ent_particle_setup_2nd
	; basic shit
	lda #ent_particle_id
	sta ent_type,x
	lda #$07
	sta ent_hp,x
	rts


ent_particle_spawn_from_egg: subroutine
	; needs to be new slot
	jsr ent_find_slot
	bmi .done
	lda #ent_particle_id
	sta ent_type,x
	lda #$01
	sta ent_r0,x
	lda #$00
	sta ent_hp,x
	; transfer egg position
	ldy ent_slot
	lda ent_x,y
	sta ent_x,x
	lda ent_x_hi,y
	sta ent_x_hi,x
	lda ent_y,y
	sta ent_y,x
	jsr ent_particle_setup_2nd
.done
	ldx ent_slot
	ldy ent_spr_ptr
	rts


ent_particle_spawn_from_baddie: subroutine
	; replaces baddy slot
	lda #ent_particle_id
	sta ent_type,x
	lda #$07
	sta ent_hp,x
	lda #$00
	sta ent_r0,x
	;jsr ent_particle_setup_2nd
	;rts

ent_particle_setup_2nd: subroutine
	; setup 2nd particle
	lda ent_x,x
	clc
	adc #$08
	sta ent_r2,x
	lda ent_x_hi,x
	adc #$00
	sta ent_r1,x
	rts
	


ent_particle_update: subroutine
	lda ent_hp,x
	bpl .not_falling

	; FALLING STATE
	; x falling
	sec
	lda ent_x,x
	sbc #$01
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
	clc
	lda ent_r2,x
	adc #$01
	sta ent_r2,x
	lda ent_r1,x
	adc #$00
	sta ent_r1,x
	; y falling
	clc
	lda ent_r6,x
	adc #$40
	sta ent_r6,x
	lda ent_r7,x
	adc #$00
	sta ent_r7,x
	clc
	lda ent_y_lo,x
	adc ent_r6,x
	sta ent_y_lo,x
	lda ent_y,x
	adc ent_r7,x
	sta ent_y,x
	cmp #$f0
	bcc .dont_despawn
	jmp ent_z_despawn
.dont_despawn
	jmp ent_particle_render

.not_falling
	dec ent_hp,x
	; check hp
	lda ent_hp,x
	bpl .lives
	;lda #$80
	;sta ent_r0,x
	lda ent_x,x
	clc
	adc #$07
	sta ent_r2,x
	lda ent_x_hi,x
	adc #$00
	sta ent_r1,x
	lda #$fd
	sta ent_r7,x
	lda #$00
	sta ent_r6,x
.lives




ent_particle_render: subroutine
	ldy ent_spr_ptr
	; always 2 sprites
	
	lda ent_r0,x
	bne .eggshells
.standard
	lda ent_hp,x
	bpl .big_x
.particle
	lda #$34
	jmp .standard_sprite_done
.big_x
	lda #$32
.standard_sprite_done
	sta temp00
	lda wtf
	lsr
	and #$03
	sta temp01
	jmp .sprites_set
.eggshells
	lda #$30
	sta temp00
	lda #$03
	sta temp01
.sprites_set

.sprite_1
	sec
	lda ent_x,x
	sbc camera_x
	sta collision_0_x
	lda ent_x_hi,x
	sbc camera_x_hi
	bne .sprite_2
	lda temp00
	sta spr_p,y
	lda temp01
	sta spr_a,y
	lda collision_0_x
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	inc_y 4

.sprite_2
	sec
	lda ent_r2,x
	sbc camera_x
	sta collision_0_x
	lda ent_r1,x
	sbc camera_x_hi
	bne .sprite_done
	lda temp00
	sta spr_p,y
	lda temp01
	ora #$40
	sta spr_a,y
	lda collision_0_x
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	inc_y 4

.sprite_done

	jmp ent_z_update_return



