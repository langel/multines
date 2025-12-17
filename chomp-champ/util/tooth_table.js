
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
	let y = i >> 4;
	tooth_cell2nm_lo += tohex(x << 1);
	tooth_cell2nm_hi += tohex(0x20 + (y >> 1));
}


const out = tooth_cell2nm_lo + '\n\n' + tooth_cell2nm_hi;

fs.writeFileSync('tooth_tables_2.asm', out);
