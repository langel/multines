/*
	APUBAB is a tiny song playroutine
*/


apubab_commands_lo:
	byte <#apubab_command_0
	byte <#apubab_command_1
	byte <#apubab_command_2
	byte <#apubab_command_3
	byte <#apubab_command_4
	byte <#apubab_command_5
	byte <#apubab_command_6
	byte <#apubab_command_7
	byte <#apubab_command_8
	byte <#apubab_command_9
	byte <#apubab_command_a
	byte <#apubab_command_b
	byte <#apubab_command_c
	byte <#apubab_command_d
	byte <#apubab_command_e
	byte <#apubab_command_f
apubab_commands_hi:
	byte >#apubab_command_0
	byte >#apubab_command_1
	byte >#apubab_command_2
	byte >#apubab_command_3
	byte >#apubab_command_4
	byte >#apubab_command_5
	byte >#apubab_command_6
	byte >#apubab_command_7
	byte >#apubab_command_8
	byte >#apubab_command_9
	byte >#apubab_command_a
	byte >#apubab_command_b
	byte >#apubab_command_c
	byte >#apubab_command_d
	byte >#apubab_command_e
	byte >#apubab_command_f


apubab_command_trampoline:
	; x has command id
	lda apubab_commands_lo,x
	sta temp00
	lda apubab_commands_hi,x
	sta temp01
	jmp (temp00)


	; set Base Temporal Unit
apubab_command_0:
	rts

	; set BTUs delay until next
apubab_command_1:
	rts

	; channel(s) trigger note id
apubab_command_2:
	; command bits indicate which channels
	; for each bit read channel note id
	rts

	; percussion macro trigger
apubab_command_3:
	rts

	; pu1 set envelope id
apubab_command_4:
	rts
	
	; pu2 set envelope id
apubab_command_5:
	rts

	; tri set BTU length
apubab_command_6:
	rts

	; noi set envelope id
apubab_command_7:
	rts

	; pu1/pu2 set duty cycle
apubab_command_8:
	; each pu has 2 bits
	rts

	; ??
apubab_command_9:
	rts

	; loop1 set point and count
apubab_command_a:
	rts
	
	; loop2 set point and count
apubab_command_b:
	rts

	; ??
apubab_command_c:
	rts

	; ??
apubab_command_d:
	rts

	; channel(s) halt
apubab_command_e:
	; command bits indicate which channels
	rts

	; song controls
apubab_command_f:
	cpx #$00
	bne .not_loop_to_beginning
.loop_to_beginning
	; reset song pointer to beginning
	rts
.not_loop_to_beginning

	rts


apubab_controls_lo:
	byte <#apubab_controls_0
	byte <#apubab_controls_1
	byte <#apubab_controls_2
	byte <#apubab_controls_3
	byte <#apubab_controls_4
	byte <#apubab_controls_5
	byte <#apubab_controls_6
	byte <#apubab_controls_7
	byte <#apubab_controls_8
	byte <#apubab_controls_9
	byte <#apubab_controls_a
	byte <#apubab_controls_b
	byte <#apubab_controls_c
	byte <#apubab_controls_d
	byte <#apubab_controls_e
	byte <#apubab_controls_f
apubab_controls_hi:
	byte >#apubab_controls_0
	byte >#apubab_controls_1
	byte >#apubab_controls_2
	byte >#apubab_controls_3
	byte >#apubab_controls_4
	byte >#apubab_controls_5
	byte >#apubab_controls_6
	byte >#apubab_controls_7
	byte >#apubab_controls_8
	byte >#apubab_controls_9
	byte >#apubab_controls_a
	byte >#apubab_controls_b
	byte >#apubab_controls_c
	byte >#apubab_controls_d
	byte >#apubab_controls_e
	byte >#apubab_controls_f

	; reset song pointer to beginning
apubab_controls_0:
	rts

	; loop back to loop1 point
apubab_controls_1:
	; dec counter
	rts

	; loop back to loop2 point
apubab_controls_2:
	; dec counter
	rts

apubab_controls_3:
	rts
apubab_controls_4:
	rts
apubab_controls_5:
	rts
apubab_controls_6:
	rts
apubab_controls_7:
	rts
apubab_controls_8:
	rts
apubab_controls_9:
	rts
apubab_controls_a:
	rts
apubab_controls_b:
	rts
apubab_controls_c:
	rts
apubab_controls_d:
	rts
apubab_controls_e:
	rts
	; stop song
apubab_controls_f:
	rts





