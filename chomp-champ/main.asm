; 
;	GAME TEMPLATE


	processor 6502

	seg.u ZEROPAGE
	org $0000
	include "./_common/definitions.asm"
	include "./_common/zero_page.asm"
	include "src/memory_map.asm"
	
	seg HEADER
	; $bff0 = 1 PRG ; $7ff0 = 2+ PRG
	org $7ff0
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER 0,2,1,NES_MIRR_VERT 

	seg CODE
	; $c000 = 1 PRG ; $8000 = 2+ PRG
	org $8000
cart_start: subroutine
	NES_INITIALIZE
	jsr bootup_clean
	jsr state_init
.idle_cpu
	jmp .idle_cpu
	include "src/states.asm"
	include "src/state_title.asm"
	include "src/state_congration.asm"
	include "src/state_continue.asm"
	include "src/state_demo.asm"
	include "src/state_nextlevel.asm"
	include "src/state_gameover.asm"
	include "src/game/camera.asm"
	include "src/game/hud.asm"
	include "src/game/level_init.asm"
	include "src/game/lib.asm"
	include "src/game/new_game.asm"
	include "src/game/player.asm"
	include "src/game/render.asm"
	include "src/game/teeth_init.asm"
	include "src/game/teeth_lib.asm"
	include "src/game/update.asm"
	include "src/ents.asm"
	include "src/ent/big_teef.asm"
	include "src/ent/eggs.asm"
	include "src/ent/food.asm"
	include "src/ent/germ.asm"
	include "src/ent/gnat.asm"
	include "src/ent/grub.asm"
	include "src/ent/particle.asm"
	include "src/ent/player.asm"
	include "src/ent/poop.asm"
	include "src/palette.asm"

	org $b380
	include "src/generated/dict_text.asm"

	org $b800
	include "src/game/tooth_tables_2.asm"
	include "src/game/teeth_tables.asm"
	org $be80
title_screen_nam:
	incbin "assets/title.bin"

	seg COMMON
	org $c000
	include "./_common/top_bank.asm"

	seg VECTORS
	org $fffa 
	.word nmi_handler ; $fffa vblank nmi
	.word cart_start  ; $fffc reset
	.word cart_start  ; $fffe irq / brk


	seg GRAPHICS
	org $010000
	incbin "assets/sprites.chr"
	incbin "assets/tiles.chr"
