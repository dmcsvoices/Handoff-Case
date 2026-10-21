// assembly_review.scad - handoff_case assembly preview and review scenes.
// Dispatch: part_id 0 (assembly preview, default view 0 with proxies) and
// part_id 90 (review_dispatch_id; view ids per assembly.json "views").
// Colors are preview-only; printable exports never include mockups.

// Both printed caps seated on the button actuators (pressed 0.3 by the
// lid-clamped stack; the cap origin is the stem bottom face).
module button_caps_seated() {
    color([0.8, 0.8, 0.2, 0.9])
        for (i = [0, 1])
            translate([button_center(i)[0], button_center(i)[1],
                       cap_stem_bottom_z()])
                button_cap();
}

// View 0: blockout product preview. The lid hovers lid_preview_gap above
// the parting plane so the interior mockups, wire alleys, and the raised
// lid read in one image.
module preview_product() {
    base();
    translate([0, 0, lid_preview_gap]) lid();
    component_mockups();
    button_caps_seated();
}

// View 1: fully assembled product.
module view_product(show_proxies) {
    base();
    lid();
    if (show_proxies) {
        component_mockups();
        button_caps_seated();
    }
}

// View 2: exploded along Z (lid and caps lifted, mockups in place).
module view_exploded() {
    base();
    translate([0, 0, lid_explode_gap]) lid();
    component_mockups();
    for (i = [0, 1])
        translate([button_center(i)[0], button_center(i)[1],
                   cap_stem_bottom_z() + cap_explode_gap])
            color([0.8, 0.8, 0.2, 0.9]) button_cap();
}

// View 3/4: printable isolation.
module view_base_isolation() {
    base();
}
module view_lid_isolation() {
    lid();
}

// View 5: interior fit review - base cavity with all mockups, lid hidden.
module view_interior() {
    base();
    component_mockups();
    button_caps_seated();
}

module assembly_review(view_id = 0, show_proxies = false) {
    if (view_id == 0) {
        preview_product();
    } else if (view_id == 1) {
        view_product(show_proxies);
    } else if (view_id == 2) {
        view_exploded();
    } else if (view_id == 3) {
        view_base_isolation();
    } else if (view_id == 4) {
        view_lid_isolation();
    } else if (view_id == 5) {
        view_interior();
    } else {
        assert(false, str("Unknown assembly_view_id: ", view_id));
    }
}
