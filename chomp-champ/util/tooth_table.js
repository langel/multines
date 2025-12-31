
const fs = require('fs');

let tohex = (x) => x.toString(16).padStart(2, '0'); 


let tooth_cell2nm_lo = 'tooth_cell2nm_lo:';
let tooth_cell2nm_hi = 'tooth_cell2nm_hi:';

for (let i = 0; i < 256; i++) {
	// setup newlines
	if (i % 16 == 0) {
		tooth_cell2nm_lo += '\n\thex ';
		tooth_cell2nm_hi += '\n\thex ';
	}
	// calc position
	let x = i & 0x1f;
	let y = i >> 5;
	let lo = (x << 1) & 0x1f;
	lo += y << 6;
	lo = lo & 0xff;
	let hi = 0x21;
	if (x >= 16) hi += 4;
	if (y >= 4) hi += 1;
	tooth_cell2nm_lo += tohex(lo);
	tooth_cell2nm_hi += tohex(hi);
}


let tooth_cell2tooth = 'tooth_cell2tooth:';
for (let i = 0; i < 256; i++) {
	// setup newlines
	if (i % 16 == 0) {
		tooth_cell2tooth += '\n\thex ';
	}
	// calc tooth id
	let x = (i >> 2) & 0x07;
	let y = i >> 7;
	tooth_cell2tooth += tohex(x + (y <<3));
}


let tooth_tile_rows_lo = 'tooth_tile_rows_lo:';
let tooth_tile_rows_hi = 'tooth_tile_rows_hi:';

for (let i = 0; i < 16; i++) {
	// setup newlines
	tooth_tile_rows_lo += '\n\thex ';
	tooth_tile_rows_hi += '\n\thex ';
	// calc base position
	let x = i & 0x07;
	let y = i >> 3;
	let lo = (x & 0x03) * 8;
	let hi = (y) ? 0x22 : 0x21;
	if (x >= 4) hi += 4;
	for (let j = 0; j < 8; j++) {
		tooth_tile_rows_lo += tohex(lo + (j << 5));
		tooth_tile_rows_hi += tohex(hi);
	}
}


const out = tooth_cell2nm_lo + '\n\n' + tooth_cell2nm_hi + '\n\n' + tooth_tile_rows_lo + '\n\n' + tooth_tile_rows_hi + '\n\n' + tooth_cell2tooth;

fs.writeFileSync('src/game/tooth_tables_2.asm', out);
