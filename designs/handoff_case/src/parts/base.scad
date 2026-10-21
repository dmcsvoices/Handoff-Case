// base.scad - handoff_case base shell + detail geometry (plan item 3.2,
// with the M3 stud towers that item 3.3 references).
// Five-sided cavity (floor + four walls at the 3.0 mm house minimum) plus:
// ESP32 drop-in L-ledge rails + USB-end stop bar, OLED bosses + window,
// SD pocket + raised pad + through-wall card slot, USB shell cutouts,
// button wells, strain-relief posts, and four M3 stud towers.
// Every feature embeds into the floor or a wall from z/y = 0 so all joins
// are positive-volume unions; named overlaps/sections are asserted.

// Rounded-rect cut prism with its axis along Y (wall-through cuts),
// built as polygon()+linear_extrude of rr_profile() (CGAL-robust at
// widths <= ~22 mm; wide windows are split by the caller). Deliberately
// NOT offset() and NOT hull-of-cylinders: both degenerate under CGAL in
// OpenSCAD 2021.01 in this model (verified via exported-STL slices).
module _y_prism_rounded(cx, y0, y1, cz, w, h, r) {
    translate([0, (y0 + y1) / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = y1 - y0, center = true)
                polygon(rr_profile(cx, cz, w, h, r));
}

module base() {
    // ---- Governance minima -------------------------------------------
    assert(floor_t >= minimum_wall_thickness,
        str("floor_t ", floor_t, " < minimum wall thickness ", minimum_wall_thickness));
    assert(wall_t >= minimum_wall_thickness,
        str("wall_t ", wall_t, " < minimum wall thickness ", minimum_wall_thickness));
    wall_floor_overlap = floor_t;
    assert(wall_floor_overlap >= minimum_structural_overlap,
        str("wall/floor overlap ", wall_floor_overlap,
            " < minimum_structural_overlap ", minimum_structural_overlap));
    wall_corner_overlap = wall_t;
    assert(wall_corner_overlap >= minimum_structural_overlap,
        str("wall corner overlap ", wall_corner_overlap,
            " < minimum_structural_overlap ", minimum_structural_overlap));
    assert(minimum_internal_edge_width >= minimum_wall_thickness,
        "minimum internal material width must meet the wall minimum");

    // ---- Rail / board stack guards (3.2 item 1) ------------------------
    // Land section above the floor meets the wall minimum...
    rail_land_t = board_lift();
    assert(rail_land_t >= minimum_wall_thickness,
        str("rail land section ", rail_land_t, " < minimum_wall_thickness"));
    // ...and the underside header pin tips keep the floor clearance.
    pin_tip_floor_clearance = board_underside_z() - esp32_pin_tip_drop - floor_t;
    assert(pin_tip_floor_clearance >= rail_pin_floor_clear,
        str("pin tips to floor ", pin_tip_floor_clearance,
            " < rail_pin_floor_clear ", rail_pin_floor_clear));
    // The land stays outboard of the header pin tips.
    assert(rail_land_w <= esp32_header_pin_inset,
        str("rail land width ", rail_land_w,
            " reaches into the header pin inset ", esp32_header_pin_inset));
    assert(rail_wall_t >= minimum_wall_thickness,
        "rail wall thinner than the house minimum");

    // ---- End-stop guards ----------------------------------------------
    assert(end_stop_t >= minimum_wall_thickness,
        "end stop bar thinner than the house minimum");
    // The bar top reaches exactly the board top face and stays below the
    // USB shells everywhere except the shell notches.
    assert(board_top_z() - floor_t >= end_stop_t,
        "end stop bar top must reach the board top face");
    end_stop_middle_web = (max(esp32_usb_xa(), esp32_usb_xb())
            - esp32_usb_shell_w / 2 - end_stop_notch_clear)
        - (min(esp32_usb_xa(), esp32_usb_xb())
            + esp32_usb_shell_w / 2 + end_stop_notch_clear);
    assert(end_stop_middle_web >= minimum_internal_edge_width - 0.001,
        str("end-stop web between shell notches ", end_stop_middle_web,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));

