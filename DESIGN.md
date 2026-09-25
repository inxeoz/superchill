---
name: "Faceted Depths"
description: "A compact isometric dungeon carved from living gemstone."
colors:
  void: "#060914"
  cavern: "#0B1020"
  ink: "#111629"
  ink-soft: "#1B2238"
  wall-top: "#202840"
  slate: "#26334D"
  slate-light: "#364765"
  floor-mist: "#303A54"
  floor-petrol: "#294654"
  floor-plum: "#40344F"
  amethyst: "#6E4B8B"
  teal: "#2A7D7B"
  amber: "#F0AD4E"
  cyan: "#6DE5DF"
  oxblood: "#C04A5D"
  gate-mauve: "#6B5268"
  paper: "#E8EDF5"
  muted: "#9AA8BD"
  facet-edge: "#0A0D18"
  plaque-ink: "rgba(6.375, 10.2, 19.125, 0.94)"
typography:
  display:
    fontFamily: "DejaVu Sans, sans-serif"
    fontSize: "42px"
    fontWeight: 400
  title:
    fontFamily: "DejaVu Sans, sans-serif"
    fontSize: "30px"
    fontWeight: 400
  body:
    fontFamily: "DejaVu Sans, sans-serif"
    fontSize: "18px"
    fontWeight: 400
  label:
    fontFamily: "DejaVu Sans, sans-serif"
    fontSize: "15px"
    fontWeight: 400
  caption:
    fontFamily: "DejaVu Sans, sans-serif"
    fontSize: "13px"
    fontWeight: 400
rounded:
  hard: "0px"
  icon: "20px"
spacing:
  hud-top: "24px"
  hud-edge: "30px"
  plaque-inset: "18–20px"
  message-inset: "22px"
components:
  plaque-objective:
    backgroundColor: "{colors.plaque-ink}"
    textColor: "{colors.paper}"
    rounded: "{rounded.hard}"
    padding: "20px"
    width: "330px"
    height: "76px"
  plaque-shards:
    backgroundColor: "{colors.plaque-ink}"
    textColor: "{colors.muted}"
    rounded: "{rounded.hard}"
    padding: "18px"
    width: "214px"
    height: "76px"
  plaque-vitality:
    backgroundColor: "{colors.plaque-ink}"
    textColor: "{colors.muted}"
    rounded: "{rounded.hard}"
    padding: "18px"
    width: "280px"
    height: "54px"
  plaque-controls:
    backgroundColor: "{colors.plaque-ink}"
    textColor: "{colors.muted}"
    rounded: "{rounded.hard}"
    padding: "19px"
    height: "30px"
  message-plaque:
    backgroundColor: "rgba(8.925, 14.025, 24.225, 0.92)"
    textColor: "{colors.paper}"
    rounded: "{rounded.hard}"
    padding: "22px"
    height: "42px"
  state-overlay:
    backgroundColor: "rgba(3.825, 5.1, 11.475, 0.82)"
    textColor: "{colors.paper}"
    rounded: "{rounded.hard}"
    size: "viewport"
  icon-crystal:
    backgroundColor: "{colors.void}"
    rounded: "{rounded.icon}"
    size: "128px"
---

# Design System: Faceted Depths

## Overview

**Creative North Star: "Faceted Depths"**

Faceted Depths presents the dungeon as a living cut gemstone. Deep ink caverns frame a low, jewel-toned isometric field whose floor planes, walls, crystals, gate, and HUD plaques are built from hard polygons rather than conventional interface chrome.

The room stays quiet and readable while semantic light supplies the drama: amber marks action, cyan marks safety and progress, and oxblood marks danger. Every entity, including the player, is drawn from script as hard faceted polygons aligned to the same NE/SE/SW/NW facing grammar; there is no raster sprite exception now.

The run opens on Level 0, River Run: a bright outdoor riverbank where bottle sources, leaves, flowing water, and a flotation jacket replace the dungeon objective. It then moves through four authored depths: Faceted Depths, Mossglass Cistern, Ember Vault, and Starfall Reliquary. Each depth changes the mineral palette, map topology, enemy silhouette, movement speed, and health profile while preserving the same shard-and-gate objective.

**Key Characteristics:**
- A 2:1 isometric world with 96 × 48 px floor diamonds and split light/shadow facets.
- Whole-pixel phosphor movement quantized to 2 px screen-space steps.
- Square ink plaques with one bright top rule and one dim bottom rule.
- Strict semantic color, sparse saturated accents, and a crystalline app icon.

