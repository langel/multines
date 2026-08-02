
big_teef_sprites:
	; upper mandible
	hex 16 18 1a 3a 1c 1e
	; lower mandible
	hex 36 38 3a 1a 3c 3e
	; connective tissue
	hex 14

big_teef_attrs:
	; upper mandible
	hex 03 03 03 83 03 03
	; lower mandible
	hex 03 03 43 c3 03 03
	; connective tissue
	hex 03

big_teef_y_offset:
	; upper mandible
	hex 02 03 06 07 04 05
	; lower mandible
	hex 03 03 05 03 06 05

ent_big_teef_spawn: subroutine
	ldx #$1f
	lda #ent_big_teef_id
	sta ent_type,x
	lda #$00
	sta ent_x_lo,x
	sta ent_x_hi,x
	lda #$80
	sta ent_y,x
	lda #$00
	sta big_teef_upper_hits
	sta big_teef_lower_hits

	; big teef palette
	lda #$16
	sta palette_cache+22
	lda #$14
	sta palette_cache+23
	lda #$27
	sta palette_cache+24

	rts


ent_big_teef_update: subroutine

	ldx ent_slot
	lda state_update_id
	cmp #state_game_update_id
	beq .in_game_update

	; title-screen behavior path (preserve existing behavior)
	; forward the animation counter
	inc ent_x,x
	lda ent_r4,x
	tax
	lda sine_table,x
	shift_r 5
	clc
	adc #$9e
	ldx ent_slot
	sta ent_y,x
	inc ent_r4,x
	inc ent_r4,x
	inc ent_r4,x

	jmp ent_big_teef_prerender

.in_game_update
	; chomp sound
	lda ent_r4,x
	cmp #$c0
	beq .sfx_go
	cmp #$c1
	beq .sfx_go
	cmp #$c2
	beq .sfx_go
	jmp .sfx_done
.sfx_go
	jsr sfx_dpcm_chomp
.sfx_done
	; world-space movement: 
	; +1 pixel +4 subpixels/frame
	clc
	lda ent_x_lo,x
	adc #$04
	sta ent_x_lo,x
	lda ent_x,x
	adc #$01
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
	cmp #$02
	bne .wrap_done
	lda #$ff
	sta ent_x_hi,x
	lda #$d0
	sta ent_x,x
	lda #$00
	sta ent_x_lo,x
.wrap_done

	; y position move toward player_y
	sec
	lda player_y
	sbc #$04 ; player_y target offset
	cmp ent_y,x
	beq .y_move_done
	bcs .move_down
.move_up
	sec
	lda ent_y_lo,x
	sbc #$60
	sta ent_y_lo,x
	lda ent_y,x
	sbc #$00
	sta ent_y,x
	jmp .y_move_done
.move_down
	clc
	lda ent_y_lo,x
	adc #$60
	sta ent_y_lo,x
	lda ent_y,x
	adc #$00
	sta ent_y,x
.y_move_done

	; keep jaw animation phase moving
	inc ent_r4,x
	inc ent_r4,x
	inc ent_r4,x

	; render above all ents
	lda #$df
	ldx ent_slot
	jsr ent_z_calc_sort_vals_9bit

ent_big_teef_prerender:
	; calc screen position
	; temp00 x cam offset
	; temp01 x cam hi offset
	sec
	lda ent_x,x
	sbc camera_x
	sta temp00
	lda ent_x_hi,x
	sbc camera_x_hi
	sta temp01

	; calc mouf parts y offsets
	; temp05 upper mandible y pos
	lda ent_y,x
	sta temp05
	; temp06 lower mandible y offset
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 5
	ldx ent_slot
	clc
	adc #$08
	sta temp06 
	; temp07 connective tissue y pos
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 6
	ldx ent_slot
	clc
	adc #$04
	adc ent_y,x
	sta temp07
	
	; visibility and hit boxes
	lda #$00
	sta ent_visible
	sta ent_damaged
	; hitbox horizontal defaults
	lda temp00
	sta collision_0_x
	lda #$30
	sta collision_0_w
	; hitbox width
	lda temp01
	beq .left_visible
	cmp #$ff
	bne .visibility_done
.right_visible
	clc
	lda collision_0_x
	adc collision_0_w
	bcc .visibility_done
	inc ent_visible
	sta collision_0_w
	lda #$00
	sta collision_0_x
	beq .visibility_done
.left_visible
	inc ent_visible
	clc
	lda collision_0_x
	adc collision_0_w
	bcc .visibility_done
	sec
	lda #$ff
	sbc collision_0_x
	sta collision_0_w
