// ---------------------------------------------------------------------------
// defaults.scad - handoff_case
// Single source of truth for the envelope, component mockups, and detail
// geometry parameters. Every input parameter is guarded with an is_undef
// fallback so the design renders even when a parameter is missing from a
// config file. All derived layout quantities are computed by named
// functions below; no part file hardcodes a size-derived constant.
//
// Coordinate frame (assembly coordinates, shared by all parts and mockups):
//   datum: outer-front-left-bottom corner of the case at [0, 0, 0]
//   +X: right (left wall inner face at x = wall_t)
//   +Y: back  (front wall inner face at y = wall_t)
//   +Z: up    (floor inner face at z = floor_t)
//
// Layout (rev_0001, derived 2026-10-20):
//   Front -> back: [front margin + OLED zone (mounted on front-wall bosses)]
//   [wire alley 9] [ESP32 band: board 60.7 along Y on drop-in L-ledge rails,
//   USB short edge + shells toward the back wall] [usb gap 2].
//   Left -> right: [M3 tower + button wells | ESP32 band: header envelope
//   31.5] [band gap 8] [SD pocket, cage mouth + inserted card facing +X].
//   Tallest content is the OLED module (34.4); the lid seat clears it.
//
// NOTE on the approved face layout: the measured board has both USB-C shells
// on a SHORT edge (photo IMG_20261020_133657593), so "USB edge toward the
// back wall" fixes the board long axis (60.7) along Y. See the design README.
//
// Structural governance: AGENTS.md section 10 and
// playbooks/how_to_design_and_verify_structural_openscad_joins.md.
// ---------------------------------------------------------------------------

// ---- Structural minima (config inputs) ----
minimum_wall_thickness = is_undef(minimum_wall_thickness) ? 3.0 : minimum_wall_thickness;
minimum_structural_overlap = is_undef(minimum_structural_overlap) ? 3.0 : minimum_structural_overlap;
minimum_internal_edge_width = is_undef(minimum_internal_edge_width) ? 3.0 : minimum_internal_edge_width;

assert(minimum_structural_overlap >= minimum_wall_thickness,
    str("minimum_structural_overlap ", minimum_structural_overlap,
        " < minimum_wall_thickness ", minimum_wall_thickness));
assert(minimum_internal_edge_width >= minimum_wall_thickness,
    str("minimum_internal_edge_width ", minimum_internal_edge_width,
        " < minimum_wall_thickness ", minimum_wall_thickness));

// ---- Boolean hygiene ----
boolean_epsilon = is_undef(boolean_epsilon) ? 0.01 : boolean_epsilon;

// ---- Shell section sizes ----
wall_t = is_undef(wall_t) ? 3.0 : wall_t;
floor_t = is_undef(floor_t) ? 3.0 : floor_t;
// lid_t = m3_cbore_depth (4.0) + the 3.0 mm retained floor under each
// head recess (raspberrypi5_case pattern), so the lid is 7.0 thick.
lid_t = is_undef(lid_t) ? 7.0 : lid_t;

// ---- Component provenance dimensions (design README table; mm) ----
// ESP32-S3 dev board (rev_0002 caliper batch 2026-10-29: 57.1 x 28.15 x
// 1.6, USB shells on the short edge opposite the module, protruding 7.7
// past the PCB, shell height 4.4; above-board header+Dupont stack 16.5
// provisional-derived from 11.4 measured pin height).
esp32_board_len = is_undef(esp32_board_len) ? 57.1 : esp32_board_len;
esp32_board_w = is_undef(esp32_board_w) ? 28.15 : esp32_board_w;
esp32_board_t = is_undef(esp32_board_t) ? 1.6 : esp32_board_t;
// Board width including the soldered side headers (1.6 mm overhang/side,
// unchanged from rev_0001's read).
esp32_header_w = is_undef(esp32_header_w) ? 31.35 : esp32_header_w;
esp32_usb_protrusion = is_undef(esp32_usb_protrusion) ? 7.7 : esp32_usb_protrusion;
esp32_usb_shell_w = is_undef(esp32_usb_shell_w) ? 9.0 : esp32_usb_shell_w;
esp32_usb_shell_h = is_undef(esp32_usb_shell_h) ? 4.4 : esp32_usb_shell_h;
// Shell centers measured from the board's header-top long edge (photo
// IMG_20261020_133657593): 4.1 / 16.4, 12.3 apart.
esp32_usb_center_a = is_undef(esp32_usb_center_a) ? 4.1 : esp32_usb_center_a;
esp32_usb_center_b = is_undef(esp32_usb_center_b) ? 16.4 : esp32_usb_center_b;
esp32_stack_h = is_undef(esp32_stack_h) ? 16.5 : esp32_stack_h;
// Underside header pin tips (~1.5 below the PCB underside) and their
// inboard inset from the long edges (2.5-3.0; minimum used for guards).
esp32_pin_tip_drop = is_undef(esp32_pin_tip_drop) ? 1.5 : esp32_pin_tip_drop;
esp32_header_pin_inset = is_undef(esp32_header_pin_inset) ? 2.5 : esp32_header_pin_inset;
// Top-side keep-outs (photo 133657593; plan 3.2 item 2): RST/BOOT 3x4
// outlines at 24.5 / 30.1 from the antenna end, 5.7 from the header-top
// long edge; module shield can at the antenna end, ~25.5 across the board
// width x ~18 along the length (WROOM-1 18.0 x 25.5 rotated; matches the
// provenance table). Conservative: the meander antenna extends past the
// can, so the keep-out is treated as a hard no-pad zone at the antenna end
// and the blades additionally clear the measured RST/BOOT boxes.
esp32_rst_from_antenna = is_undef(esp32_rst_from_antenna) ? 24.5 : esp32_rst_from_antenna;
esp32_boot_from_antenna = is_undef(esp32_boot_from_antenna) ? 30.1 : esp32_boot_from_antenna;
esp32_button_edge_inset = is_undef(esp32_button_edge_inset) ? 5.7 : esp32_button_edge_inset;
esp32_button_keepout_w = is_undef(esp32_button_keepout_w) ? 3.0 : esp32_button_keepout_w;
esp32_button_keepout_l = is_undef(esp32_button_keepout_l) ? 4.0 : esp32_button_keepout_l;
esp32_shield_zone_w = is_undef(esp32_shield_zone_w) ? 25.5 : esp32_shield_zone_w;
esp32_shield_zone_l = is_undef(esp32_shield_zone_l) ? 18.0 : esp32_shield_zone_l;