## Colors

The dungeon palette is predominantly blue-black mineral neutrals with three functional jewel signals and restrained teal, amethyst, and plum mineral variation. Level 0 opens those same roles into daylight blue, grass green, river cyan, and warm sun amber; later depths rotate the signal roles into green, ember, and astral palettes.

### Primary
- **Action Amber:** Player weapon accents, strike arcs, the objective plaque rule, and active attack feedback.
- **Safety Cyan:** Shards, collected markers, recovery bursts, transient-message rules, and the gate only after all three shards are secured.
- **Danger Oxblood:** Enemy bodies, vitality markers, damage bursts, loss state, and sealed-gate bars.

### Secondary
- **Petrol Mineral, Plum Mineral, Teal, and Amethyst:** Low-chroma floor variation and icon facets; they establish material variety without becoming extra status signals.

### Neutral
- **Void, Cavern, Ink, and Plaque Ink:** The background stack, wall faces, plaque fill, and darkest separation layer.
- **Ink Soft, Wall Top, Slate, Slate Light, and Floor Mist:** Alternating wall tops, floor bases, the control-plaque rule, and low-contrast mineral structure.
- **Facet Edge:** Near-black polygon seams that keep adjacent planes crisp.
- **Paper and Muted:** Primary HUD text and secondary labels, respectively.

**The Semantic Mineral Rule.** Amber means action, cyan means safety or progress, and oxblood means danger; jewel hues are signals before decoration.

## Typography

**Display Font:** DejaVu Sans (with `sans-serif` fallback)  
**Body Font:** DejaVu Sans (with `sans-serif` fallback)  
**Label/Mono Font:** No separate family

**Character:** Crisp, neutral system lettering sits inside an angular fantasy world. The game uses one family, regular weight, single-line strings, and no authored tracking or line height.

### Hierarchy
- **Display** (400, 42 px, uppercase): Win/loss titles only.
- **Title** (400, 30 px, uppercase): The `FACETED DEPTHS` identity plaque.
- **Body** (400, 18 px, sentence case): Centered transient messages; the end-state subtitle uses 17 px.
- **Label** (400, 14–15 px, uppercase): Shard and vitality labels plus the objective line.
- **Caption** (400, 13 px, uppercase): Keyboard controls and compact state copy.

Godot's nearest texture filter preserves hard pixel edges across raster sprites and rendered text. Do not introduce a decorative fantasy face or a second monospaced voice.

**The Signal Carries Hierarchy Rule.** Separate type with size, case, and semantic color; do not add weight, tracking, gradients, or outlines.

## Layout

The design baseline is a 1280 × 720 landscape canvas using Godot's `canvas_items` stretch with `keep` aspect. The fixed edge grammar remains anchored to the live viewport.

The 12 × 9 rooms project from `(640, 248)`; Level 00 widens to an open 16 × 11 field in the same projection. Level 00 keeps the warrior on the near riverbank under open sky, with a vertical water channel dividing the bottle-gathering side from the dungeon exit, and litter — leaves, plastic wrappers, rope coils, wood scraps, and coiled springs — scattered for pickup on both banks. Each dungeon keeps the warrior near the lower-left field and the gate on the right, while its authored wall layout changes the route. Tiles are 96 px wide by 48 px high; dungeon walls rise 58 px, outdoor hedge walls cap at 32 px, and Level 00 uses one continuous 16 px perimeter border at every camera angle. The top-left plaque identifies `LEVEL 00 / 05`, then `DEPTH 01 / 04` through `DEPTH 04 / 04`.

HUD plaques stay at the perimeter: 30 px from the left, right, and bottom edges, and 24 px from the top. Transient messages center at `y = 108`; the keyboard plaque sizes to its content plus 38 px. Camera pan, zoom, and yaw affect the world projection around the player; the HUD remains fixed. Yaw changes the ground-plane viewpoint, not a flat rotation of the finished map.

## Elevation & Depth

This world uses tonal layering and painter ordering, not blurred interface shadows. Rendering proceeds as void, cavern atmosphere and dust or open-sky atmosphere, floor facets and water, low front boundary, depth-sorted walls, sources, and entities, transient effects, then HUD.

Walls, bottle sources, shards, gate or cave exit, player, and enemies share one list sorted by ascending projected screen Y. Lower objects therefore draw later and occlude upper objects; depth must not be assigned by entity type. Projected positions round to 2 px increments before drawing, then pass through the movable 2.5D camera transform.

