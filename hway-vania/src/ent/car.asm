
; traffic vehicle, one ent type, the subtype picks the sprites
; ent_r0 lane offset, px from the right road's left edge or the left road's right edge
;        to the car, car_lane_inset + lane_off_lut in a lane, steps 1 px to change lanes
; ent_r1 lean hold timer
; ent_r2 lean from lane changes, -2..2, positive = moving right, trailing sprites lag left
; ent_r3 bits 0-1 subtype, bit 7 opposing traffic on the left road
; ent_r4 target lane, counted from the median
; ent_r5 speed, 1/32 px per frame, mph is about speed * 16 / 15
; ent_r6 cruise speed, 0 once crashed into a tree, then the car stays put
; ent_r7 lane mask, bits 0-3 right road lanes, bits 4-7 left road lanes
;        both lanes are set while changing lanes
; ent_x_hi:ent_x x of the leading sprite, x_hi $ff when off the left edge,
;        set from the lane offset every other frame, see car_place_x
; ent_y_hi:ent_y:ent_y_lo world y of the top sprite

car_look_dist    eqm 40 ; gap ahead that starts a lane change or braking
car_snap_dist    eqm 6  ; gap by the next ai frame that takes the speed of the car ahead
car_min_gap      eqm 5  ; closer than this, drop back under the car ahead's speed
car_yield_dist   eqm 64 ; player this close behind, move over
car_lane_margin  eqm 24 ; clear space ahead and behind for a lane change
car_spawn_margin eqm 16
car_lean_hold    eqm 6  ; frames between lean steps
car_lean_peak    eqm 8  ; frames a full lean holds once sideways motion stops
car_min_speed    eqm 16 ; braking floor while stuck in a closing lane
car_slope_rows   eqm 8  ; rows the road slope is measured over, offsets are in 1/8 px
car_lane_inset   eqm 3  ; px from a lane's edge to a car centered in it

; by subtype: sedan, van, semi
car_seg_count:
	hex 02 03 04
car_len:
	hex 10 18 20
car_pat_base:
	hex 00 02 05
car_pal:
	hex 01 00 00
car_lean_base:
	hex 00 0c 18

; patterns from the front of the vehicle
car_pats:
	hex 00 10
	hex 31 41 51
	hex 20 30 40 50

; trailing x offsets by |lean| 0, 1, 2, leader first, 4 per row
; neighbors differ by at most 1 and only grow, so no zigzag
car_lean_lut:
	; sedan, also the player bike
	hex 00 00 00 00
	hex 00 01 00 00
	hex 00 01 00 00
	; van
	hex 00 00 00 00
	hex 00 01 01 00
	hex 00 01 02 00
	; semi
	hex 00 00 00 00
	hex 00 00 01 01
	hex 00 01 02 03

; lane offset from the first lane, lane_pitch apart
lane_off_lut:
	hex 00 0d 1a 27


; tries one spawn, carry set when a car was placed
ent_car_spawn: subroutine
	jsr traffic_find_slot
	bpl .slot_ok
	clc
	rts
.slot_ok
	stx car_new_slot
	jsr rng_update
	; subtype from bits 1-2, 3 is another sedan
	lda rng_val0
	lsr
	and #$03
	cmp #$03
	bne .subtype_ok
	lda #$00
.subtype_ok
	sta car_new_info
	; base speed 61..80, 65..85 mph
	lda rng_val0
	shift_r 3
	cmp #20
	bcc .speed_ok
	sbc #12
.speed_ok
	clc
	adc #61
	sta car_new_speed
	; top at 28 above the screen, out of view, and a car moving up
	; on its spawn frame stays inside the 32 px despawn line
	lda #$e4
	sta car_sy_lo
	lda #$ff
	sta car_sy_hi
	; bit 0 picks the road, the left road is opposing traffic
	lda rng_val0
	lsr
	bcc .right_road
	lda car_new_info
	ora #$80
	sta car_new_info
	jmp .place
.right_road
	; half start behind, the rest start ahead when the player is faster
	lda rng_val1
	and #$04
	bne .behind
	lda player_units
	cmp car_new_speed
	beq .behind
	bcs .place
.behind
	; behind the player and 5..23 faster, about 5..25 mph
	lda rng_val1
	shift_r 3
	cmp #19
	bcc .delta_ok
	sbc #13
