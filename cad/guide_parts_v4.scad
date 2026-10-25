// Every piece of the v4 interactive assembly guide (guide-v4/), one per export, in model space
// (X left to right seen from the back, Y up, Z back to front), placed as assembled.
//   openscad -D 'gpart="frame"' -o frame.stl guide_parts_v4.scad
// export_guide_v4.py exports them all and bundles them into guide-v4/models.json.

include <camera1_v4.scad>
part = "none";          // the included model draws nothing by itself
end_grain = false;      // the frame's ends as plain panels: the grain is too many triangles for the page
gpart = "frame";
$fn = 32;

module wire(pts, d = 0.9) {
    for (i = [0 : len(pts) - 2]) hull() {
        translate(pts[i]) sphere(d = d, $fn = 8);
        translate(pts[i + 1]) sphere(d = d, $fn = 8);
    }
}
module insert() { difference() { cylinder(d = 3.5, h = insert_len); translate([0, 0, -1]) cylinder(d = 2, h = insert_len + 2); } }
module screw(len_) {     // M2 button head pointing along +Z, head at z = 0
    translate([0, 0, -1.2]) cylinder(d = 3.6, h = 1.2);
    cylinder(d = 2, h = len_);
}
module csk_screw(len_) { // M2 countersunk, head flush at z = 0, pointing +Z
    cylinder(d1 = 3.9, d2 = 2.0, h = 1.0);
    cylinder(d = 2, h = len_);
}

// ---------------------------------------------------------------- where the wires run
z_w = z_deck1 + 0.8;                     // in the deck's channels, under the board
z_pad = z_b1 + 0.05;
x_cross = notch[0] + 1.6;                // where the screen's wires turn into the channels' ends, in the notch
x_cross_usb = ch_x1 + 1.2;               // where other wires change rows: past the ribs' ends, at the board's USB end
lane_b = scr_xy[1] + 2.0;                // beside the board's bottom edge, on the deck
lane_t = btn_y - 3.2;                    // over the button carrier
z_lane_t = z_btn_base + carrier_t + 1.2;
z_over = cr_groove + 0.7;                // in the cradle's grooves
function P(k, row) = [pad_x(k), row == "g" ? row_g : row_v, z_pad];
function Pw(k, row) = [pad_x(k), row == "g" ? row_g : row_v, z_w];
chg_pad = function(k) [chg_xy[0] + chg[0] - 1.2, chg_xy[1] + 2.0 + k * 2.6, z_chg0 + 1.1];   // B+, B-, OUT+, OUT-
sw_leg = function(k) [sw_x + (k - 1) * 2.5, H + tp_h - tp_ceiling - sw[1] - 0.2, z_mid];
sh_leg = function(k) [shutter_x + (k ? 1 : -1) * (bbtn_feet / 2 - 0.4), y_sh_base - 0.15, z_mid + (k ? 1 : -1) * bbtn_leg_y];   // diagonal legs
guide_x = (cr_down[0] + cr_down[1]) / 2;   // the cradle's groove down
// up through a pad from the channel underneath
function up(k, row) = [Pw(k, row), P(k, row)];
// a screen pad up through the notch, to the crossing point, along a row's channel, up into its pad
function scr_route(i, k, row) = concat([[scr_pads[i][0], scr_pads[i][1], z_scr1 + 0.1], [scr_pads[i][0], scr_pads[i][1], z_w],
    [x_cross, scr_pads[i][1], z_w], [x_cross, row == "g" ? row_g : row_v, z_w]], up(k, row));
// from the carrier's floor down to the top channel, along it, up into a pad
function btn_route(x, k, row) = concat([[x, btn_y - 2.3, z_btn_base + carrier_t + 0.4], [x, btn_y - 2.3, z_lane_t], [x, board_xy[1] + board[1] + 1.4, z_w + 1.2],
    [x, row_v, z_w]], row == "v" ? up(k, "v") : concat([[x_cross_usb, row_v, z_w], [x_cross_usb, row_g, z_w]], up(k, "g")));

// the lane along the top, over the carrier and behind the front plate: power and shutter wires
lane_top = H - wall - 6.0;
z_top = z_fi - 3.0;
// the battery's leads: out of its top edge (by the module) into the lane along the top, over to the cradle's groove,
// down it into the porch and onto B+ / B-
bat_lead = function(k) let(x = bat_xy[0] + 0.8 + k * 1.4, gx = cr_up[0] + 1.2 + k * 1.4, ly = cr_lane_y + 2.6 - k * 1.4)   // out of the top edge by the module
    [[x, bat_xy[1] + bat[1] - 0.3, z_bat0 + bat[2] / 2], [x, bat_xy[1] + bat[1] + 1.2, z_over], [x, ly, z_over],
     [gx, ly, z_over], [gx, cr_porch[3] + 0.5, z_over], [chg_pad(k)[0] + 2.0, chg_pad(k)[1], cr_floor + 0.7], chg_pad(k)];
