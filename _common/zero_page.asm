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

controller1      byte
controller1_d    byte
controller2      byte
controller2_d    byte