// 1.3" I2C OLED module (rev_0002 caliper batch: rigid PCB 31.0 x 34.25 x
// 0.9 with ~4.4 FPC tail beyond the +X rigid edge; visible area 33.5 x 15.4;
// header 1x4 on a long edge; glass-to-pin-tip depth ~10.0-10.5; glass face
// 2.3 proud of the PCB front face; mounting holes dia 2.9 at ~30.0 x 29.8,
// NOT re-measured this batch - rev_0001 boss pattern kept, spans still
// inside the rigid 31.0 x 34.25).
oled_w = is_undef(oled_w) ? 31.0 : oled_w;
oled_h = is_undef(oled_h) ? 34.25 : oled_h;
oled_t = is_undef(oled_t) ? 0.9 : oled_t;
oled_depth = is_undef(oled_depth) ? 10.5 : oled_depth;
// FPC tail allowance beyond the +X rigid edge (width along the edge is
// provisional; fold runs in the wire alley at the module bottom).
oled_fpc_tail = is_undef(oled_fpc_tail) ? 4.4 : oled_fpc_tail;
oled_fpc_tail_w = is_undef(oled_fpc_tail_w) ? 10.0 : oled_fpc_tail_w;
oled_fpc_tail_t = is_undef(oled_fpc_tail_t) ? 0.3 : oled_fpc_tail_t;
oled_glass_w = is_undef(oled_glass_w) ? 33.5 : oled_glass_w;
oled_glass_h = is_undef(oled_glass_h) ? 24.6 : oled_glass_h;
// Glass margins on the module PCB: L 0.5 / header-side 5.7 / flex-side 3.6.
oled_glass_margin_x = is_undef(oled_glass_margin_x) ? 0.5 : oled_glass_margin_x;
oled_glass_margin_flex = is_undef(oled_glass_margin_flex) ? 3.6 : oled_glass_margin_flex;
// Glass proud of the PCB front face (measured display stack).
oled_glass_proud = is_undef(oled_glass_proud) ? 2.3 : oled_glass_proud;
oled_header_w = is_undef(oled_header_w) ? 10.2 : oled_header_w;
oled_header_h = is_undef(oled_header_h) ? 2.5 : oled_header_h;
oled_hole_span_x = is_undef(oled_hole_span_x) ? 30.0 : oled_hole_span_x;
oled_hole_span_z = is_undef(oled_hole_span_z) ? 29.8 : oled_hole_span_z;
oled_hole_d = is_undef(oled_hole_d) ? 2.9 : oled_hole_d;

// microSD reader module + inserted microSD card (rev_0002 caliper batch:
// PCB 28.2 along the card axis x 20.0; cage ~14.9 along the card axis x
// 11.4 across x ~2.9 high; card 15.0 x 11.1 x 1.0, ~3.7 inserted, ~11.3
// exposed. Module identity changed between batches - see README feedback
// record; reverting to the full-size module is a parameter change).
sd_pcb_x = is_undef(sd_pcb_x) ? 28.2 : sd_pcb_x;
sd_pcb_y = is_undef(sd_pcb_y) ? 20.0 : sd_pcb_y;
sd_pcb_t = is_undef(sd_pcb_t) ? 1.6 : sd_pcb_t;
sd_cage_x = is_undef(sd_cage_x) ? 14.9 : sd_cage_x;
sd_cage_y = is_undef(sd_cage_y) ? 11.4 : sd_cage_y;
sd_cage_h = is_undef(sd_cage_h) ? 2.9 : sd_cage_h;
sd_card_len = is_undef(sd_card_len) ? 15.0 : sd_card_len;
sd_card_w = is_undef(sd_card_w) ? 11.1 : sd_card_w;
sd_card_t = is_undef(sd_card_t) ? 1.0 : sd_card_t;
sd_card_inserted = is_undef(sd_card_inserted) ? 3.7 : sd_card_inserted;
// Card seated in the cage slot, label up, top flush with the cage top:
// seat = cage_h - card_t (1.9); derived, asserted in base().
sd_card_seat = is_undef(sd_card_seat) ? 1.9 : sd_card_seat;