.delta_ok
	clc
	adc #5
	adc player_units
	bcc .behind_fast
	lda #$ff
.behind_fast
	; never under the base speed
	cmp car_new_speed
	bcc .behind_slow
	sta car_new_speed
.behind_slow
	lda #$f0
	sta car_sy_lo
	lda #$00
	sta car_sy_hi
.place
	lda car_new_info
	and #$03
	tax
	lda car_len,x
	sta car_len_a
	lda car_new_info
	jsr car_front_row
	sta car_ring
	tay
	jsr road_lane_count
	sta car_lanes
	; lane from bits 0-1, missing outer lanes fold to 0 or 1
	lda rng_val1
	and #$03
	cmp car_lanes
	bcc .lane_ok
	and #$01
	cmp car_lanes
	bcc .lane_ok
	clc
	rts
.lane_ok
	sta car_new_lane
	; place it in the still empty slot
	ldx car_new_slot
	lda car_new_info
	sta ent_r3,x
	sta temp07
	ldy car_new_lane
	lda lane_off_lut,y
	clc
	adc #car_lane_inset
	sta ent_r0,x
	ldy car_ring
	jsr car_place_x
	; no spawning into lanes off the left edge
	lda ent_x_hi,x
	beq .on_screen
	clc
	rts
.on_screen
	lda car_new_lane
	jsr car_lane_bit
	sta car_chk_mask
	; world y = camera + screen y
	clc
	lda camera_y
	adc car_sy_lo
	sta car_chk_y_lo
	lda camera_y_hi
	adc car_sy_hi
	sta car_chk_y_hi
	lda car_len_a
	sta car_chk_len
	; behind the player, room to stay at speed instead of braking off the screen
	lda #car_spawn_margin
	ldy car_sy_hi
	bne .margin_set
	lda #car_look_dist
.margin_set
	sta car_chk_margin
	lda #$ff
	sta car_chk_self
	jsr traffic_box_clear
	bcc .fail
	ldx car_new_slot
	lda #ent_car_id
	sta ent_type,x
	lda car_new_info
	sta ent_r3,x
	lda car_new_lane
	sta ent_r4,x
	lda car_new_speed
	sta ent_r5,x
	sta ent_r6,x
	lda car_chk_mask
	sta ent_r7,x
	lda #$00
	sta ent_r1,x
	sta ent_r2,x
	sta ent_y_lo,x
	lda car_chk_y_lo
	sta ent_y,x
	lda car_chk_y_hi
	sta ent_y_hi,x
	; straight until car_render fills in the offsets
	txa
	and #$0f
	asl
	asl
	tay
	lda #$00
	sta car_off_cache,y
	sta car_off_cache+1,y
	sta car_off_cache+2,y
	sta car_off_cache+3,y
	sec
	rts
.fail
	clc
	rts


; in: a = car info (ent_r3), car_sy_lo/hi = screen y of the top, car_len_a
; out: a = ring index of the front row, top + 4 or bottom - 4 for opposing
; clobbers x temp00..temp03
car_front_row: subroutine
	asl
	bcs .bottom
	lda #$04
	bne .front_set
.bottom
	lda car_len_a
	sec
	sbc #$04
.front_set
	clc
	adc car_sy_lo
	sta temp00
	lda car_sy_hi
	adc #$00
	sta temp01
	jmp road_ring_index_screen


; in: a = lane, temp07 = car info, bit 7 opposing
; out: a = lane mask bit, clobbers y
car_lane_bit: subroutine
	bit temp07
	bpl .right
	ora #$04
.right
	tay
	lda bit_lut,y
	rts


; ent_x_hi:ent_x from the car's lane offset, ent_r0, and the road at ring row y
; right road: left edge + offset, left road: right edge - 8 - offset
; in: x = slot, y = ring index, clobbers temp00
car_place_x: subroutine
	lda ent_r3,x
	bmi .left
	lda road_r_x_offset,y
	clc
	adc ent_r0,x
	sta ent_x,x
	lda #$00
	adc #$00
	sta ent_x_hi,x
	rts
.left
	; the left edge is signed, $c0 and up is off the left of the screen
	lda #$00
	sta temp00
	lda road_l_x_offset,y
	cmp #$c0
	bcc .edge_pos
	dec temp00
.edge_pos
	clc
	adc road_w_ring,y
	bcc .right_edge
	inc temp00
