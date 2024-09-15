
title_screen_palette:
 hex 0f 15 25 14

title_screen_line_pal_base eqm $04


palette_init: subroutine
	ldx #$00
	lda title_screen_palette,x
	sta palette_cache,x
	inx
	lda title_screen_palette,x
	sta palette_cache,x
	inx
	lda title_screen_palette,x
	sta palette_cache,x
	inx
	lda title_screen_palette,x
	sta palette_cache,x
	rts


