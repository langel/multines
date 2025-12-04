
game_palette:
	; bg
	hex 0f
	; til
	hex 15 0c 31
	hex 15 0c 28
	hex 15 0c 18
	hex 15 0c 08
	; spr
	hex 02 11 38 ; player
	hex 0b 19 2a ; germ / broccoli
	hex 06 17 28 ; poop / bird leg
	hex 13 23 34 ; berries?

tooth_row_generic:
	hex e6 0b 0b 0b 0b 0b 0b e7
tooth_row_upper_top:
	hex e0 e1 e2 0b 0b e3 e4 e5
tooth_row_upper_bottom:
	hex e8 0b 0b 0b 0b 0b 0b e9
tooth_row_lower_top:
	hex f6 f7 f7 f7 f7 f7 f7 f8
tooth_row_lower_bottom:
	hex f0 f1 f2 0b 0b f3 f4 f5


state_game_init: subroutine

	jsr render_disable
	
	ldx #state_game_update_id
	sta $80
	jsr state_set_update_routine

	jsr ent_z_init

	jsr ent_player_init

	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop

	lda #$20
	sta temp00
.nametable_loop

	lda temp00
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	; clear head
	lda #$08
	ldx #$c0
.head_clear
	sta PPU_DATA
	dex
	bne .head_clear
	; gumline
	ldx #$20
	lda #$09
.loop_gumline_top
	sta PPU_DATA
	dex
	bne .loop_gumline_top
	; upper_top
	ldx #$00
	ldy #$00
.loop_upper_top
	lda tooth_row_upper_top,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_upper_top
	; generic teefs
	ldx #$00
	ldy #$00
.loop_upper_generics
	lda tooth_row_generic,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$e0
	bne .loop_upper_generics
	; upper_bottom
	ldx #$00
	ldy #$00
.loop_upper_bottom
	lda tooth_row_upper_bottom,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_upper_bottom
	; lower_top
	ldx #$00
	ldy #$00
.loop_lower_top
	lda tooth_row_lower_top,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_lower_top
	; generic teefs
	ldx #$00
	ldy #$00
.loop_lower_generics
	lda tooth_row_generic,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$e0
	bne .loop_lower_generics
	; lower_bottom
	ldx #$00
	ldy #$00
.loop_lower_bottom
	lda tooth_row_lower_bottom,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_lower_bottom
	; gumline
	ldx #$20
	lda #$09
.loop_gumline_bottom
	sta PPU_DATA
	dex
	bne .loop_gumline_bottom
	; clear butt
	lda #$08
	ldx #$80
.butt_clear
	sta PPU_DATA
	dex
	bne .butt_clear
	
	; another nametable?
	lda temp00
	clc
	adc #$04
	cmp #$28
	beq .done_nametabling
	sta temp00
	jmp .nametable_loop
.done_nametabling
	
	jsr render_enable
	
	rts