// Tactile buttons x2 (rev_0002 caliper batch: body 12.1 sq x 5.4 h, cap
// dia 8.1, actuator dia 3.9 with its top 9.3 above the mounting floor i.e.
// 3.9 protrusion above the body; 4 kinked corner terminals ~1.1 x 0.4,
// tips splaying to ~13.4-13.8 span, ~3.5-5.5 below the body; pair spacing
// 16.3 center to center).
button_body = is_undef(button_body) ? 12.1 : button_body;
button_h = is_undef(button_h) ? 5.4 : button_h;
button_cap_d = is_undef(button_cap_d) ? 8.1 : button_cap_d;
button_switch_cap_h = is_undef(button_switch_cap_h) ? 1.5 : button_switch_cap_h;
button_actuator_d = is_undef(button_actuator_d) ? 3.9 : button_actuator_d;
button_actuator_h = is_undef(button_actuator_h) ? 3.9 : button_actuator_h;
button_spacing = is_undef(button_spacing) ? 16.3 : button_spacing;
button_terminal_span = is_undef(button_terminal_span) ? 13.8 : button_terminal_span;
button_terminal_drop = is_undef(button_terminal_drop) ? 5.5 : button_terminal_drop;
// Terminal span/drop are medium-confidence (see README); the under-chamber
// is sized to the worst end of both ranges.

