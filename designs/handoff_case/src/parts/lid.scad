// lid.scad - handoff_case lid (plan item 3.3).
// Flat 7.0 plate (3.0 retained floor under Ø7 x 4 M3 head recesses) with:
// four Ø3.4 M3 clearance bores + head recesses over the base stud towers,
// two Ø8.3 button-cap guide bores (shared parameters with the base wells),
// two anti-lift blades hanging onto the board's long-edge top strips, and
// six vent slots. The button caps (3.4) ride on the top face.

// Anti-lift blade as a parameter-bound helper: arguments bind eagerly at
// the call site. (Wide deferred translate thunks referencing globals
// intermittently miscompiled under OpenSCAD 2021.01 module + CGAL cache
// contexts in this design - both blades vanished to the origin in the
// exported lid STL. Parameter binding evaluates at the call.)
module anti_lift_blade(x0, y0, z0, w, len, h) {
    translate([x0, y0, z0])
        cube([w, len, h]);
}

module lid() {
    // ---- Governance minima -------------------------------------------
    assert(lid_t >= minimum_wall_thickness,
        str("lid_t ", lid_t, " < minimum wall thickness ", minimum_wall_thickness));
    // Head recess retains the minimum floor (asserted in defaults too).
    lid_recess_floor = lid_t - m3_cbore_depth;
    assert(lid_recess_floor >= minimum_wall_thickness,
        str("floor under M3 recess ", lid_recess_floor,
            " < minimum_wall_thickness ", minimum_wall_thickness));
    // Recess rim to the station edge.
    m3_cbore_rim = m3_inset - m3_cbore_d / 2;
    assert(m3_cbore_rim >= minimum_internal_edge_width,
        str("M3 recess to lid edge ", m3_cbore_rim,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    // Cap guide bore rim under the cap flange.
    cap_flange_rim = (cap_flange_d - cap_bore_d) / 2;
    assert(cap_flange_rim >= minimum_internal_edge_width,
        str("cap flange rim ", cap_flange_rim,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    assert(cap_bore_d - cap_stem_d >= 0.4,
        "cap stem/bore clearance < 0.4 mm diametral");
    // Anti-lift blades: thickness meets the minimum; blades stay within
    // the header-pin inset and clear the keep-outs (defaults asserts).
    assert(anti_lift_blade_t >= minimum_wall_thickness,
        "anti-lift blade thinner than the house minimum");
    assert(anti_lift_blade_w <= esp32_header_pin_inset,
        str("anti-lift blade width ", anti_lift_blade_w,
            " crosses the header pin inset ", esp32_header_pin_inset));
    blade_pin_clear_right = anti_lift_blade_x0()
        - (esp32_pcb_x1() - esp32_header_pin_inset);
    assert(blade_pin_clear_right >= -boolean_epsilon,
        "right anti-lift blade fouls the header pins");
    // Vent ligaments: between columns/rows and to every bore column.
    vent_col_gap = vent_x_starts[1] - (vent_x_starts[0] + vent_w);
    assert(vent_col_gap >= minimum_internal_edge_width,
        str("vent column gap ", vent_col_gap,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    vent_row_gap = vent_y_starts[1] - (vent_y_starts[0] + vent_t);
    assert(vent_row_gap >= minimum_internal_edge_width,
        str("vent row gap ", vent_row_gap,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    vent_to_cap_bore = vent_x_starts[0]
        - (button_center(1)[0] + cap_bore_d / 2);
    assert(vent_to_cap_bore >= minimum_internal_edge_width,
        str("first vent column to cap bore ", vent_to_cap_bore,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));

    difference() {
        union() {
            // ---- Plate ----
            translate([0, 0, parting_z()])
                cube([outer_w(), outer_d(), lid_t]);

            // ---- Anti-lift blades (hang from the lid underside onto the
            // board's long-edge top strips; 3.0 embedded in the lid) ----
            anti_lift_blade(anti_lift_blade_x0(), anti_lift_blade_y0,
                            board_top_z(),
                            anti_lift_blade_x1() - anti_lift_blade_x0(),
                            anti_lift_blade_y1 - anti_lift_blade_y0,
                            parting_z() + 3.0 - board_top_z());
            anti_lift_blade(anti_lift_blade2_x0(), anti_lift_blade_y0,
                            board_top_z(),
                            anti_lift_blade2_x1() - anti_lift_blade2_x0(),
                            anti_lift_blade_y1 - anti_lift_blade_y0,
                            parting_z() + 3.0 - board_top_z());
        }

        // ---- M3 clearance bores (through) + head recesses (from top) ----
        for (s = m3_stations()) {
            translate([s[0], s[1], parting_z() - boolean_epsilon])
                cylinder(h = lid_t + 2 * boolean_epsilon,
                         d = m3_clear_d, $fn = 48);
            translate([s[0], s[1], parting_z() + lid_t - m3_cbore_depth])
                cylinder(h = m3_cbore_depth + boolean_epsilon,
                         d = m3_cbore_d, $fn = 48);
        }

        // ---- Button-cap guide bores (through, aligned to base wells) ----
        for (i = [0, 1])
            translate([button_center(i)[0], button_center(i)[1],
                       parting_z() - boolean_epsilon])
                cylinder(h = lid_t + 2 * boolean_epsilon,
                         d = cap_bore_d, $fn = 48);

        // ---- Vent slots (six, through) ----
        for (vx = vent_x_starts)
            for (vy = vent_y_starts)
                translate([vx, vy, parting_z() - boolean_epsilon])
                    cube([vent_w, vent_t, lid_t + 2 * boolean_epsilon]);
    }
}