    // ---- OLED boss / window guards (3.2 item 3) ------------------------
    boss_glass_clearance = oled_boss_h - oled_glass_proud;
    assert(boss_glass_clearance >= 0.3,
        str("glass would foul the wall: boss_h ", oled_boss_h,
            " - glass proud ", oled_glass_proud, " = ", boss_glass_clearance));
    assert(oled_boss_pilot_depth >= 6.0,
        "OLED boss pilot shallower than 6 mm");
    assert(oled_boss_pilot_depth <= oled_boss_h + wall_t - oled_boss_pilot_skin,
        str("OLED pilot breaks the wall skin: needs ",
            oled_boss_pilot_depth + oled_boss_pilot_skin,
            " > boss+wall ", oled_boss_h + wall_t));
    assert(oled_boss_d >= oled_boss_pilot_d + 2.0,
        "OLED boss smaller than its pilot");
    // Window inside the glass outline on every side.
    window_glass_margin_x = (oled_glass_w - oled_window_w()) / 2;
    window_glass_margin_z = (oled_glass_h - oled_window_h()) / 2;
    assert(window_glass_margin_x >= oled_window_glass_inset,
        str("window to glass edge x ", window_glass_margin_x,
            " < ", oled_window_glass_inset));
    assert(window_glass_margin_z >= oled_window_glass_inset,
        str("window to glass edge z ", window_glass_margin_z,
            " < ", oled_window_glass_inset));
    // Ligament between the window and the nearest boss pilot (measured on
    // the same face plane; pilots are the only voids in the bosses).
    window_pilot_ligament_z = (oled_glass_cz() - oled_window_h() / 2)
        - (oled_hole_z0() + oled_boss_pilot_d / 2);
    assert(window_pilot_ligament_z >= minimum_internal_edge_width,
        str("window to lower boss pilots ", window_pilot_ligament_z,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    window_pilot_ligament_z_top = (oled_hole_z1() - oled_boss_pilot_d / 2)
        - (oled_glass_cz() + oled_window_h() / 2);
    assert(window_pilot_ligament_z_top >= minimum_internal_edge_width,
        str("window to upper boss pilots ", window_pilot_ligament_z_top,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));
    // (The window overlaps the boss pilot columns in x by design; the
    // minimum window-to-pilot ligament is the z separation asserted above.)

    // ---- SD pocket / slot guards (3.2 item 4) --------------------------
    assert(sd_pocket_wall_t >= minimum_wall_thickness,
        "SD pocket wall thinner than the house minimum");
    assert(sd_pocket_pad_h >= minimum_wall_thickness,
        "SD pocket raised floor pad thinner than the house minimum");
    assert(sd_pocket_wall_h >= sd_pcb_t + 2.5,
        "SD pocket walls do not capture the module PCB");
    // Slot centerline on the cage-mouth/card centerline.
    slot_center_cy = sd_card_cy();
    slot_center_cz = sd_card_z0() + sd_card_t / 2;
    slot_mouth_offset = abs(slot_center_cy - sd_cage_mouth_cy());
    assert(slot_mouth_offset <= 0.5,
        str("card slot centerline ", slot_center_cy,
            " off the cage mouth centerline ", sd_cage_mouth_cy(),
            " by ", slot_mouth_offset, " > 0.5"));
    assert(sd_slot_w >= sd_card_w + 0.5,
        "card slot narrower than the card");
    assert(sd_slot_h >= sd_card_t + 0.5,
        "card slot shorter than the card");
    // Slot ligaments: bottom of the slot to the case floor.
    slot_floor_ligament = (slot_center_cz - sd_slot_h / 2) - floor_t;
    assert(slot_floor_ligament >= minimum_internal_edge_width,
        str("card slot bottom to floor ", slot_floor_ligament,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));

    // ---- USB cutout guards (3.2 item 5) --------------------------------
    usb_shell_fit_w = usb_cutout_w - (esp32_usb_shell_w + 2 * usb_cutout_clear);
    usb_shell_fit_h = usb_cutout_h - (esp32_usb_shell_h + 2 * usb_cutout_clear);
    assert(usb_shell_fit_w >= 0,
        str("USB cutout ", usb_cutout_w, " does not fit shell + 2*",
            usb_cutout_clear));
    assert(usb_shell_fit_h >= 0,
        str("USB cutout ", usb_cutout_h, " does not fit shell + 2*",
            usb_cutout_clear));
    // Web between the two cutouts: 12.3 spacing - 10.0 openings = 2.3,
    // a documented deviation from the 3.0 norm (see design README).
    usb_cutout_web = abs(esp32_usb_xb() - esp32_usb_xa()) - usb_cutout_w;
    assert(usb_cutout_web >= boolean_epsilon,
        "USB cutouts overlap each other");
    // Ligament below the lower cutout to the floor (shell envelope spans
    // the board thickness plus the 3.2 mm above-board shell height).
    usb_cutout_floor_ligament =
        (esp32_usb_shell_z0() + esp32_usb_shell_z1()) / 2
        - usb_cutout_h / 2 - floor_t;
    assert(usb_cutout_floor_ligament >= minimum_internal_edge_width,
        str("USB cutout bottom to floor ", usb_cutout_floor_ligament,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));

    // ---- Button well guards (3.2 item 6) -------------------------------
    assert(well_wall_t >= minimum_wall_thickness,
        "well wall thinner than the house minimum");
    assert(well_block_h >= floor_t + minimum_wall_thickness,
        "well block shallower than floor + a wall minimum");
    well_center_spacing = abs(button_center(1)[0] - button_center(0)[0]);
    assert(abs(well_center_spacing - button_spacing) <= boolean_epsilon,
        "well centers do not match the measured button spacing");

    // ---- Strain post guards (3.2 item 7) -------------------------------
    strain_post_rim = (strain_post_d - strain_post_bore_d) / 2;
    assert(strain_post_rim >= minimum_internal_edge_width,
        str("strain post rim ", strain_post_rim,
            " < minimum_internal_edge_width ", minimum_internal_edge_width));

    // ---- M3 tower guards (3.3 towers, base side) ------------------------
    assert(m3_pilot_depth >= 8.0,
        "M3 tower pilot shallower than 8 mm");
    tower_pilot_floor = parting_z() - m3_pilot_depth;
    assert(tower_pilot_floor > floor_t,
        "M3 tower pilot breaks the floor");
    tower_wall_overlap = wall_t;
    assert(tower_wall_overlap >= minimum_structural_overlap,
        "tower/wall overlap below minimum_structural_overlap");
    tower_floor_overlap = floor_t;
    assert(tower_floor_overlap >= minimum_structural_overlap,
        "tower/floor overlap below minimum_structural_overlap");

    // ================= Geometry ==========================================
    difference() {
        union() {
            // ---- Shell: floor + four walls (blockout) ----
            translate([0, 0, 0])
                cube([outer_w(), outer_d(), floor_t]);
            translate([0, 0, 0])
                cube([wall_t, outer_d(), base_outer_h()]);
            translate([outer_w() - wall_t, 0, 0])
                cube([wall_t, outer_d(), base_outer_h()]);
            translate([wall_t, 0, 0])
                cube([outer_w() - 2 * wall_t, wall_t, base_outer_h()]);
            translate([wall_t, outer_d() - wall_t, 0])
                cube([outer_w() - 2 * wall_t, wall_t, base_outer_h()]);

            // ---- M3 stud towers (four corners; fr moved clear of OLED) --
            for (r = m3_tower_rects())
                translate([r[0], r[1], 0])
                    cube([r[2] - r[0], r[3] - r[1], parting_z()]);

            // ---- ESP32 drop-in L-ledge rails (3.2 item 1) ----
            // Left rail: wall + land under the pcb left edge. Solids span
            // from z = 0 (embedded in the floor); the land top face is the
            // board underside (board_lift above the floor).
            translate([esp32_pcb_x0() - rail_land_w - rail_wall_t,
                       esp32_pcb_y0(), 0])
                cube([rail_wall_t, esp32_board_len, board_underside_z()]);
            translate([esp32_pcb_x0() - rail_land_w, esp32_pcb_y0(), 0])
                cube([rail_land_w, esp32_board_len, board_underside_z()]);
            // Right rail (land inboard of the wall, under the pcb edge).
            translate([esp32_pcb_x1(), esp32_pcb_y0(), 0])
                cube([rail_land_w, esp32_board_len, board_underside_z()]);
            translate([esp32_pcb_x1() + rail_land_w, esp32_pcb_y0(), 0])
                cube([rail_wall_t, esp32_board_len, board_underside_z()]);
            // End-stop bar at the USB end, spanning wall to wall between
            // the rails (through both rail walls), top at the board top.
            translate([esp32_pcb_x0() - rail_land_w - rail_wall_t,
                       esp32_pcb_y1(), 0])
                cube([esp32_pcb_x1() - esp32_pcb_x0() + 2 * (rail_wall_t + rail_land_w),
                      end_stop_t, board_top_z()]);

            // ---- OLED bosses (3.2 item 3): Ø6 on the front wall inner
            // face, embedded through the wall; pilot bored from the face --
            for (bx = [oled_hole_x0(), oled_hole_x1()])
                for (bz = [oled_hole_z0(), oled_hole_z1()])
                    translate([bx, 0, bz])
                        rotate([-90, 0, 0])
                            cylinder(h = oled_boss_h + wall_t,
                                     d = oled_boss_d, $fn = 48);

            // ---- SD pocket (3.2 item 4): raised pad + three walls ----
            translate([sd_pcb_x0() - sd_pocket_clear,
                       sd_pcb_y0() - sd_pocket_clear, 0])
                cube([sd_pcb_x + 2 * sd_pocket_clear,
                      sd_pcb_y + 2 * sd_pocket_clear, sd_pad_top_z()]);
            translate([sd_pocket_x0(), sd_pocket_y0(), 0])
                cube([sd_pocket_x1() - sd_pocket_x0(),
                      sd_pocket_wall_t, sd_pocket_top_z()]);
            translate([sd_pocket_x0(), sd_pocket_y1() - sd_pocket_wall_t, 0])
                cube([sd_pocket_x1() - sd_pocket_x0(),
                      sd_pocket_wall_t, sd_pocket_top_z()]);
            translate([sd_pocket_x0(), sd_pocket_y0(), 0])
                cube([sd_pocket_wall_t,
                      sd_pocket_y1() - sd_pocket_y0(), sd_pocket_top_z()]);

            // ---- Button wells (3.2 item 6): one block, two cavities ----
            translate([button_well_block_x0(), button_well_block_y0(), 0])
                cube([button_well_block_x1() - button_well_block_x0(),
                      well_wall_t + (button_body + 2 * well_clear),
                      well_block_h]);

            // ---- Strain-relief posts (3.2 item 7) ----
            for (p = [strain_post_oled, strain_post_sd])
                translate([p[0], p[1], 0])
                    cylinder(h = strain_post_h, d = strain_post_d, $fn = 48);
        }

        // ================= Cuts ===========================================
        // M3 tower pilots: Ø3.0 blind, >= 8 deep, open at the parting face.
        for (s = m3_stations())
            translate([s[0], s[1], parting_z() - m3_pilot_depth])
                cylinder(h = m3_pilot_depth + boolean_epsilon,
                         d = m3_pilot_d, $fn = 48);

        // End-stop shell notches (both shells, with notch clearance).
        for (cx = [esp32_usb_xa(), esp32_usb_xb()])
            translate([cx - esp32_usb_shell_w / 2 - end_stop_notch_clear,
                       esp32_pcb_y1() - boolean_epsilon,
                       esp32_usb_shell_z0() - end_stop_notch_clear])
                cube([esp32_usb_shell_w + 2 * end_stop_notch_clear,
                      end_stop_t + 2 * boolean_epsilon,
                      board_top_z() - esp32_usb_shell_z0()
                          + end_stop_notch_clear + boolean_epsilon]);

        // OLED boss pilots: Ø2.5 blind from the boss face, skin over the
        // outer wall face.
        for (bx = [oled_hole_x0(), oled_hole_x1()])
            for (bz = [oled_hole_z0(), oled_hole_z1()])
                translate([bx,
                           wall_t + oled_boss_h - oled_boss_pilot_depth,
                           bz])
                    rotate([-90, 0, 0])
                        cylinder(h = oled_boss_pilot_depth + boolean_epsilon,
                                 d = oled_boss_pilot_d, $fn = 48);

        // OLED display window through the front wall. Split into two
        // overlapping <= 22 mm rounded prisms: wide rounded-rect cuts
        // degenerate under CGAL above ~27-30 mm (defaults.scad note).
        _y_prism_rounded(oled_glass_cx() - oled_window_w() / 4 + 0.5,
                         -boolean_epsilon, wall_t + boolean_epsilon,
                         oled_glass_cz(), oled_window_w() / 2 + 1, oled_window_h(),
                         oled_window_corner_r);
        _y_prism_rounded(oled_glass_cx() + oled_window_w() / 4 - 0.5,
                         -boolean_epsilon, wall_t + boolean_epsilon,
                         oled_glass_cz(), oled_window_w() / 2 + 1, oled_window_h(),
                         oled_window_corner_r);

        // SD pocket cavity (module drop-in space over the pad).
        translate([sd_pcb_x0() - sd_pocket_clear,
                   sd_pcb_y0() - sd_pocket_clear,
                   sd_pad_top_z() - boolean_epsilon])
            cube([sd_pcb_x + 2 * sd_pocket_clear,
                  sd_pcb_y + 2 * sd_pocket_clear,
                  sd_pocket_top_z() - sd_pad_top_z() + 2 * boolean_epsilon]);

        // Card slot through the right wall + entry chamfer flare.
        translate([outer_w() - wall_t - boolean_epsilon,
                   slot_center_cy - sd_slot_w / 2,
                   slot_center_cz - sd_slot_h / 2])
            cube([wall_t + 2 * boolean_epsilon, sd_slot_w, sd_slot_h]);
        hull() {
            translate([outer_w() - wall_t + (wall_t - sd_slot_chamfer),
                       slot_center_cy - sd_slot_w / 2,
                       slot_center_cz - sd_slot_h / 2])
                cube([sd_slot_chamfer, sd_slot_w, sd_slot_h]);
            translate([outer_w() - boolean_epsilon,
                       slot_center_cy - sd_slot_w / 2 - sd_slot_chamfer,
                       slot_center_cz - sd_slot_h / 2 - sd_slot_chamfer])
                cube([boolean_epsilon, sd_slot_w + 2 * sd_slot_chamfer,
                      sd_slot_h + 2 * sd_slot_chamfer]);
        }

        // USB shell cutouts through the back wall.
        for (cx = [esp32_usb_xa(), esp32_usb_xb()])
            _y_prism_rounded(cx,
                outer_d() - wall_t - boolean_epsilon, outer_d() + boolean_epsilon,
                (esp32_usb_shell_z0() + esp32_usb_shell_z1()) / 2,
                usb_cutout_w, usb_cutout_h, usb_cutout_r);

        // Button well cavities + wire-exit slots.
        for (i = [0, 1])
            translate([button_center(i)[0] - (button_body + 2 * well_clear) / 2,
                       button_center(i)[1] - (button_body + 2 * well_clear) / 2,
                       floor_t - boolean_epsilon])
                cube([button_body + 2 * well_clear,
                      button_body + 2 * well_clear,
                      well_block_h - floor_t + 2 * boolean_epsilon]);
        for (i = [0, 1])
            translate([button_center(i)[0] - well_wire_slot_w / 2,
                       button_center(i)[1] + (button_body + 2 * well_clear) / 2
                           - boolean_epsilon,
                       floor_t - boolean_epsilon])
                cube([well_wire_slot_w,
                      well_wire_slot_d + 2 * boolean_epsilon,
                      well_wire_slot_h + boolean_epsilon]);

        // Strain post zip-tie bores.
        for (p = [strain_post_oled, strain_post_sd])
            translate([p[0], p[1], -boolean_epsilon])
                cylinder(h = strain_post_h + 2 * boolean_epsilon,
                         d = strain_post_bore_d, $fn = 32);
    }
}