// ---- Detail feature parameters (plan items 3.2-3.4) ----
// ESP32 drop-in L-ledge rails (3.2 item 1): outer wall 3.0 + land 2.0
// wide; the board lifts so underside pin tips keep >= 2.0 to the floor.
rail_wall_t = is_undef(rail_wall_t) ? 3.0 : rail_wall_t;
rail_land_w = is_undef(rail_land_w) ? 2.0 : rail_land_w;
rail_pin_floor_clear = is_undef(rail_pin_floor_clear) ? 2.0 : rail_pin_floor_clear;
// End-stop bar at the USB end (3.2 item 1): 3.0 thick, top exactly at the
// board top face, notched around the protruding USB shells.
end_stop_t = is_undef(end_stop_t) ? 3.0 : end_stop_t;
end_stop_notch_clear = is_undef(end_stop_notch_clear) ? 0.15 : end_stop_notch_clear;
// OLED bosses + window (3.2 item 3).
oled_boss_d = is_undef(oled_boss_d) ? 6.0 : oled_boss_d;
oled_boss_h = is_undef(oled_boss_h) ? 3.5 : oled_boss_h;
oled_boss_pilot_d = is_undef(oled_boss_pilot_d) ? 2.5 : oled_boss_pilot_d;
oled_boss_pilot_depth = is_undef(oled_boss_pilot_depth) ? 6.0 : oled_boss_pilot_depth;
oled_boss_pilot_skin = is_undef(oled_boss_pilot_skin) ? 0.5 : oled_boss_pilot_skin;
oled_window_clear = is_undef(oled_window_clear) ? 0.4 : oled_window_clear;
oled_window_corner_r = is_undef(oled_window_corner_r) ? 1.0 : oled_window_corner_r;
oled_window_glass_inset = is_undef(oled_window_glass_inset) ? 1.0 : oled_window_glass_inset;
// OLED active window (standard 1.3" 128x64 active area).
oled_active_w = is_undef(oled_active_w) ? 29.42 : oled_active_w;
oled_active_h = is_undef(oled_active_h) ? 14.7 : oled_active_h;
// SD pocket + card slot (3.2 item 4).
sd_pocket_clear = is_undef(sd_pocket_clear) ? 0.3 : sd_pocket_clear;
sd_pocket_wall_t = is_undef(sd_pocket_wall_t) ? 3.0 : sd_pocket_wall_t;
sd_pocket_pad_h = is_undef(sd_pocket_pad_h) ? 3.0 : sd_pocket_pad_h;
sd_pocket_wall_h = is_undef(sd_pocket_wall_h) ? 4.5 : sd_pocket_wall_h;
sd_slot_w = is_undef(sd_slot_w) ? 25.5 : sd_slot_w;
sd_slot_h = is_undef(sd_slot_h) ? 3.3 : sd_slot_h;
sd_slot_chamfer = is_undef(sd_slot_chamfer) ? 1.0 : sd_slot_chamfer;
// USB cutouts (3.2 item 5; rev_0002: height derives from the 4.4 shell).
usb_cutout_w = is_undef(usb_cutout_w) ? 10.0 : usb_cutout_w;
usb_cutout_h = is_undef(usb_cutout_h) ? 5.0 : usb_cutout_h;
usb_cutout_r = is_undef(usb_cutout_r) ? 1.0 : usb_cutout_r;
usb_cutout_clear = is_undef(usb_cutout_clear) ? 0.3 : usb_cutout_clear;
// Button side-entry holding slots (rev_0002, plan item 3: solder wires to
// the terminals first, then slide the pre-wired switch in from the front;
// the back stop aligns the actuator under the unchanged lid cap bores).
// Slot floor = base floor top (z = floor_t): body top at 8.4, actuator top
// at 12.3 (= 9.3 above the slot floor, measured).
slot_clear = is_undef(slot_clear) ? 0.15 : slot_clear;
slot_entry_lead = is_undef(slot_entry_lead) ? 0.3 : slot_entry_lead;
slot_wall_t = is_undef(slot_wall_t) ? 3.0 : slot_wall_t;
slot_tower_gap = is_undef(slot_tower_gap) ? 0.5 : slot_tower_gap;
// Under-chamber for the kinked terminals + solder joints + wire runs: the
// block stands on 3.0 outer walls; the chamber floor is the base floor top
// and the slot's floor is OPEN into the chamber (the >= 18 x >= 7 mouth).
// Chamber height 10.0 (>= the 7.0 plan opening, >= the 5.5 terminal drop).
chamber_h = is_undef(chamber_h) ? 10.0 : chamber_h;
chamber_opening_w = is_undef(chamber_opening_w) ? 18.0 : chamber_opening_w;
chamber_opening_h = is_undef(chamber_opening_h) ? 7.0 : chamber_opening_h;
well_wire_slot_d = is_undef(well_wire_slot_d) ? 2.0 : well_wire_slot_d;
// Strain-relief posts (3.2 item 7): dia 8 so the dia 2 zip-tie bore
// keeps 3.0 rims (a dia 5 post would leave 1.5 mm rims).
strain_post_d = is_undef(strain_post_d) ? 8.0 : strain_post_d;
strain_post_h = is_undef(strain_post_h) ? 8.0 : strain_post_h;
strain_post_bore_d = is_undef(strain_post_bore_d) ? 2.0 : strain_post_bore_d;
strain_post_oled = is_undef(strain_post_oled) ? [60.0, 19.0] : strain_post_oled;
strain_post_sd = is_undef(strain_post_sd) ? [60.0, 71.5] : strain_post_sd;
// M3 lid screw stations / stud towers (3.3). The front-right station is
// moved to y = 21: the front-right corner is occupied by the OLED module
// and its right mounting boss (blockout put the stations at all corners).
m3_inset = is_undef(m3_inset) ? 8.0 : m3_inset;
m3_tower_size = is_undef(m3_tower_size) ? 13.0 : m3_tower_size;
m3_fr_station_y = is_undef(m3_fr_station_y) ? 22.0 : m3_fr_station_y;
m3_pilot_d = is_undef(m3_pilot_d) ? 3.0 : m3_pilot_d;
m3_pilot_depth = is_undef(m3_pilot_depth) ? 8.0 : m3_pilot_depth;
m3_clear_d = is_undef(m3_clear_d) ? 3.4 : m3_clear_d;
m3_cbore_d = is_undef(m3_cbore_d) ? 7.0 : m3_cbore_d;
m3_cbore_depth = is_undef(m3_cbore_depth) ? 4.0 : m3_cbore_depth;
// Lid thickness must retain the minimum floor under each head recess.
assert(lid_t >= m3_cbore_depth + minimum_wall_thickness,
    str("lid_t ", lid_t, " < m3_cbore_depth ", m3_cbore_depth,
        " + minimum_wall_thickness ", minimum_wall_thickness));
// A tower must contain its station pilot with the minimum rim: the
// station inset + pilot radius + minimum_internal_edge_width <= tower size.
assert(m3_tower_size >= m3_inset + m3_pilot_d / 2 + minimum_internal_edge_width,
    str("m3_tower_size ", m3_tower_size, " too small for station inset ",
        m3_inset, " with a ", m3_pilot_d, " pilot and ",
        minimum_internal_edge_width, " rim"));
