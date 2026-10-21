// mockups.scad - handoff_case component reference mockups (detail rev).
// Non-printable faithful envelopes per the design README provenance table,
// placed at their MOUNTED positions (rails / bosses / pocket / wells).
// Dispatch ids 10-13 in parts.json. Colors are preview-only.

// ---- ESP32-S3 dev board (id 10) -----------------------------------------
// Flat on the L-ledge rails (underside at board_underside_z), long axis
// 60.7 along Y, USB short edge + shells toward the back wall. The
// above-board stack envelope is anchored to the header rows (>= 2.5
// inboard from the edges) so the lid anti-lift blades clear it.
module esp32_mockup() {
    color([0.1, 0.5, 0.2, 0.85]) {
        // PCB (60.7 x 28.3 x 1.6) on the rails.
        translate([esp32_pcb_x0(), esp32_pcb_y0(), board_underside_z()])
            cube([esp32_board_w, esp32_board_len, esp32_board_t]);
        // Above-board stack (headers + Dupont tops, ~13 above the PCB
        // face), inset to the header-pin zone.
        translate([esp32_pcb_x0() + esp32_header_pin_inset, esp32_pcb_y0(),
                   board_top_z()])
            cube([esp32_board_w - 2 * esp32_header_pin_inset,
                  esp32_board_len, esp32_stack_h]);
        // USB-C shells on the back short edge.
        for (cx = [esp32_usb_xa(), esp32_usb_xb()])
            translate([cx - esp32_usb_shell_w / 2,
                       esp32_pcb_y1(),
                       esp32_usb_shell_z0()])
                cube([esp32_usb_shell_w, esp32_usb_protrusion,
                      esp32_usb_shell_h]);
    }
}

// ---- 1.3" I2C OLED module (id 11) ----------------------------------------
// Mounted on the four front-wall bosses: glass 2.3 proud of the PCB front
// face, PCB front face at wall + oled_boss_h; header pins behind.
module oled_mockup() {
    color([0.1, 0.2, 0.7, 0.85]) {
        // Glass slab (front face oled_glass_proud ahead of the PCB face).
        translate([oled_x0() + oled_glass_margin_x,
                   oled_glass_y0(),
                   oled_z0() + oled_glass_margin_flex])
            cube([oled_glass_w, oled_glass_proud, oled_glass_h]);
        // PCB (35.6 x 0.9 x 34.4) against the boss faces.
        translate([oled_x0(), oled_pcb_y0(), oled_z0()])
            cube([oled_w, oled_t, oled_h]);
        // Header pin block behind the PCB at the top edge; back face at
        // oled_glass_y0() + oled_depth (glass-to-pin-tip envelope).
        translate([oled_x0() + (oled_w - oled_header_w) / 2,
                   oled_pcb_y0() + oled_t,
                   oled_z0() + oled_h - oled_header_h])
            cube([oled_header_w,
                  oled_depth - oled_glass_proud - oled_t,
                  oled_header_h]);
    }
}

// ---- Full-size SD reader module + card (id 12) ---------------------------
// On the raised pocket pad; cage mouth faces +X, card through the wall slot.
module sd_module_mockup() {
    color([0.7, 0.5, 0.1, 0.85]) {
        // PCB on the pad.
        translate([sd_pcb_x0(), sd_pcb_y0(), sd_pad_top_z()])
            cube([sd_pcb_x, sd_pcb_y, sd_pcb_t]);
        // Cage on the +X end of the PCB.
        translate([sd_cage_x0(),
                   sd_pcb_y0() + (sd_pcb_y - sd_cage_y) / 2,
                   sd_pad_top_z() + sd_pcb_t])
            cube([sd_cage_x, sd_cage_y, sd_cage_h]);
        // Inserted card (32 x 24 x 2.1), label up, 18 into the cage.
        translate([sd_card_x0(),
                   sd_pcb_y0() + (sd_pcb_y - sd_card_w) / 2,
                   sd_card_z0()])
            cube([sd_card_len, sd_card_w, sd_card_t]);
    }
}

// ---- Tactile buttons x2 (id 13) ------------------------------------------
// Both bodies seated in the base wells on the cavity floor (the case
// floor), actuators up; caps (part 3) ride the actuators through the lid.
module buttons_mockup() {
    color([0.6, 0.1, 0.1, 0.85])
        for (i = [0, 1]) {
            translate([button_center(i)[0] - button_body / 2,
                       button_center(i)[1] - button_body / 2, floor_t])
                cube([button_body, button_body, button_h]);
            translate([button_center(i)[0], button_center(i)[1],
                       floor_t + button_h])
                cylinder(h = button_actuator_h, d = button_actuator_d,
                         $fn = 32);
        }
}

// All four component mockups as one group (assembly previews).
module component_mockups() {
    esp32_mockup();
    oled_mockup();
    sd_module_mockup();
    buttons_mockup();
}
