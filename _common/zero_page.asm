;
;	ZERO PAGE VARIABLES

	seg ZEROPAGE
	org $0000


wtf              byte
rng00            byte
rng01            byte
nmi_lockout      byte
controls         byte
controls_d       byte

state_update_id  byte
state_render_id  byte
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
