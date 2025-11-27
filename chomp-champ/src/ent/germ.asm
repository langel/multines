
; ent_r0 animation counter
; ent_r1 frame counter
; ent_r2 poop clock



ent_germ_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_germ_id
	sta ent_type,x
.reroll
	jsr rng_update
	lda rng_val0
	cmp #$10
	bcc .reroll
	rol
	sta ent_x,x
	bcs .not_nm2
	inc ent_x_hi,x
.not_nm2
	lda rng_val1
	cmp #$d0
	bcs .reroll
	cmp #$30
	bcc .reroll
	sta ent_y,x
	; setup ppo clock
	jsr rng_update
	lda rng_val0
	sta ent_r2,x
.done
	rts

ent_germ_update: subroutine

	; spawn poop?
	lda ent_r2,x
	cmp wtf
	bne .no_poop
	;jsr ent_poop_from_germ
.no_poop

	; update animation frame
	inc ent_r0,x
	lda ent_r0,x
	cmp #$0b
	bne .not_next_frame
	lda #$00
	sta ent_r0,x
	inc ent_r1,x
	lda ent_r1,x
	and #$01
	sta ent_r1,x
.not_next_frame

	; RENDER
	jsr ent_calc_position
	lda ent_r1,x
	asl
	clc
	adc #$60
	sta temp00
	lda #$01
	sta temp01
	jsr ent_render_generic
	rts

