;; INIT STATES by using state_hook_init

;;;;;; JUMP AROUND

state_jmp_to: subroutine
	; a = jump table offset
	; caches/reload x and leaves y alone
	stx temp03
	tax
	lda #%111
	sta BANK_SELECT
	lda state_bank_table,x
	sta BANK_DATA
	lda state_jump_table_lo,x
	sta temp00
	lda state_jump_table_hi,x
	sta temp01
	ldx temp03
	jmp (temp00)

do_nothing: subroutine        
	rts

render_nothing: subroutine
	jmp state_render_done



new_game_init: subroutine
	lda #state_explore_char_new_game_id
	jsr state_jmp_to
	lda #state_explore_init_id
	jmp state_jmp_to
	jmp palette_fade_to_white_init
	rts
