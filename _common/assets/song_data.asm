

song_cc_level_start:
	
	hex 01
	hex 43 53
	hex 6f

	hex a2
	hex 27
	byte 34, 38, 22
	hex 30
	hex 14
	hex e7
	hex 12
	hex fa
	hex 27
	byte 34, 38, 22
	hex 16
	hex e7
	hex 16
	hex 27
	byte 36, 39, 24
	hex 16
	hex e7
	hex 16
	byte 38, 41, 26
	hex 31
	hex 19
	hex e7
	hex ff


song_cc_level_clear:
	hex 0d
	hex 40 50
	hex 6f

	hex 25
	byte 26, 26
	hex 30
	hex 11

	hex 22
	byte 30
	hex 11

	hex 21
	byte 33
	hex 11

	hex 21
	byte 37
	hex 31
	hex 12

	hex ff


song_cc_game_over:
	hex 40 50
	hex 65

	hex 08
	hex 27
	byte 32, 24, 29
	hex 14

	hex 0a
	hex 27
	byte 31, 22, 27
	hex 14

	hex 0b
	hex 27
	byte 29, 20, 25
	hex 15

	hex 0c
	hex 27
	byte 27, 19, 24
	hex 14

	hex ff


song_cc_game_clear:
	hex 0d
	hex 40 50
	hex 6f

	hex 25
	byte 26, 26
	hex 30
	hex 11

	hex 22
	byte 30
	hex 11

	hex 21
	byte 33
	hex 11

	hex 21
	byte 36
	hex 31
	hex 12

	hex 27
	byte 21, 37, 30
	hex 12
	
	hex 27
	byte 26, 42, 45
	hex 11
	hex 27
	byte 26, 42, 46
	hex 11
	hex 27
	byte 26, 42, 45
	hex 11
	hex 27
	byte 26, 42, 46
	hex 11
	hex 27
	byte 26, 42, 45
	hex 13

	hex e4

	hex ff


song_cc_player_death:

	hex 03
	hex 43 53
	hex 62
	hex 27
	byte 20, 23, 20
	hex 13
	hex a2
	hex 27
	byte 19, 22, 19
	hex 14
	hex fa
	hex a2
	hex 27
	byte 17, 20, 17
	hex 14
	hex fa
	hex ff


song_cc_congration:

	hex 08
	hex 43 53 ; set ppu env
	hex 64 ; tri length
	hex f6 ; mend2 begin

	; pattern0
	hex f3 ; mend1 begin
	; bar1
	hex 27 ; chord
	byte 36, 40, 22
	hex 12
	hex a3 ; set 4 loop1s
	hex 23 ; chord
	byte 36, 40
	hex 12
	hex fa ; loop1 back
	; bar2
	hex 27 ; chord
	byte 34, 38, 22
	hex 12
	hex a3 ; set 4 loop1s
	hex 23 ; chord
	byte 34, 38
	hex 12
	hex fa ; loop1 back
	hex f4 ; mend1 end
	; bar3
	hex 27 ; chord
	byte 38, 41, 29
	hex 14
	hex 23
	byte 33, 36
	hex 14
	; bar4
	hex 27
	byte 29, 21, 17
	hex 18
	hex f5 ; mend1 next
	; bar1-2 repeat
	; bar7
	hex 27 ; chord
	byte 38, 41, 29
	hex 13
	hex 23
	byte 38, 41
	hex 11
	hex 23
	byte 33, 36
	hex 14
	; bar8
	hex 27
	byte 29, 21, 17
	hex 18

	hex f7 ; mend2 end
	; pattern2
	; bar1
	hex 27
	byte 29, 33, 17
	hex 14
	hex a2 ; set loop1
	hex 23
	byte 29, 33
	hex 12
	hex fa ; loop1
	; bar2
	hex 27
	byte 31, 34, 19
	hex 16
	hex 23
	byte 31, 34
	hex 12
	; bar3
	hex 27 
	byte 33, 36, 21
	hex 14
	hex a2 ; set loop1
	hex 23
	byte 33, 36
	hex 12
	hex fa ; loop1
	; bar4
	hex 27 
	byte 29, 34, 17
	hex 18
	; bar5
	hex 61 ; tri length
	hex a3 ; set loop1
	hex 27
	byte 29, 33, 17
	hex 12
	hex fa
	hex 62 ; tri length
	hex 27
	byte 29, 33, 17
	hex 12
	; bar6
	hex 27
	byte 33, 36, 21
	hex 12
	hex 61 ; tri length
	hex 27
	byte 31, 34, 19
	hex 16
	; bar7
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 12
	hex 61 ; tri length
	hex a2 ; set loop1
	hex 27
	byte 31, 34, 19
	hex 12
	hex fa ; loop1
	hex 27
	byte 29, 33, 17
	hex 12
	; bar8
	hex 64 ; set tri
	hex 27
	byte 29, 33, 17
	hex 18

	; pattern1 repeat
	hex f8 ; mend2 next

	; pattern3
	; bar1
	hex 27
	byte 33, 36, 21
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 33, 36
	hex 12
	hex fa ; loop1
	; bar2
	hex 27
	byte 34, 38, 22
	hex 12
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 16
	; bar3
	hex 64 ; tri length
	hex 27
	byte 34, 38, 22
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 34, 38
	hex 12
	hex fa ; loop1
	; bar4
	hex 27
	byte 38, 41, 26
	hex 12
	hex 62 ; tri length
	hex 27
	byte 34, 38, 22
	hex 16
	; bar5
	hex 68 ; tri length
	hex 27
	byte 36, 40, 24
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 36, 40
	hex 12
	hex fa
	; bar6
	hex 27
	byte 34, 38, 22
	hex 12
	hex a3 ; set loop1
	hex 23
	byte 34, 38
	hex 12
	hex fa
	; bar7
	hex 62 ; tri length
	hex 27
	byte 33, 36, 21
	hex 12
	hex 27
	byte 31, 34, 19
	hex 14
	hex 27
	byte 29, 33, 17
	hex 1a

	hex f0 ; restart song
