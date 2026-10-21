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
// ESP32-S3 dev board (60.7 x 28.3 x 1.6; USB shells on the short edge
// opposite the module, protruding 7.7 past the PCB; above-board
// header + Dupont stack ~13).
esp32_board_len = is_undef(esp32_board_len) ? 60.7 : esp32_board_len;
esp32_board_w = is_undef(esp32_board_w) ? 28.3 : esp32_board_w;
esp32_board_t = is_undef(esp32_board_t) ? 1.6 : esp32_board_t;
esp32_header_w = is_undef(esp32_header_w) ? 31.5 : esp32_header_w;
esp32_usb_protrusion = is_undef(esp32_usb_protrusion) ? 7.7 : esp32_usb_protrusion;
esp32_usb_shell_w = is_undef(esp32_usb_shell_w) ? 9.0 : esp32_usb_shell_w;
esp32_usb_shell_h = is_undef(esp32_usb_shell_h) ? 3.2 : esp32_usb_shell_h;
// Shell centers measured from the board's header-top long edge (photo
// IMG_20261020_133657593): 4.1 / 16.4, 12.3 apart.
esp32_usb_center_a = is_undef(esp32_usb_center_a) ? 4.1 : esp32_usb_center_a;
esp32_usb_center_b = is_undef(esp32_usb_center_b) ? 16.4 : esp32_usb_center_b;
esp32_stack_h = is_undef(esp32_stack_h) ? 13.0 : esp32_stack_h;
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

// 1.3" I2C OLED module (PCB 35.6 x 34.4 x 0.9; glass 33.0 x 24.6; header
// 1x4 on a long edge; glass-to-pin-tip depth ~10.0-10.5; glass face 2.3
// proud of the PCB front face; mounting holes dia 2.9 at ~30.0 x 29.8).
oled_w = is_undef(oled_w) ? 35.6 : oled_w;
oled_h = is_undef(oled_h) ? 34.4 : oled_h;
oled_t = is_undef(oled_t) ? 0.9 : oled_t;
oled_depth = is_undef(oled_depth) ? 10.5 : oled_depth;
oled_glass_w = is_undef(oled_glass_w) ? 33.0 : oled_glass_w;
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

// Full-size SD reader module + inserted card (PCB 28.3 along the card axis
// x 33.3; cage ~29.2 across x 21-25 deep x 2.9 high, mouth on the edge
// opposite the 6-pin header; card 32 x 24 x 2.1, ~18 inserted, ~13 exposed).
sd_pcb_x = is_undef(sd_pcb_x) ? 28.3 : sd_pcb_x;
sd_pcb_y = is_undef(sd_pcb_y) ? 33.3 : sd_pcb_y;
sd_pcb_t = is_undef(sd_pcb_t) ? 1.6 : sd_pcb_t;
sd_cage_x = is_undef(sd_cage_x) ? 25.0 : sd_cage_x;
sd_cage_y = is_undef(sd_cage_y) ? 29.2 : sd_cage_y;
sd_cage_h = is_undef(sd_cage_h) ? 2.9 : sd_cage_h;
sd_card_len = is_undef(sd_card_len) ? 32.0 : sd_card_len;
sd_card_w = is_undef(sd_card_w) ? 24.0 : sd_card_w;
sd_card_t = is_undef(sd_card_t) ? 2.1 : sd_card_t;
sd_card_inserted = is_undef(sd_card_inserted) ? 18.0 : sd_card_inserted;
// Card seated in the cage slot, label up: bottom 0.8 above the PCB top,
// top flush with the cage top (sd_pcb_t + 0.8 + sd_card_t == sd_cage_h).
sd_card_seat = is_undef(sd_card_seat) ? 0.8 : sd_card_seat;

// Tactile buttons x2 (12.1 x 12.1 body, ~7 tall provisional, cap dia ~8,
// actuator dia 3.9 x ~1.5, pair spacing 16.3 center to center).
button_body = is_undef(button_body) ? 12.1 : button_body;
button_h = is_undef(button_h) ? 7.0 : button_h;
button_cap_d = is_undef(button_cap_d) ? 8.0 : button_cap_d;
button_actuator_d = is_undef(button_actuator_d) ? 3.9 : button_actuator_d;
button_actuator_h = is_undef(button_actuator_h) ? 1.5 : button_actuator_h;
button_spacing = is_undef(button_spacing) ? 16.3 : button_spacing;

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
// USB cutouts (3.2 item 5).
usb_cutout_w = is_undef(usb_cutout_w) ? 10.0 : usb_cutout_w;
usb_cutout_h = is_undef(usb_cutout_h) ? 4.5 : usb_cutout_h;
usb_cutout_r = is_undef(usb_cutout_r) ? 1.0 : usb_cutout_r;
usb_cutout_clear = is_undef(usb_cutout_clear) ? 0.25 : usb_cutout_clear;
// Button wells (3.2 item 6).
well_clear = is_undef(well_clear) ? 0.2 : well_clear;
well_wall_t = is_undef(well_wall_t) ? 3.0 : well_wall_t;
well_block_h = is_undef(well_block_h) ? 7.5 : well_block_h;
well_tower_gap = is_undef(well_tower_gap) ? 0.5 : well_tower_gap;
well_wire_slot_w = is_undef(well_wire_slot_w) ? 3.0 : well_wire_slot_w;
well_wire_slot_h = is_undef(well_wire_slot_h) ? 2.0 : well_wire_slot_h;
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
cap_relief_d = is_undef(cap_relief_d) ? 10.5 : cap_relief_d;