// Button-cap guide bores, anti-lift blades, vents (3.3).
cap_bore_d = is_undef(cap_bore_d) ? 8.3 : cap_bore_d;
anti_lift_blade_w = is_undef(anti_lift_blade_w) ? 1.6 : anti_lift_blade_w;
anti_lift_blade_t = is_undef(anti_lift_blade_t) ? 3.0 : anti_lift_blade_t;
anti_lift_blade_y0 = is_undef(anti_lift_blade_y0) ? 62.0 : anti_lift_blade_y0;
anti_lift_blade_y1 = is_undef(anti_lift_blade_y1) ? 85.0 : anti_lift_blade_y1;
anti_lift_keepout_clear = is_undef(anti_lift_keepout_clear) ? 2.0 : anti_lift_keepout_clear;
vent_w = is_undef(vent_w) ? 15.0 : vent_w;
vent_t = is_undef(vent_t) ? 2.0 : vent_t;
vent_x_starts = is_undef(vent_x_starts) ? [47.0, 66.0] : vent_x_starts;
vent_y_starts = is_undef(vent_y_starts) ? [64.0, 71.0, 78.0] : vent_y_starts;
// Button cap (3.4): stem, socket, press; flange sized by the 3.0 mm rim
// rule (cap_bore_d + 2*3.0) and 3.0 thick - see README deviations.
cap_stem_d = is_undef(cap_stem_d) ? 7.8 : cap_stem_d;
cap_socket_d = is_undef(cap_socket_d) ? 4.0 : cap_socket_d;
cap_socket_depth = is_undef(cap_socket_depth) ? 2.5 : cap_socket_depth;
cap_press = is_undef(cap_press) ? 0.3 : cap_press;
cap_flange_d = is_undef(cap_flange_d) ? 14.6 : cap_flange_d;
cap_flange_t = is_undef(cap_flange_t) ? 3.0 : cap_flange_t;

// ---- Layout parameters (named placements; config-driven) ----
front_margin = is_undef(front_margin) ? 5.0 : front_margin;
alley = is_undef(alley) ? 9.0 : alley;
board_margin_left = is_undef(board_margin_left) ? 5.0 : board_margin_left;
// rev_0002: the envelope is PINNED at the rev_0001 interior (93.8 x 100.9
// outer; the lid part and cap-bore positions stay unchanged). The shorter
// board/module free end play (usb end) and extra wire alley (band gap)
// instead of shrinking the case.
band_gap_min = is_undef(band_gap_min) ? 8.0 : band_gap_min;
usb_gap_min = is_undef(usb_gap_min) ? 2.0 : usb_gap_min;
interior_w_pinned = is_undef(interior_w_pinned) ? 87.8 : interior_w_pinned;
interior_d_pinned = is_undef(interior_d_pinned) ? 94.9 : interior_d_pinned;
sd_tip_gap = is_undef(sd_tip_gap) ? 1.0 : sd_tip_gap;
sd_y_offset = is_undef(sd_y_offset) ? 27.5 : sd_y_offset;
button_margin_front = is_undef(button_margin_front) ? 5.0 : button_margin_front;
button_oled_gap = is_undef(button_oled_gap) ? 3.0 : button_oled_gap;
lid_clearance = is_undef(lid_clearance) ? 8.0 : lid_clearance;

// ---- Maximum print dimension (sanity bound, not used for geometry) ----
maximum_print_dimension = is_undef(maximum_print_dimension) ? 300.0 : maximum_print_dimension;

// Layout-floor assert: the blockout wire alleys are specified at 8-10 mm.
assert(alley >= 8.0,
    str("wire alley ", alley, " mm < the 8-10 mm blockout band"));

// ===========================================================================
// Derived envelope (computed from the config inputs above; no part file
// hardcodes these). World frame: see the header.
// ===========================================================================

function button_pair_w() = button_spacing + button_body;

// Interior envelope (rev_0002): pinned at the rev_0001 values so the lid
// and all lid-side geometry stay identical. The gaps between bands become
// derived absorbers: the band gap (ESP32 rail band -> SD pocket wall)
// absorbs the narrower microSD module as extra wire alley; the USB gap
// absorbs the shorter board as end play at the USB end.
function interior_w() = interior_w_pinned;
function interior_d() = interior_d_pinned;
function interior_h() = oled_h + lid_clearance;
function band_gap() = interior_w() - board_margin_left - esp32_header_w
    - sd_pcb_x - sd_card_exposed() - sd_tip_gap;
function usb_gap() = interior_d() - front_margin - oled_depth - alley
    - esp32_board_len - esp32_usb_protrusion;

// Exposed card length beyond the cage mouth (provenance: ~13).
function sd_card_exposed() = sd_card_len - sd_card_inserted;

function outer_w() = interior_w() + 2 * wall_t;
function outer_d() = interior_d() + 2 * wall_t;
function base_outer_h() = floor_t + interior_h();
function parting_z() = base_outer_h();
function lid_top_z() = parting_z() + lid_t;

function case_center() = [outer_w() / 2, outer_d() / 2, lid_top_z() / 2];

// ---- ESP32 band anchors (world coordinates) ----
function esp32_env_x0() = wall_t + board_margin_left;
function esp32_pcb_x0() = esp32_env_x0() + (esp32_header_w - esp32_board_w) / 2;
function esp32_pcb_x1() = esp32_pcb_x0() + esp32_board_w;
function esp32_pcb_y0() = wall_t + front_margin + oled_depth + alley;
function esp32_pcb_y1() = esp32_pcb_y0() + esp32_board_len;
// Board lift: the land must be >= 3.0 thick AND the underside header pin
// tips must keep >= rail_pin_floor_clear to the floor, so the lift is the
// max of the two (1.5 + 2.0 = 3.5 governs over the 3.0 land minimum).
function board_lift() = max(minimum_wall_thickness,
    esp32_pin_tip_drop + rail_pin_floor_clear);
