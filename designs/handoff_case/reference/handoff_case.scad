// Handoff Device Case
// Parametric enclosure for ESP32-S3 DevKitC, 1.3" OLED, micro SD slot, and 2 buttons
// OpenSCAD source - edit parameters below, then render/export STL
// Author: Janelle (OpenClaw)
//
// Design notes (2026-07-21 redesign):
// - FDM / PETG. Shell and backplate join with snap-fit cantilever clips, no screws.
// - esp_mount_holes / oled_mount_holes / sd_mount_holes below are PLACEHOLDERS
//   using reference/typical part dimensions. The user's ESP32 board is a
//   non-standard OEM variant (button positions differ from the reference
//   DevKitC) -- replace esp_mount_holes with real measured positions before
//   final printing. Same caveat for the OLED and SD breakout dimensions.
// - USB/power cutout is intentionally oversized rather than precisely aligned
//   to the board's connector.

// ============================================
// PARAMETERS - adjust to your actual parts
// ============================================

// Wall thickness
wall = 2.0;
// Internal width (X) of the case
iw = 80.0;
// Internal depth (Y) of the case
id = 60.0;
// Internal height (Z) of the case
ih = 30.0;
// Clearance per side between backplate edge and interior wall (FDM slide fit)
fit_clearance = 0.2;

// --- ESP32-S3 DevKitC ---
// 70x28mm matches Espressif's official ESP32-S3-DevKitC-1 reference size.
esp_l = 70.0;            // board length
esp_w = 28.0;            // board width
esp_h = 5.5;             // board+header height (clearance)
esp_hole_d = 2.5;        // mounting hole diameter
// PLACEHOLDER mounting hole positions (local origin = board's corner).
// User's actual board deviates from this reference -- replace with measured
// positions once available.
esp_hole_inset_x = 2.0;
esp_hole_inset_y = 2.0;
esp_mount_holes = [
    [esp_hole_inset_x, esp_hole_inset_y],
    [esp_l - esp_hole_inset_x, esp_hole_inset_y],
    [esp_hole_inset_x, esp_w - esp_hole_inset_y],
    [esp_l - esp_hole_inset_x, esp_w - esp_hole_inset_y],
];
esp_standoff_h = 6.0;    // standoff height
esp_standoff_d = 5.0;    // standoff diameter

// --- 1.3" I2C OLED module ---
// PLACEHOLDER dimensions based on common 1.3" SSD1306/SH1106 modules --
// replace once the exact model/dimensions are confirmed.
oled_l = 36.0;           // module length (longer side)
oled_w = 35.5;           // module width
oled_disp_w = 22.5;      // display window width
oled_disp_h = 11.5;      // display window height
oled_hole_d = 2.0;       // module mounting hole diameter
oled_hole_inset = 3.0;   // hole distance from module edge
oled_mount_holes = [
    [oled_hole_inset, oled_hole_inset],
    [oled_l - oled_hole_inset, oled_hole_inset],
    [oled_hole_inset, oled_w - oled_hole_inset],
    [oled_l - oled_hole_inset, oled_w - oled_hole_inset],
];
oled_standoff_h = 4.0;   // standoff protrusion from front wall

// --- micro SD SPI breakout module (HW-125-style) ---
// PLACEHOLDER dimensions -- confirm against the actual breakout board.
sd_l = 42.0;             // module length
sd_w = 25.0;             // module width
sd_h = 5.0;              // module thickness (connector protrusion)
sd_slot_w = 24.0;        // width of SD card slot on case wall
sd_slot_h = 3.0;         // height of SD card slot
sd_hole_inset_x = 3.0;   // hole inset along module length
sd_hole_inset_y = 2.0;   // hole inset along module width
sd_mount_holes = [
    [sd_hole_inset_x, sd_hole_inset_y],
    [sd_l - sd_hole_inset_x, sd_hole_inset_y],
    [sd_hole_inset_x, sd_w - sd_hole_inset_y],
    [sd_l - sd_hole_inset_x, sd_w - sd_hole_inset_y],
];
sd_hole_d = 1.5;
sd_standoff_d = 4.0;
sd_standoff_h = 4.0;
sd_y0 = 8.0;             // module offset from front wall (near-front placement)

