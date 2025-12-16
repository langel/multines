;
; STATE SUBROUTINES

render_do_nothing_id           eqm $00
update_do_nothing_id           eqm $01
state_title_update_id          eqm $02
state_game_update_id           eqm $03
state_game_render_id           eqm $04

	org $8080
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing
	byte <#state_title_update
	byte <#state_game_update
	byte <#state_game_render

	org $80c0
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing
	byte >#state_title_update
	byte >#state_game_update
	byte >#state_game_render


	org $8100
	; bootup state initializer
state_init: subroutine
	;jsr state_title_init
	jsr state_game_init

	rts