function board_underside_z() = floor_t + board_lift();
function board_top_z() = board_underside_z() + esp32_board_t;
function esp32_usb_shell_z0() = board_underside_z();
function esp32_usb_shell_z1() = board_top_z() + esp32_usb_shell_h;
// Shell center x positions (from the header-top long edge measurements).
function esp32_usb_xa() = esp32_pcb_x1() - esp32_usb_center_a;
function esp32_usb_xb() = esp32_pcb_x1() - esp32_usb_center_b;

// ---- OLED anchors: mounted on front-wall bosses ----
// Bosses hold the PCB front face off the wall; the glass face sits
// oled_boss_h - oled_glass_proud clear of the wall inner face.
function oled_wall_clear() = oled_boss_h - oled_glass_proud;
function oled_x0() = button_slot_block_x1() + button_oled_gap;
function oled_glass_y0() = wall_t + oled_wall_clear();
function oled_pcb_y0() = wall_t + oled_boss_h;
function oled_z0() = floor_t;
function oled_glass_cx() = oled_x0() + oled_glass_margin_x + oled_glass_w / 2;
function oled_glass_cz() = oled_z0() + oled_glass_margin_flex + oled_glass_h / 2;
function oled_hole_x0() = oled_x0() + (oled_w - oled_hole_span_x) / 2;
function oled_hole_x1() = oled_hole_x0() + oled_hole_span_x;
function oled_hole_z0() = oled_z0() + (oled_h - oled_hole_span_z) / 2;
function oled_hole_z1() = oled_hole_z0() + oled_hole_span_z;
// Window = active area + 2*clearance per side, centered on the glass.
function oled_window_w() = oled_active_w + 2 * oled_window_clear;
function oled_window_h() = oled_active_h + 2 * oled_window_clear;

// ---- Button side-entry holding-slot block (rev_0002, plan item 3) ----
// User workflow: solder wires to the switch terminals first, then slide the
// pre-wired switch in from the FRONT; the body rides in a CLOSED-TOP slot,
// the kinked terminals + solder joints drop through the slot's OPEN FLOOR
// into the under-chamber (floor = base floor top), and the back stop seats
// the actuator under the unchanged lid cap bores. Centers are the cap-bore
// datum and MUST NOT move: the block x-origin and the slot-centering bay
// reproduce the rev_0001 well positions exactly.
function slot_w() = button_body + 2 * slot_clear;        // 12.4 slip
function slot_h() = button_h + 0.2;                       // 5.6 (0.1/side)
function slot_depth() = 14.0;
function slot_bay_margin() = 0.2;                         // rev_0001 datum
// Chamber under the block; the slot floor plate (3.0) over it carries the
// body on its cross-shaped bearing, with corner windows admitting the
// kinked terminal tips into the chamber (geometry in base.scad).
function chamber_top_z() = floor_t + chamber_h;               // 10.0
function slot_floor_z() = chamber_top_z()
    + minimum_wall_thickness;                                 // 13.0
function slot_ceiling_z() = slot_floor_z() + slot_h();        // 18.6
function slot_top_z() = slot_ceiling_z()
    + minimum_wall_thickness;                                 // 21.6 (closed top)
// Terminal tip clearance half-span for the corner windows.
function slot_tip_clear_half() = button_terminal_span / 2 + 0.5;
// Corner window geometry (cuts through the floor plate): each window
// covers the splayed tip envelope from the tip circle inward to just under
// the body edge, 3.0 deep at the floor's front and back edges.
function slot_window_inner() = button_body / 2 - 1.85;
function slot_window_d() = 3.0;
function button_slot_stop_y() = button_center_y_nominal()
    + button_body / 2;
function button_center_y_nominal() = wall_t + button_margin_front
    + slot_wall_t + (button_body + 2 * slot_bay_margin()) / 2;
function button_center(i) = [
    m3_tower_size + slot_tower_gap + slot_wall_t
        + (button_body + 2 * slot_bay_margin()) / 2 + i * button_spacing,
    button_center_y_nominal()
];
function button_slot_entry_y() = button_slot_stop_y() - slot_depth();
// The chamber is wider than the slot pair: the 13.8 mm terminal tips splay
// past the 12.4 mm slots, so the chamber side walls stand outside the tip
// envelope. The block's left end tucks 2.0 mm under the front-left M3
// tower (merged solids, no gap).
slot_block_tower_overlap = is_undef(slot_block_tower_overlap) ? 2.0 : slot_block_tower_overlap;
function slot_tip_clearance() = 0.5;
function slot_chamber_half_w() = button_terminal_span / 2
    + slot_tip_clearance();
function button_slot_block_x0() = m3_tower_size + slot_tower_gap
    - slot_block_tower_overlap;
