
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
	hex 02 03 06 07 05 05
	; lower mandible
	hex 03 03 05 04 06 05

ent_big_teef_spawn: subroutine
	ldx #$1f
	lda #ent_big_teef_id
	sta ent_type,x
	lda #$60
	sta ent_hp,x
	lda #$00
	sta ent_x_lo,x
	lda #$80
	sta ent_y,x
	lda #$00
	sta big_teef_brush_damage
	sta big_teef_floss_damage
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

	; xxx TO DO
	;     upper mandible should go up and down instead of lower manidble going down and up
	;     sine movement should be upward hald sine so it looks like its bouncing (or maybe even use gravity instead)

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

	; for z sort
	lda player_x_hi
	sta ent_x_hi,x
	; ^ this sucks
	jmp ent_big_teef_render

.in_game_update
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
	lda #$a0
	sta ent_x,x
	lda #$00
	sta ent_x_lo,x
.wrap_done

	; every other frame, move 1px toward player_y
	lda wtf
	and #$01
	bne .y_track_done
	clc
	lda player_y
	adc #$02
	sta temp04
	lda ent_y,x
	cmp temp04
	beq .y_track_done
	bcc .move_down
	dec ent_y,x
	bne .y_track_done
.move_down
	inc ent_y,x
.y_track_done

	; keep jaw animation phase moving
	inc ent_r4,x
	inc ent_r4,x
	inc ent_r4,x

	jsr ent_big_teef_damage_check
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

	; define floor point
	clc
	adc #$09
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
	beq .x_in_range
	cmp #$ff
	beq .x_in_range
	rts
.x_in_range
	; upper hitbox y = ent_y - 8
	sec
	lda ent_y,x
	sbc #$08
	sta temp01
	jsr ent_big_teef_player_hitbox_check
	jsr ent_big_teef_hitbox_upper
	; lower hitbox y = ent_y + 8
	clc
	lda ent_y,x
	adc #$08
	sta temp01
	jsr ent_big_teef_player_hitbox_check
	jsr ent_big_teef_hitbox_lower
	rts


ent_big_teef_hitbox_upper: subroutine
	; brush in upper hitbox?
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
	cmp temp01
	bcc .check_floss
	sec
	sbc temp01
	cmp #$10
	bcs .check_floss
	inc big_teef_upper_hits
	inc big_teef_brush_damage
	lda big_teef_brush_damage
	and #$03
	bne .check_floss
	ldx ent_slot
	dec ent_hp,x

.check_floss
	; floss in upper hitbox?
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
	cmp temp01
	bcc .done
	sec
	sbc temp01
	cmp #$10
	bcs .done
	inc big_teef_upper_hits
	inc big_teef_floss_damage
	inc big_teef_floss_damage
	ldx ent_slot
	dec ent_hp,x
	dec ent_hp,x
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
	cmp temp01
	bcc .check_floss
	sec
	sbc temp01
	cmp #$10
	bcs .check_floss
	inc big_teef_lower_hits
	inc big_teef_brush_damage
	lda big_teef_brush_damage
	and #$03
	bne .check_floss
	ldx ent_slot
	dec ent_hp,x

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
	cmp temp01
	bcc .done
	sec
	sbc temp01
	cmp #$10
	bcs .done
	inc big_teef_lower_hits
	inc big_teef_floss_damage
	inc big_teef_floss_damage
	ldx ent_slot
	dec ent_hp,x
	dec ent_hp,x
.done
	rts


ent_big_teef_player_hitbox_check: subroutine
	; Player point-vs-box check in world-space.
	; Box uses current mandible Y origin in temp01, size 48x16.
	lda player_is_dead
	bne .done
	lda player_iframes
	bne .done

	; player hit point (world): X = player_x + 8
	clc
	lda player_x
	adc #$08
	sta temp02
	lda player_x_hi
	adc #$00
	sta temp03

	; hitbox left/right (world): [ent_x, ent_x + 48)
	ldx ent_slot
	lda ent_x,x
	sta temp04
	lda ent_x_hi,x
	sta temp05
	clc
	lda temp04
	adc #$30
	sta temp06
	lda temp05
	adc #$00
	sta temp07

	; reject if right < player_x_hit (16-bit)
	lda temp07
	cmp temp03
	bcc .done
	bne .left_check
	lda temp06
	cmp temp02
	bcc .done

.left_check
	; reject if left >= player_x_hit (16-bit)
	lda temp05
	cmp temp03
	bcc .y_check
	bne .done
	lda temp04
	cmp temp02
	bcs .done

.y_check
	; player hit point (world) Y = player_y + $18
	clc
	lda player_y
	adc #$18
	sta temp06

	clc
	lda temp01
	adc #$10
	cmp temp06
	bcc .done
	clc
	lda temp01
	cmp temp06
	bcs .done
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