.right_edge
	sec
	sbc #$08
	bcs .less_8
	dec temp00
.less_8
	sec
	sbc ent_r0,x
	bcs .less_offset
	dec temp00
.less_offset
	sta ent_x,x
	lda temp00
	sta ent_x_hi,x
	rts


; a car partly off the road whose front reaches a tree stops dead
; in: x = slot, car_ring = ring index of the front row, car_sy_lo/hi, car_len_a
; returns x = slot, clobbers y temp00..temp06
car_tree_check: subroutine
	lda ent_r6,x
	bne .running
	rts
.running
	; temp00/01 = road left edge, signed
	ldy car_ring
	lda #$00
	sta temp01
	lda ent_r3,x
	bmi .left
	lda road_r_x_offset,y
	jmp .edge
.left
	lda road_l_x_offset,y
	cmp #$c0
	bcc .edge
	dec temp01
.edge
	sta temp00
	; on the road when 0 <= x - edge <= width - 8
	sec
	lda ent_x,x
	sbc temp00
	sta temp02
	lda ent_x_hi,x
	sbc temp01
	bne .off_road
	lda road_w_ring,y
	sec
	sbc #$08
	cmp temp02
	bcs .done
.off_road
	; front sprite center, only on screen
	lda ent_x_hi,x
	bne .done
	lda ent_r3,x
	asl
	lda #$04
	bcc .front_set
	lda car_len_a
	sbc #$04
.front_set
	clc
	adc car_sy_lo
	sta temp05
	lda car_sy_hi
	adc #$00
	bne .done
	lda temp05
	cmp #$f0
	bcs .done
	; both sides of the front sprite
	lda ent_x,x
	clc
	adc #$01
	sta temp06
	ldy temp05
	jsr road_class_lookup_screen
	cmp #$02
	beq .crash
	lda temp06
	clc
	adc #$05
	ldy temp05
	jsr road_class_lookup_screen
	cmp #$02
	bne .done
.crash
	; out of every lane so nothing brakes for it
	ldx ent_slot
	lda #$00
	sta ent_r5,x
	sta ent_r6,x
	sta ent_r7,x
.done
	ldx ent_slot
	rts


; in: car_chk_y_lo/hi world y of a box top, car_chk_len, car_chk_mask,
;     car_chk_margin space kept above and below, car_chk_self slot to skip
; out: carry set when no car in the mask's lanes is inside the box
; clobbers x y temp00
traffic_box_clear: subroutine
	ldy #traffic_min_slot
.loop
	cpy car_chk_self
	beq .next
	lda ent_type,y
	cmp #ent_car_id
	bne .next
	lda ent_r7,y
	and car_chk_mask
	beq .next
	; d = other top - box top
	sec
	lda ent_y,y
	sbc car_chk_y_lo
	sta temp00
	lda ent_y_hi,y
	sbc car_chk_y_hi
	beq .other_below
	cmp #$ff
	bne .next
	; other above, blocked when -d < other len + margin
	lda ent_r3,y
	and #$03
	tax
	lda car_len,x
	clc
	adc car_chk_margin
	clc
	adc temp00
	bcs .blocked
	bcc .next
.other_below
	; blocked when d <= box len + margin
	lda car_chk_len
	clc
	adc car_chk_margin
	cmp temp00
	bcs .blocked
.next
	iny
	cpy #traffic_max_slot
	bne .loop
	sec
	rts
.blocked
	clc
	rts


ent_car_update: subroutine
	lda ent_r3,x
	and #$03
	tay
	lda car_len,y
	sta car_len_a

	; move, speed * 8 in 8.8 px per frame
	lda ent_r5,x
	sta temp00
	lda #$00
	sta temp01
	asl temp00
	rol temp01
	asl temp00
	rol temp01
	asl temp00
	rol temp01
	lda ent_r3,x
	bmi .move_down
	sec
	lda ent_y_lo,x
	sbc temp00
	sta ent_y_lo,x
	lda ent_y,x
	sbc temp01
	sta ent_y,x
	lda ent_y_hi,x
	sbc #$00
	sta ent_y_hi,x
	jmp .moved
.move_down
	clc
	lda ent_y_lo,x
	adc temp00
	sta ent_y_lo,x
	lda ent_y,x
	adc temp01
	sta ent_y,x
	lda ent_y_hi,x
	adc #$00
	sta ent_y_hi,x
