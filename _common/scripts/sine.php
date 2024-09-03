<?php

const TAU = 2 * M_PI;

$out = "";

function hex($val) {
	return str_pad(dechex($val), 2, '0', STR_PAD_LEFT);
}

for ($i = 0; $i < 8; $i++) {
	$table = "";
	$max = 1 << $i;
	$table .= "sine_table_bit_" .($i+1). ":";
	for ($j = 0; $j < 256; $j++) {
		if ($j % 32 == 0) $table .= "\n hex ";
		$val = round((sin(($j / 255) * TAU - M_PI * 0.5) * 0.5 + 0.5) * $max);
		$table .= hex($val);
	}
	$table .= "\n\n";
	$out .= $table;
}
	
$out .= "sine_table:";
for ($j = 0; $j < 256; $j++) {
	if ($j % 32 == 0) $out .= "\n hex ";
	$val = round((sin(($j / 255) * TAU - M_PI * 0.5) * 0.5 + 0.5) * 255);
	$out .= hex($val);
}

echo $out;

file_put_contents('sine_tables.asm', $out);
