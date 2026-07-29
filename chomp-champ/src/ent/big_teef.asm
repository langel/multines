
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
.done
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

	jmp ent_big_teef_render

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
	; world-space movement: +1 pixel +4 subpixels/frame
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
	sbc #$04 ; difference with player pos
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



	jsr ent_big_teef_damage_check
	; level complete when total jaw hits overflows 8-bit sum
	clc
	lda big_teef_upper_hits
	adc big_teef_lower_hits
	bcc .no_level_complete
	jsr state_nextlevel_init
	jmp ent_z_update_return
.no_level_complete
	jmp ent_big_teef_render




ent_big_teef_render: subroutine
	ldx ent_slot
	lda state_update_id
	cmp #state_game_update_id
	beq .render_in_game
	lda #$00
	sta temp06 ; cache disabled in title mode
	lda ent_x,x
	jmp .render_x_done
.render_in_game
	jsr ent_big_teef_cache_visible_columns
	lda #$01
	sta temp06 ; cache enabled in game mode
	ldx ent_slot ; cache routine clobbers X
	sec
	lda ent_x,x
	sbc camera_x
	sta temp00
	lda temp00
.render_x_done

	; upper mandible
	sta temp00
	sta temp03 ; cache base screen x for all parts
	lda ent_y,x
	sta temp01
	lda #$16
	sta temp02 ; sprite pattern
	ldx #$00
.upper_loop
	lda temp06
	beq .upper_visible
	lda $01da,x
	beq .upper_skip
.upper_visible
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	; x
	lda temp00
	sta spr_x,y
	; y
	sec
	lda temp01
	sbc big_teef_y_offset,x
	sta spr_y,y
	inc_y 4
.upper_skip
	clc
	lda temp00
	adc #$08
	sta temp00
	inx
	cpx #$06
	bne .upper_loop

	; lower mandible
	lda temp03
	sta temp00
	ldx ent_slot
	; y pos
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 5
	clc
	adc temp01 ; y origin
	adc #$08
	sta temp01
	ldx #$06
.lower_loop
	lda temp06
	beq .lower_visible
	lda $01d4,x
	beq .lower_skip
.lower_visible
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	; x
	lda temp00
	sta spr_x,y
	; y
	clc
	lda temp01
	adc big_teef_y_offset,x
	sta spr_y,y
	inc_y 4
.lower_skip
	clc
	lda temp00
	adc #$08
	sta temp00
	inx
	cpx #$0c
	bne .lower_loop

	; render above all ents
	lda #$df
	ldx ent_slot
	jsr ent_z_calc_sort_vals_9bit
	
	; connective tissue
	; x pos
	lda temp06
	beq .tissue_visible
	lda $01da
	beq .skip_tissue
.tissue_visible
	lda temp03
	sta spr_x,y
	; y pos
	ldx ent_slot
	lda ent_y,x
	sta temp01
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 6
	clc
	adc #$04
	adc temp01
	sta spr_y,y
	; pattern
	lda #$14
	sta spr_p,y
	lda #$03
	sta spr_a,y
	inc_y 4	
.skip_tissue

.render_return
	lda state_update_id
	cmp #state_title_update_id
	bne .dont_rts
	rts
.dont_rts
	
	jmp ent_z_update_return



ent_big_teef_damage_check: subroutine
	ldx ent_slot
	; screen-space X from world-space position
	sec
	lda ent_x,x
	sbc camera_x
	sta temp00
	lda ent_x_hi,x
	sbc camera_x_hi
	sta temp01
	beq .x_in_range
	cmp #$ff
	beq .x_in_range
	rts
.x_in_range
	jsr ent_big_teef_player_hitbox_check
	; upper hitbox y = ent_y - 8
	sec
	lda ent_y,x
	sbc #$08
	sta temp02
	jsr ent_big_teef_hitbox_upper
	; lower hitbox y = ent_y + 8
	clc
	lda ent_y,x
	adc #$08
	sta temp02
	jsr ent_big_teef_hitbox_lower
	rts


