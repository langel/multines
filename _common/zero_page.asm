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
ppu_ctrl_ora     byte

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

; typically enemy collision data
collision_0_x    byte
collision_0_y    byte
collision_0_w    byte
collision_0_h    byte
; player or another enemy data
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

ent_ptr_start    byte
ent_spr_ptr      byte
ent_slot         byte
ent_slot_start   byte
ent_visible      byte
ent_z_slot       byte
ent_z_ptr_lo     byte
ent_z_ptr_hi     byte
ent_pos_x        byte
ent_pos_y        byte

scroll_nm        byte
scroll_x_hi      byte
scroll_y_hi      byte
scroll_x         byte
scroll_y         byte
camera_nm        byte
camera_x_hi      byte
camera_y_hi      byte
camera_x         byte
camera_y         byte


controller1      byte
controller1_d    byte
controller2      byte
controller2_d    byte



apu_pu1_counter		byte
apu_pu1_envelope	byte
apu_pu1_last_hi		byte
apu_tri_counter		byte ; !!! this order for x offset
apu_pu2_counter		byte
apu_pu2_envelope	byte
apu_pu2_last_hi		byte
apu_noi_counter		byte ; !!! must update apu_env_run if moved
apu_noi_envelope	byte

; apu variables
apu_rng0		byte
apu_rng1		byte
apu_temp		byte
sfx_temp00		byte
sfx_temp01		byte

sfx_phase_next_counter	byte
; counters to mask other channel audio
sfx_pu1_counter		byte
sfx_pu2_counter		byte
sfx_noi_counter		byte
; table offsets for update subroutines
sfx_pu2_update_type	byte
sfx_noi_update_type	byte

audio_song_id		byte
audio_frame_counter     byte
audio_root_tone         byte
audio_pattern_pos	byte
audio_pattern_num       byte
pitch_mod_lo  byte
pitch_mod_hi  byte



end_of_common_ram:
