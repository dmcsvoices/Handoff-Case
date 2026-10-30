# handoff_case

Parametric PLA enclosure for a handheld ESP32-S3 IoT "handoff" device:
ESP32-S3 dev board, full-size SD-card reader module + card, 1.3" I2C OLED, and
two tactile buttons. Base + M3-screwed lid; slide-in edge rails for the board.

Governing plan: `plans/current/2026-10-20-14-26-10_handoff-case.md`.
Reference photos (ruler shots used for the measurement pass): this directory,
`IMG_20261020_*.jpg`. Prior out-of-pipeline attempt preserved, history only, not
carried geometry: `reference/handoff_case.scad`, `reference/handoff_case_orig.scad`,
`reference/Internals-prototype.blend`.

## Structural constants

- `minimum_wall_thickness` = 3.0 mm
- `minimum_structural_overlap` = 3.0 mm (asserted >= wall thickness)
- `minimum_internal_edge_width` = 3.0 mm
- Datum convention: outer-front-left-bottom corner of the case at origin `[0,0,0]`;
  +X right, +Y back, +Z up. Component mockups use the same world frame.
- Filament: PLA, FDM, 0.4 mm-class nozzle assumed.

## Face layout (approved 2026-10-20)

- Front wall (+Y = 0 face): OLED behind a display window, screw-down from inside.
- Back wall: USB-C access cutout(s) aligned to the board's USB edge.
- Right wall: full-size SD card slot aligned to the module cage mouth.
- Lid (top): M3 screw stations (4), two button-cap guide bores, vent slots.
- Base: drop-in L-ledge rails for the ESP32 (board drops in from the lid
  end; lid anti-lift blades hold the long edges), end stop at USB end,
  button body wells, SD module pocket, strain-relief posts.

## Dimension provenance

Sources: 32 ruler/breadboard photos (2026-10-20 measurement pass, four-way
cross-check), manufacturer standards (Espressif module drawing, USB-C mid-mount
shell, SD card standard), and derived geometry. Classification: [M] measured from
photo with local scale, [S] manufacturer-specified standard, [D] derived, [P]
provisional — verify before final print.

| Dimension | Value (mm) | Class | Source / conflict resolution |
|---|---|---|---|
| ESP32-S3 board L x W x thickness | 60.7 x 28.3 x 1.6 | M / M / P | Photos 133657593, 133727599 (header-pitch-anchored); bottom-view 51.9 mm read rejected (0.55 mm end margins physically impossible). Thickness: standard FR4. |
| ESP32 overall width w/ soldered headers | ~31.5 | D | Headers protrude 2-4 mm per side (photo 133657593). |
| ESP32 header rows | 2 x 21-pin, 2.54 pitch, span 50.8 | M | Pin-count from label rows (photos 133657593, 133842431); 20 pitches = 50.8 mm. |
| ESP32 USB-C connectors | 2, on short edge opposite module; centers 12.3 apart, 4.1 / 16.4 from top edge; shell 9.0 W x 7.5 D, protrudes 7.7 past PCB; height above board ~3.2 | M / M / S | Spacing cross-checked in two photos (agent agreement); shell dims standard mid-mount USB-C; margin values +/-0.5. |
| ESP32 RST / BOOT buttons | 3 x 4 outline, RST 24.5 / BOOT 30.1 from antenna end, ~5.7 from top edge | M | Photo 133657593. Clearance only, no external access required. |
| ESP32-S3 module + antenna keep-out | 25.5 x 18 shield zone + meander end | M / S | Photos 133752373, 133657593. PLA wall is RF-transparent; keep-out is for clearance only. |
| ESP32 mounting holes | none | M | Photos 133657593, 133842431 — motivates slide-in rails. |
| ESP32 above-board stack (headers + Dupont) | ~13 | P | No scaled side view exists; breadboard profile photo 134240331. Drives internal height; verify with calipers. |
| OLED module PCB | 35.6 x 34.4 x 0.9 | M | Photos 132310760, 132324795, 132410037 (three consistent ruler-scaled reads). |
| OLED mounting holes x4 | dia 2.9, spans ~30.0 x 29.8, inset 2.5-3.5 from edges | M | Same photos; cross-photo spread is oblique error — treat +/-0.6, verify by caliper before final print. |
| OLED glass outline | 33.0 x 24.6; margins L0.5 / R0.8 / header-side 5.7 / flex-side 3.6 | M | Photo 132353154. |
| OLED active window | 29.42 x 14.7 | S | Display was off in all photos (not directly measurable); standard 1.3" 128x64 active area. Window cut uses this — flag if module differs. |
| OLED header | 1x4, 2.54, GND-VCC-SCL-SDA on long edge, ~0.9 off-center; total height above board face 6.9-7.2 | M / D | Photos 132310760, 132410037. |
| OLED module overall depth (glass to pin tips) | ~10.0-10.5 | D | Photo 132410037. |
| SD module PCB | 33.3 x 28.3 x ~1.6 | M / P | Anchored to the 24.0 mm standard card width in photo 134055205 (full-size SanDisk Ultra). The "microSD, 13.5 x 14.9 module" reading is rejected: internally inconsistent (24 mm card cannot fit a 13.4 mm cage) and contradicted by the card-labelled photo. |
| SD cage | ~29.2 W x 21-25 D, ~2.9 above PCB; mouth on edge opposite 6-pin header | M | Photos 134055205, 132851913 (card-anchored). |
| SD card | 32 x 24 x 2.1, inserts label-up from header-opposite edge | S / M | Standard + photo 134055205. Insertion depth ~18; exposed ~13. |
| SD module holes | 2 x dia ~1.5, span ~28.2 (possibly 4 holes) | P | Photo 134055205, low confidence. Too small for M3 — pocket retention used instead. |
| Tactile buttons x2 | 12.1 x 12.1 body, cap dia 7.9-8.0, leads span ~10, pair spacing 16.3 | M | 12 x 12-class switches, NOT 6 x 6: the "6.0 mm body" reads came from a 2x ruler-scale error (re-deriving photo 134157366 pixels with the 24 mm card anchor gives 12.6-13.1 mm body and 7.8-8.0 mm cap, matching). |
| Button total height | ~7 (7-9 class) | P | No usable scaled side view — verify with calipers; caps and pockets are parameterized around it. |
| Wire routing | Dupont loops, bend radius >= ~15 | M | Photos 134055205, 134240331 — internal wire alleys sized accordingly. |

