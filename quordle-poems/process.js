const fs = require('fs');
const path = require('path');

function split_line(line, max_len = 28) {
	const words = line.split(/\s+/);  
	const chunks = [];
	let current = '';
	for (const word of words) {
		if ((current + ' ' + word).trim().length <= max_len) {
			current += (current ? ' ' : '') + word;
		}
		else {
			if (current) chunks.push(current);
			current = word.length <= max_len ? word : word.slice(0, max_len); 
		}
	}
	if (current) chunks.push(current);
	return chunks;
}

function format_block(lines) {
	const padded_lines = [];
	for (let i = 0; i < 4; i++) {
		const line = lines[i] || '';
		const withLeftPadding = '  ' + line;
		const fullLine = withLeftPadding.padEnd(32, ' ');
		padded_lines.push(fullLine);
	}
	return padded_lines.join('');
}



// Path to the input file
const filePath = path.join(__dirname, 'input.txt');


// Read file and split into lines
const file_content = fs.readFileSync('poems.txt', 'utf-8');
const lines = file_content.split(/\r?\n/);


// Filter out empty lines
const poems = lines.filter(line => line.trim() !== '');

console.log('number of poems: ' + poems.length);

let max_length = 0;
let counter = 0;
let formatted = [];
for (let i = 0; i < poems.length; i++) {
	let poem = poems[i].trim();
	if (poem.length > max_length) max_length = poem.length;
	if (poem.length > 64) console.log(i +': ' + poem + '(' + poem.length + ')');
	let format = split_line(poem);
	if (format.length > 3) console.log(split_line(poem));
	formatted.push(format);
	counter++;
}
console.log('max poem length: ' + max_length);
console.log('total poem count: ' + counter);


let blocks = [];

for (const poem of formatted) {
	const block = format_block(poem);
	console.log(block);
	const byte_array = Uint8Array.from(Buffer.from(block, 'ascii'));
	blocks.push(byte_array);
}

fs.writeFileSync('quordles.bin', Buffer.concat(blocks));
