;
; STATE SUBROUTINES

render_do_nothing_id           eqm $00
update_do_nothing_id           eqm $01
state_title_update_id          eqm $02
state_game_update_id           eqm $03
state_game_render_id           eqm $04
state_gameover_update_id       eqm $05
state_nextlevel_update_id      eqm $06
state_congration_update_id     eqm $07
state_demo_update_id           eqm $08
state_continue_update_id       eqm $09
state_hud_render_id            eqm $0a
state_congration_render_id     eqm $0b


	org $8030
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing
	byte <#state_title_update
	byte <#state_game_update
	byte <#state_game_render
	byte <#state_gameover_update
	byte <#state_nextlevel_update
	byte <#state_congration_update
	byte <#state_demo_update
	byte <#state_continue_update
	byte <#state_hud_render
	byte <#state_congration_render

	org $8040
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing
	byte >#state_title_update
	byte >#state_game_update
	byte >#state_game_render
	byte >#state_gameover_update
	byte >#state_nextlevel_update
	byte >#state_congration_update
	byte >#state_demo_update
	byte >#state_continue_update
	byte >#state_hud_render
	byte >#state_congration_render


	org $8050
	; bootup state initializer
state_init: subroutine

	; setup dict text
	lda #<chomp_champ_alphabet_table
	sta alphabet_table_lo
	lda #>chomp_champ_alphabet_table
	sta alphabet_table_hi

	; start initial state
	;jsr state_title_init
	jsr init_new_game
	;jsr state_gameover_init
	lda #$1b
	sta game_level
	;jsr state_nextlevel_init
	jsr state_game_level_init
	;jsr state_congration_init
	;jsr state_continue_init
	;jsr state_demo_init

	rts



