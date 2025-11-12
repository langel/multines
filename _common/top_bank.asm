;
; COMMON SUBROUTINES

	include "./_common/lib/nmi.asm"

	include "./_common/lib/math.asm"
	include "./_common/lib/rng.asm"
	include "./_common/lib/util.asm"
	include "./_common/lib/input.asm"

	include "./_common/lib/state.asm"
	include "./_common/lib/ent.asm"
	include "./_common/lib/score.asm"
	include "./_common/lib/sprite.asm"
	include "./_common/lib/collision.asm"

	org $f000
	include "./_common/lib/nametable.asm"

	org $f500
	include "./_common/lib/sine_tables.asm"
	include "./_common/lib/decimals.asm"