### 2026-10-29 caliper feedback batch (supersedes photo-derived values; rev_0002)

Source: `updated_measurements/` (73 photos: digital-caliper component
measurements + printed rev_0001 base/cap fit checks). Printed revision:
rev_0001 STLs (commit 7d280e3), pink PLA; printer/profile unrecorded —
feedback tied to unrecorded print conditions (evidence limit). Competing
causes: the 2026-10-20 ruler-photo reads (English/inch rule ambiguity, 2x
error class) vs the 2026-10-29 caliper LCD transcriptions (authoritative);
the SD module identity CHANGED between batches (full-size module + card
in the 2026-10-20 photos vs microSD module + card photographed 2026-10-29)
— rev_0002 designs for the measured microSD module; reverting is a
parameter change if the full-size module returns.

| Parameter | rev_0001 (superseded) | rev_0002 (measured) | Class |
|---|---|---|---|
| esp32_board_len | 60.7 | 57.1 (+end play seen in printed rails) | measured (caliper LCD) |
| esp32_board_w | 28.3 | 28.15 | measured |
| esp32_header_w (board + side headers) | 31.5 | 31.35 | derived (unchanged 1.6/side overhang) |
| esp32 above-board pin height | ~13 stack (P) | 11.4 pin height; stack 16.5 provisional-derived | measured / P |
| esp32_usb_shell_h | 3.2 (standard) | 4.4 | measured |
| oled rigid PCB | 35.6 x 34.4 | 31.0 x 34.25 (+ ~4.4 FPC tail beyond +X edge) | measured |
| oled glass outline | 33.0 x 24.6 | 33.5 x 24.6 outline; visible area 33.5 x 15.4 | measured |
| SD module identity | full-size reader 33.3 x 28.3 | **microSD reader 28.2 x 20.0** | measured; batch change |
| sd cage | 29.2 x 21-25 | 14.9 x 11.4 (~2.9 high) | measured, medium |
| sd card | full-size 32 x 24 x 2.1 | microSD 15.0 x 11.1 x ~1.0 | measured (card labelled microSD) |
| sd card exposed | ~13 | ~11.3 (inserted 3.7) | measured, medium |
| button body | 12.1 x 12.1 x 7.0 (P) | 12.1 sq x 5.4 | measured |
| button cap dia | 7.9-8.0 | 8.1 | measured |
| button actuator | 3.9 dia x ~1.5 (P) | 3.9 dia, top 9.3 above mounting floor | measured |
| button terminals | unmodeled | 4 kinked corner blades ~1.1 x 0.4, tips splay to ~13.4-13.8 span, ~3.5-5.5 below body | measured, medium |
| cap stem printed | 7.8 design | 7.9 printed (fit verified) | print verified |
| USB cutouts printed | 10.0 x 4.5 | ~11 x 4.3 observed | observed; design kept (10.0 x 5.0 derives from the 4.4 shell) |

Superseded values stay visible above for provenance; `configs/rev_0001.json`
is unchanged (immutable revision). OLED mounting-hole spans were NOT
re-measured this batch — the rev_0001 boss pattern (30.0 x 29.8) is kept
and still fits inside the rigid 34.25 x 31.0; flag for a future caliper
pass.

