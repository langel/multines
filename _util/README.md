## Dictionary Text Pipeline

- Config: `_util/dict_config.json`
- Processor: `_util/dict_process.js`
- Example per-game input: `chomp-champ/util/text_dict_input.json`

Run from repo root:

`node _util/dict_process.js`

Outputs:

- Master dictionary asm: `_common/generated/dictionary.asm`
- Per-game encoded text asm: `<game>/src/generated/dict_text.asm`

Config notes:

- `games` is a simple directory list (for example `["chomp-champ", "star-dodger"]`).
- `gameInputFile` and `gameOutputFile` are shared paths under each game directory.
- If a game input file is missing, the processor auto-creates a template input JSON.
- Output directories are auto-created when writing generated asm files.

Rules enforced by the processor:

- Per-game alphabet pattern ids cannot use `$80-$ff`.
- New line byte is `$f0`, end-of-passage byte is `$f1`.
- Dictionary is limited to a 4KB window starting at configured base address.
