
state_demo_init: subroutine
	jsr render_disable
	jsr sprites_clear

	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_gnat_spawn
	jsr ent_poop_spawn
	jsr ent_grub_spawn

	ldx game_level
	stx state07
.extra_germs
	jsr ent_germ_spawn
	ldx state07
	dex
	stx state07
	bpl .extra_germs

	; clear tooth cell damage ram ($600-$6ff)
	lda #$00
	ldx #$00
.clear_tooth_cell_ram
	sta $600,x
	inx
	bne .clear_tooth_cell_ram

	; XXX level init should do this
	; create some tooth dirt
	lda #$00
.dirt_loop
	tax
	inc $600,x
	txa
	clc
	adc #$0b
	bcc .dirt_loop
	rts

state_demo_update: subroutine
	jsr render_enable
	jmp nmi_update_done
	

