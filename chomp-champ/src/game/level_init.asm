
game_palette:
	; bg
	hex 0f
	; til
	hex 15 00 31
	hex 15 18 28
	hex 15 08 18
	hex 15 0f 08
	; spr
	hex 02 11 38 ; player
	hex 0b 19 2a ; germ / broccoli
	hex 06 17 37 ; poop / bird leg
	hex 13 23 34 ; berries?


food_level_pop:
	hex 02 00 03 02 03 01
	hex 02 03 02 01 05 03
	hex 02 05 03 05 02 01
	hex 02 01 02 04 03 03
	hex 05 03
food_gap_level_pop:
	hex 00 02 01 03 02 03
	hex 02 01 03 02 03 02
	hex 03 04 03 05 02 04
	hex 05 03 03 04 03 04
	hex 03 05
germ_level_pop:
	hex 00 00 01 00 01 03
	hex 02 02 03 01 02 04
	hex 02 02 02 01 03 05
	hex 01 01 02 01 03 06
	hex 04 04
grub_level_pop:
	hex 00 00 00 01 01 02
	hex 00 00 00 05 01 02
	hex 01 01 01 09 01 02
	hex 03 04 05 07 04 05
	hex 06 07


state_game_level_init: subroutine

	jsr render_disable

	ldx #state_game_render_id
	jsr state_set_render_routine
	ldx #state_game_update_id
	jsr state_set_update_routine

	lda #CTRL_8x16
	sta ppu_ctrl_ora

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop
	
	jsr ent_player_init

	lda #$00
	sta germ_attacked
	sta floss_status



	; build level here
	; DIRT
	lda #$00
	sta tooth_index
	sta cell_sweep
	lda game_level
	asl ; x2!!
	sta temp07
.dirty_loops
	jsr rng_update
	; 1st dirtied cell from rng_val0
	lda rng_val0
	sta temp00
	jsr .apply_random_dirt
	; 2nd dirtied cell from rng_val1
	lda rng_val1
	sta temp00
	jsr .apply_random_dirt
	dec temp07
	bne .dirty_loops
	jmp .level_dirt_done
.apply_random_dirt
	; temp00 random byte
	; top nibble: number of non-missing teeth to skip
	; low nibble: cell id (0..15) within target tooth
	lda temp00
	and #$f0
	shift_r 4
	sta temp01 ; skip count
	lda temp00
	and #$0f
	sta temp02 ; cell index in tooth
	lda #$ff
	sta temp03 ; runaway guard for all-missing edge case
.seek_target_tooth
	ldx tooth_index
	lda tooth_total_dmg,x
	bmi .next_tooth
	lda temp01
	beq .target_found
	dec temp01
.next_tooth
	inc tooth_index
	lda tooth_index
	and #$0f
	sta tooth_index
	dec temp03
	bne .seek_target_tooth
	rts
.target_found
	ldx tooth_index
	txa
	shift_l 4
	clc
	adc temp02
	tay
	lda teeth_cell_tables,y
	tax
	inc $600,x
	rts
.level_dirt_done

	; GNAT
	lda game_level
	cmp #$07
	bne .no_gnat
	jsr ent_gnat_spawn
.no_gnat

	; EGGS
	lda game_level
	and #$07
	sec
	sbc #$04
	bmi .no_eggs
	sta temp07
.eggs_loop
	jsr ent_eggs_spawn
	dec temp07
	bpl .eggs_loop
.no_eggs

	; GERMS
	ldx game_level
	dex
	lda germ_level_pop,x
	beq .germs_done
	sta state00
.germs_loop
	jsr ent_germ_spawn
	dec state00
	bne .germs_loop
.germs_done

	; GRUBS
	ldx game_level
	dex
	lda grub_level_pop,x
	beq .grubs_done
	sta state00
.grubs_loop
	jsr ent_grub_spawn
	dec state00
	bne .grubs_loop
.grubs_done

	; GAP FOODS
	ldx game_level
	dex
	lda food_gap_level_pop,x
	beq .food_gaps_done
	sta state00
.food_gaps_loop
	jsr ent_food_spawn_in_gap
	dec state00
	bne .food_gaps_loop
.food_gaps_done

	; FOODS
	ldx game_level
	dex
	lda food_level_pop,x
	beq .foods_done
	sta state00
.foods_loop
	jsr ent_food_spawn
	dec state00
	bne .foods_loop
.foods_done



	jsr teeth_init
	jsr teeth_init_playfield
	jsr hud_init
	
	jsr render_enable
	
	rts

