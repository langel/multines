
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


const out = tooth_cell2nm_lo + '\n\n' + tooth_cell2nm_hi;

fs.writeFileSync('src/game/tooth_tables_2.asm', out);