ent_big_teef_hitbox_upper: subroutine
	; brush in upper hitbox?
	lda controller1
	and #BRUSH_BUTTON
	beq .done
	lda brush_hit_x
	cmp temp00
	bcc .done
	sec
	sbc temp00
	cmp #$30
	bcs .done
	lda brush_hit_y
	cmp temp02
	bcc .done
	sec
	sbc temp02
	cmp #$10
	bcs .done
	inc big_teef_upper_hits
	inc big_teef_upper_hits
	and #$03
	bne .done
	ldx ent_slot

.done
	rts


ent_big_teef_hitbox_lower: subroutine
	; brush in lower hitbox?
	lda controller1
	and #BRUSH_BUTTON
	beq .check_floss
	lda brush_hit_x
	cmp temp00
	bcc .check_floss
	sec
	sbc temp00
	cmp #$30
	bcs .check_floss
	lda brush_hit_y
	cmp temp02
	bcc .check_floss
	sec
	sbc temp02
	cmp #$10
	bcs .check_floss
	inc big_teef_lower_hits
	and #$03
	bne .check_floss
	ldx ent_slot

.check_floss
	; floss in lower hitbox?
	lda floss_status
	beq .done
	lda floss_hit_x
	cmp temp00
	bcc .done
	sec
	sbc temp00
	cmp #$30
	bcs .done
	lda floss_hit_y
	cmp temp02
	bcc .done
	sec
	sbc temp02
	cmp #$10
	bcs .done
	inc big_teef_lower_hits
	ldx ent_slot
.done
	rts


ent_big_teef_player_hitbox_check: subroutine
	; Player point-vs-box check in world-space.
	; Box uses current mandible Y origin in temp01, size 48x16.
	lda player_is_dead
	bne .done
	lda player_iframes
	bne .done
	lda ent_visible
	beq .done

	; setup player
	lda player_hit_x
	sta collision_1_x
	lda player_hit_y
	sta collision_1_y
	lda #$10
	sta collision_1_w
	lda #$20
	sta collision_1_h

	; setup big_teef
	lda temp01
	bmi .off_left
	clc
	lda temp00
	adc #$30
	bcs .off_right
	lda temp00
	sta collision_0_x
	lda #$30
	sta collision_0_w
	jmp .x_done
.off_left
	lda #$00
	sta collision_0_x
	clc
	lda temp00
	adc #$30
	sta collision_0_w
	jmp .x_done
.off_right
	lda temp00
	sta collision_0_x
	sec
	lda #$ff
	sbc temp00
	sta collision_0_w
.x_done
	clc
	lda ent_y,x
	adc #$08
	sta collision_0_y
	; XXX depends on oscillation
	lda #$20
	sta collision_0_h

	; process collision
	jsr collision_detect
	beq .done
.player_collides
	lda #player_death_timer
	sta player_is_dead
	lda #$04
	sta ent_r0
.done
	rts


ent_big_teef_cache_visible_columns: subroutine
	; Cache visibility for 6 horizontal sprite columns.
	; $01da-$01df = column 0..5 visible flags (1=render, 0=skip)
	ldx ent_slot
	lda ent_x,x
	sta temp00
	lda ent_x_hi,x
	sta temp01
	ldx #$00
	stx ent_visible
.column_loop
	; screen = world - camera
	sec
	lda temp00
	sbc camera_x
	sta temp02
	lda temp01
	sbc camera_x_hi
	beq .visible
	bne .not_visible
.visible
	inc ent_visible
	lda #$01
	bne .store
.not_visible
	lda #$00
.store
	sta $01da,x
	; advance world x by 8 pixels for next column
	clc
	lda temp00
	adc #$08
	sta temp00
	lda temp01
	adc #$00
	sta temp01
	inx
	cpx #$06
	bne .column_loop
	rts
