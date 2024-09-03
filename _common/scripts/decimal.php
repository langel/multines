<?php

$out = "";

$arrs = [
	'zero_pad_10s' => [],
	'zero_pad_01s' => [],
	'space_pad_10s' => [],
	'space_pad_01s' => [],
];

$space = 0x3f;

function hex($val) {
	return str_pad(dechex($val), 2, '0', STR_PAD_LEFT);
}

for ($tens = 0; $tens < 10; $tens++) {
	for ($ones = 0; $ones < 10; $ones++) {
		$arrs['zero_pad_10s'][] = $tens;
		$arrs['zero_pad_01s'][] = $ones;
		if ($tens == 0) $arrs['space_pad_10s'][] = $space;
		else $arrs['space_pad_10s'][] = $tens;
		if ($tens == 0 && $ones == 0) $arrs['space_pad_01s'][] = $space;
		else $arrs['space_pad_01s'][] = $ones;
	}
}

foreach ($arrs as $table => $data) {
	$out .= $table."_table:";
	for ($i = 0; $i < 100; $i++) {
		if ($i % 10 == 0) $out .= "\n hex ";
		$out .= hex($data[$i]);
	}
	$out .= "\n\n";
	if ($table == 'zero_pad_01s') {
		$out .= " ds 56,\$ff";
		$out .= "\n\n";
	}
}

echo $out;

file_put_contents('decimals.asm', $out);
