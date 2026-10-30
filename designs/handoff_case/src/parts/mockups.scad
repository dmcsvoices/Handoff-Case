// mockups.scad - handoff_case component reference mockups (rev_0002).
// Non-printable faithful envelopes per the design README provenance table
// and the 2026-10-29 caliper batch, placed at their MOUNTED positions.
// Dispatch ids 10-13 in parts.json. Colors are preview-only.
//
// NOTE: every placement is hoisted into a module-local variable before the
// translate() calls (OpenSCAD 2021.01 intermittently drops deferred
// translate thunks whose arguments are function chains under CGAL
// --render; locals bind at statement time - the same fix as the lid
// anti-lift blades).

// ---- ESP32-S3 dev board (id 10) -----------------------------------------
module esp32_mockup() {
    px0 = esp32_pcb_x0();
    py0 = esp32_pcb_y0();
    zu = board_underside_z();
    color([0.1, 0.5, 0.2, 0.85]) {
        // PCB (57.1 x 28.15 x 1.6) on the rails.
        translate([px0, py0, zu])
            cube([esp32_board_w, esp32_board_len, esp32_board_t]);
        // Above-board stack (16.5 above the PCB face), inset to the
        // header-pin zone so the lid anti-lift blades clear it.
        translate([px0 + esp32_header_pin_inset, py0, board_top_z()])
            cube([esp32_board_w - 2 * esp32_header_pin_inset,
                  esp32_board_len, esp32_stack_h]);
        // USB-C shells on the back short edge (9.0 wide, 7.7 protruding,
        // 4.4 shell height above the board face).
        for (cx = [esp32_usb_xa(), esp32_usb_xb()])
            translate([cx - esp32_usb_shell_w / 2,
                       esp32_pcb_y1(),
                       esp32_usb_shell_z0()])
                cube([esp32_usb_shell_w, esp32_usb_protrusion,
                      esp32_usb_shell_h]);
    }
}

// ---- 1.3" I2C OLED module (id 11) ----------------------------------------
module oled_mockup() {
    x0 = oled_x0();
    gy0 = oled_glass_y0();
    py0 = oled_pcb_y0();
    z0 = oled_z0();
    color([0.1, 0.2, 0.7, 0.85]) {
        // Glass slab (front face oled_glass_proud ahead of the PCB face).
        translate([x0 + oled_glass_margin_x, gy0,
                   z0 + oled_glass_margin_flex])
            cube([oled_glass_w, oled_glass_proud, oled_glass_h]);
        // Rigid PCB (31.0 x 0.9 x 34.25) against the boss faces.
        translate([x0, py0, z0])
            cube([oled_w, oled_t, oled_h]);
        // Header pin block behind the PCB at the top edge; back face at
        // oled_glass_y0() + oled_depth (glass-to-pin-tip envelope).
        translate([x0 + (oled_w - oled_header_w) / 2,
                   py0 + oled_t,
                   z0 + oled_h - oled_header_h])
            cube([oled_header_w,
                  oled_depth - oled_glass_proud - oled_t,
                  oled_header_h]);
        // FPC tail allowance beyond the +X rigid edge (thin slab at the
        // flex side, fold clearance in the alley).
        translate([x0 + oled_w, gy0 + 0.6,
                   z0 + oled_glass_margin_flex])
            cube([oled_fpc_tail, oled_fpc_tail_t, oled_fpc_tail_w]);
    }
}

// ---- microSD reader module + card (id 12) --------------------------------
module sd_module_mockup() {
    px0 = sd_pcb_x0();
    py0 = sd_pcb_y0();
    pz = sd_pad_top_z();
    color([0.7, 0.5, 0.1, 0.85]) {
        // PCB on the pad.
        translate([px0, py0, pz])
            cube([sd_pcb_x, sd_pcb_y, sd_pcb_t]);
        // Cage on the +X end of the PCB.
        translate([sd_cage_x0(), py0 + (sd_pcb_y - sd_cage_y) / 2,
                   pz + sd_pcb_t])
            cube([sd_cage_x, sd_cage_y, sd_cage_h]);
        // Inserted card (15.0 x 11.1 x 1.0), label up, 3.7 into the cage.
        translate([sd_card_x0(), py0 + (sd_pcb_y - sd_card_w) / 2,
                   sd_card_z0()])
            cube([sd_card_len, sd_card_w, sd_card_t]);
    }
}

// ---- Tactile buttons x2 (id 13) ------------------------------------------
module buttons_mockup() {
    color([0.6, 0.1, 0.1, 0.85])
        for (i = [0, 1]) {
            cx = button_center(i)[0];
            cy = button_center(i)[1];
            // Body (12.1 sq x 5.4) on the slot floor.
            translate([cx - button_body / 2, cy - button_body / 2,
                       slot_floor_z()])
                cube([button_body, button_body, button_h]);
            // Switch cap (dia 8.1) on the body top.
            translate([cx, cy, slot_floor_z() + button_h])
                cylinder(h = 1.5, d = button_cap_d, $fn = 32);
            // Actuator plunger (dia 3.9) up to 9.3 above the slot floor.
            translate([cx, cy, slot_floor_z() + button_h + 1.5])
                cylinder(h = button_actuator_top_z() - slot_floor_z()
                            - button_h - 1.5,
                         d = button_actuator_d, $fn = 32);
            // Kinked terminal envelope: crossed blades under the body,
            // tips splaying to the measured span, drop into the chamber.
            translate([cx, cy - button_terminal_span / 2,
                       slot_floor_z() - button_terminal_drop])
                cube([1.1, button_terminal_span, button_terminal_drop]);
            translate([cx - button_terminal_span / 2, cy,
                       slot_floor_z() - button_terminal_drop])
                cube([button_terminal_span, 1.1, button_terminal_drop]);
        }
}

// All four component mockups as one group (assembly previews).
module component_mockups() {
    esp32_mockup();
    oled_mockup();
    sd_module_mockup();
    buttons_mockup();
}
