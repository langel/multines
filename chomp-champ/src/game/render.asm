
state_game_render: subroutine
	; uses popslide
	; 1st byte : number of steps
	;            0 = no more tasks
	; 2nd byte : ppu addr hi
	; 3rd byte : ppu addr lo
	; then step bytes
	tsx
	stx temp00
	ldx #$ff
	txs
.task_next
	pla
	beq .done
	tay
	pla
	sta PPU_ADDR
	pla 
	sta PPU_ADDR
.yloop
	pla
	sta PPU_DATA
	dey
	bne .yloop
	jmp .task_next
.done
	ldx temp00
	txs

	jsr hud_render

	jmp nmi_render_done


	; called to render dirt by level init
state_level_render: subroutine
	; uses popslide
	; 1st byte : number of steps
	;       0 = no more tasks
	; 2nd byte : ppu addr hi
	; 3rd byte : ppu addr lo
	; then step bytes
	tsx
	stx temp00
	ldx #$ff
	txs
.task_next
	pla
	beq .done
	tay
	pla
	sta PPU_ADDR
	pla 
	sta PPU_ADDR
.yloop
	pla
	sta PPU_DATA
	dey
	bne .yloop
	jmp .task_next
.done
	ldx temp00
	txs
	rts


state_game_prerender: subroutine

	; reset render queue
	; store in temp03
	ldy #$00
	sty $100
	sty temp03

	; check for tooth blackout
	ldx tooth_index
	lda tooth_total_dmg,x
	bpl .check_blackout_threshold
	jmp .do_blackout
.check_blackout_threshold
	cmp #$40
	bcc .no_blackout
	jmp .do_blackout
.no_blackout

	; throttle number of cells to
	; render per frame
	lda #$04
	sta temp07

	; update cells
	ldx tooth_update_queue_size
	bne .queue_loop
	jmp .tooth_cells_done
.queue_loop
	dex
	stx tooth_update_queue_size
	; precalc the 4 tiles
	lda tooth_needs_update,x
	tay
	lda tooth_cell2tooth,y
	tax
	lda tooth_total_dmg,x
	bpl .tooth_not_dead
.no_render
	jmp .cell_not_rendered_bc_tooth_dead
.tooth_not_dead
	lda tooth_cell_dmg,y
	bne .render_dirt
	jmp .render_clean
.render_dirt
	sta temp01
	tya
	sta temp00
	; cell quadrant 0
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+0
	; cell quadrant 1
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+1
	; cell quadrant 2
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+2
	; cell quadrant 3
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+3

	; check tooth side edges
	tya
	and #$03
	bne .not_left_edge
	; on left edge
	lda temp01
	shift_r 2
	shift_l 4
	clc
	adc #$16
	sta tooth_tile_cache+0
	sta tooth_tile_cache+2
	jmp .not_right_edge
.not_left_edge
	cmp #$03
	bne .not_right_edge
	; on right edge
	lda temp01
	shift_r 2
	shift_l 4
	clc
	adc #$17
	sta tooth_tile_cache+1
	sta tooth_tile_cache+3
.not_right_edge
	; check bottom edge of top teeth
	tya
	and #$e0
	cmp #$60
	bne .top_edge_check_done
	lda temp01
	tya
	and #$03
	bne .not_top_tooth_bottom_left
	lda #$7b
	sta tooth_tile_cache+2
	jmp .edge_check_done
.not_top_tooth_bottom_left
	cmp #$03
	bne .not_top_tooth_bottom_right
	lda #$45
	sta tooth_tile_cache+3
.not_top_tooth_bottom_right
.top_edge_check_done
	; check top edge of bottom teeth
	tya
	and #$e0
	cmp #$80
	bne .edge_check_done
	lda temp01
	shift_r 2
	clc
	adc #$7c
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	tya
	and #$03
	bne .not_bottom_tooth_top_left
	lda #$06
	sta tooth_tile_cache+0
	jmp .edge_check_done
.not_bottom_tooth_top_left
	cmp #$03
	bne .not_bottom_tooth_top_right
	lda #$07
	sta tooth_tile_cache+1
.not_bottom_tooth_top_right
.edge_check_done
	jmp .plot_render

