;
; STATE SUBROUTINES

render_do_nothing_id                   eqm $00
update_do_nothing_id                   eqm $01
title_screen_update_id                 eqm $02

	org $8080
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing
	byte <#title_screen_update

	org $80c0
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing
	byte >#title_screen_update

	org $8100
	; bootup state initializer
state_init: subroutine
	lda #<title_screen_nam
	sta temp00
	lda #>title_screen_nam
	sta temp01
	lda #$20
	jsr nametable_load
	jsr palette_init
	ldx #title_screen_update_id
	jsr state_set_update_routine
	jsr render_enable
	rts


title_screen_update: subroutine
	jsr render_enable
.palette_cycle
	lda wtf
	SHIFT_R 4
	clc
	adc state00
	sta state00
	tax
	lda sine_table,x
	SHIFT_R 6
	SHIFT_L 4
	clc
	adc #title_screen_line_pal_base
	sta palette_cache+3

	jmp nmi_update_done


