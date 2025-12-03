/*
	convert 
	DASM listing export 
	to a
	Mesen LaBel file
*/

const ANSI = {
	reset: "\x1b[0m",
	bright: "\x1b[1m",
	fg_green: "\x1b[32m",
	fg_red: "\x1b[31m",
	fg_yellow: "\x1b[33m",
}


if (process.argv[2] === undefined) {
	console.log(`${ANSI.fg_yellow}missing directory argument${ANSI.reset}`);
	process.exit();
}

let dir = process.argv[2];

let fs = require('fs');
let input = `./${dir}/listing.txt`;
if (!fs.existsSync(input)) {
	console.log('failed to find ' + input);
	process.exit(1);
}

let output = `./${dir}/rom.mlb`;
fs.writeFileSync(output, '', { flag: 'w+' });
let text = '';

let lines = fs.readFileSync(input).toString().split("\n");
for (const [i, line] of lines.entries()) {
	// zero page labels
	if (line.match(/U[0-9A-Fa-f]{4}/) !== null
	&& line.indexOf('byte.b') > 0) {
		let addr = line.substring(9, 13);
		let label = line.substring(28);
		label = label.split(' ')[0];
		text += 'R:'+addr+':'+label+"\n";
	}
	// program labels
	if (line.match(/\t\t\t\t   /g) !== null
	&& line[20] !== ' ' 
	&& line[20] !== "\t"
	//&& line[22] !== '.'
	&& !/eqm/i.test(line)) {
		let addr = parseInt(line.substring(9, 14), 16);
		addr -= 0x8000;
		addr = addr.toString(16).padStart(4, '0');
		let label = line.substring(20);
		label = label.split(' ')[0].replace(/^\./, '');
		text += 'P:'+addr+':'+label+"\n";
	}
}

fs.appendFileSync(output, text);