function button_chamber_x0() = button_center(0)[0] - slot_chamber_half_w();
function button_chamber_x1() = button_center(1)[0] + slot_chamber_half_w();
function slot_outer_wall_t() = button_chamber_x0() - button_slot_block_x0();
function button_slot_block_x1() = button_chamber_x1() + slot_outer_wall_t();
function button_slot_block_y0() = button_slot_entry_y();
function button_slot_block_y1() = button_slot_stop_y() + slot_wall_t;
// Slot-level outer wall faces (the stepped-upper wall footprint).
function button_slot_up_x0() = button_slot_x0(0) - slot_wall_t;
function button_slot_up_x1() = button_slot_x1(1) + slot_wall_t;
// Slot x-spans (closed-top channels) and the middle web between them.
function button_slot_x0(i) = button_center(i)[0] - slot_w() / 2;
function button_slot_x1(i) = button_center(i)[0] + slot_w() / 2;
function button_slot_web_x0() = button_slot_x1(0);
function button_slot_web_x1() = button_slot_x0(1);
// Under-chamber: shared cavity (both bays) under the slot floor plate;
// open at the front (the >= 18 x >= 7 mouth) and at the back (wire exit
// toward the alley); floor = the base floor top.
function button_chamber_h() = chamber_top_z() - floor_t;

// Cap stack arithmetic (rev_0002, plan 3.4): the button rests on the
// ELEVATED slot floor (the under-chamber is below it), so the actuator top
// sits 9.3 above the slot floor; the socket top presses it cap_press below
// nominal at lid closed; the stem bottom clears the body top (no relief
// needed at rev_0002 stack heights).
function button_body_top_z() = slot_floor_z() + button_h;
function button_actuator_top_z() = slot_floor_z()
    + button_h + button_actuator_h;
function cap_stem_bottom_z() = button_actuator_top_z() - cap_press
    - cap_socket_depth;
function cap_stem_top_z() = parting_z() + lid_t;
function cap_stem_len() = cap_stem_top_z() - cap_stem_bottom_z();
// Relief over the switch's own cap (dia 8.1 x ~1.5) so the stem bottom can
// reach the plunger; depth derived from the stack (0 at rev_0001 heights).
function cap_switch_cap_top_z() = button_body_top_z() + button_switch_cap_h;
function cap_relief_d() = button_cap_d + 0.6;
function cap_relief_depth() = max(0,
    cap_switch_cap_top_z() - cap_stem_bottom_z() + 0.5);

// ---- SD anchors (module rests on a raised pocket floor pad) ----
function sd_pcb_x0() = wall_t + interior_w() - sd_tip_gap - sd_card_exposed() - sd_pcb_x;
function sd_pcb_x1() = sd_pcb_x0() + sd_pcb_x;
function sd_cage_x0() = sd_pcb_x1() - sd_cage_x;
function sd_card_x0() = sd_pcb_x1() - sd_card_inserted;
function sd_card_x1() = sd_card_x0() + sd_card_len;
function sd_pcb_y0() = wall_t + sd_y_offset;
function sd_pocket_x0() = sd_pcb_x0() - sd_pocket_clear - sd_pocket_wall_t;
function sd_pocket_x1() = sd_pcb_x1() + sd_pocket_clear;
function sd_pocket_y0() = sd_pcb_y0() - sd_pocket_clear - sd_pocket_wall_t;
function sd_pocket_y1() = sd_pcb_y0() + sd_pcb_y + sd_pocket_clear;
function sd_pad_top_z() = floor_t + sd_pocket_pad_h;
function sd_pocket_top_z() = sd_pad_top_z() + sd_pocket_wall_h;
function sd_card_cy() = sd_pcb_y0() + (sd_pcb_y - sd_card_w) / 2 + sd_card_w / 2;
function sd_card_z0() = sd_pad_top_z() + sd_pcb_t + sd_card_seat;
function sd_cage_mouth_cy() = sd_pcb_y0() + sd_pcb_y / 2;

// ---- M3 stations / towers ----
// [fl, fr, bl, br]; fr is moved forward-to-back to clear the OLED zone.
function m3_stations() = [
    [m3_inset, m3_inset],
    [outer_w() - m3_inset, m3_fr_station_y],
    [m3_inset, outer_d() - m3_inset],
    [outer_w() - m3_inset, outer_d() - m3_inset]
];
function m3_tower_rects() = [
    [0, 0, m3_tower_size, m3_tower_size],
    [outer_w() - m3_tower_size, m3_fr_station_y - m3_tower_size / 2,
     outer_w(), m3_fr_station_y + m3_tower_size / 2],
    [0, outer_d() - m3_tower_size, m3_tower_size, outer_d()],
    [outer_w() - m3_tower_size, outer_d() - m3_tower_size,
     outer_w(), outer_d()]
];

// ---- Anti-lift blades (lid) over the board's long-edge top strips ----
// Blade x-span sits between the board edge and the header-pin zone
// (pins >= 2.5 inboard), i.e. the pad keeps the pin inset.
function anti_lift_blade_x0() = esp32_pcb_x1() - 0.2 - anti_lift_blade_w;
function anti_lift_blade_x1() = esp32_pcb_x1() - 0.2;
function anti_lift_blade2_x0() = esp32_pcb_x0() + 0.2;
function anti_lift_blade2_x1() = esp32_pcb_x0() + 0.2 + anti_lift_blade_w;

