;
; STATE SUBROUTINES

render_do_nothing_id                   eqm $00
update_do_nothing_id                   eqm $01

	org $8080
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing

	org $80c0
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing

	org $8100
	; bootup state initializer
state_init: subroutine
	jsr palette_init
	jsr render_enable
	rts