.render_clean
	; empty cell of dirt
	lda #$0b
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	sta tooth_tile_cache+2
	sta tooth_tile_cache+3
	; check tooth side edges
	tya
	and #$03
	bne .not_clean_left_edge
	lda #$e6
	sta tooth_tile_cache+0
	sta tooth_tile_cache+2
	jmp .not_clean_right_edge
.not_clean_left_edge
	cmp #$03
	bne .not_clean_right_edge
	lda #$e7
	sta tooth_tile_cache+1
	sta tooth_tile_cache+3
.not_clean_right_edge
	; check bottom edge of top teeth
	tya
	and #$e0
	cmp #$60
	bne .top_edge_clean_check_done
	lda temp01
	tya
	and #$03
	bne .not_top_tooth_bottom_left_clean
	lda #$e8
	sta tooth_tile_cache+2
	jmp .edge_check_clean_done
.not_top_tooth_bottom_left_clean
	cmp #$03
	bne .not_top_tooth_bottom_right_clean
	lda #$e9
	sta tooth_tile_cache+3
.not_top_tooth_bottom_right_clean
.top_edge_clean_check_done
	; check top edge of bottom teeth
	tya
	and #$e0
	cmp #$80
	bne .edge_check_clean_done
	lda #$f7
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	tya
	and #$03
	bne .not_bottom_tooth_top_left_clean
	lda #$f6
	sta tooth_tile_cache+0
	jmp .edge_check_clean_done
.not_bottom_tooth_top_left_clean
	cmp #$03
	bne .not_bottom_tooth_top_right_clean
	lda #$f8
	sta tooth_tile_cache+1
.not_bottom_tooth_top_right_clean
.edge_check_clean_done

.plot_render
	ldx tooth_update_queue_size
	; top row of cell
	ldy temp03
	lda #$02 ; number of render steps
	PUSHY
	lda tooth_needs_update,x
	stx temp00
	tax
	lda tooth_cell2nm_hi,x
	PUSHY
	lda tooth_cell2nm_lo,x
	PUSHY
	lda tooth_tile_cache+0
	PUSHY
	lda tooth_tile_cache+1
	PUSHY
	; bottom row of cell
	lda #$02 ; number of render steps
	PUSHY
	ldx temp00
	lda tooth_needs_update,x
	tax
	lda tooth_cell2nm_hi,x
	PUSHY
	lda tooth_cell2nm_lo,x
	clc
	adc #$20
	PUSHY
	lda tooth_tile_cache+2
	PUSHY
	lda tooth_tile_cache+3
	PUSHY
	sty temp03
	ldx temp00
	jmp .render_cell_done

.render_cell_done
	; check cells throttle
	dec temp07
	beq .tooth_cells_done
.cell_not_rendered_bc_tooth_dead
	; next cell
	ldx tooth_update_queue_size
	bne .do_loop
	; loop done
	jmp .tooth_cells_done
.do_loop
	jmp .queue_loop
.tooth_cells_done
	ldy temp03
	; Queue safety net: if queue is empty, enqueue one 4-cell chunk
	; from the sweep cursor for a non-missing, non-truly-clean tooth.
	lda tooth_update_queue_size
	bne .cell_sweep_done
	lda cell_sweep
	sta temp00
	lsr
	lsr
	tax
	lda tooth_total_dmg,x
	bmi .advance_cell_sweep
	lda tooth_true_clean,x
	bne .advance_cell_sweep
	lda temp00
	and #$03
	asl
	asl
	sta temp01
	txa
	shift_l 4
	clc
	adc temp01
	tax
	ldy #$00
.cell_sweep_queue_4
	lda teeth_cell_tables,x
	sta tooth_needs_update,y
	inx
	iny
	cpy #$04
	bne .cell_sweep_queue_4
	lda #$04
	sta tooth_update_queue_size
.advance_cell_sweep
	inc cell_sweep
	lda cell_sweep
	and #$3f
	sta cell_sweep
.cell_sweep_done
	ldy temp03


	; update gumline tiles
	ldx tooth_index
	lda tooth_total_dmg,x
	; do not render blackout teeth
	bpl .gumline_update
	jmp .gumline_done
.gumline_update
	lda #$08 ; always update 8 tiles
	PUSHY
	lda tooth_true_clean,x
	bne .gumline_is_clean
	lda tooth_total_dmg,x
	bne .gumline_has_dirt
	lda #$01 ; minimum dirt if food blocks clean state
