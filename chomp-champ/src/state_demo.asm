
state_demo_init: subroutine
	jsr render_disable
	jsr sprites_clear

	ldx #state_game_render_id
	jsr state_set_render_routine
	ldx #state_demo_update_id
	jsr state_set_update_routine

	lda #CTRL_8x16
	sta ppu_ctrl_ora

	lda #$00
	sta germ_attacked
	; kill big teef
	sta $031f

	; fresh demo?
	lda player_lives
	beq .start_fresh_demo
	bmi .start_fresh_demo
	jmp .done_fresh_demo

.start_fresh_demo
	jsr chompchamp_reset_game

	jsr ent_germ_spawn
	jsr ent_germ_spawn
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
	jsr ent_eggs_spawn
	lda #$1b
	sta ent_x,x
	lda #$01
	sta ent_x_hi,x
	lda #$a0
	sta ent_y,x

	; create some tooth dirt
	lda #$00
.dirt_loop
	tax
	inc $600,x
	txa
	clc
	adc #$0b
	bcc .dirt_loop
.done_fresh_demo

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop
	
	jsr ent_player_init

	jsr teeth_init
	jsr teeth_init_playfield
	jsr hud_init
	
	NMI_ENABLE

	rts



state_demo_update: subroutine
	jsr render_enable
	jsr controller_read

	lda controller1_d
	bne .to_title_screen

	jsr teeth_update
	jsr ent_grub_convergence
	jsr hud_sprite0

	lda #$00
	sta controller1
	sta controller1_d
	jsr game_player_update
	jsr ent_z_update
	jsr hud_update
	jsr state_game_prerender

	lda player_is_dead
	cmp #$01
	bne .not_end
.to_title_screen
	jsr state_title_init
.not_end

	ldy #$00
	ldx #$0f
.dead_teeth_loop
	lda tooth_total_dmg,x
	bpl .not_dead
	iny
.not_dead
	dex
	bpl .dead_teeth_loop
	cpy #$0f
	bne .not_gameover
	lda #$00
	sta player_lives
	jsr state_title_init
.not_gameover


	jmp nmi_update_done
	

