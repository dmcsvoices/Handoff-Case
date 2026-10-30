// button_cap.scad - handoff_case printed button cap (rev_0002 stack).
// Modeled at its own fabrication origin: stem bottom face at z = 0.
// Flange on the lid top face; stem slides in the Ø8.3 lid guide bore; the
// blind Ø4 socket sleeves the Ø3.9 actuator plunger; the Ø8.7 relief
// clears the switch's own Ø8.1 cap so the stem can reach the plunger.
// Printed x2 (both tactile buttons).
//
// Stack arithmetic (defaults.scad functions, rev_0002):
//   slot_floor_z    = floor_t + chamber_opening_h          (= 10.0)
//   body_top_z      = slot_floor_z + button_h              (= 15.4)
//   switch_cap_top  = body_top_z + button_switch_cap_h     (= 16.9)
//   actuator_top_z  = slot_floor_z + 9.3 measured          (= 19.3)
//   stem_bottom_z   = actuator_top_z - press - socket_depth (= 16.5)
//   relief_depth    = switch_cap_top - stem_bottom + 0.5   (= 0.9)
//   stem_len        = (parting_z + lid_t) - stem_bottom_z  (= 35.9)

module button_cap() {
    // ---- Fit / governance asserts ------------------------------------
    assert(cap_socket_d >= button_actuator_d + 0.1,
        str("socket ", cap_socket_d, " < actuator ", button_actuator_d,
            " + 0.1"));
    assert(cap_bore_d - cap_stem_d >= 0.4,
        "cap stem to guide bore clearance < 0.4 mm diametral");
    assert(cap_press <= button_actuator_h / 2,
        "cap press exceeds half the measured actuator height");
    assert(cap_relief_depth() >= 0,
        "relief depth negative");
    assert(cap_stem_bottom_z() >= button_body_top_z() - boolean_epsilon,
        str("stem bottom ", cap_stem_bottom_z(),
            " fouls the button body top ", button_body_top_z()));
    assert(cap_socket_depth > cap_relief_depth(),
        "actuator socket shallower than the switch-cap relief");
    cap_flange_rim = (cap_flange_d - cap_bore_d) / 2;
    assert(cap_flange_rim >= minimum_internal_edge_width,
        str("cap flange rim ", cap_flange_rim,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    assert(cap_flange_t >= minimum_wall_thickness,
        "cap flange thinner than the house minimum");
    assert(cap_stem_len() >= minimum_wall_thickness,
        "cap stem shorter than the house minimum");

    difference() {
        union() {
            // Stem: from the origin (stem bottom face) up to the lid top.
            cylinder(h = cap_stem_len(), d = cap_stem_d, $fn = 48);
            // Flange on the lid top face.
            translate([0, 0, cap_stem_len()])
                cylinder(h = cap_flange_t, d = cap_flange_d, $fn = 64);
        }
        // Relief over the switch cap (only when the stack needs it).
        if (cap_relief_depth() > 0)
            translate([0, 0, -boolean_epsilon])
                cylinder(h = cap_relief_depth() + 2 * boolean_epsilon,
                         d = cap_relief_d(), $fn = 48);
        // Blind actuator socket from the stem bottom.
        translate([0, 0, -boolean_epsilon])
            cylinder(h = cap_socket_depth + boolean_epsilon,
                     d = cap_socket_d, $fn = 32);
    }
}
