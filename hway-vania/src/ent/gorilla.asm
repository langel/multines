
; ent_r0 sine counter
; ent_r1 wing counter
; ent_r2 wing frame


ent_gorilla_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_gorilla_id
	sta ent_type,x
.done
	lda #$30
	sta ent_x,x
	lda #$28
	sta ent_y,x
	lda #$80
	sta ent_r0,x
	rts



ent_gorilla_update: subroutine
	; update 

	; increase sine pahse
	inc ent_r0,x
	ldy ent_r0,x
	lda sine_table,y
	lsr
	clc
	adc ent_x,x
	sta temp00
	clc
	tya
	adc #$40
	tay
	lda sine_table,y
	lsr
	clc
	adc ent_y,x
	sta temp01

	; animate hair
	lda #$00
	sta temp03
	lda ent_r0,x
	bmi .hair_flip_done
	lda #$40
	sta temp03
.hair_flip_done


	; set metasprite id
	; XXX mouf open or closed
	lda wtf
	shift_r 4
	and #$01
	sta temp02

	; adjust eyeline
	lda #$00
	sta temp04 ; x offset
	sta temp05 ; y offset
	; calc x offset
	lda temp00
	adc #$08
	cmp $0360
	bcc .look_right
	sbc #$10
	cmp $0360
	bcc .x_done
.look_left
	dec temp04
	jmp .x_done
.look_right
	inc temp04
.x_done
	; clac y offset
	lda temp01
	cmp $03c0
	bcc .look_down
.look_up
	dec temp05
	jmp .y_done
.look_down
	inc temp05
.y_done

	; wing animation
	dec ent_r1,x
	bpl .wing_anim_done
	inc ent_r2,x
	lda ent_r2,x
	and #$01
	sta ent_r2,x
	lda #$05
	sta ent_r1,x
.wing_anim_done
	
	; setup collision
	lda temp00
	sta collision_1_x
	lda temp01
	sta collision_1_y
	lda #$10
	sta collision_1_w
	lda #$18
	sta collision_1_h

	lda #$01
	sta temp06
	lda #$02
	sta temp07
	jsr collision_detect
	beq .no_hit
	lda wtf
	shift_r 1
	and #$03
	sta temp06
	sta temp07
.no_hit


	; RENDER
	ldy ent_spr_ptr
	; x
	clc
	lda temp00
	sta spr_x,y
	sta spr_x+8,y
	sta spr_x+16,y	
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	sta spr_x+20,y
	lda temp03
	beq .hair_fix_done
	lda temp00
	sta spr_x+4,y
	clc
	adc #$08
	sta spr_x,y
.hair_fix_done
	; y
	clc
	lda temp01
	sta spr_y,y
	sta spr_y+4,y
	clc
	adc #$08
	sta spr_y+8,y
	sta spr_y+12,y
	clc
	adc #$08
	sta spr_y+16,y	
	sta spr_y+20,y
	; a
	lda temp06
	ora temp03
	sta spr_a,y
	sta spr_a+4,y
	lda temp06
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y
	sta spr_a+20,y
	; p
	lda temp02
	bne .frame1
.frame0
	lda #$0e
	clc
	sta spr_p,y
	adc #$01
	sta spr_p+4,y
	adc #$0f
	sta spr_p+8,y
	adc #$01
	sta spr_p+12,y
	adc #$0f
	sta spr_p+16,y
	adc #$01
	sta spr_p+20,y
	jmp .frame_done
.frame1
	lda #$0e
	sta spr_p,y
	lda #$0f
	sta spr_p+4,y
	lda #$1e
	sta spr_p+8,y
	lda #$1f
	sta spr_p+12,y
	lda #$3e
	sta spr_p+16,y
	lda #$3f
	sta spr_p+20,y
.frame_done

	tya
	clc
	adc #$18
	tay

	; eyes
	; x
	clc
	lda temp00
	adc temp04
	sta spr_x,y
	clc
	adc #$08
	sta spr_x+4,y
	; y
	clc
	lda temp01
	adc temp05
	adc #$07
	sta spr_y,y
	sta spr_y+4,y
	; a
	lda #$00
	sta spr_a,y
	lda #$40
	sta spr_a+4,y
	; p
	lda #$4e
	sta spr_p,y
	sta spr_p+4,y

	tya
	clc
	adc #$08
	tay

	; mouf
	lda temp00
	sta spr_x,y
	clc
	adc #$08
	sta spr_x+4,y
	lda temp01
	clc
	adc #$10
	sta spr_y,y
	sta spr_y+4,y
	lda #$02
	sta spr_a,y
	lda #$42
	sta spr_a+4,y
	lda #$4f
	sta spr_p,y
	sta spr_p+4,y

	tya
	clc
	adc #$08
	tay

	; wings
	; x pos
	lda temp00
	sec
	sbc #$0e
	sta spr_x,y
	clc
	adc #$08
	sta spr_x+4,y
	adc #$14
	sta spr_x+8,y
	adc #$08
	sta spr_x+12,y
	; y pos
	lda temp01
	clc
	adc #$06
	sta spr_y,y
	sta spr_y+4,y
	sta spr_y+8,y
	sta spr_y+12,y
	; a
	lda temp07
	sta spr_a+8,y
	sta spr_a+12,y
	ora #$40
	sta spr_a,y
	sta spr_a+4,y
	; p
	lda ent_r2,x
	bne .wframe1
.wframe0
	lda #$0d
	sta spr_p,y
	sta spr_p+12,y
	lda #$0c
	sta spr_p+4,y
	sta spr_p+8,y
	jmp .wings_done
.wframe1
	lda #$1d
	sta spr_p,y
	sta spr_p+12,y
	lda #$1c
	sta spr_p+4,y
	sta spr_p+8,y
.wings_done

	tya
	clc
	adc #$10
	tay

	rts