Contact shadows are flattened diamonds beneath shards, the player, and enemies. Plaques use a hard black rectangle offset by 5 × 7 px. There are no soft or diffuse shadow treatments.

**The Facet Before Shadow Rule.** Establish depth with split planes and painter order; use only hard offsets and contact diamonds for shadow.

## Shapes

The recurring silhouette is a sharp 2:1 diamond. Every floor diamond is divided into two triangular facets, and wall tops repeat the same split. Wall outlines are 1–1.5 px near-black strokes with no anti-aliased softness.

Crystals use a vertically stretched four-point kite with side points at 72% of the vertical radius, a darker lower half, a 1.5 px light rim, and a center seam. The player is the original Tiny Questers warrior recreated procedurally. Its 64 × 64 pixel frames (4 facings × 4 walk frames, plus a sword sprite per facing) are baked into `PLAYER_PIXELS` as a shared 27-colour palette and compact pixel grids; each opaque pixel is drawn as a 2 × 2 rect at the sprite's original screen anchor, with transparent-boundary pixels feathered (anti-aliased) so the silhouette reads smooth and HD rather than hard-stepped — and no PNG is loaded at runtime. The character animates through four states: walk (4-frame cycle), run (Shift, faster cycle + forward lean), jump (Space on the surface, a parabola hop that keeps the shadow grounded), and hurt (recoil shake + red flash during invulnerability). The 128 × 128 app icon is a faceted cryst The 128 × 128 app icon is a faceted crystal on a void field with a 20 px rounded-square container and 4 px paper-colored crystal seams; it is the only rounded container in the system.

Curves are reserved for tiny dust motes, crystal eyes, gate pulses, and attack arcs. Plaques, floors, walls, markers, crystals, and the gate otherwise use straight polygon edges and zero corner radius.

## Components

All visible components are custom-drawn Godot geometry in `faceted_depths.gd`; there is no widget library, HTML control layer, hover state, or browser-only navigation. The keyboard guide is a passive plaque, not an interactive control.

### Plaques
- **Shared grammar:** `rgba(6.375, 10.2, 19.125, 0.94)` fill, square corners, 5 × 7 px black shadow at 25% alpha, 2 px semantic top rule, and 1 px bottom rule at 28% accent alpha.
- **Objective:** 330 × 76 px at `(30, 24)`; 30 px paper title above a 15 px amber objective.
- **Shards:** 214 × 76 px at the top-right; 14 px muted label and three 13 px-radius diamonds spaced 58 px apart. Collected markers are cyan; missing markers are muted at 25% alpha.
- **Bottles:** The same top-right footprint on Level 0, stretched taller with a third row; a faceted bottle icon and count occupy the left half, jacket readiness or remaining bottles occupies the right, and a leaf icon with the running total item count (bottles included) sits on the bottom row.
- **Vitality:** 280 × 54 px at bottom-left; 14 px muted label and five 10 px-radius diamonds spaced 29 px apart. Active markers are oxblood; lost markers are muted at 20% alpha.
- **Controls:** Content-fit, 30 px high, 19 px inset, slate-light top rule, and 13 px muted uppercase copy.

### Level Select
- **Level select:** Full-viewport dark veil with one square selection panel, five numbered rows from `00` through `04`, a bright selected row, and keyboard-only guidance. `L` opens it during play; `W/S` or arrows move; `Enter/Space` confirms; `L/Esc` closes.

### Crafting Table
- **Crafting table:** `B` opens a square overlay on Level 0. It is a recipe-driven builder: a BUILD OPTIONS selector lists the craftable recipes as chips (LIFE JACKET, FISHING CATCHER, and any others added to the `RECIPES` data), the current one highlighted and any already-built one marked BUILT. `Tab` cycles the recipe. A unified ELEMENT SOURCES material palette starts empty and, as items are collected, reveals them as normal craft elements in a two-column grid — bottle sources first, then debris kinds (LEAVES, PLASTIC WRAPPERS, ROPE, WOOD SCRAPS, COILED SPRINGS). `W/S` selects an element, `Space` adds a matching item to the selected recipe (items not needed by that recipe are rejected), `X` removes the last added item, `Enter` builds the recipe once its materials are met, and `B/Esc` closes. The right column shows the selected recipe's required materials with added/needed counts and a BUILD/ADD/status line. LIFE JACKET needs 8 empty bottles and is wearable (WEARING, G to drop, E to wear); FISHING CATCHER needs rope×2, wood scrap, plastic wrapper and coiled spring and is carried to the river.