// screen pads, bottom to top: BLK CS DC RES SDA SCL VCC GND
scr_to = [[18, "g"], [19, "g"], [14, "g"], [2, "v"], [16, "g"], [17, "g"], [1, "v"], [20, "g"]];
foot_l = function(i) [btn_xs[i] - wire_x0 - wire_w / 2, btn_y - bbtn_leg_y, z_btn_base + carrier_t + 0.9];   // a switch's signal leg, through its wire hole
foot_r = function(i) [btn_xs[i] + wire_x0 + wire_w / 2, btn_y + bbtn_leg_y, z_btn_base + carrier_t + 0.9];   // the diagonal leg: GND
WIRES = concat(
    [for (i = [0 : 7]) [str("w_screen_", i), scr_route(i, scr_to[i][0], scr_to[i][1]), 0.8]],
    [
    ["w_btn_left", btn_route(foot_l(0)[0], 12, "v"), 0.9],      // GPIO 3
    ["w_btn_ok", btn_route(foot_l(1)[0], 13, "v"), 0.9],        // GPIO 46
    ["w_btn_right", btn_route(foot_l(2)[0], 15, "g"), 0.9],     // GPIO 48, crosses at the USB end
    ["w_shutter", concat([sh_leg(0), [shutter_x - 1, H - wall - 1, z_mid - 1.2], [shutter_x - 1, lane_top, z_top], [pad_x(19), lane_top, z_top],
                          [pad_x(19), board_xy[1] + board[1] + 1.4, z_w + 1.2], [pad_x(19), row_v, z_w]], up(19, "v")), 0.9],
    ["w_bgnd_chain", [foot_r(0), foot_r(1), foot_r(2)], 0.9],
    ["w_bgnd_shutter", [foot_r(0), [foot_r(0)[0], lane_top + 1, z_top - 1], [shutter_x + 3.2, lane_top + 1, z_top - 1],
                        [shutter_x + 3.2, H - wall - 1, z_mid + 1.2], sh_leg(1)], 0.9],
    ["w_bgnd_board", concat([foot_r(2), [foot_r(2)[0], board_xy[1] + board[1] + 1.4, z_w + 1.2], [foot_r(2)[0], row_v, z_w],
                             [x_cross_usb + 0.6, row_v, z_w], [x_cross_usb + 0.6, row_g + 0.6, z_w], [pad_x(20), row_g + 0.6, z_w]], up(20, "g")), 0.9],
    ["w_bat_red", bat_lead(0), 1.3],
    ["w_bat_black", bat_lead(1), 1.3],
    ["w_out_plus", [chg_pad(2), [chg_pad(2)[0] + 2.0, chg_pad(2)[1], cr_floor + 0.7], [cr_up[1] - 1.0, cr_porch[3] + 0.5, z_over],
                    [cr_up[1] - 1.0, lane_top - 1, z_top + 1.2], [sw_x - 1.2, lane_top - 1, z_top + 1.2], [sw_x - 1.2, H - wall - 1, z_mid],
                    [sw_leg(1)[0], H + 1, z_mid], sw_leg(1) - [0, 2.0, 0]], 1.3],
    ["w_5v", concat([sw_leg(2) - [0, 2.0, 0], [sw_x + 2.5, H + 1, z_mid], [sw_x + 2.5, H - wall - 1, z_lane_t],
                     [pad_x(20), board_xy[1] + board[1] + 1.4, z_w + 1.2], [pad_x(20), row_v, z_w]], up(20, "v")), 1.3],
    ["w_gnd", concat([chg_pad(3), [chg_pad(3)[0] + 2.0, chg_pad(3)[1], cr_floor + 0.7], [guide_x, cr_porch[1] + 1.0, cr_floor + 0.7], [guide_x, 6.0, z_over], [div_x + 1.5, 6.0, z_over], [div_x + 2.5, lane_b, z_over],
                      [div_x + 4.5, lane_b, z_w], [pad_x(20) - 0.6, lane_b, z_w], [pad_x(20) - 0.6, row_g - 0.4, z_w]], up(20, "g")), 1.3],
    ["w_sense", concat([[res_box[0] + res_box[2], res_box[1] + res_box[3] / 2, cr_floor + 1.2], [guide_x + 0.9, res_box[1] + res_box[3] / 2, cr_floor + 0.7],
                        [guide_x + 0.9, 7.2, z_over], [div_x + 1.5, 7.2, z_over], [div_x + 2.5, lane_b + 0.9, z_over], [div_x + 4.5, lane_b + 0.9, z_w],
                        [pad_x(3), lane_b + 0.9, z_w], [pad_x(3), row_g, z_w]], [P(3, "g")]), 0.9]
    ]);

