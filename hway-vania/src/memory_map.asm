; zero page variables and other definitions


speed_hi       byte
speed_lo       byte
mph            byte
scroll_y_lo    byte ; sub pixels

ppu_attr_ptr_lo     byte
ppu_attr_ptr_hi     byte
ppu_tile_ptr_lo     byte
ppu_tile_ptr_hi     byte

road_r_x         byte
road_l_x         byte


player_is_dead       byte


road_r_x_offset   eqm $0700
road_l_x_offset   eqm $0710
attr_row_cache    eqm $07b8
tree_row_cache    eqm $07c0
tile_row_cache    eqm $07e0