// ---- Layout parameters (named placements; config-driven) ----
front_margin = is_undef(front_margin) ? 5.0 : front_margin;
alley = is_undef(alley) ? 9.0 : alley;
board_margin_left = is_undef(board_margin_left) ? 5.0 : board_margin_left;
band_gap = is_undef(band_gap) ? 8.0 : band_gap;
usb_gap = is_undef(usb_gap) ? 2.0 : usb_gap;
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

// Interior envelope, derived from mockup placement (world mm):
//   X: left margin | ESP32 header envelope | band gap | SD module
//      (card tip sd_tip_gap shy of the right inner face = the slot plane)
//   Y: front margin | OLED zone (glass-to-pin depth) | wire alley |
//      ESP32 board length | USB shell protrusion | USB access gap
//   Z: tallest content (OLED module) + lid content clearance
function interior_w() = board_margin_left + esp32_header_w + band_gap
    + sd_pcb_x + sd_card_exposed() + sd_tip_gap;
function interior_d() = front_margin + oled_depth + alley
    + esp32_board_len + esp32_usb_protrusion + usb_gap;
function interior_h() = oled_h + lid_clearance;

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
function oled_x0() = button_well_block_x1() + button_oled_gap;
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

// ---- Button well anchors (positions become the cap-bore datum) ----
// Well centers must reproduce the measured 16.3 mm pair spacing, so the
// shared wall derives from it: shared = spacing - cavity (3.8 >= 3.0).
function button_well_cavity() = button_body + 2 * well_clear;
function button_well_block_x0() = m3_tower_size + well_tower_gap;
function button_well_shared_wall() = button_spacing - button_well_cavity();
function button_well_block_x1() = button_well_block_x0()
    + 2 * well_wall_t + 2 * button_well_cavity()
    + button_well_shared_wall();
function button_well_block_y0() = wall_t + button_margin_front;
function button_well_cavity_y0() = button_well_block_y0() + well_wall_t;
function button_center(i) = [
    button_well_block_x0() + well_wall_t + button_well_cavity() / 2
        + i * button_spacing,
    button_well_cavity_y0() + button_well_cavity() / 2
];
// Cap stack arithmetic (3.4): the socket top presses the actuator cap_press
// below its nominal top at lid closed; the stem bottom needs a relief over
// the button body top face.
function button_body_top_z() = floor_t + button_h;
function button_actuator_top_z() = button_body_top_z() + button_actuator_h;
function cap_stem_bottom_z() = button_actuator_top_z() - cap_press
    - cap_socket_depth;
function cap_relief_depth() = button_body_top_z() - cap_stem_bottom_z();
function cap_stem_top_z() = parting_z() + lid_t;
function cap_stem_len() = cap_stem_top_z() - cap_stem_bottom_z();

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
       <= wall_t + interior_d() - usb_gap + boolean_epsilon,
    "ESP32 USB shells exceed the back-wall access gap");
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
// The OLED must stay inside the interior and clear of the right wall.
assert(oled_x0() + oled_w <= wall_t + interior_w() - 2.0,
    "OLED module crosses the interior right edge");
// Rails / board stack fit under the lid with the content clearance.
assert(board_top_z() + esp32_stack_h
       <= wall_t + 0 + interior_h() - lid_clearance + boolean_epsilon,
    "ESP32 above-board stack exceeds the lid content clearance");
assert(floor_t + oled_h <= wall_t + 0 + interior_h() - lid_clearance + boolean_epsilon,
    "OLED exceeds the lid content clearance");
// Anti-lift blades must miss the top keep-outs by the clearance floor.
assert(anti_lift_blade_y0 >= esp32_pcb_y0() + esp32_shield_zone_l
       + anti_lift_keepout_clear - boolean_epsilon,
    "anti-lift blades start inside the module shield keep-out");
assert(anti_lift_blade_y0 >= esp32_pcb_y0() + esp32_boot_from_antenna
       + esp32_button_keepout_l / 2 + anti_lift_keepout_clear - boolean_epsilon,
    "anti-lift blades start inside the RST/BOOT keep-out");
assert(cap_relief_depth() > 0,
    "cap stem bottom lands above the button body top (no relief needed?)");
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
