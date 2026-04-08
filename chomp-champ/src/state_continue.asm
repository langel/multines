; state00 pointer position
; state01 germ x pos
; state02 germ velocity lo
; state03 germ velocity hi
; state04 germ y pos lo
; state05 germ y pos hi
; state06 germ anim frame
; state07 germ anim counter

state_continue_init: subroutine

	jsr render_disable
	jsr sprites_clear
	jsr registers_clear

	; check for continues
	lda continues
	bpl .continues_left
	jsr state_title_init
	rts
.continues_left
	dec continues
	
	; clear screen
	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill
	
	; "continue"
	lda #<chomp_champ_passage_04
	sta temp00
	lda #>chomp_champ_passage_04
	sta temp01
	lda #$e8
	sta temp02
	lda #$20
	sta temp03
	lda #%000000010
	sta temp04
	jsr dict_text_plot
	; "yeah"
	lda #<chomp_champ_passage_05
	sta temp00
	lda #>chomp_champ_passage_05
	sta temp01
	lda #$ad
	sta temp02
	lda #$21
	sta temp03
	jsr dict_text_plot
	; "nope"
	lda #<chomp_champ_passage_06
	sta temp00
	lda #>chomp_champ_passage_06
	sta temp01
	lda #$2d
	sta temp02
	lda #$22
	sta temp03
	jsr dict_text_plot

	; bg palette
	lda #$0f
	sta $e7
	lda #$27
	sta $ec
	lda #$2a
	sta $ef
	lda #$16
	sta $f2
	; sprite palette
	ldx #$00
.pal_loop
	lda game_palette+13,x
	sta $f4,x
	inx
	cpx #$06
	bne .pal_loop
	; continue attr
	ldx #$23
	stx PPU_ADDR
	lda #$ca
	sta PPU_ADDR
	lda #%01010101
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	; yeah attr
	stx PPU_ADDR
	lda #$db
	sta PPU_ADDR
	lda #%10101010
	sta PPU_DATA
	sta PPU_DATA
	; nope attr
	stx PPU_ADDR
	lda #$e3
	sta PPU_ADDR
	lda #%11111111
	sta PPU_DATA
	sta PPU_DATA

	lda #CTRL_8x16
	sta ppu_ctrl_ora
	lda #$00
	sta scroll_nm
	sta scroll_y
	lda #$04
	sta scroll_x

	lda #$00
	sta state00
	
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	ldx #state_continue_update_id
	jsr state_set_update_routine

	NMI_ENABLE

	rts


state_continue_update: subroutine

	jsr render_enable
	jsr controller_read

	lda controller1_d
	and #BUTTON_START|BUTTON_B|BUTTON_A
	bne .do_action
	lda controller1_d
	and #BUTTON_LEFT|BUTTON_RIGHT|BUTTON_UP|BUTTON_DOWN|BUTTON_SELECT
	beq .controls_done
	inc state00
	lda state00
	and #$01
	sta state00
	jmp .controls_done
.do_action
	lda state00
	bne .not_yeah
	; yeah 
	; replace all missing teeth
	; replenish player lives
	jsr chompchamp_reset_game
	jsr state_game_level_init
	jmp nmi_update_done
.not_yeah
	; nope
	; goto title screen
	jsr state_title_init
	jmp nmi_update_done
.controls_done

	; life head
	lda #$b8
	sta spr_p
	lda #$ba
	sta spr_p+4
	lda #$00
	sta spr_a
	sta spr_a+4
	lda #$44
	sta spr_x
	lda #$4c
	sta spr_x+4
	lda state00
	shift_l 5
	clc
	adc #$62
	sta spr_y
	sta spr_y+4

	; bouncing germ
	lda state05
	cmp #$e0
	bcc .skip_velocity_reset
	jsr rng_update
	lda rng_val0
	sta state02
	lda rng_val1
	and #$07
	sta state03
	lda #$e0
	sta state05
.skip_velocity_reset	
	; animation
	inc state07
	lda state07
	cmp #$05
	bne .anim_done
	lda #$00
	sta state07
	lda state06
	clc
	adc #$04
	sta state06
	cmp #$34
	bne .anim_done
	lda #$00
	sta state06
.anim_done
	clc
	lda state06
	adc #$40
	sta spr_p+8
	adc #$02
	sta spr_p+12
	; attr
	lda state03
	bpl .not_falling
	lda #$a1
	bne .set_a
.not_falling
	lda #$01
.set_a
	sta spr_a+8
	sta spr_a+12
	; x axis stuff
	inc state01
	ldx state01
	lda sine_table,x
	ldx #$f7
	jsr shift_percent
	sta spr_x+8
	clc
	adc #$08
	sta spr_x+12
	; y axis stuff
	sec
	lda state04
	sbc state02
	sta state04
	lda state05
	sbc state03
	sta state05
	sta spr_y+8
	sta spr_y+12
	sec
	lda state02
	sbc #$30
	sta state02
	lda state03
	sbc #$00
	sta state03

	jmp nmi_update_done
