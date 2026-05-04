
congration_text:
	hex 5c 68 67 60 6b 5a 6d 62 68 67 79 08 
congration_text_len	eqm #$0c
congration_slot_wrap	eqm #$30

player_frames:
	hex 09 0c 05 09 0c 05

; state03 = congration_text index
; state04 = cached next plot nametable lo
; state05 = cached next plot nametable hi
; state06 = pattern row (0-7)
; state07 = row write frame divider

state_congration_init: subroutine

	jsr render_disable

	lda #$09
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill

	jsr sprites_clear
	jsr registers_clear
	
	; reset hud split-scroll
	lda #$00
	sta sprite0_active
	
	; setup pallete
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop
	lda #$0f
	sta palette_cache+1
	lda #$20
	sta palette_cache+2
	lda #$0f
	sta palette_cache+4
	lda #$00
	sta palette_cache+5

	; "YOUR TIME"
	lda #<chomp_champ_passage_25
	sta temp00
	lda #>chomp_champ_passage_25
	sta temp01
	lda #$8c
	sta temp02
	lda #$26
	sta temp03
	lda #%000000000
	sta temp04
	jsr dict_text_plot
	; plot timer
	lda #$03 
	sta temp01
	lda #$00
	sta temp00
	lda #$50
	sta temp02
	lda #$78
	sta temp03
	lda #$76
	sta temp04
	jsr timer_prerender
	; trasnfer to screen
	lda #$26
	sta PPU_ADDR
	lda #$ab
	sta PPU_ADDR
	ldx #$00
.timer_plot
	lda $300,x
	sta PPU_DATA
	inx
	cpx #$0b
	bne .timer_plot
	; timer attr
	lda #$27
	sta PPU_ADDR
	lda #$ea
	sta PPU_ADDR
	lda #%01010101
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA

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
	sta player_x ; player x pos

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

	lda sprite0_active
	beq .skip_wait
	jsr congration_sprite0
.skip_wait

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
	
	; sprite 0
	lda #$20
	sta spr_a
	lda #$10
	sta spr_p
	lda #$ea
	sta spr_x
	lda #$80
	sta spr_y
	; enable hud split-scroll
	lda #$01
	sta sprite0_active

	; walk player's victory lap
	; animate
	ldy #$00
	inc state00 ; frame counter
	lda state00
	ldx state01
	cmp player_frames,x
	bcc .not_next_frame
	sty state00
	inc state01 ; anim frame
	lda state01
	cmp #$06
	bcc .not_next_frame
	sty state01
.not_next_frame
	; move
	sec
	lda player_x_lo
	sbc #$d0
	sta player_x_lo
	lda player_x
	sbc #$00
	sta player_x 
	; render
	; x
	lda player_x
	sta spr_x+16
	sta spr_x+24
	clc
	adc #$08
	sta spr_x+20
	sta spr_x+28
	; y
	lda #$a8
	sta spr_y+16
	sta spr_y+20
	clc
	adc #$10
	sta spr_y+24
	sta spr_y+28
	; a
	lda #$40
	sta spr_a+16
	sta spr_a+20
	sta spr_a+24
	sta spr_a+28
	; s
	lda state01
	shift_l 2
	tax
	lda player_walk_left_spr,x
	sta spr_p+16
	inx
	lda player_walk_left_spr,x
	sta spr_p+20
	inx
	lda player_walk_left_spr,x
	sta spr_p+24
	inx
	lda player_walk_left_spr,x
	sta spr_p+28


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



congration_sprite0: subroutine

	lda sprite0_active
	beq .hide_timer

.wait0	
	bit PPU_STATUS
	bvs .wait0
   lda #$c0
.wait1	
	bit PPU_STATUS
	beq .wait1
	
	ldx #$04
	lda #$9c
	ldy #$60
	stx PPU_ADDR
	sta PPU_SCROLL
	ldx #$00
	stx PPU_SCROLL
	sty PPU_ADDR

	lda controller1
	and #BUTTON_UP|BUTTON_LEFT|BUTTON_DOWN|BUTTON_RIGHT|BUTTON_SELECT
	bne .dont_hide_timer
.hide_timer
	lda #%00010110
	sta PPU_MASK
.dont_hide_timer

	rts
