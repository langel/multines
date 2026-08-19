
state__template_init: subroutine

	jsr render_disable

	; setup state

	jsr render_enable

	rts


state__template_update: subroutine

	jsr ents_update

	jmp nmi_update_done	
