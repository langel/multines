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

ent_r0   eqm ent_r400
ent_r1   eqm ent_r420
ent_r2   eqm ent_r440
ent_r3   eqm ent_r460
ent_r4   eqm ent_r480
ent_r5   eqm ent_r4a0
ent_r6   eqm ent_r4b0
ent_r7   eqm ent_r4c0