// --- Tactile buttons (reset/boot utility functions, top face) ---
btn_w = 6.0;             // button body width
btn_h = 6.0;             // button body depth
btn_shaft_d = 3.0;       // actuator shaft diameter
btn_shaft_h = 3.5;       // actuator protrusion height
btn_hole_d = 6.5;        // hole in case for button body
btn_spacing = 15.0;      // center-to-center distance
btn_cap_d = 6.0;         // printed button cap diameter (optional)

// --- USB/power cutout (back wall) ---
// Deliberately oversized rather than aligned to the connector's exact
// position, per the user's choice -- easier than measuring a moving target.
usb_w = 24.0;
usb_h = 12.0;

// --- Snap-fit fingers (shell/backplate joint, PETG cantilever clips) ---
// Sized for a firm hold since the case is expected to be opened rarely.
// Fingers are part of the backplate; matching notches are cut into the
// shell's 4 side walls as shallow blind pockets (they don't punch through
// to the outside). No rotate()/mirror() is used for placement -- each wall
// direction is written out explicitly in snap_finger() below, since a
// composed rotate+translate is exactly what misplaced the original SD
// standoffs.
finger_w = 10.0;                 // width of each cantilever arm
finger_t = 1.6;                  // arm thickness (flex direction)
finger_h = 9.0;                  // arm height above the backplate's top face
nub_h = 2.5;                     // height of the catch nub (top of the arm)
nub_protrude = 0.8;              // how far the nub reaches into the wall notch
finger_running_clearance = 0.4;  // gap between the plain shaft and the wall
notch_depth = 0.8;               // depth of the catch notch (blind pocket)
notch_fit = 0.3;                 // extra clearance around the notch vs. the nub

// --- Derived dimensions ---
ow = iw + 2*wall;              // outer width
od = id + 2*wall;              // outer depth
oh = ih + 2*wall;              // outer height
bp_w = iw - 2*fit_clearance;   // backplate width (slides into interior with clearance)
bp_d = id - 2*fit_clearance;   // backplate depth
bp_origin = wall + fit_clearance; // X/Y translate applied to the backplate at assembly

// ============================================
// MODULES
// ============================================

// A standoff with a screw hole
module standoff(h, d, hole_d) {
    difference() {
        cylinder(h=h, d=d, $fn=32);
        translate([0, 0, -0.5])
            cylinder(h=h+1, d=hole_d, $fn=32);
    }
}

// A cantilever snap-fit finger. Base sits at z=0 (backplate's top face),
// tip at z=h. dir selects which wall it engages and thus which way the
// catch nub protrudes -- written explicitly per direction (no rotate/mirror)
// so each case is easy to verify by inspection.
module snap_finger(w, shaft_t, h, nub_h, nub_protrude, dir) {
    if (dir == "front") {
        union() {
            translate([-w/2, 0, 0])
                cube([w, shaft_t, h - nub_h]);
            translate([-w/2, -nub_protrude, h - nub_h])
                cube([w, shaft_t + nub_protrude, nub_h]);
        }
    } else if (dir == "back") {
        union() {
            translate([-w/2, -shaft_t, 0])
                cube([w, shaft_t, h - nub_h]);
            translate([-w/2, -shaft_t, h - nub_h])
                cube([w, shaft_t + nub_protrude, nub_h]);
        }
    } else if (dir == "left") {
        union() {
            translate([0, -w/2, 0])
                cube([shaft_t, w, h - nub_h]);
            translate([-nub_protrude, -w/2, h - nub_h])
                cube([shaft_t + nub_protrude, w, nub_h]);
        }
    } else if (dir == "right") {
        union() {
            translate([-shaft_t, -w/2, 0])
                cube([shaft_t, w, h - nub_h]);
            translate([-shaft_t, -w/2, h - nub_h])
                cube([shaft_t + nub_protrude, w, nub_h]);
        }
    }
}

// ============================================
// MAIN SHELL (front, top, sides -- open at the bottom for the backplate)
// ============================================
module shell() {
    oled_pocket_h = min(oled_w, ih); // guard against the pocket over-cutting the ceiling

