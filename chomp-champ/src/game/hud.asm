
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
	lda wtf
	shift_r 4
	and #$01
	clc
	adc #$01
	;lda #$02
	jmp .done
.dead
	lda #$03
.done
	rts


hud_init: subroutine

	; reset hud split-scroll
	lda #$00
	sta hud_initted

	; setup render for frame 1
	lda #$00
	sta hud_tooth_addr
	lda #$08
	sta hud_tooth_tile

	; make room for sprite 0
	lda #$08
	sta ent_ptr_start

	; overwrite bg palette 0
	lda #$04
	sta $e8
	lda #$27
	sta $e9
	lda #$32
	sta $ea

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
	; cache palette in zp
	lda game_palette+1
	sta temp00
	lda game_palette+2
	sta temp01
	lda game_palette+3
	sta temp02
	; check if it setup
	lda hud_initted
	bne .wait0
	rts
.wait0	
	bit PPU_STATUS
	bvs .wait0
   lda #$c0
.wait1	
	bit PPU_STATUS
	beq .wait1

	; disable rendering
	lda #$00
	sta PPU_CTRL
	sta PPU_MASK
	; update palette
	lda #$3f
	sta PPU_ADDR
	lda #$01
	sta PPU_ADDR
	lda temp00
	sta PPU_DATA
	lda temp01
	sta PPU_DATA
	lda temp02
	sta PPU_DATA

	ldx #02
.scanline_wait
	dex
	bne .scanline_wait
	nop
	nop
	nop
	nop
	
	; fine scrolling method
	lda camera_nm
	lsr
	lda #$00
	rol
	shift_l 2
	sta PPU_ADDR
	lda #$20 ; y offset
	sta PPU_SCROLL
	and #%11111000
	shift_l 2
	sta temp00
	ldx camera_x
	txa
	shift_r 3
	ora temp00
	stx PPU_SCROLL
	sta PPU_ADDR

	; enable rendering
	lda #CTRL_NMI|CTRL_BG_1000
	ora ppu_ctrl_ora
	ora camera_nm
	sta PPU_CTRL
	lda #%00011110
	sta PPU_MASK
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
	dex ; dont show last life
	bmi .lives_done
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
	bpl .life_sprite_loop
.lives_done

	; sprite 0
	lda #$20
	sta spr_a
	lda #$10
	sta spr_p
	lda #$ba
	sta spr_x
	lda #$1d
	sta spr_y
	; enable hud split-scroll
	lda #$01
	sta hud_initted

	; player indicator
	lda ent_r3 ; player dir
	bmi .head_mirror
.head_fine
	lda #$00
	jmp .head_assigned
.head_mirror
	lda #$40
.head_assigned
	sta spr_a+4
	lda #$12
	sta spr_p+4
	lda player_x_hi
	lsr
	lda player_x
	ror
	lsr
	lsr
	clc
	adc #$9d
	sta spr_x+4
	lda #$20
	sta spr_y+4

	rts



hud_render: subroutine

	lda #$20
	sta PPU_ADDR
	lda hud_tooth_addr
	sta PPU_ADDR
	lda hud_tooth_tile
	sta PPU_DATA

	rts
