// main.scad - handoff_case part dispatch.
// Part ids (parts.json):
//   0  = assembly preview (blockout product view with component mockups)
//   1  = base (printable)
//   2  = lid (printable)
//   3  = button_cap (printable, printed twice; blockout placeholder)
//   10 = esp32 mockup (reference, non-printable)
//   11 = oled mockup (reference, non-printable)
//   12 = sd_module mockup (reference, non-printable)
//   13 = buttons mockup (reference, non-printable)
//   90 = assembly review scene (review_dispatch_id in assembly.json; not a
//        printable part).
// Config-driven per-part entries are injected by scripts/scad_build_all.py
// (part_id + part params), so this file hardcodes no config values.
// Mockups and the base/lid are modeled in the shared world frame; the
// button_cap is modeled at its own fabrication origin.

include <lib/defaults.scad>;
include <parts/base.scad>;
include <parts/lid.scad>;
include <parts/button_cap.scad>;
include <parts/mockups.scad>;
include <parts/assembly_review.scad>;

review_dispatch_id = 90;

_part_id = is_undef(part_id) ? 0 : part_id;

if (_part_id == 0) {
    // Assembly preview: lid raised for interior visibility, proxies shown.
    assembly_review(0, true);
} else if (_part_id == 1) {
    render(convexity = 10) base();
} else if (_part_id == 2) {
    render(convexity = 10) lid();
} else if (_part_id == 3) {
    render(convexity = 10) button_cap();
} else if (_part_id == 10) {
    esp32_mockup();
} else if (_part_id == 11) {
    oled_mockup();
} else if (_part_id == 12) {
    sd_module_mockup();
} else if (_part_id == 13) {
    buttons_mockup();
} else if (_part_id == review_dispatch_id) {
    // Product, exploded, isolation and interior review scenes per
    // assembly.json "views" (assembly_view_id, show_proxies).
    assembly_review(is_undef(assembly_view_id) ? 0 : assembly_view_id,
                    is_undef(show_proxies) ? false : show_proxies);
} else {
    assert(false, str("Unknown part_id: ", _part_id));
}