// ---- Mockup fit guards (construction asserts; STL evidence later) ----
assert(esp32_pcb_y0() + esp32_board_len + esp32_usb_protrusion
       <= wall_t + interior_d() - usb_gap() + boolean_epsilon,
    "ESP32 USB shells exceed the back-wall access gap");
assert(usb_gap() >= usb_gap_min,
    str("usb gap ", usb_gap(), " < floor ", usb_gap_min));
assert(band_gap() >= band_gap_min,
    str("band gap ", band_gap(), " < floor ", band_gap_min,
        " - the microSD module must not grow back into the rail band"));
assert(sd_card_x1() <= wall_t + interior_w() - sd_tip_gap + boolean_epsilon,
    "SD card tip crosses the right-wall slot plane");
// The SD pocket wall must clear the right rail's outer face (the pocket
// wall may extend into the band gap; the gap is module-to-module).
assert(sd_pocket_x0() >= esp32_pcb_x1() + rail_land_w + rail_wall_t + 0.5
       - boolean_epsilon,
    "SD pocket wall fouls the right rail");
// The SD module occupies the band BEHIND the front (OLED/button) zone:
// the front zone end to the SD pocket front wall is one of the wire alleys.
assert(sd_pocket_y0() >= wall_t + front_margin + oled_depth + 8.0 - boolean_epsilon,
    "SD pocket to OLED zone gap < the 8 mm wire alley floor");
// The OLED (rigid + FPC tail) must stay inside the interior and clear of
// the right wall / front-right tower zone.
assert(oled_x0() + oled_w + oled_fpc_tail
       <= wall_t + interior_w() - 2.0,
    "OLED rigid + FPC tail crosses the interior right edge");
// Rails / board stack fit under the lid with the content clearance.
assert(board_top_z() + esp32_stack_h
       <= wall_t + 0 + interior_h() - lid_clearance + boolean_epsilon,
    "ESP32 above-board stack exceeds the lid content clearance");
assert(oled_z0() + oled_h <= wall_t + 0 + interior_h() - lid_clearance
       + boolean_epsilon,
    "OLED exceeds the lid content clearance");
// Button slot block: slip fit, chamber admission, datum alignment.
assert(slot_w() - button_body >= 2 * slot_clear - boolean_epsilon,
    "slot narrower than the slip clearance");
assert(button_chamber_x1() - button_chamber_x0() >= button_terminal_span,
    str("under-chamber ", button_chamber_x1() - button_chamber_x0(),
        " < the terminal tip span ", button_terminal_span));
assert(button_chamber_h() >= button_terminal_drop,
    str("under-chamber height ", button_chamber_h(),
        " < the terminal drop ", button_terminal_drop));
assert(button_chamber_h() >= chamber_opening_h,
    "chamber mouth taller than the chamber");
assert(chamber_opening_w >= 18.0 && chamber_opening_h >= 7.0,
    "chamber mouth below the plan minimum (18 x 7)");
assert(abs(button_center(1)[0] - button_center(0)[0] - button_spacing)
       <= boolean_epsilon,
    "button centers do not match the measured spacing (cap-bore datum)");
assert(cap_stem_bottom_z() >= button_body_top_z() - boolean_epsilon,
    str("cap stem bottom ", cap_stem_bottom_z(),
        " fouls the button body top ", button_body_top_z()));
// Anti-lift blades must miss the top keep-outs by the clearance floor.
assert(anti_lift_blade_y0 >= esp32_pcb_y0() + esp32_shield_zone_l
       + anti_lift_keepout_clear - boolean_epsilon,
    "anti-lift blades start inside the module shield keep-out");
assert(anti_lift_blade_y0 >= esp32_pcb_y0() + esp32_boot_from_antenna
       + esp32_button_keepout_l / 2 + anti_lift_keepout_clear - boolean_epsilon,
    "anti-lift blades start inside the RST/BOOT keep-out");
assert(cap_press <= button_actuator_h / 2,
    "cap press exceeds half the measured actuator height");

// Part dispatch fallback (main.scad overrides via the build scripts).
part_id = is_undef(part_id) ? 0 : part_id;

// Rounded-rectangle 2D profile (CCW, arcs resolved to line segments) for
// polygon()-based wall cut prisms. NOTE: wide rounded-rect cut prisms
// degenerate under CGAL in OpenSCAD 2021.01 once their width exceeds
// ~27-30 mm (straight runs vanish in the exported STL; the preview hides
// it). Callers must split wide windows into overlapping <= 22 mm prisms
// (see base.scad); each child stays under the failure threshold.
function rr_profile(cx, cz, w, h, r, n = 8) =
    let(hw = w / 2, hh = h / 2)
    [ for (c = [[-1, -1, 180], [1, -1, 270], [1, 1, 0], [-1, 1, 90]])
        let(bx = cx + c[0] * (hw - r), bz = cz + c[1] * (hh - r))
        for (i = [0:n-1])
            let(a = c[2] + i / (n - 1) * 90)
            [bx + r * cos(a), bz + r * sin(a)]
    ];
