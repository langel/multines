ent_nothing_id          eqm #$00
ent__templaite_id       eqm #$01

ents_max  eqm #$1f

ent_update_lo:
	byte <do_nothing
	byte <ent__template_update
ent_update_hi:
	byte >do_nothing
	byte >ent__template_update