module part_named(n) {
    // ---- the case
    if (n == "frame") frame();
    if (n == "deck") deck();
    if (n == "cradle") cradle();
    if (n == "carrier") carrier();
    if (n == "back_plate") back_plate();
    if (n == "front_plate") translate([0, 0, z_fi]) front_plate();
    if (n == "caps") for (i = [0 : 2]) translate([btn_xs[i], btn_y, cap_top]) button_cap(i);
    if (n == "shutter_cap") ghost("shuttercap");
    if (n == "knob") ghost("knob");
    if (n == "lens_barrel") translate([lens_c[0], lens_c[1], D]) mirror([1, 0, 0]) lens_barrel();
    if (n == "top_plate") top_plate();
    if (n == "top_bits") top_bits_placed();
    if (n == "bottom_plate") bottom_plate();
    // plain panels here (the grain is too many triangles for the page), and the portrait as a flat inlay
    if (n == "covering_front") translate([0, 0, D]) linear_extrude(bump) leatherette_2d();
    if (n == "covering_back") translate([0, 0, -bump]) linear_extrude(bump - 0.02) back_leatherette_2d();
    if (n == "portrait") translate([0, 0, -bump - 0.03]) linear_extrude(0.06) portrait_ink();
    if (n == "windows") window_card();

    // ---- electronics
    if (n == "battery") ghost("battery");
    if (n == "foam") zbox(bat_xy[0] + 3, bat_xy[1] + 4, bat[0] - 6, bat[1] - 8, z_bi + 0.02, z_bat0);
    if (n == "screen_glass") zbox(glass_xy[0], glass_xy[1], scr_glass[0], scr_glass[1], z_bi - scr_sink + 0.04, z_scr1 - scr_pcb);
    if (n == "screen_active") zbox(win_xy[0], win_xy[1], scr_active[0], scr_active[1], z_bi - scr_sink - 0.02, z_bi - scr_sink + 0.1);
    if (n == "screen_pcb") difference() {
        zbox(scr_xy[0], scr_xy[1], scr[0], scr[1], z_scr1 - scr_pcb, z_scr1);
        for (h = scr_holes) zcyl(h, scr_hole_d, z_bi, z_scr1 + 1);
    }
    if (n == "screen_pads") for (p = scr_pads) translate([p[0], p[1], z_scr1 - 0.01]) cylinder(d = 1.6, h = 0.08);
    if (n == "screen_pad") for (y = [scr_xy[1] + 0.8, scr_xy[1] + scr[1] - 6.8]) zbox(scr_xy[0] + 8, y, scr[0] - 12, 6, z_scr1 + 0.01, z_deck0);
    if (n == "board_pcb") difference() {
        zbox(board_xy[0], board_xy[1], board[0], board[1], z_b0, z_b1);
        for (h = board_holes) zcyl(h, board_hole_d, z_b0 - 1, z_b1 + 1);
    }
    if (n == "board_pads") for (k = [1 : n_pads], y = [row_g, row_v]) translate([pad_x(k), y, z_b1 - 0.01]) cylinder(d = 1.7, h = 0.08);
    if (n == "board_module") zbox(board_xy[0] - board_ant, lens_c[1] - board_mod[1] / 2, board_mod[0], board_mod[1], z_b1, z_b1 + board_mod[2]);
    if (n == "board_parts") {
        for (y = [usb_ttl, usb_otg]) zbox(x_b1 + usb_over - usb_c[1], board_xy[1] + y - usb_c[0] / 2, usb_c[1], usb_c[0], z_b0 + usb_top - usb_c[2], z_b0 + usb_top);
        zbox(board_xy[0] + 36, board_xy[1] + 9, 10, 6, z_b1, z_b1 + 1.6);                // USB-serial chip
        zbox(board_xy[0] + 25, lens_c[1] - 6, 4, 12, z_b1, z_b1 + 1.8);                  // camera socket
        for (y = [board_xy[1] + 3, board_xy[1] + board[1] - 7]) zbox(x_b1 - 14, y, 4, 4, z_b1, z_b1 + 1.6);   // RST, BOOT
        zbox(board_xy[0] + 2, lens_c[1] - 7.5, 15, 15, z_b0 - 1.5, z_b0);                // microSD socket underneath
    }
    if (n == "camera") translate([lens_c[0], lens_c[1], 0]) {
        zbox(-cam_holder / 2 - 0.5, -cam_holder / 2 - 2, cam_holder + 1, cam_holder + 2.5, z_cam0, z_cam0 + cam_pcb_t);
        zbox(-cam_holder / 2, -cam_holder / 2, cam_holder, cam_holder, z_cam0 + cam_pcb_t, z_lens - cam_barrel[1]);
        translate([0, 0, z_lens - cam_barrel[1] - 0.01]) cylinder(d = cam_barrel[0], h = cam_barrel[1] - 0.3);
    }
    if (n == "camera_glass") translate([lens_c[0], lens_c[1], z_lens - 0.32]) cylinder(d = cam_barrel[0] - 2.4, h = 0.3);
    if (n == "camera_tape") translate([lens_c[0], lens_c[1], 0]) zbox(-3.5, -3.5, 7, 7, z_b1 + board_mod[2], z_cam0);
    if (n == "ribbon") {   // folded back from the camera onto the board's socket
        x0 = lens_c[0] + cam_holder / 2 + 0.5;
        wire([[x0, lens_c[1], z_cam0 + 0.4], [x0 + 2.4, lens_c[1], z_cam0 + 0.2], [x0 + 3.6, lens_c[1], z_cam0 - 1.4],
              [x0 + 3.0, lens_c[1], z_b1 + board_mod[2] + 0.2], [board_xy[0] + 25, lens_c[1], z_b1 + 1.9]], 4.0);
    }
    if (n == "charger_pcb") zbox(chg_xy[0], chg_xy[1], chg[0], chg[1], z_chg0, z_chg0 + 1.0);
    if (n == "charger_parts") {
        zbox(chg_xy[0] - chg_usb_over, chg_c[1] - 4.5, 7.4, 9.0, z_chg0 + 1.0, z_chg0 + chg_t);
        zbox(chg_xy[0] + 9, chg_xy[1] + 2, 3, 3, z_chg0 + 1.0, z_chg0 + 2.0);
        for (k = [0 : 3]) translate(chg_pad(k) + [0, 0, -0.05]) cylinder(d = 1.6, h = 0.1);
    }
    if (n == "resistors") for (j = [0, 1]) translate([res_box[0] + 1.0, res_box[1] + 2.0 + j * 3.0, cr_floor + 1.2]) rotate([0, 90, 0]) cylinder(d = 2.3, h = res_box[2] - 2.0);
    if (n == "buttons") ghost("buttons");
    if (n == "shutter_sw") ghost("shutter");
    if (n == "slide_sw") { ghost("switch"); for (k = [0 : 2]) translate(sw_leg(k)) translate([-0.3, -2.0, -0.3]) cube([0.6, 2.2, 0.6]); }