.gumline_has_dirt
	shift_r 4
	cmp #$03
	bcc .dont_threshold
	lda #$03
.dont_threshold
	sta temp01 ; tile dmg group value
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	; which row?
	lda tooth_index
	and #$08
	bne .gumline_bottom_row
.gumline_top_row
	ldx temp01
	lda gumline_top_row_tile_id,x
	jmp .gumline_tile_ready
.gumline_bottom_row
	ldx temp01
	lda gumline_bottom_row_tile_id,x
.gumline_tile_ready
	tax
	; 18 bytes rolled loop
	lda #$08    
	sta temp07
.gumline_pushy_loop
	txa
	sta $100,y
	iny
	inx
	dec temp07
	bne .gumline_pushy_loop
	txa
	sta $100,y
	; was 46 bytes unrolled
	jmp .gumline_done
.gumline_is_clean
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	; which row?
	ldx #$00
	lda tooth_index
	and #$08
	bne .gumline_clean_bottom
.gumline_clean_top
	lda tooth_row_upper_top,x
	PUSHY
	inx
	cpx #$08
	bne .gumline_clean_top
	jmp .gumline_done
.gumline_clean_bottom
	lda tooth_row_lower_bottom,x
	PUSHY
	inx
	cpx #$08
	bne .gumline_clean_bottom
.gumline_done


	; lets dick around with attributes
	ldx tooth_index
	lda tooth_total_dmg,x
	bpl .attr_tooth_alive
	jmp .skip_black_out
.attr_tooth_alive
	lda tooth_total_dmg,x
	shift_r 4
	sta temp00
	cmp #$04
	bcc .choose_palette
	lda #$03
.choose_palette
	sta temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	sta temp00 ; attr val
	ldx tooth_index
	; tooth root row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_root_attr_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	; tooth top row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_main_attr_top_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	; tooth bottom row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_main_attr_bottom_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	
	jmp .skip_black_out


	; tooth_total_dmg >= #$40
	; routed here from top of prerender
.do_blackout
	; If tooth is already missing, render blackout visuals only.
	; Neighbor dirtying should happen once on transition, not every frame.
	bpl .blackout_transition
	jmp .blackout_render_only
.blackout_transition
	; set blackout status
	ora #$80
	sta tooth_total_dmg,x
	; dirty neighboring teeths
	stx temp00
	txa
	shift_l 3
	tay
	; 26 bytes rolled loop
	lda #$08
	sta temp07
.deadtooth_neighbor_dirten_loop
	lda tooth_dead_neighbor_dirt,y
	tax
	inc $600,x
	iny
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
	dec temp07
	bne .deadtooth_neighbor_dirten_loop
	; was 136 cycles unrolled
	ldx temp00
.blackout_render_only
	ldy temp03
	; gumline
	lda #$08
	PUSHY
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	lda tooth_index
	and #$08
	bne .gumline_empty_bottom
.gumline_empty_top
	ldx #$00
	; 17 bytes rolled loop
	lda #$08
	sta temp07
.gumline_empty_top_loop
	lda gumline_top_empty_tile_pattern,x
	sta $100,y
	iny
	inx
	dec temp07
	bne .gumline_empty_top_loop
	; was 64 bytes unrolled
	jmp .gumline_empty_done
.gumline_empty_bottom
	ldx #$00
	; 17 bytes rolled loop
	lda #$08
	sta temp07
.gumline_empty_bottom_loop
	lda gumline_bottom_empty_tile_pattern,x
	sta $100,y
	iny
	inx
	dec temp07
	bne .gumline_empty_bottom_loop
	; was 64 bytes unrolled
	; xxx could maybe save some more bytes
	; by using a pointer for both tables
.gumline_empty_done
	; setup x register
	lda tooth_index
	shift_l 3
	tax
	; 40 bytes rolled loop (includes inner loop)
	lda #$08
	sta temp06
.blackout_tile_row_loop
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	; 12 bytes rolled inner loop
	lda #$08
	sta temp07
.blackout_cell_pushy_loop
	PUSHY
	dec temp07
	bne .blackout_cell_pushy_loop
	; was 34 bytes unrolled inner loop
	inx
	dec temp06
	bne .blackout_tile_row_loop
	; was 440 bytes unrolled (including inner)
.skip_black_out

.done
	lda #$00
	sta $100,y

	rts