.moved

	; screen y, despawn 32 above or 16 below the screen
	sec
	lda ent_y,x
	sbc camera_y
	sta car_sy_lo
	lda ent_y_hi,x
	sbc camera_y_hi
	sta car_sy_hi
	beq .alive
	cmp #$ff
	beq .above
	cmp #$01
	bne .despawn
	lda car_sy_lo
	beq .alive
	bne .despawn
.above
	lda car_sy_lo
	cmp #$e0
	bcs .alive
.despawn
	ent_despawn
	ldy ent_spr_ptr
	rts
.alive

	; road lookups on alternate frames, slots take turns to spread the cost
	; x only changes here, so lane changes run 1 px every other frame against the road
	lda #$ff
	sta car_ring
	txa
	eor wtf
	sta car_cand
	lsr
	bcs .lateral_done
	lda ent_r3,x
	jsr car_front_row
	sta car_ring
	ldx ent_slot
	; ai every 8th frame
	lda car_cand
	and #$07
	bne .ai_done
	ldy car_ring
	jsr road_lane_count
	sta car_lanes
	ldx ent_slot
	jsr car_ai
.ai_done
	; crashed cars stay where they hit
	lda ent_r6,x
	beq .lateral_done
	; 1 px toward the target lane
	ldy ent_r4,x
	lda lane_off_lut,y
	clc
	adc #car_lane_inset
	cmp ent_r0,x
	beq .lane_moved
	bcc .lane_down
	inc ent_r0,x
	bne .lane_moved
.lane_down
	dec ent_r0,x
.lane_moved
	cmp ent_r0,x
	bne .placed
	; settled, only the target lane is occupied
	lda ent_r7,x
	sec
	sbc #$01
	and ent_r7,x
	beq .placed
	lda ent_r3,x
	sta temp07
	lda ent_r4,x
	jsr car_lane_bit
	ldx ent_slot
	sta ent_r7,x
.placed
	ldy car_ring
	jsr car_place_x
	jsr car_tree_check
.lateral_done

	; lean toward the target lane while changing lanes, temp06 = -1, 0 or 1
	; the sprites follow road curves in car_render
	lda #$00
	sta temp06
	lda ent_r6,x
	beq .dir_set
	ldy ent_r4,x
	lda lane_off_lut,y
	clc
	adc #car_lane_inset
	sec
	sbc ent_r0,x
	beq .dir_set
	; a growing lane offset moves right on the right road, left on the left road
	lda #$01
	bcs .dir_sign
	lda #$ff
.dir_sign
	ldy ent_r3,x
	bpl .dir_set
	eor #$ff
	clc
	adc #$01
.dir_set
	sta temp06
	lda ent_r1,x
	beq .lean_ready
	ldy temp06
	bne .lean_call
	dec ent_r1,x
	jmp car_render
.lean_ready
	; straight and not moving sideways, nothing changes
	lda ent_r2,x
	ora temp06
	beq .lean_done
.lean_call
	lda ent_r2,x
	sta temp02
	lda ent_r1,x
	sta temp03
	lda temp06
	jsr lean_step
	ldx ent_slot
	lda temp02
	sta ent_r2,x
	lda temp03
	sta ent_r1,x
.lean_done

	jmp car_render


; lane collapse, lookahead, lane changes, braking, player yield
; runs every 8th frame per car
; in: x = slot, car_lanes, car_len_a
car_ai: subroutine
	lda ent_r6,x
	bne .running
	rts
.running
	; the lane is closing under the car, merge in
	lda ent_r4,x
	cmp car_lanes
	bcc .lane_valid
	lda car_lanes
	bne .merge
	rts
.merge
	sec
	sbc #$01
	jsr car_try_lane
	bcs .lane_valid
	; blocked, slow down until a gap opens
	lda ent_r5,x
	cmp #car_min_speed
	bcc .lane_valid
	sbc #$04
	sta ent_r5,x
.lane_valid
	jsr car_lookahead
	; temp01 = the gap by the next ai frame, 8 frames of closing speed is speed / 4 px
	lda car_gap
	sta temp01
	cmp #$ff
	beq .gap_ready
	lda ent_r5,x
	sec
	sbc car_gap_speed
	bcc .gap_ready
	lsr
	lsr
	sta temp00
	lda car_gap
	sec
	sbc temp00
	bcs .gap_store
	lda #$00
