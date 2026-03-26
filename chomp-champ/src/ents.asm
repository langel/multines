ent_nothing_id     eqm #$00
ent_big_teef_id    eqm #$01
ent_food_id        eqm #$02
ent_germ_id        eqm #$03
ent_gnat_id        eqm #$04
ent_player_id      eqm #$05
ent_poop_id        eqm #$06
ent_grub_id        eqm #$07
ent_eggs_id        eqm #$08
ent_particle_id    eqm #$09

ent_r0     eqm ent_r400
ent_r1     eqm ent_r420
ent_r2     eqm ent_r440
ent_r3     eqm ent_r460
ent_r4     eqm ent_r480
ent_r5     eqm ent_r4a0
ent_r6     eqm ent_r4c0
ent_r7     eqm ent_r4e0

ent_dir    eqm ent_r500


ent_update_lo:
	byte <do_nothing
	byte <ent_big_teef_update
	byte <ent_food_update
	byte <ent_germ_update
	byte <ent_gnat_update
	byte <ent_player_update
	byte <ent_poop_update
	byte <ent_grub_update
	byte <ent_eggs_update
	byte <ent_particle_update
ent_update_hi:
	byte >do_nothing
	byte >ent_big_teef_update
	byte >ent_food_update
	byte >ent_germ_update
	byte >ent_gnat_update
	byte >ent_player_update
	byte >ent_poop_update
	byte >ent_grub_update
	byte >ent_eggs_update
	byte >ent_particle_update

