

state_continue_init: subroutine

	jsr render_disable
	jsr sprites_clear

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

	; palette
	lda #$0f
	sta $e7
	lda #$01
	sta $e8
	sta $f4
	lda #$21
	sta $e9
	sta $f5
	lda #$22
	sta $ea
	sta $f6

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

	jmp nmi_update_done