    // ---- inserts and screws
    if (n == "inserts") {
        for (p = posts) { translate([p[0], p[1], z_bi]) insert(); translate([p[0], p[1], z_fi - insert_len]) insert(); }
        for (q = concat(deck_tabs, board_holes)) translate([q[0], q[1], z_deck0 - insert_len]) insert();
        for (x = tp_screws) translate([x, H, z_mid]) rotate([90, 0, 0]) insert();
        for (x = bp_screws) translate([x, 0, z_mid]) rotate([-90, 0, 0]) insert();
    }
    if (n == "inserts_barrel") for (a = [90, 210, 330]) translate([lens_c[0] + barrel_screw_r * cos(a), lens_c[1] + barrel_screw_r * sin(a), D]) insert();
    if (n == "screws_back") for (p = posts) translate([p[0], p[1], 0]) csk_screw(5);
    if (n == "screws_front") for (p = posts) translate([p[0], p[1], D]) mirror([0, 0, 1]) csk_screw(5);
    if (n == "screws_deck") for (t = deck_tabs) translate([t[0], t[1], z_deck1]) mirror([0, 0, 1]) screw(4);
    if (n == "screws_board") for (h = board_holes) translate([h[0], h[1], z_b1]) mirror([0, 0, 1]) screw(8);
    if (n == "screws_carrier") for (b = carrier_bosses) translate([b[0], b[1], z_btn_base + carrier_t]) mirror([0, 0, 1]) screw(6);
    if (n == "screws_bottom") for (x = bp_screws) translate([x, -bp_h, z_mid]) rotate([-90, 0, 0]) csk_screw(8);
    if (n == "screws_top") for (x = tp_screws) translate([x, H + tp_h, z_mid]) rotate([90, 0, 0]) csk_screw(13);
    if (n == "screws_barrel") for (a = [90, 210, 330])
        translate([lens_c[0] + barrel_screw_r * cos(a), lens_c[1] + barrel_screw_r * sin(a), z_fi]) mirror([0, 0, 1]) screw(5);

    // ---- wires, one piece each (the v4 pin plan; every board wire comes up through its pad from underneath)
    for (w = WIRES) if (n == w[0]) wire(w[1], w[2]);
    if (n == "_ends") for (w = WIRES) echo(str("WIRE ", w[0], " ", w[1][0], " ", w[1][len(w[1]) - 1]));
}
part_named(gpart);
