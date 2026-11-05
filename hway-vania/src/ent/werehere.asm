
; ent_r0 pal frame
; ent_r1 pal counter
; ent_r2 sine counter


ent_werehere_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_werehere_id
	sta ent_type,x
.done

	lda #$58
	sta ent_x,x
	lda #$40
	sta ent_y,x

	lda #$01
	sta ent_r0,x

	rts

	; letters defined top-down, left-right
	; values alternate pattern and attribute
	; 00 pattern ignored
werehere_w: ; 00
	hex ac 00 bc 00 ac 40 bc 40
werehere_e: ; 01
	hex ad 00 ad 80 00 00 00 00
werehere_a: ; 02 ; apostrophe
	hex bd 00 00 00 00 00 00 00
werehere_r: ; 03
	hex ae 00 be 00 00 00 00 00
werehere_h: ; 04
	hex af 00 bf 00 af 40 bf 40

	; phrase data
	; 3 byte records
	; letter, x offset, y offset
	; 1 byte padding
werehere_data:
	hex 00 00 00 00 ; W
	hex 01 14 00 00 ; E
	hex 02 0b 00 00 ; '
	hex 03 0c 00 00 ; R
	hex 01 0e 00 00 ; E
	hex 04 cc 1c 00 ; H
	hex 01 14 00 00 ; E
	hex 03 0e 00 00 ; R
	hex 01 0e 00 00 ; E


ent_werehere_update: subroutine
	; update logic

	inc ent_r1,x
	lda ent_r1,x
	cmp #$0b
	bne .next_pal_done
	lda #$00
	sta ent_r1,x
	inc ent_r0,x
	lda ent_r0,x
	and #$03
	bne .pal_ready
	clc
	adc #$01
.pal_ready
	sta ent_r0,x
.next_pal_done

	; SINE SPEED
	clc
	lda ent_r2,x
	adc #$03
	sta ent_r2,x
	sta temp01
	
	; render (reload y?)
	
	lda ent_x,x
	sta temp04
	lda ent_y,x
	sta temp05
	lda ent_r0,x
	sta temp00

	ldx #$00
.loop:
	; temp00 attr pal
	; temp01 sine pos
	clc
	lda temp01
	adc #$17
	sta temp01
	; temp02 x register
	; temp03 letter id
	; temp04 x offset
	; temp05 y offset
	; temp06 y SINE
	ldy temp01
	lda sine_table,y
	shift_r 4
	sta temp06
	; temp07 y SINE
	lda temp01
	clc
	adc #$40
	tay
	lda sine_table,y
	shift_r 5
	sta temp07

	; stash x
	stx temp02
	txa
	shift_l 2
	tax
	; letter id
	lda werehere_data,x
	sta temp03
	; x offset
	ldy temp01
	clc
	lda werehere_data+1,x
	adc temp04
	sta temp04
	; y offset
	clc
	lda temp01
	adc #$40
	tay
	clc
	lda werehere_data+2,x
	adc temp05
	sta temp05

	ldy ent_spr_ptr
	
	lda temp03
	shift_l 3
	tax
	; letter sprite 0
	lda werehere_w,x
	sta spr_p,y
	lda werehere_w+1,x
	ora temp00
	sta spr_a,y
	clc
	lda temp04
	adc temp06
	sta spr_x,y
	clc
	lda temp05
	adc temp07
	sta spr_y,y
	inc_x 2
	inc_y 4
.spr_0_done
	; letter sprite 1
	lda werehere_w,x
	beq .spr_1_next
	sta spr_p,y
	lda werehere_w+1,x
	ora temp00
	sta spr_a,y
	clc
	lda temp04
	adc temp06
	sta spr_x,y
	clc
	lda temp05
	adc temp07
	adc #$08
	sta spr_y,y
.spr_1_next
	inc_x 2
	inc_y 4
.spr_1_done
	; letter sprite 2
	lda werehere_w,x
	beq .spr_2_next
	sta spr_p,y
	lda werehere_w+1,x
	ora temp00
	sta spr_a,y
	clc
	lda temp04
	adc temp06
	adc #$08
	sta spr_x,y
	clc
	lda temp05
	adc temp07
	sta spr_y,y
.spr_2_next
	inc_x 2
	inc_y 4
.spr_2_done
	; letter sprite 3
	lda werehere_w,x
	beq .spr_3_next
	sta spr_p,y
	lda werehere_w+1,x
	ora temp00
	sta spr_a,y
	clc
	lda temp04
	adc temp06
	adc #$08
	sta spr_x,y
	clc
	lda temp05
	adc temp07
	adc #$08
	sta spr_y,y
.spr_3_next
	inc_x 2
	inc_y 4
.spr_3_done

	sty ent_spr_ptr
	ldx temp02
	inx
	cpx #$09
	beq .render_done
	jmp .loop
.render_done

	rts