.gap_store
	sta temp01
.gap_ready
	lda temp01
	cmp #car_look_dist
	bcs .clear_ahead
	cmp #car_snap_dist
	bcs .not_close
	; close behind, follow at the speed of the car ahead,
	; a little under it while inside car_min_gap so the gap opens back up
	lda car_gap_speed
	ldy car_gap
	cpy #car_min_gap
	bcs .follow
	sec
	sbc #$02
	bcs .follow
	lda #$00
.follow
	cmp ent_r6,x
	bcc .follow_store
	lda ent_r6,x
.follow_store
	sta ent_r5,x
.not_close
	; pass toward the median first, only when settled in a lane
	jsr car_is_changing
	bne .brake
	lda ent_r4,x
	sec
	sbc #$01
	jsr car_try_lane
	bcc .pass_out
	rts
.pass_out
	lda ent_r4,x
	clc
	adc #$01
	jsr car_try_lane
	bcc .brake
	rts
.brake
	; 4 per ai frame, never under the car ahead
	lda ent_r5,x
	sec
	sbc #$04
	bcc .brake_match
	cmp car_gap_speed
	bcs .brake_store
.brake_match
	lda ent_r5,x
	cmp car_gap_speed
	bcc .done
	lda car_gap_speed
.brake_store
	sta ent_r5,x
	rts
.clear_ahead
	; back up to cruise speed, 2 per ai frame
	lda ent_r5,x
	cmp ent_r6,x
	bcs .yield
	adc #$02
	cmp ent_r6,x
	bcc .accel_store
	lda ent_r6,x
.accel_store
	sta ent_r5,x
.yield
	; right road only, move over for the player closing from behind
	lda ent_r3,x
	bmi .done
	lda player_lane_mask
	and ent_r7,x
	beq .done
	lda player_units
	cmp ent_r5,x
	beq .done
	bcc .done
	jsr car_is_changing
	bne .done
	; distance from the car's back to the player's top
	sec
	lda player_wy
	sbc ent_y,x
	sta temp00
	lda player_wy_hi
	sbc ent_y_hi,x
	bne .done
	lda temp00
	sec
	sbc car_len_a
	bcc .done
	cmp #car_yield_dist
	bcs .done
	; outer lane first, then toward the median
	lda ent_r4,x
	clc
	adc #$01
	jsr car_try_lane
	bcs .done
	lda ent_r4,x
	sec
	sbc #$01
	jsr car_try_lane
.done
	rts


; z clear when the car is between lanes, x = slot
car_is_changing: subroutine
	lda ent_r3,x
	sta temp07
	lda ent_r4,x
	jsr car_lane_bit
	cmp ent_r7,x
	rts


; in: a = lane, $ff for none, x = slot
; out: carry set when the change started
car_try_lane: subroutine
	cmp car_lanes
	bcs .fail
	sta car_cand
	lda ent_r3,x
	sta temp07
	lda car_cand
	jsr car_lane_bit
	sta car_chk_mask
	lda ent_y,x
	sta car_chk_y_lo
	lda ent_y_hi,x
	sta car_chk_y_hi
	lda car_len_a
	sta car_chk_len
	lda #car_lane_margin
	sta car_chk_margin
	stx car_chk_self
	jsr traffic_box_clear
	ldx ent_slot
	bcc .fail
	lda car_cand
	sta ent_r4,x
	lda ent_r7,x
	ora car_chk_mask
	sta ent_r7,x
	sec
	rts
.fail
	clc
	rts


; nearest car ahead sharing a lane
; out: car_gap px from this car's front to its back, $ff none, car_gap_speed
car_lookahead: subroutine
	lda #$ff
	sta car_gap
	ldy #traffic_min_slot
.loop
	cpy ent_slot
	beq .next
	lda ent_type,y
	cmp #ent_car_id
	bne .next
	lda ent_r7,y
	and ent_r7,x
	beq .next
	lda ent_r3,x
	bmi .down
	; up the road, ahead is smaller y, gap = top - other top - other len
	sec
	lda ent_y,x
	sbc ent_y,y
	sta temp00
	lda ent_y_hi,x
	sbc ent_y_hi,y
	bne .next
	lda ent_r3,y
	and #$03
	tax
	lda car_len,x
	ldx ent_slot
	jmp .gap
