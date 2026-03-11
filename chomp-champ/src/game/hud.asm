
hud_tooth_addr     eqm $190
hud_tooth_tile     eqm $191


hud_dmg_to_tile: subroutine
	; a = tile damage
	; returns offset in a
	cmp #$00
	beq .done
	bmi .dead
	cmp #$30
	bcs .mostly_dead
.damages
	lda #$01
	jmp .done
.mostly_dead
	lda #$02
	jmp .done
.dead
	lda #$03
.done
	rts


hud_init: subroutine

	; setup render for frame 1
	lda #$00
	sta hud_tooth_addr
	lda #$08
	sta hud_tooth_tile

	; make room for sprite 0
	lda #$08
	sta ent_ptr_start

	; top teeth meter
	PPU_ADDR_SET $2054
	ldx #$00
.top_teeth_loop
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	clc
	adc #$0c
	sta PPU_DATA
	inx
	cpx #$08
	bne .top_teeth_loop

	; bottom teeth meter
	PPU_ADDR_SET $2074
.bottom_teeth_loop
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	tay
	lda hud_bottom_teeth_tiles,y
	sta PPU_DATA
	inx
	cpx #$10
	bne .bottom_teeth_loop

	rts


hud_sprite0: subroutine
	lda hud_initted
	bne .wait0
	inc hud_initted
	rts
.wait0	
	bit PPU_STATUS
	bvs .wait0
   lda #$c0
.wait1	
	bit PPU_STATUS
	beq .wait1
	; update scroll
	lda camera_x
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL
	lda #CTRL_NMI|CTRL_BG_1000
	ora ppu_ctrl_ora
	ora camera_nm
	sta PPU_CTRL
	rts



hud_bottom_teeth_tiles:
	hex 05 15 25 35

hud_update: subroutine
	; setup ppu addr target
	; and tooth map tile id
	ldx tooth_index
	cpx #$08
	bcs .bottom_row_tooth
.top_row_tooth
	txa
	clc
	adc #$54
	sta hud_tooth_addr
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	clc
	adc #$0c
	sta hud_tooth_tile
	jmp .tooth_update_done
.bottom_row_tooth
	txa
	clc
	adc #$6c
	sta hud_tooth_addr
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	tay
	lda hud_bottom_teeth_tiles,y
	sta hud_tooth_tile
.tooth_update_done

	; lives sprites
	ldx player_lives
	ldy #$e0
.life_sprite_loop
	; attr
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	; sprite
	lda #$b8
	sta spr_p,y
	lda #$ba
	sta spr_p+4,y
	; x
	txa
	shift_l 4
	clc
	adc #$10
	sta spr_x,y
	adc #$08
	sta spr_x+4,y
	; y
	lda #$0e
	sta spr_y,y
	sta spr_y+4,y
	INC_Y 8
	dex
	bne .life_sprite_loop

	; sprite 0
	lda #$00
	sta spr_a
	lda #$10
	sta spr_p
	lda #$dd
	sta spr_x
	lda #$1d
	sta spr_y

	rts



hud_render: subroutine

	lda #$20
	sta PPU_ADDR
	lda hud_tooth_addr
	sta PPU_ADDR
	lda hud_tooth_tile
	sta PPU_DATA

	rts
