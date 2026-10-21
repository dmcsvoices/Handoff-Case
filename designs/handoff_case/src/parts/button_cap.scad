// button_cap.scad - handoff_case printed button cap (plan item 3.4).
// Modeled at its own fabrication origin: stem bottom face at z = 0.
// Flange on the lid top face; stem slides in the Ø8.3 lid guide bore; the
// blind Ø4 socket presses the Ø3.9 actuator cap_press below its nominal
// top at lid closed; the Ø10.5 relief clears the button body top so the
// stem can reach the press position. Printed x2 (both tactile buttons).
//
// Stack arithmetic (defaults.scad functions):
//   body_top_z      = floor_t + button_h                       (= 10.0)
//   actuator_top_z  = body_top_z + button_actuator_h           (= 11.5)
//   stem_bottom_z   = actuator_top_z - cap_press - socket_depth (= 8.7)
//   relief_depth    = body_top_z - stem_bottom_z               (= 1.3)
//   stem_len        = (parting_z + lid_t) - stem_bottom_z      (= 43.7)

module button_cap() {
    // ---- Fit / governance asserts ------------------------------------
    assert(cap_socket_d >= button_actuator_d + 0.1,
        str("socket ", cap_socket_d, " < actuator ", button_actuator_d,
            " + 0.1"));
    assert(cap_bore_d - cap_stem_d >= 0.4,
        "cap stem to guide bore clearance < 0.4 mm diametral");
    assert(cap_press <= button_actuator_h / 2,
        "cap press exceeds half the measured actuator height");
    assert(cap_relief_depth() > 0,
        "stem bottom above the button body top: relief would be negative");
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
        // Blind actuator socket from the stem bottom.
        translate([0, 0, -boolean_epsilon])
            cylinder(h = cap_socket_depth + boolean_epsilon,
                     d = cap_socket_d, $fn = 32);
        // Body relief over the button top face.
        translate([0, 0, -boolean_epsilon])
            cylinder(h = cap_relief_depth() + 2 * boolean_epsilon,
                     d = cap_relief_d, $fn = 48);
    }
}
