;
; STATE SUBROUTINES

render_do_nothing_id                   eqm $00
update_do_nothing_id                   eqm $01

	org $8000
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing

	org $8040
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing

	org $8080
	; bootup state initializer
state_init: subroutine
	rts
