const fs = require('fs');
const path = require('path');

const header_size = 0x10;
const prg_size = 0x8000;
const chr_size = 0x2000;
const chr_repeat_count = 8;
const tens_offset = 0x24d;
const ones_offset = 0x252;
const tens_patch_offset = header_size + tens_offset;
const ones_patch_offset = header_size + ones_offset;
const tile_base = 0x50;
const output_count = 256;
const minimum_rom_size = header_size + prg_size + chr_size;

function usage_and_exit() {
  console.error('Usage: node util/generate_hex_variants.js <source-file>');
  process.exit(1);
}

function to_hex_byte(value) {
  return value.toString(16).padStart(2, '0');
}

function to_dec_byte(value) {
  return value.toString(10).padStart(3, '0');
}

function repeat_buffer(buffer, count) {
  return Buffer.concat(Array.from({ length: count }, () => buffer));
}

function main() {
  const source_arg = process.argv[2];
  if (!source_arg || process.argv.length > 3) {
    usage_and_exit();
  }

  const source_path = path.resolve(source_arg);
  if (!fs.existsSync(source_path)) {
    console.error(`Input file does not exist: ${source_path}`);
    process.exit(1);
  }

  const source_buffer = fs.readFileSync(source_path);
  const minimum_required_size = Math.max(ones_patch_offset + 1, minimum_rom_size);
  if (source_buffer.length < minimum_required_size) {
    console.error(
      `Input file is too small (${source_buffer.length} bytes). Requires at least ${minimum_required_size} bytes.`
    );
    process.exit(1);
  }

  const parsed_source = path.parse(source_path);
  const output_dir = path.resolve(process.cwd(), 'output');
  const roms_output_dir = path.join(output_dir, 'roms');
  fs.mkdirSync(output_dir, { recursive: true });
  fs.mkdirSync(roms_output_dir, { recursive: true });

  const chr_x8_path = path.join(output_dir, 'CHRx8.bin');
  let chr_x8_size = 0;

  for (let i = 0; i < output_count; i++) {
    const high_nibble = (i >> 4) & 0x0f;
    const low_nibble = i & 0x0f;

    const patched_buffer = Buffer.from(source_buffer);
    patched_buffer[tens_patch_offset] = tile_base + high_nibble;
    patched_buffer[ones_patch_offset] = tile_base + low_nibble;

    const header_start = 0;
    const header_end = header_start + header_size;
    const prg_start = header_end;
    const prg_end = prg_start + prg_size;
    const chr_start = prg_end;
    const chr_end = chr_start + chr_size;
    const header_slice = patched_buffer.subarray(header_start, header_end);
    const prg_slice = patched_buffer.subarray(prg_start, prg_end);
    const chr_slice = patched_buffer.subarray(chr_start, chr_end);
    if (header_slice.length !== header_size) {
      console.error('Unexpected header split length.');
      process.exit(1);
    }

    const dec_suffix = to_dec_byte(i);
    const hex_suffix = to_hex_byte(i);
    const variant_stem = `${parsed_source.name}_${dec_suffix}_${hex_suffix}`;
    const rom_name = `${variant_stem}${parsed_source.ext}`;
    const rom_path = path.join(roms_output_dir, rom_name);
    // Remove any existing file first to avoid overwrite issues on Windows.
    fs.rmSync(rom_path, { force: true });
    fs.writeFileSync(rom_path, patched_buffer);

    const prg_x2 = repeat_buffer(prg_slice, 2);
    const prg_x2_name = `${variant_stem}_prgx2.bin`;
    const prg_x2_path = path.join(output_dir, prg_x2_name);
    fs.rmSync(prg_x2_path, { force: true });
    fs.writeFileSync(prg_x2_path, prg_x2);

    if (i === 0) {
      const chr_x8 = repeat_buffer(chr_slice, chr_repeat_count);
      fs.rmSync(chr_x8_path, { force: true });
      fs.writeFileSync(chr_x8_path, chr_x8);
      chr_x8_size = chr_x8.length;
    }
  }

  console.log(`Input: ${source_path}`);
  console.log(`ROM output directory: ${roms_output_dir}`);
  console.log(`PRG output directory: ${output_dir}`);
  console.log(`Generated ROM files: ${output_count}`);
  console.log(`Generated PRG x2 files: ${output_count}`);
  console.log(`Generated CHR x8 file: ${chr_x8_path} (${chr_x8_size} bytes)`);
  console.log(`Header offset applied: 0x${header_size.toString(16)}`);
  console.log(
    `Offsets patched: 0x${tens_patch_offset.toString(16)} (tens), 0x${ones_patch_offset.toString(16)} (ones)`
  );
}

main();
