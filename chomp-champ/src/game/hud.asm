
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
	rts
.mostly_dead
	lda wtf
	shift_r 4
	and #$01
	clc
	adc #$01
	rts
.dead
	lda #$03
.done
	rts


hud_init: subroutine

	; set correct y scroll
	lda #$ec
	sta scroll_y
	
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
	sta $f1
	lda #$27
	sta $f2
	lda #$32
	sta $f3

	; write level indicator
	jsr hud_write_week

	; top teeth meter
	PPU_ADDR_SET $2055
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
	PPU_ADDR_SET $2075
.bottom_teeth_loop
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	tay
	lda hud_bottom_teeth_tiles,y
	sta PPU_DATA
	inx
	cpx #$10
	bne .bottom_teeth_loop

	; teeth meter attributes
	lda #$23
	sta PPU_ADDR
	lda #$c5
	sta PPU_ADDR
	lda #%11111111
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA

	rts


hud_sprite0: subroutine
	; cache palette values in zp
	lda #$15
	sta temp00
	lda #$0f
	sta temp01
	lda #$08
	sta temp02
	; fine scrolling cache
	lda camera_nm
	lsr
	lda #$00
	rol
	shift_l 2
	sta temp04
	lda #$20 ; y offset
	sta temp05
	and #%11111000
	shift_l 2
	sta temp04 ; temp
	ldx camera_x
	stx temp06
	txa
	shift_r 3
	ora temp04 
	sta temp07

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

	; load up palette values
	ldx temp01
	ldy temp02
	; disable rendering
	lda #$00
	nop
	sta PPU_CTRL
	sta PPU_MASK
	; update palette
	lda #$3f
	sta PPU_ADDR
	lda #$0d
	sta PPU_ADDR
	lda temp00
	sta PPU_DATA
	stx PPU_DATA
	sty PPU_DATA

	; wait for next scanline
	ldx #$0a
.scan_wait
	dex
	bne .scan_wait

	; fine scrolling write
	lda temp04
	sta PPU_ADDR
	lda temp05
	sta PPU_SCROLL
	lda temp06
	sta PPU_SCROLL
	lda temp07
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
	adc #$55
	sta hud_tooth_addr
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	cmp #$00
	bne .top_true_clean_done
	ldy tooth_true_clean,x
	bne .top_true_clean_done
	tay
	iny
	tya
.top_true_clean_done
	clc
	adc #$0c
	sta hud_tooth_tile
	jmp .tooth_update_done
.bottom_row_tooth
	txa
	clc
	adc #$6d
	sta hud_tooth_addr
	lda tooth_total_dmg,x
	jsr hud_dmg_to_tile
	tay
	cmp #$00
	bne .bottom_true_clean_done
	lda tooth_true_clean,x
	bne .bottom_true_clean_done
	iny
.bottom_true_clean_done
	lda hud_bottom_teeth_tiles,y
	sta hud_tooth_tile
.tooth_update_done

	; check for tooth partical spawns
	lda tooth_total_dmg,x
	bpl .tooth_particle_done
	; tooth is gone
	lda tooth_hud_gone,x
	bne .tooth_particle_done
	; spawn particle
	inc tooth_hud_gone,x
	jsr ent_particle_spawn_from_tooth_indicator
.tooth_particle_done

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
	adc #$18
	sta spr_x,y
	adc #$08
	sta spr_x+4,y
	; y
	lda #$12
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
	lda #$a9
	sta spr_x
	lda #$21
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
	lda #$24
	sta spr_y+4

	rts


state_hud_render: subroutine
	jsr hud_render
	jmp nmi_render_done


hud_render: subroutine

	lda #$20
	sta PPU_ADDR
	lda hud_tooth_addr
	sta PPU_ADDR
	lda hud_tooth_tile
	sta PPU_DATA

	lda is_paused
	beq .paused_done
	cmp #$01
	beq .write_paused
	cmp #$02
	beq .paused_done
	lda #$00
	sta is_paused
	jsr hud_write_week
	ldx #state_game_render_id
	jsr state_set_render_routine
	jmp .paused_done
.write_paused
	; "PAUSED"
	lda #<chomp_champ_passage_08
	sta temp00
	lda #>chomp_champ_passage_08
	sta temp01
	lda #$4d
	sta temp02
	lda #$20
	sta temp03
	lda #%000000000
	sta temp04
	jsr dict_text_plot
	inc is_paused
.paused_done

	rts


hud_write_week: subroutine
	; "WEEK"
	lda #<chomp_champ_passage_07
	sta temp00
	lda #>chomp_champ_passage_07
	sta temp01
	lda #$4d
	sta temp02
	lda #$20
	sta temp03
	lda #%000000000
	sta temp04
	jsr dict_text_plot
	; level integer
	lda #$20
	sta PPU_ADDR
	lda #$6f
	sta PPU_ADDR
	ldx game_level
	clc
	lda zero_pad_10s_table,x
	adc #$50
	sta PPU_DATA
	clc
	lda zero_pad_01s_table,x
	adc #$50
	sta PPU_DATA
	rts
