const fs = require('fs');
const path = require('path');

const HEADER_SIZE = 0x10;
const TENS_OFFSET = 0xF6;
const ONES_OFFSET = 0xFB;
const TENS_PATCH_OFFSET = HEADER_SIZE + TENS_OFFSET;
const ONES_PATCH_OFFSET = HEADER_SIZE + ONES_OFFSET;
const TILE_BASE = 0x50;
const OUTPUT_COUNT = 256;

function usageAndExit() {
  console.error('Usage: node util/generate_hex_variants.js <source-file>');
  process.exit(1);
}

function toHexByte(value) {
  return value.toString(16).padStart(2, '0');
}

function toDecByte(value) {
  return value.toString(10).padStart(3, '0');
}

function main() {
  const sourceArg = process.argv[2];
  if (!sourceArg || process.argv.length > 3) {
    usageAndExit();
  }

  const sourcePath = path.resolve(sourceArg);
  if (!fs.existsSync(sourcePath)) {
    console.error(`Input file does not exist: ${sourcePath}`);
    process.exit(1);
  }

  const sourceBuffer = fs.readFileSync(sourcePath);
  if (sourceBuffer.length <= ONES_PATCH_OFFSET) {
    console.error(
      `Input file is too small (${sourceBuffer.length} bytes). Requires at least ${ONES_PATCH_OFFSET + 1} bytes.`
    );
    process.exit(1);
  }

  const parsed = path.parse(sourcePath);
  const outputDir = path.resolve(process.cwd(), 'output');
  fs.mkdirSync(outputDir, { recursive: true });

  for (let i = 0; i < OUTPUT_COUNT; i++) {
    const highNibble = (i >> 4) & 0x0f;
    const lowNibble = i & 0x0f;

    const patched = Buffer.from(sourceBuffer);
    patched[TENS_PATCH_OFFSET] = TILE_BASE + highNibble;
    patched[ONES_PATCH_OFFSET] = TILE_BASE + lowNibble;

    const decSuffix = toDecByte(i);
    const hexSuffix = toHexByte(i);
    const outName = `${parsed.name}_${decSuffix}_${hexSuffix}${parsed.ext}`;
    const outPath = path.join(outputDir, outName);
    // Remove any existing file first to avoid overwrite issues on Windows.
    fs.rmSync(outPath, { force: true });
    fs.writeFileSync(outPath, patched);
  }

  console.log(`Input: ${sourcePath}`);
  console.log(`Output directory: ${outputDir}`);
  console.log(`Generated files: ${OUTPUT_COUNT}`);
  console.log(`Header offset applied: 0x${HEADER_SIZE.toString(16)}`);
  console.log(
    `Offsets patched: 0x${TENS_PATCH_OFFSET.toString(16)} (tens), 0x${ONES_PATCH_OFFSET.toString(16)} (ones)`
  );
}

main();
