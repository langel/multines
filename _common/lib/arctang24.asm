
; quadrants
; 
;  0 | 1
;  --+--
;  2 | 3

; 24 angular regions total (0-23)
; 6 regions per quadrant
;  direction  
; 12 o'clock  6   up
;  3 o'clock  0   right
;  6 o'clock  18  down
;  9 o'clock  12  left

arctang24_to_dir8:
	hex 00 00 01 01 01 02
	hex 02 02 03 03 03 04
	hex 04 04 05 05 05 06
	hex 06 06 07 07 07 00
        

arctang24:
	; aimer position arguments
	;	collision_1_x
	;	collision_1_y
	; target position arguments
	;	collision_1_w
	;	collision_1_h
	; uses these zp vars
	;	temp00 = quadrant
	;	temp01 = region
	;	temp02 = y delta
	;	temp03 = "small"
	;	temp04 = "large"
	;	temp05 = "half"
	; returns a = direction (or region)
	
	; find quadrant
	lda #0
	sta temp00
	; y quadrants
	lda collision_1_h
	sec
	sbc collision_1_y
	bcc .top_quadrant
.bottom_quadrant
	inc temp00
	inc temp00
	jmp .y_quadrant_done
.top_quadrant
	lda collision_1_y
	sec
	sbc collision_1_h
.y_quadrant_done
	sta temp02
	tay
	; x quadrants
	lda collision_1_w
	sec
	sbc collision_1_x
	bcc .left_quadrant
.right_quadrant
	inc temp00
	jmp .x_quadrant_done
.left_quadrant
	lda collision_1_x
	sec
	sbc collision_1_w
.x_quadrant_done
	tax
	; quadrant is now in temp00
	; start finding that region
	cpx temp02
	bcs .x_greater_or_equal_y
.x_less_than_y
	lda #16
	sta temp01
	stx temp03
	sty temp04
	bne .determine_region
.x_greater_or_equal_y
	lda #0
	sta temp01
	stx temp04
	sty temp03
.determine_region
	lda temp03
	lsr
	sta temp05
	lda temp03
	asl
	bcs .q_smaller
	clc
	adc temp05
	bcs .q_smaller
	cmp temp04
	bcc .q_larger
.q_smaller ; S * 2.5 > L
	lsr temp05
	lda temp03
	clc
	adc temp05
	cmp temp04
	bcc .region1
	bcs .region0
.q_larger ; S * 2.5 < L
	lda temp03
	asl
	asl
	asl
	bcs .region2
	sec
	sbc temp05
	cmp temp04
	bcc .region3
	jmp .region2
.region0  ; L / S < 1.25	; d = 3,9,15,21
	lda temp01
	clc
	bmi .result_lookup
.region1  ; 1.25 < L / S < 2.5	; d = 2,4,8,10,14,16,20,22
	lda temp01
	clc 
	adc #4
	bpl .result_lookup
.region2  ; 2.5 < L / S < 7.5	; d = 1,5,7,11,13,17,19,23
	lda temp01
	clc
	adc #8
	bpl .result_lookup
.region3 ; 7.5 < L / S		; d = 0,6,12,18
	lda temp01
	clc
	adc #12
.result_lookup
	; temp01 should be ready in the accumulator
	adc temp00
	tax
	lda arctang24_translation_table,x
	rts

        
arctang24_translation_table:
	byte  9, 3,15,21
	byte 10, 2,14,22
	byte 11, 1,13,23
	byte 12, 0,12, 0
	byte  9, 3,15,21
	byte  8, 4,16,20
	byte  7, 5,17,19
	byte  6, 6,18,18
        
        
   
arctang24_bound_dir: subroutine
	; a = value to be bounded
	; returns value 0..23 in a
	bpl .check_above_24
.below_0
	clc
	adc #24
	rts
.check_above_24
	cmp #24
	bcc .bounded
	sec
	sbc #24
.bounded
	rts



		  ; XXX
		  ; data needs refactoring to work
		  ; with signed velocity values
        
;     reduce cycle counts by keeping these
;     tables on the same page
ARCTANG_REGION_TO_X_VELOCITY_TABLE:
	byte 0, 1, 2, 3, 4, 5
	byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
	byte 6, 5, 4, 3, 2, 1
ARCTANG_REGION_TO_Y_VELOCITY_TABLE:
	byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
	byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE:
	; 1 = plus
	; 0 = minus
	byte 1, 1, 1, 1, 1, 1
	byte 0, 0, 0, 0, 0, 0
	byte 0, 0, 0, 0, 0, 0
	byte 1, 1, 1, 1, 1, 1
ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE:
	; 1 = plus
	; 0 = minus
	byte 0, 0, 0, 0, 0, 0
	byte 0, 0, 0, 0, 0, 0
	byte 1, 1, 1, 1, 1, 1
	byte 1, 1, 1, 1, 1, 1


arctang_velocity_tables:
	; region id	angle degrees
	; 	0	0
	; 	1 	15
	; 	2	30
	; 	3	45
	; 	4	60
	; 	5	75
	; 	6	90
arctang_velocity_6.66:
	byte 168, 6
	byte 109, 6
	byte 193, 5
	byte 119, 4
	byte  84, 3
	byte 183, 1
	byte   0, 0
arctang_velocity_4.5:
	byte 127, 4
	byte  88, 4
	byte 229, 3
	byte  46, 3
	byte  64, 2
	byte  42, 1
	byte   0, 0
arctang_velocity_3.33:
	byte  85, 3
	byte  56, 3
	byte 227, 2
	byte  91, 2
	byte 171, 1
	byte 221, 0
	byte   0, 0
arctang_velocity_2.5:
	byte 127, 2
	byte 104, 2
	byte  43, 2
	byte 197, 1
	byte  64, 1
	byte 166, 0
	byte   0, 0
arctang_velocity_1.75:
	byte 191, 1
	byte 176, 1
	byte 131, 1
	byte  61, 1
	byte 223, 0
	byte 115, 0
	byte   0, 0
arctang_velocity_1.25:
	byte  64, 1
	byte  53, 1
	byte  20, 1
	byte 225, 0
	byte 161, 0
	byte  81, 0
	byte   0, 0
arctang_velocity_0.75:
	byte 191, 0
	byte 184, 0
	byte 166, 0
	byte 135, 0
	byte  96, 0
	byte  49, 0
	byte   0, 0
arctang_velocity_0.33:
	byte  84, 0
	byte  81, 0
	byte  73, 0
	byte  59, 0
	byte  42, 0
	byte  22, 0
	byte   0, 0
arctang_velocities_lo:
	byte #<arctang_velocity_6.66
	byte #<arctang_velocity_4.5
	byte #<arctang_velocity_3.33
	byte #<arctang_velocity_2.5
	byte #<arctang_velocity_1.75
	byte #<arctang_velocity_1.25
	byte #<arctang_velocity_0.75
	byte #<arctang_velocity_0.33
