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
	bne .not_next
	inc state01
.not_next
	lda state01
	and #$02
	beq .throb_asym
.throb_symm
	lda state00
	clc
	adc #$07
	sta state00
	jmp .throb_done
.throb_asym
	lda wtf
	SHIFT_R 4
	clc
	adc state00
	sta state00
.throb_done
	tax
	; color 3
	lda sine_table,x
	SHIFT_R 6
	SHIFT_L 4
	clc
	adc #title_screen_line_pal_base
	sta palette_cache+3
	; color 1
	lda state00
	clc
	adc #$20
	tax
	lda sine_table,x
	SHIFT_R 7
	SHIFT_L 4
	tay
	clc
	adc #$05
	sta palette_cache+1
	; color 2
	lda state00
	clc
	adc #$40
	tax
	lda sine_table,x
	SHIFT_R 7
	SHIFT_L 4
	tay
	clc
	clc
	adc #$15
	sta palette_cache+2
; throb canclel
	lda state01
	and #$03
	cmp #$03
	beq .throb_cancel
	and #$03
	bne .throb_dont_cancel
.throb_cancel
	lda #$15
	sta palette_cache+1
	lda #$25
	sta palette_cache+2
.throb_dont_cancel
	jmp nmi_update_done