.down
	; down the road, gap = other top - top - len
	sec
	lda ent_y,y
	sbc ent_y,x
	sta temp00
	lda ent_y_hi,y
	sbc ent_y_hi,x
	bne .next
	lda car_len_a
.gap
	sta temp01
	lda temp00
	sec
	sbc temp01
	bcs .gap_pos
	lda #$00
.gap_pos
	cmp car_gap
	bcs .next
	sta car_gap
	lda ent_r5,y
	sta car_gap_speed
.next
	iny
	cpy #traffic_max_slot
	bne .loop
	rts


; in: a = x step this frame, temp02 = lean, temp03 = hold timer
; out: temp02 temp03, the lean moves one step toward 2, -2 or 0
; a full lean holds car_lean_peak frames after the last step toward it
; clobbers temp04
lean_step: subroutine
	sta temp04
	beq .no_push
	eor temp02
	bmi .no_push
	lda temp02
	cmp #$02
	beq .peak
	cmp #$fe
	bne .no_push
.peak
	lda #car_lean_peak
	sta temp03
	rts
.no_push
	lda temp03
	beq .ready
	dec temp03
	rts
.ready
	lda temp04
	beq .target
	bmi .target_left
	lda #$02
	bne .target
.target_left
	lda #$fe
.target
	; both are -2..2, compare with a +2 bias
	clc
	adc #$02
	sta temp04
	lda temp02
	clc
	adc #$02
	cmp temp04
	beq .done
	bcs .step_left
	inc temp02
	jmp .hold
.step_left
	dec temp02
.hold
	lda temp02
	cmp #$02
	beq .peak
	cmp #$fe
	beq .peak
	lda #car_lean_hold
	sta temp03
.done
	rts


; car_off_cache entry = x offset of each sprite from the leader, top sprite first
; each sprite follows the road slope over car_slope_rows rows, plus the lane change lean,
; and stays within 1 px of the sprite it follows
; a sprite only moves when it is 3/4 px or more from where it should be,
; so the whole pixel road rows do not make it flicker
; the lanes are measured from the right road's left edge or the left road's right edge
; in: x = slot, car_ring = ring index of the leader's row, returns x = slot
; clobbers y temp00 temp05..temp07
car_offsets: subroutine
	; row of the leader from the top of the ring
	lda car_ring
	sec
	sbc state02
	bcs .k_ok
	adc #road_ring_rows
.k_ok
	sta car_k
	; temp05 sprite count, temp06 lean row, temp07 lean
	lda ent_r3,x
	and #$03
	tay
	lda car_seg_count,y
	sta temp05
	lda ent_r2,x
	sta temp07
	bpl .lean_abs
	eor #$ff
	clc
	adc #$01
.lean_abs
	asl
	asl
	clc
	adc car_lean_base,y
	sta temp06
	txa
	and #$0f
	asl
	asl
	sta car_off_base

	; car_slope = edge change over car_slope_rows rows toward the trailing sprites
	ldy car_ring
	lda ent_r3,x
	bmi .opp
	lda road_r_x_offset,y
	sta car_ref
	lda car_k
	clc
	adc #car_slope_rows
	cmp #road_ring_rows-1
	bcc .fwd_k
	lda #road_ring_rows-2
.fwd_k
	clc
	adc state02
	cmp #road_ring_rows
	bcc .fwd_ring
	sbc #road_ring_rows
.fwd_ring
	tay
	lda road_r_x_offset,y
	sec
	sbc car_ref
	sta car_slope
	lda #$00
	jmp .leader
.opp
	lda road_l_x_offset,y
	clc
	adc road_w_ring,y
	sta car_ref
	lda car_k
	sec
	sbc #car_slope_rows
	bcs .opp_k
	lda #$00
.opp_k
	clc
	adc state02
	cmp #road_ring_rows
	bcc .opp_ring
	sbc #road_ring_rows
.opp_ring
	tay
	lda road_l_x_offset,y
	clc
	adc road_w_ring,y
	sec
	sbc car_ref
	sta car_slope
	; the bottom sprite leads
	ldy temp05
	dey
	tya
.leader
	clc
	adc car_off_base
	tay
	lda #$00
	sta car_off_cache,y
	sta car_prev
	sta car_ideal
	lda #$01
	sta car_j

.loop
	lda car_j
	cmp temp05
	bne .sprite
	rts
