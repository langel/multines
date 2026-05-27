# RAM Page `$0100-$01FF` Audit

This document summarizes all known uses of CPU RAM page `$0100` across the repository.

## Scope and Method

- Searched for explicit page-1 literals in assembly:
  - `\$01[0-9a-fA-F]{2}`
  - `\$1[0-9a-fA-F]{2}` (captures forms like `$142`)
- Reviewed stack-related opcodes in assembly:
  - `pha`, `pla`, `php`, `plp`, `tsx`, `txs`
- Excluded non-RAM false positives such as `org $010000` ROM addressing and comments/docs.

## Sequential `$0100-$01FF` Map (by RAM address)

- `$0100-$01ff` - CPU stack page (implicit)
  - Called/used by all `JSR/RTS/RTI`, IRQ/NMI entry, and explicit `PHA/PLA/PHP/PLP/TSX/TXS`.

- `$0100` / `$0100,y` / `$0100,x`
  - `_common/definitions.asm` macro `PUSHY` writes queue bytes to `$0100,y`.
  - `chomp-champ/src/game/render.asm` calls that macro and also writes queue control/terminator at `$0100...`.
  - `quordle-poems/vectors.asm` RAM-clear loop writes `$0100,x` (with stack-top skip guard).

- `$0120+offset`
  - `_common/definitions.asm` macro `state_char_equip_anim_popslider` reads `$0120 + ...`.
  - Used by projects including `quordle-poems` via shared macro include.

- `$0142`, `$0146`, `$014a`
  - `_common/lib/apu_engine.asm` direct `inc` writes in `apu_bend_down`.

- `$0160-$0173` (APU cache window)
  - `_common/lib/apu_engine.asm` defines `apu_cache = $0160`.
  - `apu_init` writes the full cached register block (`$0160 + y`, `y=0..$13`).
  - `apu_update` and related audio routines read/write indexed `apu_cache+...`.

- `$0188`
  - `chomp-champ/src/game/player.asm` writes `floss_status` mirror/debug value.

- `$0190-$0191`
  - `chomp-champ/src/game/hud.asm` variables:
    - `$0190` `hud_tooth_addr`
    - `$0191` `hud_tooth_tile`

- `$01a0-$01af`
  - `_common/lib/nametable.asm` pattern data buffer scratch.
  - Used by `pattern_to_nametable` and `pattern_row_to_nametable`.

- `$01c0-$01cf`
  - `_common/lib/nametable.asm` pattern pointer/data scratch.
  - Used by `pattern_to_nametable` and `pattern_row_to_nametable`.

- `$01d0-$01d2`
  - `_common/lib/nametable.asm` row decode temp scratch.
  - Used by `pattern_row_to_nametable` and `metapattern_to_nametable_8x16`.

- `$01e0-$01e1`
  - `chomp-champ/src/memory_map.asm` variables:
    - `$01e0` `game_level`
    - `$01e1` `continues`

## A) Explicit RAM Page `$0100-$01FF` Usage

### 1) Shared/Common Code

- `_common/lib/nametable.asm`
  - Uses page-1 scratch/work buffers for pattern decode and row expansion.
  - Active addresses include:
    - `$01a0-$01af` (pattern data buffer region)
    - `$01c0-$01cf` (pattern pointer/data scratch)
    - `$01d0-$01d2` (row/tile temp scratch)
  - Used by:
    - `pattern_to_nametable`
    - `pattern_row_to_nametable`
    - `metapattern_to_nametable_8x16`

- `_common/lib/apu_engine.asm`
  - Defines APU shadow/cache base:
    - `apu_cache = $0160`
  - Also has direct increments at:
    - `$0142`, `$0146`, `$014a`
  - These are all page-1 RAM writes.

- `_common/definitions.asm` (macros)
  - `PUSHY` macro writes to `$0100,y`.
  - `state_char_equip_anim_popslider` reads from `$0120 + ...`.
  - These are explicit page-1 RAM accesses used by consumers of the macros.

### 2) `chomp-champ`

- `chomp-champ/src/game/render.asm`
  - Uses `$0100` page as a render command/queue buffer (`$0100,y`), including terminator write.
  - Also initializes/reset pointer/control via `$0100`.
  - Heavy user of `PUSHY` flow from `_common/definitions.asm`.

- `chomp-champ/src/game/player.asm`
  - Writes `floss_status` mirror/debug value to `$0188`.

- `chomp-champ/src/game/hud.asm`
  - Defines HUD vars in page-1:
    - `hud_tooth_addr = $0190`
    - `hud_tooth_tile = $0191`

- `chomp-champ/src/memory_map.asm`
  - Defines game state values in page-1:
    - `game_level = $01e0`
    - `continues = $01e1`

### 3) `quordle-poems`

- `quordle-poems/vectors.asm`
  - RAM clear loop writes to `$0100,x` (with intentional skip behavior near stack top).

- `quordle-poems/definitions.asm`
  - Same macro-level page-1 usage as noted in `_common/definitions.asm`:
    - `$0100,y` and `$0120+...` patterns.

## B) Implicit Stack-Page Usage (CPU Stack on `$0100-$01FF`)

Even when not explicitly addressing `$01xx`, the 6502 stack always resides on page `$0100`.

- Global implicit users:
  - `JSR/RTS`
  - `RTI` (interrupt return)
  - NMI/IRQ entry (CPU push behavior)
  - `PHA/PLA`, `PHP/PLP`, `TSX/TXS`

### Manual stack-opcode occurrences (assembly grep summary)

- `_common/lib/dict_text.asm`: 10
- `chomp-champ/src/game/render.asm`: 14
- `_common/definitions.asm`: 8
- `_common/lib/nmi.asm`: 2
- `quordle-poems/vectors.asm`: 3
- `quordle-poems/definitions.asm`: 8

Note: this count does not include implicit stack activity from `JSR/RTS/RTI` and interrupt entry/exit.

## C) Not RAM Page-1 (False Positives)

These matched textual searches but are not CPU RAM page `$0100-$01FF` allocations:

- `org $010000` in multiple `main.asm` files (ROM address space, not CPU RAM page 1).
- Comments/docs mentioning `$01xx` (for example `_common/lib/apu.md`).
- Comment-only references like `<= $01f0` where no page-1 read/write occurs.

## Quick Risk Notes

- `_common/lib/nametable.asm` intentionally uses page-1 scratch buffers. Any future stack-heavy code around these routines should avoid overlapping assumptions.
- `chomp-champ/src/game/render.asm` uses `$0100` as a software queue while the CPU stack also lives on page-1; this is valid but timing/stack depth should remain controlled.
- `quordle-poems/vectors.asm` deliberately writes page-1 during RAM clear with stack-top exceptions; this behavior should be preserved if refactored.
