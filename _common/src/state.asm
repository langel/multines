state_set_render_routine: subroutine
	; x = state id
	stx state_render_id
	lda state_table_lo,x
	sta state_render_lo
	lda state_table_hi,x
	sta state_render_hi
	rts
	
state_set_update_routine: subroutine
	; x = state id
	stx state_update_id
	lda state_table_lo,x
	sta state_update_lo
	lda state_table_hi,x
	sta state_update_hi
	rts
        
render_do_nothing: subroutine
	jmp nmi_render_done

update_do_nothing: subroutine
	jmp nmi_update_done


