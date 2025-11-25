;
;	ZERO PAGE VARIABLES


wtf              byte
rng00            byte
rng01            byte
nmi_lockout      byte

rng_seed0        byte
rng_seed1        byte
rng_val0         byte
rng_val1         byte


ppu_mask_emph    byte
ppu_huh_holder   byte ; XXX replace
spr_offset     byte
ent_offset     byte

scroll_x         byte
scroll_y         byte

state00          byte
state01          byte
state02          byte
state03          byte
state04          byte
state05          byte
state06          byte
state07          byte

temp00           byte
temp01           byte
temp02           byte
temp03           byte
temp04           byte
temp05           byte
temp06           byte
temp07           byte

collision_0_x    byte
collision_0_y    byte
collision_0_w    byte
collision_0_h    byte
collision_1_x    byte
collision_1_y    byte
collision_1_w    byte
collision_1_h    byte

score00			  byte
score01			  byte
score02			  byte
score03			  byte

state_render_id  byte
state_update_id  byte
state_render_lo  byte
state_render_hi  byte
state_update_lo  byte
state_update_hi  byte

ent_spr_ptr      byte
ent_slot         byte
ent_slot_start   byte

controller1      byte
controller1_d    byte
controller2      byte
controller2_d    byte
	


	org $0400
ent_type  byte
	org $0420
ent_hp    byte
	org $0500
ent_x_hi  byte
	org $0440
ent_x     byte
	org $0460
ent_x_lo  byte
	org $0480
ent_y_hi  byte
	org $04a0
ent_y     byte
	org $04c0
ent_y_lo  byte
	org $04e0
ent_r0    byte
	org $0520
ent_r1    byte
	org $0540
ent_r2    byte
	org $0560
ent_r3    byte
	org $0580
ent_r4    byte
	org $05a0
ent_r5    byte
	org $05c0
ent_r6    byte
	org $05e0
ent_r7    byte
