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



// Path to the input file
const filePath = path.join(__dirname, 'input.txt');


// Read file and split into lines
const file_content = fs.readFileSync('poems.txt', 'utf-8');
const lines = file_content.split(/\r?\n/);


// Filter out empty lines
const poems = lines.filter(line => line.trim() !== '');

console.log('number of poems: ' + poems.length);

let max_length = 0;
for (let i = 0; i < poems.length; i++) {
	let poem = poems[i].trim();
	if (poem.length > max_length) max_length = poem.length;
	if (poem.length > 64) console.log(i +': ' + poem + '(' + poem.length + ')');
	let formatted = split_line(poem);
	if (formatted.length > 3) console.log(split_line(poem));
}
console.log('max poem length: ' + max_length);


