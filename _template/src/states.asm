;
; STATE SUBROUTINES

	org $c000
state_table_lo:
	byte <#do_nothing
	byte <#state_game_init

	org $c020
state_table_hi:
	byte >#do_nothing
	byte >#state_game_init


state_init: subroutine
	rts
