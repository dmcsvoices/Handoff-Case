---
plan_id: 2026-10-29-20-30-00_handoff-case-rev2-feedback
title: Handoff Case rev_0002 — physical print feedback + button holding slots
summary: Apply 2026-10-29 caliper/print feedback (board 57.1, USB shells 4.4, OLED 31.0 rigid, microSD module, button 5.4 mm body) and replace button wells with side-entry holding slots that accept pre-wired switches, as immutable rev_0002.
status: current
created_at: 2026-10-29-20-30-00
---

# Handoff Case rev_0002 — physical print feedback + button holding slots

Key: `[ ]` pending task, `[x]` completed task, `[?]` needs validation, `[-]` closed task

Follows `playbooks/how_to_apply_physical_print_feedback_to_a_new_revision.md`.
Source of feedback: `designs/handoff_case/updated_measurements/` (75 photos,
2026-10-29: digital-caliper component measurements + printed rev_0001 base/cap
fit checks). Printed revision: rev_0001 STLs (commit 7d280e3), pink PLA,
printer/profile unrecorded (feedback tied to unrecorded print conditions -
noted as evidence limit).

## Evidence summary (caliper-verified, superseding photo-derived values)

| Parameter | rev_0001 | Measured 2026-10-29 | Class |
|---|---|---|---|
| esp32_board_len | 60.7 | 57.1 (+end play observed in printed rails) | measured (caliper LCD) |
| esp32_board_w | 28.3 | 28.15 | measured |
| esp32_board_t | 1.6 | 1.6 | confirmed |
| esp32 header pin above board | 11.4 (provisional) | 11.4 | measured |
| esp32_usb_shell_h | 3.2 (standard) | 4.4 | measured |
| oled_l (rigid PCB) | 35.6 | 31.0 (+ ~4.4 FPC tail beyond rigid edge) | measured |
| oled_w | 35.6/34.4 | 34.25 | measured |
| oled glass visible | 33.0 x 24.6 | 33.5 x 15.4 | measured (visible area) |
| sd module PCB | 33.3 x 28.3 | 28.2 x 20.0 | measured |
| sd card | full-size 32x24x2.1 | microSD 15.0 x 11.1 x ~1.0 | measured (card labelled microSD) |
| sd cage | 29.2 x 21-25 | 14.9 x 11.4 | measured, medium |
| sd card exposed | ~13 | ~11.3 | measured, medium |
| button body | 12.1 x 12.1 x 7.0 h | 12.1 sq x 5.4 h; cap Ø 8.1; actuator top 9.3 above mount | measured |
| button terminals | unmodeled | 4 corner blades, kinked, ~1.1 x 0.4 section, tips splay to ~13.4-13.8 span, ~3.5-5.5 below body | measured, medium |
| cap stem printed | 7.8 | 7.9 printed | print verified |
| USB cutouts printed | 10.0 x 4.5 | ~11 x 4.3 observed | observed; keep design |

Competing causes recorded: original ruler-photo misreads (English-rule unit
ambiguity, 2x error class) vs new caliper LCD transcriptions (authoritative);
SD module identity changed between batches (full-size module + full-size card
in 2026-10-20 photos vs microSD module + microSD card photographed
2026-10-29) - rev_0002 designs for the measured microSD module; revert is a
parameter change if the full-size module returns.

- [ ] 1. Publish staged revision without touching rev_0001.
  - [x] 1.1 Run `python scripts/scad_new_revision.py --design handoff_case --base-config designs/handoff_case/configs/rev_0001.json` to create `configs/rev_0002.json` (rev_0001 and its artifacts stay immutable). Candidate iterated in configs/ + output/ first; published once verified. The immutable snapshot build worked around a `--destination revision` staging-validation regression via a driver reusing scad_build_all machinery (scripts untouched; recorded in the journal + README).
