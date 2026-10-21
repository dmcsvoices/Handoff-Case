// cap_stack_coupon.scad - governed temporary fit-test coupon for
// handoff_case item 4.2 (playbooks/how_to_create_fit_test_coupons_and_
// partial_prints.md). Highest-risk mating profile: the button-cap /
// guide-bore / actuator stack (provisional button height, 0.3 mm press).
// Three press variants side by side: 0.05 (min) / 0.3 (nominal) /
// 0.5 (max). Derived from production modules and parameters only.
// Lives under output/handoff_case/probes/ and is REMOVED before the
// final artifact audits (see README 4.2 note: coupon artifacts cannot be
// reconciled with the flat governed output set without polluting the
// product manifest, so they are transient evidence).
//
// Usage:
//   openscad -o output/handoff_case/probes/cap_stack_coupon.stl \
//     -D coupon_mode=0 output/handoff_case/probes/cap_stack_coupon.scad
//   openscad -o output/handoff_case/probes/cap_stack_coupon_section.png \
//     --imgsize=1400,900 --autocenter --viewall --projection=o \
//     --camera=60,-120,30,80,0,0,400 -D coupon_mode=1 \
//     output/handoff_case/probes/cap_stack_coupon.scad

include <../../../designs/handoff_case/src/lib/defaults.scad>;
include <../../../designs/handoff_case/src/parts/lid.scad>;
include <../../../designs/handoff_case/src/parts/button_cap.scad>;
include <../../../designs/handoff_case/src/parts/mockups.scad>;

coupon_mode = is_undef(coupon_mode) ? 0 : coupon_mode;
press_variants = [0.05, 0.3, 0.5];

// One coupon station: a plate segment carrying a production-derived Ø8.3
// guide bore (replicated from the lid bore parameters), the production
// button_cap() placed at the pressed stem-bottom position for the
// variant press, and a production-dimension actuator stub on a body
// pedestal so the engagement reads in section.
module coupon_station(index) {
    press = press_variants[index];
    x0 = index * 25;
    stem_bottom = button_actuator_top_z() - press - cap_socket_depth;
    difference() {
        // Plate segment: lid thickness around the bore.
        translate([x0 - 10, -10, parting_z()])
            cube([20, 20, lid_t]);
        // Guide bore (production diameter, through).
        translate([x0, 0, parting_z() - boolean_epsilon])
            cylinder(h = lid_t + 2 * boolean_epsilon, d = cap_bore_d, $fn = 48);
    }
    // Button body pedestal (production envelope, top at body_top_z).
    translate([x0 - button_body / 2, -button_body / 2, floor_t])
        cube([button_body, button_body, button_h]);
    // Actuator stub (production dimensions).
    translate([x0, 0, button_body_top_z()])
        cylinder(h = button_actuator_h, d = button_actuator_d, $fn = 32);
    // Production cap shifted from the nominal press to this variant.
    translate([x0, 0, stem_bottom - cap_stem_bottom_z()])
        button_cap();
}

if (coupon_mode == 0) {
    // Export mode: all three stations, printable as one coupon.
    for (i = [0, 1, 2]) coupon_station(i);
} else if (coupon_mode == 1) {
    // Section mode: Y-slab through the stations exposing the press stack.
    intersection() {
        for (i = [0, 1, 2]) coupon_station(i);
        translate([-15, -0.8, 0]) cube([90, 1.6, 60]);
    }
    // 5 mm ruler ticks.
    color([0.9, 0.1, 0.1])
        for (x = [-10:5:60])
            translate([x, -1.2, 4])
                cube([0.25, 2.4, 5]);
} else {
    assert(false, str("Unknown coupon_mode: ", coupon_mode));
}
