# APU Engine Notes

This documents how the audio system works across:

- `_common/lib/apu_engine.asm`
- `_common/lib/apu_sfx.asm`

## High-level model

The engine is split into two layers:

- `apu_engine.asm`: persistent frame mixer and channel state machine
- `apu_sfx.asm`: trigger routines and optional per-frame SFX updaters

Per frame, the game should call:

1. `apu_update`
2. game logic continues

At startup/reset, call:

1. `apu_init`

## Channel ownership

Current intended ownership in comments/code:

- Pulse 1: music/system tone usage
- Pulse 2: SFX-heavy channel
- Triangle: music tone support
- Noise: SFX-heavy channel

SFX are designed to use Pulse 2 + Noise where possible. Some SFX intentionally write Pulse 1 directly.

## State storage

### Hardware cache

- `apu_cache = $0160`
- Mirrors key APU register values before writing them to `$4000+`.
- `apu_update` copies part of this cache to hardware every frame.

Important cache offsets used by the engine/SFX:

- `apu_cache+$0 .. +$7`: pulse register blocks
- `apu_cache+$a`: triangle timer low
- `apu_cache+$c`: noise volume/envelope
- `apu_cache+$e`: noise period

### Zero-page control state

Defined in `_common/zero_page.asm`:

- Channel counters: `apu_pu1_counter`, `apu_pu2_counter`, `apu_tri_counter`, `apu_noi_counter`
- Envelope selectors: `apu_pu1_envelope`, `apu_pu2_envelope`, `apu_noi_envelope`
- Last-hi suppression: `apu_pu1_last_hi`, `apu_pu2_last_hi`
- SFX scheduler fields: `sfx_pu2_update_type`, `sfx_noi_update_type`
- SFX local temp vars: `sfx_temp00..sfx_temp03`
- Pitch helpers: `audio_root_tone`, `pitch_mod_lo`, `pitch_mod_hi` (hi currently mostly unused)

## `apu_init`

`apu_init` performs:

- Initializes `$4000..$4013` from `apu_init_register_values`
- Initializes `apu_cache` to the same defaults
- Writes:
  - `$4015 = $0f` (channel enable mask)
  - `$4017 = $40` (frame counter mode)
- Clears active updater IDs:
  - `sfx_pu2_update_type = 0`
  - `sfx_noi_update_type = 0`
- Seeds APU-local RNG bytes:
  - `apu_rng0 = $11`
  - `apu_rng1 = $7f`

## Pitch and envelopes

### Pitch lookup

- `apu_set_pitch` uses `periodTableLo/Hi`
- Inputs:
  - `X = pitch index`
  - `Y = channel timer offset` (`$02` pulse1, `$06` pulse2, `$0a` triangle)
- Writes timer bytes into `apu_cache`

It also resets pulse hi compare sentinels (`apu_pu1_last_hi`, `apu_pu2_last_hi`) so timer high writes retrigger correctly.

### Envelope dispatch

- `apu_env_run` dispatches using envelope ID in `apu_pu1_envelope,x`
- Envelope function pointer tables:
  - `apu_env_table_lo`
  - `apu_env_table_hi`
- Returns a 4-bit volume in `A`

Envelope shapes include linear and exponential variants (`lin_long`, `lin_tiny`, `exp_*`).

## `apu_update` frame pipeline

`apu_update` does the following in order:

1. Run SFX updater delegators:
   - `sfx_update_delegator(sfx_pu2_update_type)`
   - `sfx_update_delegator(sfx_noi_update_type)`
2. Update pulse channels (loop for pulse1 then pulse2):
   - decrement counter
   - if expired, silence volume register
   - else run envelope and write pulse registers
3. Update triangle channel via `apu_tri_counter`
4. Update noise channel via `apu_noi_counter` + noise envelope
5. Copy selected cached bytes to APU registers (`$400b` block copy loop)
6. Advance APU-local RNG (`apu_rng0`, `apu_rng1`)
7. Decrement SFX masking counters (`sfx_pu1_counter..sfx_noi_counter`)

## SFX trigger/update architecture

### One-shot trigger table