.sprite
	; sprite index from the top
	lda ent_r3,x
	bpl .seg_fwd
	lda temp05
	clc
	sbc car_j
	jmp .seg_set
.seg_fwd
	lda car_j
.seg_set
	clc
	adc car_off_base
	sta car_seg
	; where it should be, 1/8 px
	lda car_ideal
	clc
	adc car_slope
	sta car_ideal
	lda temp07
	beq .no_lean
	lda car_j
	clc
	adc temp06
	tay
	lda car_lean_lut,y
	; trailing sprites lag opposite the lean
	bit temp07
	bmi .lean_ok
	eor #$ff
	clc
	adc #$01
.lean_ok
	asl
	asl
	asl
	clc
	adc car_ideal
	jmp .want_set
.no_lean
	lda car_ideal
.want_set
	sta car_want
	; stays put unless 6/8 px or more away
	ldy car_seg
	lda car_off_cache,y
	asl
	asl
	asl
	sta temp00
	lda car_want
	sec
	sbc temp00
	clc
	adc #$05
	cmp #$0b
	bcs .move
	lda car_off_cache,y
	jmp .clamp
.move
	; nearest pixel
	lda car_want
	clc
	adc #$04
	cmp #$80
	ror
	cmp #$80
	ror
	cmp #$80
	ror
.clamp
	; within 1 px of the sprite before
	sec
	sbc car_prev
	beq .same
	bmi .step_left
	inc car_prev
	jmp .same
.step_left
	dec car_prev
.same
	lda car_prev
	sta car_off_cache,y
	inc car_j
	jmp .loop


; x = slot, returns y = sprite pointer
car_render: subroutine
	; nothing when the sprite page is full or the car is off the left edge
	lda traffic_oam_full
	ora ent_x_hi,x
	beq .visible
	ldy ent_spr_ptr
	rts
.visible
	; collision box when the top is on screen
	lda car_sy_hi
	bne .collision_done
	lda ent_x,x
	sta collision_1_x
	lda car_sy_lo
	sta collision_1_y
	lda #$08
	sta collision_1_w
	lda car_len_a
	sta collision_1_h
.collision_done
	; offsets every 4th frame, on a frame ent_car_update found the leader's row
	lda car_ring
	bmi .offsets_done
	txa
	eor wtf
	and #$02
	bne .offsets_done
	jsr car_offsets
.offsets_done
	txa
	and #$0f
	asl
	asl
	sta car_off_base
	; temp00 pattern base, temp01 attribute, temp02 sprite count
	lda ent_r3,x
	and #$03
	tay
	lda car_pat_base,y
	sta temp00
	lda car_seg_count,y
	sta temp02
	lda car_pal,y
	sta temp01
	lda ent_r3,x
	bpl .attr_done
	; opposing, front at the bottom, flipped
	lda temp01
	ora #$80
	sta temp01
.attr_done
	; temp05/06 sprite screen y, temp07 sprite index from the top
	lda car_sy_lo
	sta temp05
	lda car_sy_hi
	sta temp06
	lda #$00
	sta temp07
	ldy ent_spr_ptr
.seg_loop
	lda temp06
	bne .seg_next
	lda temp05
	cmp #$ef
	bcs .seg_next
	sta spr_y,y
	; leader first index, the bottom leads when flipped
	lda temp07
	bit temp01
	bpl .lead_done
	eor #$ff
	clc
	adc temp02
.lead_done
	clc
	adc temp00
	tax
	lda car_pats,x
	sta spr_p,y
	lda temp01
	sta spr_a,y
	lda car_off_base
	clc
	adc temp07
	tax
	lda car_off_cache,x
	sta car_cand
	ldx ent_slot
	clc
	adc ent_x,x
	sta spr_x,y
	; carry with a positive offset or none with a negative one wrapped
	lda car_cand
	bmi .offset_neg
	bcs .wrapped
	bcc .written
.offset_neg
	bcc .wrapped
.written
	inc_y 4
	bne .seg_next
	; sprite page full, the rest of traffic skips rendering this frame
	inc traffic_oam_full
	jmp .finish
.wrapped
	lda #$ff
	sta spr_y,y
.seg_next
	clc
	lda temp05
	adc #$08
	sta temp05
	lda temp06
	adc #$00
	sta temp06
	inc temp07
	lda temp07
	cmp temp02
	bne .seg_loop
.finish
	sty ent_spr_ptr
	ldx ent_slot
	rts
