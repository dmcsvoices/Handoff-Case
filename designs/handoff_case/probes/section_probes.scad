// section_probes.scad - governed temporary inspection geometry for
// handoff_case item 4.1 (playbooks/how_to_create_and_use_openscad_sections_
// probes_and_crops.md). Lives under output/handoff_case/probes/ and is
// REMOVED before the final artifact audits. Derives every section from the
// production modules and parameters - no redrawn dimensions. View
// directions are tilted a few degrees off the section normal to dodge the
// OpenSCAD 2021.01 axis-aligned preview hole-occlusion artifact (the
// exported geometry is unaffected; see design README toolchain note).
//
// Usage (from repo root):
//   openscad -o output/handoff_case/probes/section_<n>.png \
//     --imgsize=1400,1000 --autocenter --viewall --projection=o \
//     --camera=<from probe camera table> \
//     -D probe_id=<n> output/handoff_case/probes/section_probes.scad

include <../../../designs/handoff_case/src/lib/defaults.scad>;
include <../../../designs/handoff_case/src/parts/base.scad>;
include <../../../designs/handoff_case/src/parts/lid.scad>;
include <../../../designs/handoff_case/src/parts/button_cap.scad>;

probe_id = is_undef(probe_id) ? 0 : probe_id;

// 5 mm ruler ticks across the slab bounds (probe-only overlay, red).
module ruler_x(x0, x1, y, z) {
    color([0.9, 0.1, 0.1])
        for (x = [x0:5:x1])
            translate([x, y - 0.45, z - 2.5])
                cube([0.25, 0.9, x == x0 ? 10 : 5]);
}
module ruler_z(z0, z1, y, x) {
    color([0.9, 0.1, 0.1])
        for (z = [z0:5:z1])
            translate([x - 2.5, y - 0.45, z])
                cube([x == 0 ? 10 : 5, 0.9, 0.25]);
}

if (probe_id == 1) {
    // 1: Rail + land cross-section at the board mid-length (plane normal
    //    to Y). Expect: rail wall 3.0, land 2.0 x 3.5, board underside at
    //    floor+3.5, pin-tip to floor 2.0.
    intersection() {
        base();
        translate([0, 57.0, 0]) cube([50, 1.5, 22]);
    }
    ruler_x(4, 46, 57.0, 0.5);
    ruler_z(0, 20, 57.0, 4.75);
} else if (probe_id == 2) {
    // 2: End-stop bar + shell notches at the USB end (plane normal to Y).
    //    Expect: bar 3.0 thick, top at board top 8.1, notches around both
    //    shells, web between notches 3.0.
    intersection() {
        base();
        translate([0, 88.9, 0]) cube([50, 1.5, 16]);
    }
    ruler_x(14, 44, 88.9, 3.0);
    ruler_z(0, 14, 88.9, 15.0);
} else if (probe_id == 3) {
    // 3: OLED bosses + pilots + window ligament (plane normal to Y at the
    //    front wall mid). Expect: 4x Ø6 bosses, Ø2.5 pilots, window edge
    //    to lower pilot column 4.6, window inside glass 1.39/4.55.
    intersection() {
        base();
        translate([45, 1.0, 0]) cube([45, 1.2, 42]);
    }
    ruler_x(50, 86, 1.0, 2.5);
    ruler_z(2, 40, 1.0, 49.5);
} else if (probe_id == 4) {
    // 4: SD pocket + card slot floor ligament (plane normal to X through
    //    the slot centre). Expect: slot 3.3 tall centred at card centre
    //    9.45, slot bottom to case floor 4.8, pad 3.0, pocket walls 3.0.
    intersection() {
        base();
        translate([73.0, 20, 0]) cube([1.5, 50, 16]);
    }
    ruler_z(0, 14, 45.0, 70.0);
} else if (probe_id == 5) {
    // 5: USB cutouts + web (plane normal to Y at the back wall mid).
    //    Expect: two 10.0 x 4.5 openings, r1 corners, web 2.3
    //    (user-approved exception), floor ligament 3.65.
    intersection() {
        base();
        translate([10, 99.0, 0]) cube([35, 1.5, 16]);
    }
    ruler_x(14, 42, 99.0, 3.0);
    ruler_z(0, 14, 99.0, 15.5);
} else if (probe_id == 6) {
    // 6: M3 tower overlap at the front-left corner (plane normal to X
    //    through the fl station). Expect: 13x13 tower bridging floor and
    //    both walls, Ø3 pilot 8 deep, tops at parting plane.
    intersection() {
        base();
        translate([7.0, 0, 0]) cube([1.5, 16, 50]);
    }
    ruler_z(30, 50, 8.0, 11.5);
} else if (probe_id == 7) {
    // 7: Lid recess floor + M3 bore at the fr station (plane normal to X).
    //    Expect: Ø3.4 bore through, Ø7 x 4.0 recess from the top, retained
    //    floor 3.0 over the parting plane.
    intersection() {
        lid();
        translate([85.0, 14, 0]) cube([1.5, 18, 60]);
    }
    ruler_z(43, 55, 22.0, 88.0);
} else if (probe_id == 8) {
    // 8: Lid cap-bore ligaments (plan section just under the parting
    //    plane). Expect: Ø8.3 cap bores at the well centres, >= 3.0 to the
    //    first vent column and to the fr tower.
    intersection() {
        lid();
        translate([10, 5, 44.5]) cube([55, 28, 1.2]);
    }
    ruler_x(15, 50, 17.0, 44.5);
} else if (probe_id == 9) {
    // 9: Anti-lift blade section (plane normal to X through the right
    //    blade). Expect: 1.6 wide x 3.0 thick blade from the lid underside
    //    down to the board top face 8.1.
    intersection() {
        lid();
        translate([36.9, 55, 0]) cube([1.0, 40, 55]);
    }
    ruler_z(0, 50, 74.0, 34.5);
} else {
    assert(false, str("Unknown probe_id: ", probe_id));
}
