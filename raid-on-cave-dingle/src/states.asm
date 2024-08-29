;
; STATE SUBROUTINES

render_do_nothing_id                   eqm $00
update_do_nothing_id                   eqm $01
state_level_update_id                  eqm $02

	org $8080
state_table_lo:
	byte <#render_do_nothing
	byte <#update_do_nothing
	byte <#state_level_update

	org $80c0
state_table_hi:
	byte >#render_do_nothing
	byte >#update_do_nothing
	byte >#state_level_update

	org $8100
	; bootup state initializer
state_init: subroutine
	jsr state_level_init
	ldx #state_level_update_id
	jsr state_set_update_routine
	rts

ent_x_tab:
	hex 02 03 04 05 
	hex 02 03 04 05 06 07 08 09 10 11
	hex 02 03 04 05 06 07 08 09 10 11
ent_y_tab:
	hex 07 07 07 07
	hex 0b 0b 0b 0b 0b 0b 0b 0b 0b 0b
	hex 0d 0d 0d 0d 0d 0d 0d 0d 0d 0d

level_pal:
	hex 0f
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22
	hex 0c 11 22

state_level_init: subroutine

	; nametable	
	lda #<level_nam
	sta temp00
	lda #>level_nam
	sta temp01
	lda #$20
	jsr nametable_load

	; palette
	ldx #$18
.pal_loop
	lda level_pal,x
	sta palette_cache,x
	dex
	bpl .pal_loop

	; populate ents
	ldx #$00
.loop
	txa
	asl
	asl
	asl
	tay
	lda #$01
	sta ent_type,y
	lda ent_x_tab,x
	sta ent_x_grid,y
	lda ent_y_tab,x
	sta ent_y_grid,y
	tya
	lsr
	tay
	lda #$02
	sta spr_i,y
	lda #$00
	sta spr_a,y
	inx
	cpx #24
	bne .loop
	rts



state_level_update: subroutine
	jsr render_enable
	jsr ents_update
	jmp nmi_update_done