.visibility_done

	; top mandible collisions
	sec
	lda temp05
	sbc #$04
	sta collision_0_y
	lda #$0a
	sta collision_0_h
	jsr custom_hitbox_entry
	clc
	lda big_teef_upper_hits
	adc ent_damaged
	sta big_teef_upper_hits

	lda #$00
	sta ent_damaged
	; bottom mandible collisions
	clc
	lda temp05
	adc #$04
	adc temp06
	sta collision_0_y
	jsr custom_hitbox_entry
	clc
	lda big_teef_lower_hits
	adc ent_damaged
	sta big_teef_lower_hits

	
	; level complete when total jaw hits overflows 8-bit sum
	clc
	lda big_teef_upper_hits
	adc big_teef_lower_hits
	sta ent_hp,x
	bcc .no_level_complete
	jsr state_nextlevel_init
	jmp ent_z_update_return
.no_level_complete



ent_big_teef_render: subroutine
	; temp02 x cam offset
	; temp03 x cam hi offset
	; temp04 bitwise columns to render

	; copy screen position
	lda temp00
	sta temp02
	lda temp01
	sta temp03

	lda state_update_id
	cmp #state_game_update_id
	beq .get_in_game_columns
	lda #%11111100
	sta temp04
	jmp .render_columns

.get_in_game_columns
	lda #%00000000
	sta temp04
	ldy #$06
.calc_columns_loop
	lda temp03
	bne .unvisible
.visible
	sec
	bcs .push_column_bit
.unvisible
	clc
.push_column_bit
	ror temp04
	; move x pos
	clc
	lda temp02
	adc #$08
	sta temp02
	lda temp03
	adc #$00
	sta temp03
	; next
	dey
	bne .calc_columns_loop

.render_columns
	ldy ent_spr_ptr

	; mandibles
	; draw right-to-left
	; copy/adjust screen position
	clc
	lda temp00
	adc #$28
	sta temp02
	lda temp01
	adc #$00
	sta temp03
	; setup col loop
	ldx #$05
.mandible_render_loop
	asl temp04 ; col cache
	bcc .mandible_column_done
	; x pos
	lda temp02
	sta spr_x+0,y
	sta spr_x+4,y
	; y pos upper
	sec
	lda temp05
	sbc big_teef_y_offset+0,x
	sta spr_y+0,y
	; y pos lower
	clc
	lda temp05
	adc temp06
	adc big_teef_y_offset+6,x
	sta spr_y+4,y
	; attr upper
	lda big_teef_attrs+0,x
	sta temp00 ; done with og cam x
	lda big_teef_upper_hits
	jsr big_teef_mandible_attr
	sta spr_a+0,y
	; attr lower
	lda big_teef_attrs+6,x
	sta temp00 ; done with og cam x
	lda big_teef_lower_hits
	jsr big_teef_mandible_attr
	sta spr_a+4,y
	; spr
	lda big_teef_sprites+0,x
	sta spr_p+0,y
	lda big_teef_sprites+6,x
	sta spr_p+4,y
.mandible_column_done
	tya
	clc
	adc #$08
	tay
	; move x pos
	sec
	lda temp02
	sbc #$08
	sta temp02
	lda temp03
	sbc #$00
	sta temp03
	; next
	dex
	bmi .mandible_render_done
	jmp .mandible_render_loop
.mandible_render_done
	
	; connective tissue
	lda temp03
	bne .connective_tissue_done
	lda ent_visible
	beq .connective_tissue_done
	; x pos
	clc
	lda temp02
	adc #$08
	sta spr_x,y
	; y pos
	lda temp07
	sta spr_y,y
	; pattern
	lda #$14
	sta spr_p,y
	; attr
	lda ent_hp+$1f
	cmp #$c0
	bcc .ct_norm_attr
.ct_flash_attr
	lda wtf
	shift_r 3
	and #$03
	jmp .ct_set_attr
.ct_norm_attr
	lda #$03
.ct_set_attr
	sta spr_a,y
	inc_y 4	
.connective_tissue_done

.render_return
	lda state_update_id
	cmp #state_title_update_id
	bne .dont_rts
	rts
.dont_rts
	
	jmp ent_z_update_return



big_teef_mandible_attr: subroutine
	cmp #$20
	bcc .no_flash
	cmp #$a0
	bcs .flash_more
.flash_less
	lda wtf
	shift_r 3
	and #$03
	ora #$02
	sta temp01 ; done with og cam_x_hi
	lda temp00
	and #$f8
	ora temp01
	rts
.flash_more
	lda wtf
	shift_r 3
	and #$03
	sta temp01 ; done with og cam_x_hi
	lda temp00
	and #$f8
	ora temp01
	rts
.no_flash
	lda temp00
	rts
