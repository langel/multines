;
; COMMON SUBROUTINES

	include "./_common/src/nmi.asm"

	include "./_common/src/math.asm"
	include "./_common/src/rng.asm"
	include "./_common/src/util.asm"
	include "./_common/src/input.asm"

	include "./_common/src/state.asm"
	include "./_common/src/ent.asm"
	include "./_common/src/score.asm"
	include "./_common/src/sprite.asm"
	include "./_common/src/collision.asm"

	org $f000
	include "./_common/src/nametable.asm"

	org $f500
	include "./_common/src/sine_tables.asm"
	include "./_common/src/decimals.asm"