    difference() {
        // Outer shell
        cube([ow, od, oh], center=false);

        // Hollow interior, open at the bottom (backplate provides the floor)
        translate([wall, wall, -0.1])
            cube([iw, id, ih + wall + 0.2], center=false);

        // OLED display window (front face, center)
        translate([
            (ow - oled_disp_w)/2,
            wall - 0.5,
            (oh - oled_disp_h)/2 + 2  // slightly above center
        ])
            cube([oled_disp_w, wall+1, oled_disp_h], center=false);

        // OLED module clearance pocket behind front wall
        translate([
            (ow - oled_l)/2,
            wall - 0.5,
            (oh - oled_pocket_h)/2 + 2
        ])
            cube([oled_l, 5, oled_pocket_h], center=false);

        // SD card slot (right side wall, near front)
        sd_slot_center_y = sd_y0 + sd_l/2;
        translate([
            ow - wall - 0.5,
            sd_slot_center_y - sd_slot_w/2,
            wall + 4
        ])
            cube([wall+1, sd_slot_w, sd_slot_h], center=false);

        // SD module connector clearance pocket
        translate([
            ow - wall - 4,
            sd_slot_center_y - sd_w/2 - 2,
            wall + 1
        ])
            cube([5, sd_w + 4, sd_h + 2], center=false);

        // Button holes (top face, near front)
        for (i = [-1, 1]) {
            translate([
                (ow - btn_hole_d)/2 + i * (btn_spacing/2),
                15,
                oh - 0.5
            ])
                cylinder(h=wall+1, d=btn_hole_d, $fn=32);
        }

        // Button pocket behind top wall
        translate([
            (ow - btn_hole_d)/2 - (btn_spacing/2) - 2,
            15 - btn_h/2 - 1,
            oh - wall - 4
        ])
            cube([btn_spacing + 5, btn_h + 2, 5], center=false);

        // USB/power cable hole (back wall) -- oversized, not connector-aligned
        translate([
            (ow - usb_w)/2,
            od - 0.5,
            wall + 2
        ])
            cube([usb_w, wall+1, usb_h], center=false);

        // Ventilation slots on left side
        for (i = [0:1:3]) {
            translate([
                -0.5,
                20 + i*10,
                wall + 5
            ])
                cube([wall+1, 6, 2], center=false);
        }

        // Snap-fit catch notches -- shallow blind pockets in the inner wall
        // face, positioned clear of every other cutout above. Z-range
        // matches the finger's nub height (see snap_finger / backplate()).
        notch_z0 = bp_origin + wall + (finger_h - nub_h) - notch_fit;
        notch_z1 = bp_origin + wall + finger_h + 1;
        notch_w = finger_w + 2*notch_fit;

        // Front wall notch (x centered at 10, clear of the OLED pocket)
        translate([10 - notch_w/2, wall - notch_depth, notch_z0])
            cube([notch_w, notch_depth, notch_z1 - notch_z0]);

        // Back wall notch (x centered at 70, clear of the USB cutout)
        translate([70 - notch_w/2, od - wall, notch_z0])
            cube([notch_w, notch_depth, notch_z1 - notch_z0]);

        // Left wall notch (y centered at 10, clear of the vent slots)
        translate([wall - notch_depth, 10 - notch_w/2, notch_z0])
            cube([notch_depth, notch_w, notch_z1 - notch_z0]);

        // Right wall notch (y centered at 55, clear of the SD slot)
        translate([ow - wall, 55 - notch_w/2, notch_z0])
            cube([notch_depth, notch_w, notch_z1 - notch_z0]);
    }

    // Internal mounting posts for OLED (on front wall).
    // dy is clamped so the standoff (which has real radius, not just an
    // axis line) can't poke past the shell's ceiling/floor -- oled_w is a
    // placeholder and, taken at face value, pushes the top posts 1.75mm
    // past the top face. Revisit this clamp once real OLED dimensions
    // are confirmed; if oled_w keeps growing, ih may need to grow too.
    oled_standoff_r = 2; // matches the "4" diameter passed to standoff() below
    oled_dy_safe = oh/2 - 2 - oled_standoff_r - 0.5;
    translate([ow/2, wall+oled_standoff_h, oh/2 + 2])
        rotate([90, 0, 0]) {
            for (p = oled_mount_holes) {
                dy = max(min(p[1] - oled_w/2, oled_dy_safe), -oled_dy_safe);
                translate([p[0] - oled_l/2, dy, 0])
                    standoff(oled_standoff_h, 4, oled_hole_d);
            }
        }