- [ ] 2. Parameter corrections in the rev_0002 candidate (named parameters only, no compensating coordinate edits).
  - [x] 2.1 Adopt measured values: esp32_board_len=57.1, esp32_board_w=28.15, esp32_usb_shell_h=4.4, oled_l=31.0 (+ oled_fpc_tail allowance ~4.4), oled_w=34.25, oled glass visible 33.5 x 15.4, button_h=5.4, button_actuator_top=9.3 above slot floor, esp32 header pin height 11.4, esp32_stack_h=16.5 (provisional-derived).
  - [x] 2.2 SD module resize: sd_pcb_x=28.2, sd_pcb_y=20.0, sd_cage_x=14.9, sd_cage_y=11.4, sd_card 15.0 x 11.1 x 1.0, sd_card_inserted/exposed updated, sd_slot 12.5 x 2.5 with chamfer, pocket cavity (28.2+0.6) x (20.0+0.6), pocket walls >= 3.0; keep pocket at right wall; freed floor space becomes wire alley.
  - [x] 2.3 USB cutout height derives from shell: usb_cutout_h = shell_h + 2*0.3 (>= 5.0), width stays 10.0.
- [ ] 3. Button retention redesign (user-specified workflow: solder wires to switch terminals first, then slide the pre-wired switch in from the side; terminals and solder joints live below the body with wire access).
  - [x] 3.1 Replace the two wells with a holding-slot block: per button a side-entry horizontal slot (12.4 wide x 5.6 tall x ~14 deep, 0.15/side slip clearance, 0.3 entry lead) with a back stop that aligns the actuator under the existing lid cap bores; cap bore X/Y positions and the lid part remain unchanged.
  - [x] 3.2 Slot entry faces the front wire alley; the block stands on 3.0 walls forming an under-chamber per button (>= 18 wide x >= 7 tall opening in the slot floor) admitting the kinked terminals (tip span <= 13.8), solder joints, and wire runs; chamber exits toward the strain-relief/alley side; assert all wall/floor sections >= 3.0.
  - [x] 3.3 Button vertical location: slot floor at base floor top; body top at 5.4; actuator top at 9.3 above slot floor; assert alignment to cap bores (shared parameters with the lid).
  - [x] 3.4 Recompute the cap stack for rev_0002: stem_bottom = actuator_top - cap_press(0.3) - socket_depth(2.5); stem length from parting plane; socket Ø4.0 over actuator Ø3.9 unchanged; keep cap bore Ø8.3 / stem Ø7.8 (printed fit verified).
  - [x] 3.5 Document the assembly sequence (wire -> slide in until back stop -> cap retains) in the design README.
- [ ] 4. Regression verification.
  - [x] 4.1 Complete build into output/handoff_case/ + `--audit-only` pass; contract validation pass.
  - [x] 4.2 Structural evidence for changed features: sections through the new slot block/under-chamber and resized SD pocket/slot; ligament asserts; shell check on base/cap STLs; record in README verification section (new rev_0002 subsection, rev_0001 section untouched).
  - [x] 4.3 Update the cap-stack coupon source at designs/handoff_case/probes/cap_stack_coupon.scad to the rev_0002 stack (actuator top 9.3, new stem numbers) with the same 3 press variants.
  - [x] 4.4 Artifact-bound assembly review for rev_0002 after artifact review.
- [ ] 5. Documentation and checkpoint.
  - [x] 5.1 README: append the 2026-10-29 feedback batch to the provenance table (marking superseded values), record feedback source + competing causes + evidence limits, update the known-unverified list (terminal drop length remains medium-confidence; printer conditions unrecorded).
  - [x] 5.2 Journal 2026-10-29 entry; review diff; propose commit message; commit and push after explicit approval. Journal written; diff reviewed; commit message proposed and approved by the user 2026-10-30; committed and pushed.

## Open items to resolve during execution

- OLED mounting-hole spans were not re-measured this batch; rev_0002 keeps the
  rev_0001 boss pattern (spans ~30.0 x 29.8 vs rigid PCB 34.25 x 31.0 - still
  inside). Flag for a future caliper pass.
- Terminal projection below body is medium-confidence (3.5-5.5); under-chamber
  height 7 covers the range; verify at physical assembly.
- Envelope not shrunk for the shorter board/module (end play and freed alley
  space accepted); a future revision may reclaim ~3.6 mm of depth.

## Authoring Rules

- Use `YYYY-MM-DD-HH-mm-ss_slug.md` with a lowercase, hyphenated slug.
- Make `plan_id` match the filename stem exactly.
- Use only the required front matter keys shown above.
- Decompose work until each leaf item has one clear completion condition.
- Use `[-]` only for intentionally closed or de-scoped work.
- Keep file location aligned to `future`, `current`, or `past` status.