### Known-unverified after the 2026-10-29 batch

1. Terminal projection below the body is medium-confidence (3.5-5.5) —
   the under-chamber height 7 covers the range; verify at physical assembly.
2. Button switch-cap height above the body (~1.5 assumed) — drives the
   printed cap relief; verify at assembly.
3. OLED mounting-hole spans (+/-0.6) and FPC tail width (~10 assumed).
4. esp32_stack_h 16.5 is provisional-derived (11.4 pins + Dupont margin).
5. Printer conditions for the rev_0001 feedback print are unrecorded —
   the cap-stem fit verdict ties to that unrecorded profile.
6. Slicer layer-path review still outstanding for all revisions.

These are config parameters in `configs/rev_0002.json`; update through a
new revision when measured (measurement playbook step 9).

## rev_0001 blockout envelope (item 3.1, derived 2026-10-20)

All quantities derive from the provenance values above plus named layout
parameters (defaults in `src/lib/defaults.scad`, config in
`configs/rev_0001.json`). Datum: outer-front-left-bottom at `[0,0,0]`, +X
right, +Y back, +Z up; world mm throughout.

Board orientation: the measured board carries both USB-C shells on a SHORT
edge (photo IMG_20261020_133657593), so the approved face layout ("back
wall: USB-C cutout aligned to the board's USB edge") fixes the board long
axis (60.7) along Y, antenna end toward the front, USB shells protruding
toward the back wall. The interior is sized around the mockup placements:

- `interior_w = board_margin_left(5) + esp32_header_w(31.5) + band_gap(8)
  + sd_pcb_x(28.3) + sd_card_exposed(14) + sd_tip_gap(1) = 87.8`
  (card exposed = card 32 - inserted 18 = 14; card tip sits 1 mm shy of the
  right inner face = the future slot plane)
- `interior_d = front_margin(5) + oled_depth(10.5) + alley(9)
  + esp32_board_len(60.7) + esp32_usb_protrusion(7.7) + usb_gap(2) = 94.9`
- `interior_h = oled_h(34.4) + lid_clearance(8) = 42.4` (OLED module is
  the tallest content)

Outer: `93.8 x 100.9 x 45.4` base + 7.0 lid plate = 52.4 overall.

Placement (world coordinates, from the functions in defaults.scad):

- OLED: mounted on four front-wall bosses (see below); glass face
  `boss_h(3.5) - glass_proud(2.3) = 1.2` clear of the wall inner face.
- Buttons: pair at front-left, bodies seated in the base wells (cavity
  floor = case floor), 16.3 mm spacing; wells start right of the front-left
  M3 tower. Caps ride the actuators through the lid guide bores.
- ESP32: flat on the L-ledge rails (underside at floor + 3.5, see below),
  header envelope 5 mm from the left inner face, USB short edge + shells
  2 mm shy of the back wall.
- SD module: right band on a raised pocket pad, cage mouth facing +X, card
  through the right-wall slot; pocket front wall 8.7 mm behind the OLED
  zone (one of the >= 8 mm wire alleys). Dupont loop room (bend radius
  >= ~15) is the open band behind the OLED zone and around the SD module.

Wire alleys: behind the OLED zone 9 (param `alley`), between ESP32 band and
SD pocket wall ~4.7 (`band_gap` 8 is module-to-module), SD pocket to OLED
zone 8.7.

## Detail geometry (rev_0001, plan items 3.2-3.4)

ESP32 retention (base, 3.2): two Y-running L-ledge rails under the board's
long edges - each a 3.0 wall + a 2.0-wide land. The board lift is
`max(3.0 land, pin_tip_drop 1.5 + floor clearance 2.0) = 3.5`, so the
underside header pin tips (~1.5 below the PCB, >= 2.5 inboard) hang over the
open inter-rail cavity with 2.0 mm to the floor. No top lips. End-stop bar
(3.0 thick, wall-to-wall between the rails) at the USB end reaches exactly
the board top face (8.1) and is notched 0.15 around each protruding shell
(3.0 web between notches). RST/BOOT (24.5/30.1 from antenna, 5.7 from the
top long edge, 3x4) and the antenna-end shield keep-out (module can
~25.5 across the board width x ~18 along the length per the provenance
table, WROOM-1 18.0 x 25.5 rotated; the meander end extends past the can
and the keep-out is kept conservative) are exposed as parameters for the
lid anti-lift blade stations.

OLED mount (base front wall, 3.2): four Ø6 bosses at the measured hole spans
(30.0 x 29.8 on the 35.6 x 34.4 PCB) hold the PCB 3.5 off the wall so the
glass (2.3 proud) clears by 1.2; each boss carries a Ø2.5 blind pilot 6.0
deep (0.5 skin over the outer wall face) for M2.5 self-tapping screws
through the module holes. The window through the front wall is the active
area 29.42 x 14.7 + 0.4 per side, corner r 1.0, centered on the glass; it
sits >= 1.0 mm inside the glass outline on every side (x margin 1.39, z
margin 4.55) and >= 3.0 from the boss pilots (z ligaments 4.6 / 7.2).

SD pocket + slot (base, 3.2): three 3.0 walls around the 33.3 x 28.3 PCB
with 0.3 clearance per side on a 3.0 raised floor pad (module top of pad at
6.0); walls 4.5 proud capture the 1.6 PCB. Card slot through the right wall
25.5 x 3.3 centered on the cage-mouth/card centerline (offset 0.0 <= 0.5),
1.0 chamfer flare on the outer entry face; slot bottom to floor ligament
4.8 >= 3.0.

USB cutouts (back wall, 3.2): two separate 10.0 x 4.5 openings, corner r
1.0, one per shell, centered on the measured shell positions; each shell
fits with 0.25 clearance. Ligament between openings is 2.3 (12.3 spacing -
10.0 openings) - a documented deviation from the 3.0 norm, forced by the
0.25 shell clearance at the measured 12.3 spacing; a single shared cutout or
a confirmed >= 13.0 spacing fixes it (see deviations).

Button wells (base, 3.2): one block, two 12.5 sq cavities (12.1 body + 0.2
per side), shared wall derived from the measured spacing
(`16.3 - 12.5 = 3.8` >= 3.0), outer walls 3.0, block 7.5 tall (cavity depth
4.5); a 3.0 x 2.0 wire-exit slot in the back wall of each well. Well
centers are the cap-bore datum for the lid (same `button_center()`).

Strain-relief posts (base, 3.2): two Ø8 x 8 posts with a Ø2 vertical
zip-tie bore (rim 3.0) in the OLED and SD wire alleys.

M3 join (3.3): four 13x13 stud towers in the base corners, tops exactly at
the parting plane, each bridging the floor and its nearest wall(s) with full
3.0 overlap; Ø3.0 blind pilot 8.0 deep from the top. The lid carries Ø3.4
clearance bores and Ø7 x 4.0 head recesses from the top with a 3.0 retained
floor (hence lid_t 7.0). M3 screw into the Ø3.0 pilot = thread-forming /
self-tapping in PLA (house precedent). The front-right station moved to
y = 22: the front-right corner is occupied by the OLED module and its right
mounting boss.

Lid (3.3, cont.): two Ø8.3 cap guide bores through the plate (aligned to
the base wells); two anti-lift blades (1.6 wide x 3.0 thick) hanging from
the lid underside onto the board's long-edge top strips (>= 2.5 mm pin
inset, y 62-85 clearing the shield and RST/BOOT keep-outs by >= 2.0),
bottoms at the board top face at nominal - the 0.2 mm FDM stack tolerance is
absorbed at screw clamp; six 15 x 2 vent slots (column gap 4.0, row gap
5.0, >= 3.0 to bores/edges). Print the lid plate-down (blades up).