    // Internal mounting standoffs for SD module (right side wall, near front)
    // Plain vertical cylinders -- no rotation, to avoid the earlier bug class.
    sd_module_x0 = ow - wall - 2 - sd_w;
    for (p = sd_mount_holes)
        translate([sd_module_x0 + p[1], sd_y0 + p[0], wall + 1])
            standoff(sd_standoff_h, sd_standoff_d, sd_hole_d);

    // Button retainers (small posts behind top holes)
    for (i = [-1, 1]) {
        translate([
            (ow - btn_hole_d)/2 + i * (btn_spacing/2),
            15,
            oh - wall - 4
        ])
            difference() {
                cylinder(h=4, d=8, $fn=32);
                translate([0, 0, -0.5])
                    cylinder(h=5, d=btn_hole_d+0.5, $fn=32);
            }
    }
}

// ============================================
// BACK PLATE (removable bottom panel) with ESP32 standoffs and snap fingers
// ============================================
module backplate() {
    cube([bp_w, bp_d, wall], center=false);

    // ESP32 mounting standoffs
    // Align ESP32 so its USB port faces the cable hole (back of case)
    esp_x = (bp_w - esp_l)/2;
    esp_y = (bp_d - esp_w)/2 + 5; // shift toward front to leave room for wires
    for (p = esp_mount_holes)
        translate([esp_x + p[0], esp_y + p[1], wall])
            standoff(esp_standoff_h, esp_standoff_d, esp_hole_d);

    // Small wire strain relief posts
    translate([esp_x + esp_l/2, esp_y - 5, wall])
        standoff(4, 5, 2);
    translate([esp_x + esp_l/2 - 8, esp_y - 5, wall])
        standoff(4, 5, 2);

    // Snap-fit fingers -- positions chosen clear of the ESP32 footprint and
    // of the shell's OLED/SD/USB/vent cutouts (see matching notches in shell()).
    // Each finger's local (x,y) is just its intended WORLD position minus
    // bp_origin, since the whole backplate is translated by bp_origin at
    // assembly (see the top-level render call below).
    fx_front = 10 - bp_origin;
    fy_front = (wall + finger_running_clearance) - bp_origin;

    fx_back = 70 - bp_origin;
    fy_back = (od - wall - finger_running_clearance) - bp_origin;

    fx_left = (wall + finger_running_clearance) - bp_origin;
    fy_left = 10 - bp_origin;

    fx_right = (ow - wall - finger_running_clearance) - bp_origin;
    fy_right = 55 - bp_origin;

    translate([fx_front, fy_front, wall])
        snap_finger(finger_w, finger_t, finger_h, nub_h, nub_protrude, "front");
    translate([fx_back, fy_back, wall])
        snap_finger(finger_w, finger_t, finger_h, nub_h, nub_protrude, "back");
    translate([fx_left, fy_left, wall])
        snap_finger(finger_w, finger_t, finger_h, nub_h, nub_protrude, "left");
    translate([fx_right, fy_right, wall])
        snap_finger(finger_w, finger_t, finger_h, nub_h, nub_protrude, "right");
}

// ============================================
// OPTIONAL BUTTON CAPS (print separately)
// ============================================
module button_caps() {
    for (i = [0, 1]) {
        translate([i * 12, 0, 0]) {
            cylinder(h=2, d=btn_cap_d, $fn=32);
            translate([0, 0, 2])
                cylinder(h=2, d=btn_shaft_d, $fn=32);
        }
    }
}

// ============================================
// RENDER SELECTION
// ============================================
// Set one to true to render, or both true to see the assembly
render_shell = true;
render_backplate = true;
render_button_caps = false;

if (render_shell) {
    color("SkyBlue") shell();
}

if (render_backplate) {
    color("LightGreen") translate([bp_origin, bp_origin, -wall - 2]) backplate();
}

if (render_button_caps) {
    color("Orange") translate([ow/2 - 6, 15, oh]) button_caps();
}
