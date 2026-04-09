
congration_text:
	hex 5c 68 67 60 6b 5a 6d 62 68 67 79 08 
congration_text_len	eqm #$0c
congration_slot_wrap	eqm #$30

; state03 = congration_text index
; state04 = cached next plot nametable lo
; state05 = cached next plot nametable hi
; state06 = pattern row (0-7)
; state07 = row write frame divider

state_congration_init: subroutine

	jsr render_disable

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill

	jsr sprites_clear
	jsr registers_clear
	
	; setup pallete
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop
	lda #$21
	sta palette_cache+2

	; update state system
	ldx #state_congration_update_id
	jsr state_set_update_routine
	ldx #state_congration_render_id
	jsr state_set_render_routine
	lda #CTRL_8x16
	sta ppu_ctrl_ora
	lda #$00
	sta scroll_nm
	sta scroll_x
	sta scroll_y
	sta state03 ; congration_text index
	sta state04
	sta state05
	sta state06 ; pattern row (0-7)
	sta state07 ; row write frame divider

	lda #$f7
	sta state02 ; player x pos

	jsr apu_init
	
	NMI_ENABLE

	rts




state_congration_render: subroutine
	; CONGRATION!! scroller
	; write one pattern row every 4 frames so row updates
	; stay aligned with 2px/frame horizontal scrolling.
	inc state07
	lda state07
	cmp #$04
	bcc .scroller_after_plot
	lda #$00
	sta state07
	; setup color tiles
	lda #$08
	sta temp04
	lda #$09
	sta temp05
	lda #$0a
	sta temp06
	lda #$0b
	sta temp07
	; load next pattern id from text stream
	; state03 is a rolling slot counter, so derive text index modulo len.
	lda state03
.text_index_mod_loop
	cmp #congration_text_len
	bcc .text_index_ready
	sec
	sbc #congration_text_len
	jmp .text_index_mod_loop
.text_index_ready
	tax
	lda congration_text,x
	sta temp00
	; packed control:
	; bit0=pattern table (1), bits1-3=pattern row
	lda state06
	asl
	ora #$01
	sta temp01
	; use cached destination for current row
	lda state04
	sta temp02
	lda state05
	sta temp03
	jsr pattern_row_to_nametable
	; advance row, then advance glyph once all 8 rows are emitted
	inc state06
	lda state06
	cmp #$08
	bcc .scroller_after_plot
	lda #$00
	sta state06
	inc state03
	lda state03
	cmp #congration_slot_wrap
	bcc .scroller_after_plot
	lda #$00
	sta state03
.scroller_after_plot
	; scroll by 2 pixels/frame
	clc
	lda scroll_x
	adc #$02
	sta scroll_x
	bcc .scroller_scroll_done
	inc scroll_nm
	lda scroll_nm
	and #$01
	sta scroll_nm
.scroller_scroll_done
	jmp nmi_render_done




state_congration_update: subroutine
	jsr render_enable

/*
	; a good place to test sound?
	jsr apu_update

	lda wtf
	cmp #$20
	bne .no_sound
	jsr sfx_brush_down
.no_sound
*/
	; rotate text color
	lda wtf
	and #$1f
	bne .color_fine
	inc palette_cache+2
	lda palette_cache+2
	cmp #$2d
	bne .color_fine
	lda #$21
	sta palette_cache+2
.color_fine

	; walk player's victory lap
	; animate
	ldy #$00
	inc state00 ; frame counter
	lda state00
	cmp #$0a
	bcc .not_next_frame
	sty state00
	inc state01 ; anim frame
	lda state01
	cmp #$06
	bcc .not_next_frame
	sty state01
.not_next_frame
	; move
	dec state02 ; x pos
	; render
	; x
	lda state02
	sta spr_x+0
	sta spr_x+8
	clc
	adc #$08
	sta spr_x+4
	sta spr_x+12
	; y
	lda #$a8
	sta spr_y+0
	sta spr_y+4
	clc
	adc #$10
	sta spr_y+8
	sta spr_y+12
	; a
	lda #$40
	sta spr_a+0
	sta spr_a+4
	sta spr_a+8
	sta spr_a+12
	; s
	lda state01
	shift_l 2
	tax
	lda player_walk_left_spr,x
	sta spr_p+0
	inx
	lda player_walk_left_spr,x
	sta spr_p+4
	inx
	lda player_walk_left_spr,x
	sta spr_p+8
	inx
	lda player_walk_left_spr,x
	sta spr_p+12


	; prepare next-frame destination after scroll has been updated
	; cache destination in state04/state05 for next row plot
	; deterministic slot progression for glyph placement:
	; columns advance by 8 tiles and wrap every 4 glyphs.
	; state03=0 starts at second nametable column 8.
	lda #$24
	sta state05
	lda state03
	sta temp00
	asl
	asl
	asl
	clc
	adc #$08
	sta temp01 ; raw column advance (8,16,24,32, ...)

	; destination row base = ($e0 + state06*32)
	; ($e0 is 4 tile rows below previous $60 base)
	lda state06
	asl
	asl
	asl
	asl
	asl
	clc
	adc #$e0
	sta state04
	lda state05
	adc #$00
	sta state05
	; normalize x column to 0..31 and toggle nametable on each wrap
.normalize_column
	lda temp01
	cmp #$20
	bcc .column_ready
	sec
	sbc #$20
	sta temp01
	lda state05
	eor #$04
	sta state05
	jmp .normalize_column
.column_ready
	; add slot column offset
	clc
	lda state04
	adc temp01
	sta state04
	lda state05
	adc #$00
	sta state05

	; sine y pos
	ldx wtf
	lda sine_table,x
	shift_r 4
	sta scroll_y

	; controls reset to title screen
	jsr controller_read
	lda controller1_d
	and #BUTTON_START
	beq .not_title_screen
	jsr state_title_init
.not_title_screen
	

	jmp nmi_update_done



