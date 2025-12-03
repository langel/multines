ent_nothing_id     eqm #$00
ent_big_teef_id    eqm #$01
ent_food_id        eqm #$02
ent_germ_id        eqm #$03
ent_player_id      eqm #$04
ent_poop_id        eqm #$05


ent_update_lo:
	byte <do_nothing
	byte <ent_big_teef_update
	byte <ent_food_update
	byte <ent_germ_update
	byte <ent_player_update
	byte <ent_poop_update
ent_update_hi:
	byte >do_nothing
	byte >ent_big_teef_update
	byte >ent_food_update
	byte >ent_germ_update
	byte >ent_player_update
	byte >ent_poop_update

ent_render_lo:
	byte <do_nothing
	byte <ent_big_teef_render
	byte <ent_food_render
	byte <ent_germ_render
	byte <ent_player_render
	byte <ent_poop_render
ent_render_hi:
	byte >do_nothing
	byte >ent_big_teef_render
	byte >ent_food_render
	byte >ent_germ_render
	byte >ent_player_render
	byte >ent_poop_render