### Messages and States
- **Message plaque:** Top-centered at `y = 108`, content width plus 44 px, 42 px high, cyan top rule, 18 px paper text, and alpha fade on exit.
- **State overlay:** Full-viewport dark veil, no buttons; a cyan or oxblood crystal, 42 px title, and 17 px restart/result subtitle communicate win or loss. Restart remains the physical `R` key.

### World Units
- **Floor:** One base diamond plus a 7% lightened right triangle, 12% darkened left triangle, and ink seam. Level 0 uses the same facets as sunlit grass and paths.
- **River:** Split cyan-blue diamonds with stepped paper glints that drift along the channel; collision remains impassable until the life jacket is crafted.
- **Wall:** 58 px ink faces, alternating top mineral, one lightened top facet, and hard near-black seams; Level 0 hedge walls cap at 32 px and its full perimeter uses a continuous 16 px wall height.
- **Bottle sources:** Faceted dustbins, recycling bins, crates, coolers, trash bags, and compost heaps use hard polygon bodies and are ringed by litter — leaves, plastic wrappers, rope coils, wood scraps, and coiled springs. Searching yields empty bottles among that litter, and every source visibly loses bottles and leaves with each search.
- **Litter items:** Free-standing faceted debris (leaf clusters, crumpled wrappers, rope coils, wood scraps, coiled springs) lies on Level 00 ground cells on both banks; the warrior picks an item up with `F` when within reach — never automatically — with a burst and an item-count increment. A two-line plaque above the nearest reachable item shows its name (LEAVES, PLASTIC WRAPPER, ROPE, WOOD SCRAP, COILED SPRING) over the `F  PICK UP` hint. When several items are within reach, `F` opens a CHOOSE ITEM list instead: rows group in-reach litter by kind with counts, `W/S` selects, `ENTER/SPACE` gathers every item of the selected kind at once, and `ESC/B/F` closes. Picked litter appears in the crafting table's ELEMENT SOURCES list, exactly like bottle items. There is no separate junk category: every piece of debris — leaves, wrappers, rope, wood, springs, bottles — is an ordinary inventory item and craft material.
- **Life jacket:** Two cyan flotation blocks with ink straps and light facets sit over the player while equipped. `G` drops them at the player’s feet and picks them up again nearby; while dropped, they render as a faceted ground item and the river becomes impassable.
- **Shard:** A bobbing cyan crystal, flattened contact shadow, and three orbiting paper motes.
- **Enemies:** Four procedural silhouettes share the same depth ordering and contact-shadow grammar: shardling crystals, mireling bubbles, forge golems, and astral sentinels. Hit flash turns each body paper-white.
- **Gate:** A symmetrical faceted seal, paper core, and translucent halo. It is sealed mauve with three oxblood bars, then becomes cyan after all three shards.
- **HUD marker:** The same vertically stretched diamond as a crystal, reduced to 10–13 px radii for shard and vitality state.
- **Effects:** Amber slash arcs last 0.20 s; cyan or oxblood radial line bursts last 0.34 s; damage adds decaying whole-pixel screen shake.
- **App icon:** A cyan crystal silhouette split into teal, amber, and amethyst facets on void, with paper seams and the 20 px container radius.

## Do's and Don'ts

### Do:
- **Do** preserve the strict amber-action, cyan-safety, and oxblood-danger mapping in every state.
- **Do** keep Level 0's daylight palette and every depth's palette and enemy silhouette paired with its authored map while preserving the shared semantic color roles.
- **Do** quantize projected world positions to 2 px screen-space increments.
- **Do** sort walls, sources, shards, exits, player, and enemies by projected screen Y before drawing effects and HUD.
- **Do** keep camera movement limited to the world layer and preserve a fixed, readable HUD.
- **Do** keep HUD plaques at 24–30 px viewport margins and transient messages top-centered.
- **Do** build room surfaces from split diamonds, straight seams, and hard offsets; reserve rounding for the app icon.

### Don't:
- **Don't** introduce smooth subpixel camera drift, blurred shadows, gradients, glass blur, or soft rounded cards.
- **Don't** use amber for progress or safety, or use cyan and oxblood interchangeably.
- **Don't** show a dungeon gate in Level 0 or show a depth gate as open or cyan before all three shards are collected.
- **Don't** add buttons, hover states, menus, or browser-only chrome to this keyboard-controlled game.
- **Don't** reintroduce a raster player sprite; the player must stay script-drawn like every other entity.
