# Desert Storm — Handoff Notes

Godot 4.7.2, `superchill/faceted_depths.gd` (single-file game), tests in `game_test.gd`.
This doc covers the DESERT STORM level and everything added around it in this work
session. Everything below is implemented and verified (`game_test: ok`).

## Run / verify

```
cd /home/inxeoz/Work/tries/superchill
timeout 15s godot --headless --path . -s game_test.gd       # exit 0 + "game_test: ok"
timeout 30s godot --path . --script res://capture_desert.gd # needs a real display; writes screenshots/
```

Screenshots exist at `screenshots/desert_storm_{blind,goggles,beacon}.png`.

## Where DESERT STORM sits

- Index 6 of 9 levels, right after SEND HELP MESSAGE (radio); the helicopter drops
  you into it, its exit leads to JUNGLE (index 7). Also pickable from the level select.
- Chain: RIVER RUN(0) -> 4 dungeons(1-4) -> radio(5) -> **desert(6)** -> jungle(7) -> night jungle(8) -> win.

## Level contents

- 30 x 18 sand arena; dunes + storm-dimmed sun in the background; wind streaks.
- 6 sparse trees, 16 stone boulders (solid), 5 skeleton bone piles (decor, walkable).
- Collectables (surface litter): `cloth` x6, `metal scrap` x4, `wine glass` x3.
- 3 material spirits (cloth, metal_scrap, wine_glass) that gate the DESERT GOGGLES recipe.
- Exit at (28,1), top-right; start at (1,16), bottom-left.

## Core mechanics

### Storm visibility
- `storm_darkness()`: 0.85 blind / 0.26 with goggles.
- `storm_visibility_radius()` = `STORM_VISIBILITY_BASE` (2.2 tiles) x `STORM_GOGGLE_BOOST` (3.0) with goggles.
- Overlay (`draw_storm_overlay`): NO full-screen tint. A hard clear hole around the
  player (radius = sight pool), then radial arc bands fade to full storm within ~155px.
  Wind streaks and background sand grains are skipped inside the hole.
- **Spirits burn beacons through the storm** (drawn on top of the overlay) so they are
  always findable: pulsing accent glow + bright core.

### Gate storm (guards the exit)
- A fixed lethal band just before the exit: `STORM_GATE_MIN (24,1)` .. `STORM_GATE_MAX
  (28,5)`. The exit cell (28,1) sits inside it.
- `in_gate_storm(pos)` / `gate_storm_blind()` (in zone + no goggles).
- Blind inside it: `storm_visibility_radius()` -> 0 (total blackout, `draw_storm_overlay`
  fills the viewport), and any hyena bite calls `storm_slay()` = instant death. The
  goggles are the only way through.
- The band is drawn as a denser wall of sand even with goggles (passable, still visible).
- The STORM VISION HUD plaque switches its footer to a gate-storm warning in the zone.

### Desert Goggles
- Recipe id `desert_goggles`: `cloth` x2 + `metal scrap` x1 + `wine glass` x1.
- Gated by the three material spirits via `MATERIAL_IDEAS` / `MATERIAL_SPIRITS`
  (pattern shared with the night-jungle flint/wood/leaves spirits).
- Craft -> `has_desert_goggles = true`. Passive/worn on the face (drawn on the player),
  NOT main gear, NOT droppable. Sword stays active so you can fight.
- Without goggles:
  - Sight pool is tiny (2.2 tiles); a hyena inside the pool is revealed and
    fightable (`hyena_revealed()` = distance <= pool, goggles NOT required).
    Hyenas outside the pool stay hidden in the storm.
  - A revealed hyena is a normal fight: sword (3 HP), and its bite is 1 wound.
  - A swing at a still-hidden (out-of-pool) hyena passes through it.
- With goggles: the pool triples, so hyenas are revealed from much farther and
  stay fightable (3 HP, sword); bites are normal 1-damage wounds.

### Hyena AI (6 hyenas)
- Spawned >= 6 tiles from the start: (2,2) (12,1) (27,4) (26,9) (5,2) (24,12).
- Three states, per-enemy `mode`/`chase` fields:
  1. **Roam**: drift to random nearby walkable spots (`hyena_roam_target`) at 0.7 t/s.
  2. **Detect**: player enters `HYENA_SNIFF_RANGE` (6.5 tiles) -> mode flips to `hunt`.
  3. **Hunt**: follow via BFS `flow`; speed = `enemy.speed` (1.0) x (1 + 1.2 x chase).
- Chase meter (0..1): builds while the player **lingers** (`player_linger`, 0->6s
  standing, drains at 2x while moving). Brief pauses keep them at follower pace;
  staying ~1.5s+ ramps aggression up to 3.0/s chase build (full rush at 6s standing).
  Moving again, bites, and blocked paths bleed chase off. Dust streaks draw at chase > 0.5.
- `update_enemies()` runs on the desert even though it is a surface level (added to `_process`),
  which was a real bug before: hyenas were frozen statues in actual play.
- Art: animated 4-leg trot (thick lines — polygon legs degenerated and crashed
  triangulation at some gaits), raised tufted tail, mane ridge, flank spots, open-jaw
  snout, amber eyes.

## Files touched this session

- `faceted_depths.gd` — level entry, items (`cloth`/`metal scrap`/`wine glass`), recipe,
  material spirits, storm overlay + desert atmosphere, goggles, hyena AI + art,
  stones/skeletons, HUD storm plaque, level-select row, test hooks.
- `game_test.gd` — `validate_desert_level()` + dispatch, hyena linger/chase/reveal/spawn checks.
- `capture_desert.gd` (new, untracked) — screenshot helper used for visual verification.
- `screenshots/desert_storm_*.png` (new, untracked).

## Known notes / possible follow-ups

- `draw_night_overlay()` (night jungle) centers its light pool at `iso_to_screen(player_position)`.
  The desert overlay instead uses `CAMERA_PIVOT + camera_offset + screen_shake + iso_to_screen(...) * camera_zoom`
  which is the actual on-screen player position. The night-jungle pool may be drawn at
  the wrong place on screen — pre-existing, not touched this session.
- A revealed hyena draws a pulsing danger halo (spirit-beacon style) so the
  fight reads clearly through the storm. Ordinary bites are wounds: the player can
  win or die. The only exception is inside the gate storm while blind, where a bite
  is the lethal `storm_slay()` (see "Gate storm").
- Blind play is intentionally brutal (hidden pack outside the small pool). Balance knobs:
  `HUNT_LINGER_TIME`, `HYENA_SNIFF_RANGE`, `HYENA_ROAM_SPEED`, chase ramp/factor, hyena count.
- Hyenas roam into walls can briefly stall (new roam target only re-picked on arrival);
  acceptable with sparse boulders.
- PRODUCT.md / DESIGN.md still describe the old 5-level run; level count wording is stale.
- No new SFX for the storm/goggles; reused existing streams (spirit, pickups, lose).
