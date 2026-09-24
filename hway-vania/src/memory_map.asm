; zero page variables and other definitions


speed_hi       byte
speed_lo       byte
mph            byte
scroll_y_lo    byte ; sub pixels

ppu_attr_ptr_lo     byte
ppu_attr_ptr_hi     byte
ppu_tile_ptr_lo     byte
ppu_tile_ptr_hi     byte

road_x         byte

player_is_dead       byte


road_row_x_offset eqm $0700
attr_row_cache    eqm $07d8
tile_row_cache    eqm $07e0
