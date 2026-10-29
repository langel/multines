
; ent_r0 sine counter
; ent_r1 wing counter
; ent_r2 wing frame
; ent_r3 mouth counter
; ent_r4 hair counter

; temp00 x origin
; temp01 y origin
; temp02 hair frame
; temp03 hair mirror flag
; temp04 eyeline x
; temp05 eyeline y
; temp06 collision attribute
; temp07 wings attribute

ent_gorilla_spawn: subroutine
	jsr baddies_find_slot
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


ent_gorilla_mouf:
	hex 2f 3f 4f 5f 5f 4f 3f 2f


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
	; animation frame
	lda ent_r4,x
	clc
	adc #42
	sta ent_r4,x
	shift_r 7
	and #$01
	shift_l 4
	clc
	adc #$0e
	sta temp02
	; attr mirror
	lda #$00
	sta temp03
	lda ent_r0,x
	bmi .hair_flip_done
	lda #$40
	sta temp03
.hair_flip_done


	; adjust eyeline
	lda #$00
	sta temp04 ; x offset
	sta temp05 ; y offset
	; calc x offset
	lda temp00
	adc #$08
	cmp player_x
	bcc .look_right
	sbc #$10
	cmp player_x
	bcc .x_done
.look_left
	dec temp04
	jmp .x_done
.look_right
	inc temp04
.x_done
	; clac y offset
	lda temp01
	cmp player_y
	bcc .look_down
.look_up
	dec temp05
	jmp .y_done
.look_down
	inc temp05
.y_done
	
	; mouf animation
	lda wtf
	shift_r 3
	and #$07
	tay
	lda ent_gorilla_mouf,y
	sta ent_r3,x

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

	; top left
	lda temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	lda temp06 
	ora temp03
	sta spr_a,y
	lda temp03
	beq .tl_p_normal
.tl_p_abnormal
	lda temp02
	clc
	adc #$01
	jmp .tl_set_p
.tl_p_normal
	lda temp02
.tl_set_p
	sta spr_p,y
	inc_y 4

	; top right
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda temp01
	sta spr_y,y
	lda temp06 
	ora temp03
	sta spr_a,y
	lda temp03
	bne .tr_p_normal
.tr_p_abnormal
	lda temp02
	clc
	adc #$01
	jmp .tr_set_p
.tr_p_normal
	lda temp02
.tr_set_p
	sta spr_p,y
	inc_y 4

	; mid left
	lda temp00
	sta spr_x,y
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda temp06
	sta spr_a,y
	lda #$2e
	sta spr_p,y
	inc_y 4

	; mid right
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda temp06
	ora #$40
	sta spr_a,y
	lda #$2e
	sta spr_p,y
	inc_y 4

	; butt left
	lda temp00
	sta spr_x,y
	lda temp01
	clc
	adc #$10
	sta spr_y,y
	lda temp06
	sta spr_a,y
	lda ent_r3,x
	sta spr_p,y
	inc_y 4
	; butt right
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda temp01
	clc
	adc #$10
	sta spr_y,y
	lda temp06
	ora #$40
	sta spr_a,y
	lda ent_r3,x
	sta spr_p,y
	inc_y 4


	; eyes left
	; x
	clc
	lda temp00
	adc temp04
	sta spr_x,y
	; y
	clc
	lda temp01
	adc temp05
	adc #$07
	sta spr_y,y
	; a
	lda #$00
	sta spr_a,y
	; p
	lda #$3e
	sta spr_p,y
	inc_y 4
	
	; eyes right
	; x
	clc
	lda temp00
	adc temp04
	clc
	adc #$08
	sta spr_x,y
	; y
	clc
	lda temp01
	adc temp05
	adc #$07
	sta spr_y,y
	; a
	lda #$40
	sta spr_a,y
	; p
	lda #$3e
	sta spr_p,y
	inc_y 4

	tya
	clc
	adc #$08
	tay

	; mouf
	lda temp00
	sta spr_x,y
	lda temp01
	clc
	adc #$11
	sta spr_y,y
	lda #$02
	sta spr_a,y
	lda #$4e
	sta spr_p,y
	inc_y 4
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda temp01
	clc
	adc #$11
	sta spr_y,y
	lda #$42
	sta spr_a,y
	lda #$4e
	sta spr_p,y
	inc_y 4

	; wings
	; leftmost
	lda temp00
	sec
	sbc #$0e
	sta temp00
	sta spr_x,y
	lda temp01
	clc
	adc #$06
	sta temp01
	sta spr_y,y
	lda temp07
	ora #$40
	sta spr_a,y
	lda ent_r2,x
	shift_l 4
	ora #$0d
	sta spr_p,y
	; left
	inc_y 4
	lda temp00
	clc
	adc #$08
	sta temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	lda temp07
	ora #$40
	sta spr_a,y
	lda ent_r2,x
	shift_l 4
	ora #$0c
	sta spr_p,y
	inc_y 4
	; right
	inc_y 4
	lda temp00
	clc
	adc #$14
	sta temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	lda temp07
	sta spr_a,y
	lda ent_r2,x
	shift_l 4
	ora #$0c
	sta spr_p,y
	inc_y 4
	; rightmost
	inc_y 4
	lda temp00
	clc
	adc #$08
	sta temp00
	sta spr_x,y
	lda temp01
	sta spr_y,y
	lda temp07
	sta spr_a,y
	lda ent_r2,x
	shift_l 4
	ora #$0d
	sta spr_p,y
	inc_y 4

	rts