Button cap (3.4, printed x2): flange Ø14.6 x 3.0 on the lid top face; stem
Ø7.8 sliding in the Ø8.3 bore; blind actuator socket Ø4.0 x 2.5 (actuator
Ø3.9); Ø10.5 x 1.3 body relief at the stem bottom. Stack arithmetic
(defaults.scad): body_top = 3 + 7 = 10.0; actuator_top = 11.5;
stem_bottom = 11.5 - 0.3 press - 2.5 socket = 8.7; stem_len = 52.4 - 8.7 =
43.7; the socket top (11.2) presses the actuator 0.3 below nominal at lid
closed. NOTE: 0.3 press preloads the tactile switch - actuator travel is
known-unverified (#2); if the switches read constantly closed, drop
`cap_press` toward 0.05 in the next revision.

## Documented deviations from the 3.0 mm house norm

- Board underside at floor + 3.5 (not + 3.0): pin tip drop 1.5 + the 2.0
  floor clearance govern over the 3.0 land minimum; the land is 3.5 thick.
- Lid 7.0 thick (not the 3.0 blockout plate): the Ø7 x 4 head recess must
  retain a 3.0 floor (raspberrypi5_case pattern).
- USB cutout web 2.3 (< 3.0): 10.0 openings at the measured 12.3 shell
  spacing leave 2.3; the 0.25 shell clearance wins. **User-approved
  exception 2026-10-20** (short back-wall web between two small access
  openings; no load path, both openings bordered by >= 3.0 elsewhere).
- OLED boss rim around the Ø2.5 pilot is 1.75 (< 3.0): the Ø6 boss diameter
  is fixed by the module hole spacing. **User-approved exception
  2026-10-20** (M2.5 self-tapping retention boss on the front wall; the
  3.0 wall behind the boss carries any load).
- Rail land 2.0 wide and anti-lift blades 1.6 wide (< 3.0): both must fit
  between the board edge and the 2.5 mm header-pin inset. **User-approved
  exception 2026-10-20** (the 3.0 rail wall and the 3.0 blade thickness
  carry the loads; land/blade widths are location limits, not sections).
- Cap flange Ø14.6 x 3.0 (not Ø12 x 2.0): the 3.0 rim rule around the Ø8.3
  bore governs.
- Strain posts Ø8 (not Ø5): the Ø2 bore needs 3.0 rims.
- Button wells / OLED / front-right tower moved right vs blockout: the
  corner towers + wells + OLED module did not fit the blockout x-positions;
  the envelope itself is unchanged.
- rev_0002 slot-floor between-bays rim 1.5 (< 3.0): mathematically forced
  by the measured 16.3 mm pair spacing vs the 13.8 mm worst-case terminal
  tip span (16.3 - 13.8 = 2.5 total for two windows); the floor plate is a
  non-structural retention plate and the window rims elsewhere are >= 3.0.
  **User-approved exception 2026-10-30** (same class as the rev_0001 land/
  blade width exceptions: a location-limit strip, not a load section).
- rev_0002 anti-lift blade X pinned at rev_0001 (lid geometry-identical
  constraint): the measured board is 0.15 mm narrower, so the pinned right
  blade overlaps the new edge strip by 1.45 of its 1.6 width and clears
  the header pins by >= 0.85 (asserted).
- Toolchain note (not a geometry deviation): OpenSCAD 2021.01 preview
  hides axis-aligned through-holes (OpenCSG occlusion artifact) and CGAL
  degenerates single rounded-rect cut prisms wider than ~27 mm. The window
  is therefore cut as two overlapping <= 22 mm polygon prisms
  (`rr_profile` in defaults.scad); the exported STLs carry the full
  geometry (verified by STL slicing).


## Verification record

### 4.1 Structural review (rev_0001, 2026-10-20)

Source revision/config: rev_0001 (mutable, `configs/rev_0001.json`).
Method: governed temporary section probes (per the sections/probes
playbook) rendered to transient `section_<n>.png` files (removed before
the final audits per artifact governance; measurements recorded below),
with probe source preserved at `designs/handoff_case/src/probes/section_probes.scad`;
plus independent line-section measurements of the installed STLs (pure-Python
mesh checks reusing `scripts/verify_raspberrypi5_case.py` machinery - no
new dependencies). Summarised below.

| # | Feature | Evidence | Measured (STL line sections) | Result |
|---|---|---|---|---|
| 1 | ESP32 L-ledge rails | section_1.png | rail wall 4.6-7.6 (3.0), land 7.6-9.6 (2.0), rail top z 6.5 = floor+3.5, pin cavity floor z 3.0 -> tip clearance 2.0 | PASS |
| 2 | End stop + shell notches | section_2.png | bar top z 8.1 = board top; notch column z 6.35 at shell x; web between notches x 26.15-29.15 (3.0) | PASS |
| 3 | OLED bosses + pilots + window | section_3.png | boss Ø6 spans 51.1-57.1 / 81.1-87.1; pilots Ø2.5 (y 0.5-6.5, 0.5 skin); window void x 53.19-83.41 (30.22), corners rounded | PASS |
| 4 | SD pocket + slot floor ligament | section_4.png | slot z 7.8-11.1 (3.3) centred 9.45; floor ligament 7.8-3.0 = 4.8 >= 3.0 | PASS |
| 5 | USB cutouts + web | section_5.png | cutouts z 6.65-11.15 (4.5); floor ligament 3.65; web x 26.5-28.8 (2.3, user-approved exception) | PASS (with exception) |
| 6 | M3 tower overlap | section_6.png | tower z 0-45.4 merged with left wall x 0-13; pilot z 0-37.4 (8.0 deep, open at parting plane) | PASS |
| 7 | Lid recess floor | section_7.png | recess column z 45.4-48.4 retained floor 3.0; Ø3.4 bore through (void at station centre) | PASS |
| 8 | Cap-bore ligaments | section_8.png | bores Ø8.3 voids 18.6-26.9 / 34.9-43.2 at z 49; solid ligament between bores and to vents >= 3.0 (asserts) | PASS |
| 9 | Anti-lift blades | section_9.png | blade z 8.1-52.4 at x 9.8-11.4, embedded 3.0 in lid | PASS (after fix, see below) |

Join inventory: wall/floor and wall/wall overlaps 3.0 (asserted);
tower-wall/floor overlaps 3.0 (measured, #6); rail/floor embed full
sections; boss/wall embed 3.0; pocket walls/pad 3.0 (asserted + #4);
blade/lid embed 3.0 (measured, #9). Post-subtraction ligaments per #2-#5,
#7-#8.

Internal edge/material strip inventory: all named strips asserted in
source; measured strips: end-stop web 3.0 (#2), USB web 2.3 (approved
exception), slot floor ligament 4.8 (#4), cutout floor ligament 3.65 (#5),
recess floor 3.0 (#7), cap-bore to vent >= 3.0 (assert + #8). Known
sub-minimum features (user-approved 2026-10-20): USB web 2.3, boss pilot
rim 1.75, rail land 2.0 / blade width 1.6.

Section locations reviewed: rail mid-length (#1), stop bar mid (#2), front
wall mid (#3), slot centre (#4), back wall mid (#5), fl tower (#6), fr
recess (#7), cap-bore plane (#8), blade mid-span (#9) - start/mid/end
coverage per feature class as required.

Post-subtraction checks: all overlaps re-measured on the exported STL
after every cut (table above) - PASS.

Unexpected positive-volume shells: **found and fixed during 4.1** - the
first installed lid STL contained the two anti-lift blades as a phantom
box at the origin (both blades missing from the plate): OpenSCAD 2021.01
intermittently miscompiles the wide deferred `translate()` thunks for the
blade pair under module + CGAL-cache contexts. Fix: parameter-bound
`anti_lift_blade()` helper (eager argument binding). Re-verified: lid =
1 shell, blades at x 9.8-11.4 / 36.1-37.7, z 8.1-52.4, stable across 5
consecutive renders; all installed STLs re-checked (below). The buttons
mockup intentionally has 2 shells (two physically separate switches) -
not a defect.

Shell audit (installed STLs, pure-Python mesh topology: manifold, winding,
signed volume, connected components):
- base_rev_0001.stl: 1 shell, 3580 tris, vol 101077 mm3, span 93.8 x 100.9 x 45.4
- lid_rev_0001.stl: 1 shell, 2108 tris, vol 66258 mm3, span 93.8 x 100.9 x 44.3 (8.1-52.4)
- button_cap_rev_0001.stl: 1 shell, 572 tris, vol 2506 mm3, flange Ø14.6, socket 2.5 deep
- esp32/oled/sd_module mockups: 1 shell each (envelope unions)
- buttons mockup: 2 shells by design (two switches)

Slicer layer-path review: not performed (no slicer run in this task) -
unverified; required before final print.

Intentional disconnected geometry: none in printable parts (buttons
mockup represents two components; lid/base/cap single shells).

Fit-test coupon: see 4.2.

Result: **passed** (construction, section, post-subtraction, shell, and
connectivity evidence; slicer evidence outstanding).

### 4.2 Fit review (rev_0001, 2026-10-20)

Interface classification and clearance stack (nominal | allowance stack |
status). `P` = driven by a provisional/unverified measurement.

| Interface | Type | Driving measurement | Chosen fit | Status |
|---|---|---|---|---|
| Rail land -> board underside | fixed support | board lift 3.5 = pin drop 1.5 (P) + floor clear 2.0 | 0 (rests on land) | unverified (P) |
| Pin tips -> floor | fixed clearance | pin drop 1.5 (P) | 2.0 | unverified (P) |
| Board lateral -> rail walls | location play | land 2.0 inboard of each rail wall | 2.0/side | verified (construction) |
| End stop -> PCB end face | fixed contact | measured board length 60.7 | 0 (retention) | verified (construction) |
| USB shell -> cutout | fixed clearance | shell 9.0 x 3.2 (M) | 0.25/side | verified (#5) |
| Card -> slot | slip | card 24.0 x 2.1 (S/M) | 0.75/side, 0.6 top/bottom | verified (#4) |
| Glass -> wall inner face | fixed clearance | glass proud 2.3 (M), boss 3.5 | 1.2 | verified (#3) |
| Module holes -> bosses | registration slip | hole Ø2.9 (M), boss Ø6 | 1.55 radial | verified (#3) |
| Window -> active area | fixed reveal | active 29.42 x 14.7 (S) | 0.4/side | verified (#3) |
| SD pocket -> PCB | slip | PCB 33.3 x 28.3 (M) | 0.3/side | verified (assert + #4) |
| M3 screw -> tower pilot | press/thread-form | pilot Ø3.0 | 0 (self-tapping in PLA) | unverified (physical) |
| M3 screw -> lid bore | slip | screw Ø3.0, bore Ø3.4 | 0.2 radial | verified (#7) |
| Cap stem -> guide bore | slip | stem Ø7.8, bore Ø8.3 | 0.25 radial | unverified (P stack) |
| Actuator -> socket | slip | actuator Ø3.9 (M) | 0.05 radial | unverified (P) |
| Cap press at lid closed | press | button_h 7.0 (P), actuator_h 1.5 (P) | 0.3 preload | unverified (P) - RISK |
| Wells -> button body | slip | body 12.1 (M) | 0.2/side | verified (construction) |
| Blades -> board top | fixed contact | board top 8.1 (derived) | 0 nominal (0.2 FDM at clamp) | unverified (P) |

Highest-risk mating profile: the cap/bore/actuator press stack (provisional
button height + 0.3 mm press - a constant 0.3 preload may keep the tactile
switches closed). Coupon: `designs/handoff_case/src/probes/cap_stack_coupon.scad` (transient,
removed before the final audits) replicating the full stack at press
0.05 / 0.3 / 0.5 with production-derived plate, bore, stem, socket,
actuator and body dimensions; section render reviewed
(`cap_stack_coupon_section.png`): all three variants assemble with the
socket engaging the actuator and the stem clearing the bore. Coupon STL
generated (3 stations, plate-down print orientation). **Artifact-governance
disposition:** the governed flat output audit rejects any extra file, and
adding the coupon to parts.json would pollute the product decomposition
with a non-product part, so the coupon artifacts were transient (removed
before the final audits) and the source lives outside the hash-audited
`src/` tree at `designs/handoff_case/src/probes/cap_stack_coupon.scad`
(preserved; render with OpenSCAD to regenerate the STL before printing).
Physical print + measurement: pending - all `unverified` rows above gate
fabrication readiness.

### 4.3 Complete gate (rev_0001, 2026-10-20)

Complete: printable manifest built and audited (8 STL + 136 PNG,
`build_manifest.json` audit PASS). Artifact-bound assembly review rendered
(`scad_render_assembly_review.py --set full`) and audited PASS
(`assembly_review_manifest.json` binds the exact `build_manifest.json`
hash and every authoritative STL hash; unified output audit: 8 STL +
147 PNG + 2 manifests, flat). Review PNGs inspected (product isometric,
interior iso, walls): window, slot, cutouts, towers, caps, and rails all
at intended faces. Note: OpenSCAD reports the combined assembly preview
export as non-2-manifold (expected for the union preview; printable leaf
STLs are each a single verified shell per 4.1). Slicer layer-path review:
not performed - unverified, required before final print.

## rev_0002 changes (2026-10-29 feedback plan)

Envelope: PINNED at the rev_0001 interior (87.8 x 94.9, outer 93.8 x
100.9) so the lid part stays geometry-identical (verified by STL vertex
hash). The shorter board (57.1) and narrower microSD module free space as
end play and extra wire alley instead of shrinking the case:
`usb_gap` derives to 5.6 (2.0 minimum + 3.6 end play at the USB end);
`band_gap` derives to ~10.8 (extra alley beside the microSD pocket). The
OLED got 0.15 shorter, absorbed by `lid_clearance` 8.0 -> 8.15 so the
parting plane and the whole lid stay fixed.

Button retention replaced (user workflow: solder wires to the switch
terminals FIRST, then slide the pre-wired switch in from the front; the
cap retains it):

- Per button a CLOSED-TOP side-entry slot: 12.4 wide x 5.6 tall x 14.0
  deep (0.15/side slip on the 12.1 body), 0.3 entry lead at the mouth.
  The slot floor plate (3.0) carries the body; its corner windows
  (3.2 x 3.0 per corner, covering the 13.8 mm tip splay) admit the kinked
  terminals, solder joints, and wires into the shared under-chamber
  (floor = base floor top, height 7.0 >= 5.5 drop, open toward the wire
  alley at the rear). The 3.0 ceiling captures the body vertically.
- The body rests at slot floor z 13.0; back stop seats the actuator under
  the UNCHANGED lid cap bores (centers 22.75 / 39.05 x 17.25; the block
  tucks 2.0 under the front-left M3 tower as merged solids).
- Assembly sequence: solder wires to the terminals -> slide the switch in
  through the front mouth until the back stop -> the printed cap (through
  the lid bore) sleeves the plunger and retains the switch. Until the cap
  is fitted the switch is not vertically captured — keep the case level
  or let the wires hold it.

Cap stack (rev_0002): slot_floor 13.0; body top 18.4; switch cap (dia
8.1 x ~1.5) top 19.9; actuator top 22.3 (= 9.3 above the slot floor);
stem_bottom = 22.3 - 0.3 - 2.5 = 19.5; relief over the switch cap 0.9
deep (dia 8.7); socket dia 4.0 x 2.5; stem length = 52.4 - 19.5 = 32.9.

### rev_0002 verification (2026-10-29)

Source revision/config: rev_0002, `configs/rev_0002.json` (published).
Method: same governed approach as the rev_0001 review - section probes
(`src/probes/section_probes.scad`, transient renders), independent STL
line-section measurements, pure-Python mesh topology, artifact-bound
assembly review. rev_0001 records above remain the history for unchanged
features; only the changed features are re-evidenced here.

| Feature | Evidence | Measured (STL line sections) | Result |
|---|---|---|---|
| Holding-slot block | probe 10 section | floor plate z 10-13 (3.0), closed-top channels z 13-18.6 (5.6), ceiling 18.6-21.6 (3.0), chamber z 3-10 (7.0), stepped outer walls, back stop y 23.3 | PASS |
| Under-chamber + windows | probes 10/11 + sections | chamber 7.0 >= 5.5 terminal drop; corner-window column void through the plate; window rims: between-bays 1.5 (documented deviation), bearing strips 3.0 | PASS (with deviation) |
| Back stop / datum | section + asserts | button centres 22.75 / 39.05 x 17.25 (unchanged; `slot_pair_spacing` assert); actuator under lid bores | PASS |
| microSD pocket + slot | probe 11 | slot z 8.75-11.25 (12.5 x 2.5 centred 10.0), floor ligament 5.75, pocket 0.3/side, seat flush (`seat = cage_h - card_t` assert) | PASS |
| USB cutout height | section | cutouts z 7.0-12.0 (5.0 = 4.4 shell + 2x0.3), floor ligament 4.0, web 2.3 (approved exception) | PASS |
| End stop (shorter board) | probe 2 | bar top z 8.1 = board top; notches around both 4.4-tall shells; web 3.0 | PASS |
| Rails (shorter/narrower board) | probe 1 | rail top z 6.5 (floor+3.5), tip clearance 2.0; envelope end play at the USB end (`usb_gap` derives 5.6) | PASS |
| Cap stack | coupon + sections | socket 2.5 deep over plunger; stem bottom 19.5 (actuator top 22.3 - 0.3 press - 2.5); stem length 32.9; switch-cap relief 0.9 x dia 8.7; stem dia 7.8 in dia 8.3 bore | PASS |
| Lid identity | STL vertex hash | lid_rev_0002 vertex-hash == lid_rev_0001 (geometry-identical); anti-lift blade X pinned (overlaps the 0.15 narrower board edge by 1.45/1.6, pins clear >= 0.85, asserted) | PASS |

Shell audit (installed rev_0002 STLs): base 1 shell (3996 tris), lid 1
(2108), button_cap 1 (572), all four mockups 1 each; buttons mockup 2
shells by design (two physically separate switches). No unexpected
disconnected shells. OpenSCAD's combined assembly-preview export reports
non-2-manifold as expected for the union preview (throwntogether backfaces
are a render artifact, not geometry; the per-part STLs are each single
verified shells and the review STL export carries the full geometry,
18270 vertices).

Coupon: `src/probes/cap_stack_coupon.scad` updated to the rev_0002 stack
(actuator top 9.3 above the slot floor; three press variants 0.05 / 0.3 /
0.5); sanity render inspected (three stations assemble with the socket
engaging the plunger). Regenerate transiently from the source for the
physical print; coupon STL/PNG are not part of the governed flat output.

Complete gate: build manifest audit PASS (8 STL + 136 PNG + manifest);
contract PASS (5 assemblies, 8 parts, 11 interfaces, 11 views); unified
output audit PASS (8 STL + 147 PNG + 2 manifests, 157 files, flat);
artifact-bound assembly review rendered and audited for rev_0002
(`assembly_review_manifest.json` binds the exact current
`build_manifest.json` hash and every authoritative STL hash).

Revision snapshot: `revisions/handoff_case/rev_0002/` (146 artifacts +
manifest + params.json), config/parts/params hashes match the audited
output build and all 8 STL vertex-hashes are geometry-identical. Caveat
recorded per the playbook: the snapshot was built minutes before a
geometry-neutral source edit (mockup placement hoisting - the same OpenSCAD
deferred-thunk robustness fix as the lid blades), so its manifest's source
hash predates the final tree and its `--audit-only` flags the drift; the
output build (final tree) is the fully audited reference. Re-publication
as a new number for a source-text-only change was judged worse; flag for
the next framework pass (either snapshot the source in the revision dir or
allow re-publication while uncommitted).

Slicer layer-path review: not performed - unverified, required before
final print.

Result: **passed at the construction/evidence level**; physical fit of the
terminal drop, switch-cap height, and cap press remains unverified (see
known-unverified).

## Part classification (parts.json dispatch ids)

| id | name | classification |
|---|---|---|
| 0 | assembly_preview | assembly preview (non-printable) |
| 1 | base | printable |
| 2 | lid | printable |
| 3 | button_cap | printable (printed x2; flange/stem/socket per item 3.4) |
| 10 | esp32 | reference mockup (non-printable) |
| 11 | oled | reference mockup (non-printable) |
| 12 | sd_module | reference mockup (non-printable) |
| 13 | buttons | reference mockup (non-printable) |

Mockups are faithful envelopes per the provenance table (ESP32 incl.
protruding USB shells; OLED incl. glass-to-pin-tip depth; SD incl. inserted
card; buttons 12.1 sq x ~7 at 16.3 spacing) and are modeled in the shared
world frame. The base and lid are also world-frame; the button_cap is
modeled at its own fabrication origin with its assembly transform in
`assembly.json`.