`sfx_init_table_lo/hi` maps SFX IDs to trigger routines, e.g.:

- `sfx_player_damage`
- `sfx_enemy_death`
- `sfx_brush_up`
- `sfx_phase_next`

These routines typically:

- write immediate register/cache values
- set counters/envelopes
- optionally install a per-frame updater by setting:
  - `sfx_pu2_update_type`
  - `sfx_noi_update_type`

### Per-frame updater table

`sfx_update_table_lo/hi` maps updater IDs to routines, e.g.:

- `sfx_player_death_update`
- `sfx_enemy_death_update`
- `sfx_powerup_battery_update`
- `sfx_tingler_update`
- `sfx_brush_up_update`

Stopping an updater:

- Pulse2 path: set `sfx_pu2_update_type = 0` (`sfx_pu2_update_stop`)
- Noise path: set noise silent (`apu_cache+$c = $10`) and `sfx_noi_update_type = 0` (`sfx_noi_update_stop` / `sfx_noi_update_clear`)

## Practical usage

### Startup

- Call `apu_init` once after reset/new-game audio reset.

### Triggering an SFX

Typical pattern:

1. Load desired SFX ID
2. Index into `sfx_init_table_lo/hi`
3. `jmp (temp00)` into trigger routine

Some game code writes updater IDs directly for immediate behaviors (for example brush movement sounds).

### Per-frame

- Ensure `apu_update` runs once each frame (normally from update/NMI flow depending on project timing).

## Gotchas and constraints

- `apu_env_run` depends on current ZP variable ordering (comments in `zero_page.asm` note this).
- Many SFX write hardware registers directly (`$4004..$4007`) while others use `apu_cache`; mixed style is intentional but easy to misuse.
- `pitch_mod_hi` is defined but not fully integrated in some channel math (comments note TODOs).
- If a sound appears "stuck", check updater IDs first (`sfx_pu2_update_type`, `sfx_noi_update_type`).

## Add New SFX (quick guide)

Use this checklist when adding a new sound effect.

### 1) Pick channel strategy first

Decide which channel(s) the sound owns:

- preferred: Pulse 2 and/or Noise
- optional: Pulse 1 only for special moments

Also decide if it is:

- one-shot only (single trigger write), or
- multi-frame (needs updater state over several frames)

### 2) Add the trigger routine in `apu_sfx.asm`

Create `sfx_<name>:` that does initial setup:

- sets pulse/noise regs (direct `$400x`) or `apu_cache` values
- sets envelope/counter fields (`apu_*_counter`, `apu_*_envelope`) as needed
- if multi-frame, sets updater ID:
  - `sfx_pu2_update_type = <id>` and/or
  - `sfx_noi_update_type = <id>`

Prefer ending with `rts`.

### 3) Register trigger in init tables

Append your trigger to both:

- `sfx_init_table_lo`
- `sfx_init_table_hi`

Keep LO/HI table ordering identical.

### 4) Add updater routine only if needed

If the sound evolves over time:

- implement `sfx_<name>_update:`
- consume `sfx_temp00..sfx_temp03` for local sequencing state
- clear updater ID when done:
  - `sta sfx_pu2_update_type` with `#0`, or
  - use `sfx_noi_update_clear`/`sfx_noi_update_stop`

Then register updater in:

- `sfx_update_table_lo`
- `sfx_update_table_hi`

Again, keep LO/HI ordering aligned.

### 5) Add ID constant(s)

If your code refers to symbolic updater IDs, add/update the `sfx_*_id` constants near the update table section.

### 6) Trigger from game code

From gameplay code, call your SFX trigger via your project’s SFX dispatch path (or direct routine call if that is the local pattern).

For repeating actions, gate re-triggering with `sfx_pu2_counter`/`sfx_noi_counter` so sounds do not restart every frame.

### 7) Quick validation checklist

- Sound starts on expected event.
- Sound stops cleanly (no stuck updater ID).
- No unintended channel stealing from other active sounds.
- Rapid retrigger behavior is acceptable.
- Transition to title/gameover/demo does not leave stale SFX state.

