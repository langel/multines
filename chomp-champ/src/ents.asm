ent_nothing_id     eqm #$00
ent_big_teef_id    eqm #$01
ent_food_id        eqm #$02
ent_germ_id        eqm #$03
ent_poop_id        eqm #$04

ents_max  eqm #$1f

ent_update_lo:
	byte <do_nothing
	byte <ent_big_teef_update
	byte <ent_food_update
	byte <ent_germ_update
	byte <ent_poop_update
ent_update_hi:
	byte >do_nothing
	byte >ent_big_teef_update
	byte >ent_food_update
	byte >ent_germ_update
	byte >ent_poop_update


