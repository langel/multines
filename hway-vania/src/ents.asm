ent_nothing_id        eqm #$00
ent_template_id       eqm #$01
ent_car_id            eqm #$02

ents_max  eqm #$1f

ent_update_lo:
	byte <#do_nothing
	byte <#ent_template_update
	byte <#ent_car_update
ent_update_hi:
	byte >#do_nothing
	byte >#ent_template_update
	byte >#ent_car_update

