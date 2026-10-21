// Handoff Device Case
// Parametric enclosure for ESP32-S3 DevKitC, 1.3" OLED, micro SD slot, and 2 buttons
// OpenSCAD source - edit parameters below, then render/export STL
// Author: Janelle (OpenClaw)

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
// Lid/back plate overlap
overlap = 4.0;
// Screw hole diameter for case assembly
screw_d = 3.0;
// Screw head countersink diameter
screw_head_d = 6.0;

// --- ESP32-S3 DevKitC ---
esp_l = 70.0;            // board length
esp_w = 28.0;            // board width
esp_h = 5.5;             // board+header height (clearance)
esp_hole_d = 2.5;        // mounting hole diameter
esp_hole_inset_x = 2.0;  // hole distance from short ends
esp_hole_inset_y = 2.0;  // hole distance from long edges
esp_standoff_h = 6.0;    // standoff height
esp_standoff_d = 5.0;    // standoff diameter

// --- 1.3" I2C OLED module ---
oled_l = 36.0;           // module length (longer side)
oled_w = 35.5;           // module width
oled_disp_w = 22.5;      // display window width
oled_disp_h = 11.5;      // display window height
oled_hole_d = 2.0;       // module mounting hole diameter
oled_standoff_h = 4.0;   // standoff from front wall

// --- micro SD SPI module ---
sd_l = 42.0;             // module length
sd_w = 25.0;             // module width
sd_h = 5.0;              // module thickness
sd_slot_w = 24.0;        // width of SD card slot on case wall
sd_slot_h = 3.0;         // height of SD card slot

// --- Tactile buttons ---
btn_w = 6.0;             // button body width
btn_h = 6.0;             // button body depth
btn_shaft_d = 3.0;       // actuator shaft diameter
btn_shaft_h = 3.5;       // actuator protrusion height
btn_hole_d = 6.5;        // hole in case for button body
btn_spacing = 15.0;      // center-to-center distance
btn_cap_d = 6.0;         // printed button cap diameter (optional)

// --- Derived dimensions ---
ow = iw + 2*wall;        // outer width
od = id + 2*wall;        // outer depth
oh = ih + 2*wall;        // outer height

// ============================================
// MODULES
// ============================================

// A centered box with optional wall thickness
module box(size, wall=0, center=false) {
    if (wall == 0) {
        cube(size, center=center);
    } else {
        difference() {
            cube(size, center=center);
            translate([wall, wall, wall])
                cube([size[0]-2*wall, size[1]-2*wall, size[2]-wall+0.1], center=false);
        }
    }
}

// A standoff with a screw hole
module standoff(h, d, hole_d, center=false) {
    difference() {
        cylinder(h=h, d=d, $fn=32);
        translate([0, 0, -0.5])
            cylinder(h=h+1, d=hole_d, $fn=32);
    }
}

// ============================================
// MAIN SHELL (front, top, sides)
// ============================================
module shell() {
    difference() {
        // Outer shell
        cube([ow, od, oh], center=false);

        // Hollow interior
        translate([wall, wall, wall])
            cube([iw, id, ih+0.1], center=false);

        // Back plate recess (so the lid sits flush)
        translate([wall/2, wall/2, 0])
            cube([ow-wall, od-wall, overlap+0.1], center=false);

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
            (oh - oled_w)/2 + 2
        ])
            cube([oled_l, 5, oled_w], center=false);

        // SD card slot (right side wall, near front)
        translate([
            ow - wall - 0.5,
            od - 15 - sd_slot_w/2,
            wall + 4
        ])
            cube([wall+1, sd_slot_w, sd_slot_h], center=false);

        // SD module clearance pocket
        translate([
            ow - wall - 4,
            od - 15 - sd_w/2 - 2,
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

        // USB/power cable hole (back side)
        translate([
            (ow - 14)/2,
            od - 0.5,
            wall + 3
        ])
            cube([14, wall+1, 6], center=false);

        // Ventilation / reset access slots on left side
        for (i = [0:1:3]) {
            translate([
                -0.5,
                20 + i*10,
                wall + 5
            ])
                cube([wall+1, 6, 2], center=false);
        }

        // Corner screw holes for lid attachment
        for (x = [wall*2, ow-wall*2], y = [wall*2, od-wall*2]) {
            translate([x, y, -0.5])
                cylinder(h=oh+1, d=screw_d, $fn=32);
            // Countersink at the bottom (outside of case)
            translate([x, y, -0.5])
                cylinder(h=3, d=screw_head_d, $fn=32);
        }
    }

    // Internal mounting posts for OLED (on front wall)
    translate([ow/2, wall+oled_standoff_h, oh/2 + 2])
        rotate([90, 0, 0]) {
            for (dx = [-oled_l/2+3, oled_l/2-3], dy = [-oled_w/2+3, oled_w/2-3]) {
                translate([dx, dy, 0])
                    standoff(oled_standoff_h, 4, oled_hole_d);
            }
        }

    // Internal mounting posts for SD module (right side wall)
    translate([ow - wall - 3, od - 15, wall + 1])
        rotate([0, 0, 90]) {
            for (dx = [-sd_l/2+3, sd_l/2-3], dy = [-sd_w/2+2, sd_w/2-2]) {
                translate([dx, dy, 0])
                    standoff(3, 4, 1.5);
            }
        }

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
// BACK PLATE / LID with ESP32 standoffs
// ============================================
module backplate() {
    difference() {
        // Plate that fits into the shell recess
        cube([ow-wall, od-wall, wall], center=false);

        // Corner screw holes
        for (x = [wall*1.5, ow-wall*2.5], y = [wall*1.5, od-wall*2.5]) {
            translate([x, y, -0.5])
                cylinder(h=wall+1, d=screw_d, $fn=32);
        }
    }

    // ESP32 mounting standoffs (centered on the plate)
    // Align ESP32 so its USB port faces the cable hole (back of case)
    esp_x = (ow - wall - esp_l)/2;
    esp_y = (od - wall - esp_w)/2 + 5; // shift toward front to leave room for wires
    translate([esp_x, esp_y, wall]) {
        for (dx = [esp_hole_inset_x, esp_l - esp_hole_inset_x],
             dy = [esp_hole_inset_y, esp_w - esp_hole_inset_y]) {
            translate([dx, dy, 0])
                standoff(esp_standoff_h, esp_standoff_d, esp_hole_d);
        }
    }

    // Small wire strain relief posts
    translate([esp_x + esp_l/2, esp_y - 5, wall])
        standoff(4, 5, 2);
    translate([esp_x + esp_l/2 - 8, esp_y - 5, wall])
        standoff(4, 5, 2);
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
    color("LightGreen") translate([0, 0, -wall - 0.5]) backplate();
}

if (render_button_caps) {
    color("Orange") translate([ow/2 - 6, 15, oh]) button_caps();
}
