
gumline_nm_addr_lo:
	hex e0 e8 f0 f8
	hex e0 e8 f0 f8
	hex 00 08 10 18
	hex 00 08 10 18
gumline_nm_addr_hi:
	hex 20 20 20 20
	hex 24 24 24 24
	hex 23 23 23 23
	hex 27 27 27 27
gumline_top_row_tile_id:
	hex 18 28 38 48
gumline_bottom_row_tile_id:
	hex 80 88 90 98
gumline_top_clean_tile_pattern:
	hex e0 e1 e2 0b 0b e3 e4 e5
gumline_top_empty_tile_pattern:
	hex ea eb ec 08 08 ed ee ef
gumline_bottom_clean_tile_pattern:
	hex f0 f1 f2 0b 0b f3 f4 f5
gumline_bottom_empty_tile_pattern:
	hex fa fb fc 08 08 fd fe ff

tooth_main_white_tile_pattern:
	hex e6 0b 0b 0b 0b 0b 0b e7
tooth_top_edge_white_tile_pattern:
	hex e8 0b 0b 0b 0b 0b 0b e9
tooth_bottom_edge_white_tile_pattern:
	hex f6 f7 f7 f7 f7 f7 f7 f8

; these are mostly redundant
; xxx but still in use BOOOOOOO
tooth_row_generic:
	hex e6 0b 0b 0b 0b 0b 0b e7
tooth_row_upper_top:
	hex e0 e1 e2 0b 0b e3 e4 e5
tooth_row_upper_bottom:
	hex e8 0b 0b 0b 0b 0b 0b e9
tooth_row_lower_top:
	hex f6 f7 f7 f7 f7 f7 f7 f8
tooth_row_lower_bottom:
	hex f0 f1 f2 0b 0b f3 f4 f5


; lookup tables for tooth health
teeth_cell_tables:
; top row
tooth_0_table:
	hex 00 01 02 03
	hex 20 21 22 23
	hex 40 41 42 43
	hex 60 61 62 63
tooth_1_table:
	hex 04 05 06 07
	hex 24 25 26 27
	hex 44 45 46 47
	hex 64 65 66 67
tooth_2_table:
	hex 08 09 0a 0b
	hex 28 29 2a 2b
	hex 48 49 4a 4b
	hex 68 69 6a 6b
tooth_3_table:
	hex 0c 0d 0e 0f
	hex 2c 2d 2e 2f
	hex 4c 4d 4e 4f
	hex 6c 6d 6e 6f
tooth_4_table:
	hex 10 11 12 13
	hex 30 31 32 33
	hex 50 51 52 53
	hex 70 71 72 73
tooth_5_table:
	hex 14 15 16 17
	hex 34 35 36 37
	hex 54 55 56 57
	hex 74 75 76 77
tooth_6_table:
	hex 18 19 1a 1b
	hex 38 39 3a 3b
	hex 58 59 5a 5b
	hex 78 79 7a 7b
tooth_7_table:
	hex 1c 1d 1e 1f
	hex 3c 3d 3e 3f
	hex 5c 5d 5e 5f
	hex 7c 7d 7e 7f

; bottom row
tooth_8_table:
	hex 80 81 82 83
	hex a0 a1 a2 a3
	hex c0 c1 c2 c3
	hex e0 e1 e2 e3
tooth_9_table:
	hex 84 85 86 87
	hex a4 a5 a6 a7
	hex c4 c5 c6 c7
	hex e4 e5 e6 e7
tooth_a_table:
	hex 88 89 8a 8b
	hex a8 a9 aa ab
	hex c8 c9 ca cb
	hex e8 e9 ea eb
tooth_b_table:
	hex 8c 8d 8e 8f
	hex ac ad ae af
	hex cc cd ce cf
	hex ec ed ee ef
tooth_c_table:
	hex 90 91 92 93
	hex b0 b1 b2 b3
	hex d0 d1 d2 d3
	hex f0 f1 f2 f3
tooth_d_table:
	hex 94 95 96 97
	hex b4 b5 b6 b7
	hex d4 d5 d6 d7
	hex f4 f5 f6 f7
tooth_e_table:
	hex 98 99 9a 9b
	hex b8 b9 ba bb
	hex d8 d9 da db
	hex f8 f9 fa fb
tooth_f_table:
	hex 9c 9d 9e 9f
	hex bc bd be bf
	hex dc dd de df
	hex fc fd fe ff


	; attribute tables
tooth_attr_hi:
	hex 23 23 23 23
	hex 27 27 27 27
	hex 23 23 23 23
	hex 27 27 27 27
tooth_root_attr_lo:
	hex c8 ca cc ce
	hex c8 ca cc ce
	hex f0 f2 f4 f6
	hex f0 f2 f4 f6
tooth_main_attr_top_lo:
	hex d0 d2 d4 d6
	hex d0 d2 d4 d6
	hex e0 e2 e4 e6
	hex e0 e2 e4 e6
tooth_main_attr_bottom_lo:
	hex d8 da dc de
	hex d8 da dc de
	hex e8 ea ec ee
	hex e8 ea ec ee


tooth_dead_neighbor_dirt:
	; top row
	; tooth 0
	hex 04 24 44 64 04 24 44 64
	; tooth 1
	hex 03 23 43 63 08 28 48 68
	; tooth 2
	hex 07 27 47 67 0c 2c 4c 6c
	; tooth 3
	hex 0b 2b 4b 6b 10 30 50 70
	; tooth 4
	hex 0f 2f 4f 6f 14 34 54 74
	; tooth 5
	hex 13 33 53 73 18 38 58 78
	; tooth 6
	hex 17 37 57 77 1c 3c 5c 7c
	; tooth 7
	hex 1b 3b 5b 7b 1b 3b 5b 7b
	; bottom row
	; tooth 8
	hex 84 a4 c4 e4 84 a4 c4 e4
	; tooth 9
	hex 83 a3 c3 e3 88 a8 c8 e8
	; tooth a
	hex 87 a7 c7 e7 8c ac cc ec
	; tooth b
	hex 8b ab cb eb 90 b0 d0 f0
	; tooth c
	hex 8f af cf ef 94 b4 d4 f4
	; tooth d
	hex 93 b3 d3 f3 98 b8 d8 f8
	; tooth e
	hex 97 b7 d7 f7 9c bc dc fc
	; tooth f
	hex 9b bb db fb 9b bb db fb

