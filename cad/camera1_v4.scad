// Digicam camera 1, v4 (24 Oct 2026): the retro body rebuilt around the parts as measured.
//
// What changed from v3, and why:
//   - the real parts: the screen is 61.7 x 37 x 4 mm, the board 62.4 x 28 with its ESP32
//     module's antenna 4.5 mm past the end, two holes only (at the USB end) and two USB-C
//     ports. v3's frame was too short for the board and too tight for the screen
//   - the screen sits on four pins through its own corner holes (no tight lip)
//   - a wiring deck between the screen and the board: a channel under each pad row (the
//     board is its roof), two ribs that carry the board between the rows, and a notch at
//     the screen's pin end, open at the edge, so the soldered bundle slides in
//   - the board and the deck share two screws at the board's holes, into the frame
//   - a power cradle over the battery: a pocket for the charge module, a slot for the
//     battery-level resistors, and guides for the wires
//   - every wire passage is open from the front or big enough to pass the switch through
//   - polish: countersunk screws, the front ones hidden under the leather; engraving on the
//     top plate, round the lens barrel and on the bottom; chamfered USB openings
//
// 25 Oct: exterior in the style of the Leica M6, in brown: a silver top plate and a silver bottom
// plate either side of a brown body (frame and plates printed brown, leather front and back and
// grain on the two ends), so there's no brown-to-black edge. Top: a frosted frame-line window
// beside the viewfinder, a bigger speed dial, an advance lever and collar round the shutter, a
// round rewind-style knob on the power switch, a frame-counter window. Front: a mount ring, a lens
// release button and a frame selector lever; a focusing tab on the barrel. Back: the leather covers
// it all (portrait included) round a slim silver screen bezel, and hides all four screws.
// The inside is unchanged, apart from two bosses in the bottom wall for the bottom plate.
// 25 Oct, second pass, on the M6's proportions (138 x 79 x 38 mm): the body is 128 wide, so it keeps
// the M6's width to height. The silver cover comes down the front and the ends to 44 mm (a third
// of the height, as on the M6) and its corners are rounder; the edges are 3 mm round. The lens is
// bigger (44 mm), and its mount ring, lens release and frame selector are one print with it. The
// name, RYAN / LIM, is engraved in Futura like the M6's LEICA / M6. Strap holes through both ends.
// The battery is held by spring tabs, not a tight fit. Fewer loose parts: the window inserts are
// one dark card behind the front windows, and the screen's bezel is part of the back covering.
// 25 Oct, third pass: Ryan is left-handed, so this is a left-handed M6, the M6 mirrored: the shutter,
// speed dial, advance lever and frame counter are on the left as you hold it, the rewind knob (the
// power switch) on the right, and the windows, the name and the lens's release and selector are
// mirrored with them. The lens stays left of centre seen from the front (its place is set by the board).
// 25 Oct, last fixes: the screen is turned round, its pins by the board's module (3V3) end, as its
// wires were cut (the firmware turns the picture round); its glass sinks 1.2 mm into the back plate
// and a gentle bevel runs from the glass up through the plate and the leather's smooth frame. The
// silver front gets more of the M6's detail: raised rims round the windows, a round badge where
// the red dot is, the rewind lever with its R, a small "No. 01" under the viewfinder. The lens and
// the bottom read "digicam" and "ryan lim". Both of the board's USB-C sockets have an opening.
// 25 Oct, after the test print: the screen's glass now rests on its pocket's floor (the rings round
// the locating pins held the screen up, so the glass hung above its pocket and the parts on the
// screen's back lifted the deck); the pocket is wider; the covering's frame round the screen is a
// smooth curve. The deck clears the screen's flex and parts with a big opening, and grows a wire
// tray beside the screen's pins. The screen moves 4 mm toward the battery, so the wires soldered to its
// pins rise clear of the ESP32 module's overhang. No height changes, and the deck's screw tabs stay
// on the printed frame's bosses: the frame still fits (the back plate, carrier and deck are reprinted).
//
// Construction: a frame (the sides) between a back plate and a front plate, M2 screws into
// heat-set inserts; a top plate on the frame's top wall. Everything prints without supports.
//
// Coordinates: X across the body seen from the BACK (screen side), Y up, Z from the back
// face (0) to the front face (D). Print exports are mirrored back to real space (real()).
//
//   openscad -D 'part="frame"' -o export/v4/frame.stl camera1_v4.scad
//   python3 export_v4.py        (every part, renders, and the fit check)

part = "assembly";
show_parts = true;
$fn = 48;

// ================================================================ parts as measured (MEASURE = still an estimate)
// ESP32-S3-CAM board (GOOUUU, N16R8): component side to the front, USB end to the right
// (seen from the back), module end to the left
board = [62.4, 28.0];       // PCB, without the module's overhang
board_pcb = 1.5;            // MEASURE (chip top to microSD bottom is 6.1 = 1.5 socket + PCB + 3.1 module)
board_ant = 4.5;            // the module and its antenna overhang the PCB at the module end
board_mod = [25.5, 18.0, 3.1];   // ESP32-S3-WROOM-1: length along the board (incl. overhang), width, height
board_hole_d = 2.5;
board_hole_at = [2.0, 1.5]; // hole centre from the USB end, and from the long edge
pad0 = 1.9;                 // first pad's centre from the module end: MEASURE (read off the listing photo)
pad_edge = 1.3;             // pad row centre from the long edge (rows 25.4 apart): MEASURE
n_pads = 20;
pitch = 2.54;
usb_c = [8.94, 7.3, 3.2];   // USB-C socket: width, length, height
usb_top = 4.2;              // socket top above the PCB's underside (measured)
usb_over = 0.6;             // socket face past the PCB's end: MEASURE
usb_ttl = 8.6;              // TTL (programming) socket centre from the GND row's long edge: MEASURE
usb_otg = 19.4;             // OTG socket centre, same edge: MEASURE (no opening; GPIO 19/20 drive the screen)
board_under = 2.0;          // tallest part under the board (microSD socket 1.5)
lens_from_end = 11.5;       // lens centre from the PCB's module end: MEASURE (from the listing photo)
cam_holder = 8.5;
cam_pcb_t = 1.0;
cam_h = 5.5;                // back of the camera PCB to the front of the lens: MEASURE
cam_barrel = [8.0, 2.0];
cam_tape = 0.2;             // thin double-sided tape under the camera (the board sits 1 mm higher since 26 Oct)

// 2.0 in screen, GMT020-02-8P (ST7789, 240 x 320): pins on one short edge, glass facing you
scr = [61.7, 37.0];
scr_t = 4.0;                // glass face to the back of the PCB
scr_pcb = 1.6;
scr_glass = [51.7, 35.9];   // glass: 5 mm in from each short edge; its width is MEASURE (the v3 lip was 0.4 tight at 35.5)
scr_glass_in = 5.0;
scr_hole_d = 2.5;
scr_hole_at = [1.5, 4.6];   // hole centre from the short edge, from the long edge (measured: 27.8 mm between centres across)
scr_active = [40.8, 30.6];
scr_act_from_pins = 9.4;    // visible area from the pin edge (11.5 from the other: the glass's dead strip is there)
scr_pin_in = 1.8;           // pad row from the pin edge: MEASURE

// charge/boost module: USB-C on one short edge, its pads (B+ B- OUT+ OUT-) on the other
chg = [15.5, 11.7];
chg_t = 3.8;
chg_usb_z = 2.2;            // socket centre above the module's underside: MEASURE
chg_usb_over = 0.6;         // MEASURE
chg_led = [9.0, 0];         // charge LED, from the USB end and the centre line: MEASURE

bat = [34, 50, 10];         // battery, standing, leads out of the top
btn = 5.0;                  // the shutter's tactile switch, flat feet
btn_h = 6.0;                // base to the top of the plunger (all four switches)
btn_feet = 7.6;
btn_body = 3.5;             // MEASURE
// The three back switches are 6 x 6 SMD tactile switches with FOUR gull-wing legs, two out of each of
// the +-X sides near the corners (Allen's carrier for v3, PR #2: legs 0.7 wide, centres 4.5 apart in Y,
// flat feet 0.3 below the body's base). Their pockets in the carrier follow his design.
bbtn_w = 5.8;               // body, measured 5.7-5.8 (the datasheet says 6.0)
bbtn_feet = 8.0;            // feet, tip to tip (datasheet 8.0 +-0.3)
bbtn_body = 3.6;            // base to the body's metal top (the snap fingers catch this edge), datasheet
bbtn_leg_y = 2.25;          // leg centre, either side of the middle of the body
bbtn_leg_w = 0.7;
bbtn_leg_drop = 0.3;        // how far the feet sit below the body's base
sw = [8.6, 3.6, 3.6];       // slide switch: length (slide direction), height (knob side), width
sw_knob = [2.0, 1.5, 1.5];
sw_travel = 2.0;

// ================================================================ body
W = 128;                    // the M6's width to height (138 x 79) at this camera's height
H = 58;
R = 4;
wall = 2.4;
clr = 0.3;
t_back = 2.0;
t_front = 2.4;
bump = 1.2;                 // the front rim stands this far proud of the front plate (the covering's thickness)
lip = 3.0;                  // the rim round the front covering: as wide as the edges are round
tp_h = 10.2;
port_t = 1.2;               // the wall left in front of a USB socket (thinned from inside)
edge_r = 3.0;
function fillet_pts(r, n = 8) = [for (i = [0 : n]) let(a = 90 * i / n) [r - r * cos(a), r - r * sin(a)]];
function teardrop_pts(r, n = 4) = concat([for (i = [0 : n]) let(a = 45 * i / n) [r - r * cos(a), r - r * sin(a)]], [[2 * r * (1 - cos(45)), 0]]);
edge_back = teardrop_pts(edge_r);
edge_front = fillet_pts(edge_r);
square_edge = [[0, 0]];

// depth: back plate | screen | deck | (channels) | board | module | camera | front plate
z_bi = t_back;
scr_sink = 1.4;                         // the glass sits this deep in a pocket in the back plate (a 0.6 floor)
z_scr1 = z_bi - scr_sink + scr_t;       // back of the screen's PCB
z_deck0 = z_bi + scr_t - 1.2 + 0.3 + 1.0;   // 1.5 mm above the screen's back (26 Oct: 1 mm higher than the first
                                        // frame's bosses), clear of the parts on it; foam strips fill the gap
deck_t = 1.0;
z_deck1 = z_deck0 + deck_t;
deck_gap = 2.4;                         // under the board: wires in the channels, the microSD socket
z_b0 = z_deck1 + deck_gap;              // underside of the board
z_b1 = z_b0 + board_pcb;
z_cam0 = z_b1 + board_mod[2] + cam_tape;
z_lens = z_cam0 + cam_h;
z_bat0 = z_bi + 0.8;                    // on 1 mm foam tape (squeezed to 0.8)
z_cr0 = z_bat0 + bat[2] + 0.2;          // the power cradle on the battery's front
cr_t = 0.8;
z_chg0 = z_cr0 + cr_t;
lens_recess = 0.6;
z_fi = max(z_lens + lens_recess - t_front, z_lens - cam_barrel[1] + 0.3, z_chg0 + chg_t + 0.6);
cav = z_fi - z_bi;
D = z_fi + t_front;
z_mid = z_bi + cav / 2;
echo(str("V4 BODY ", W, " x ", H + tp_h, " x ", D + bump, " mm (plates ", D, "), cavity ", cav));

// ================================================================ layout, seen from the back
post_in = 5.8;
post_r = 3.2;
posts = [[post_in, post_in], [W - post_in, post_in], [W - post_in, H - post_in], [post_in, H - post_in]];
insert_d = 3.2;             // M2 heat-set insert, 3.5 mm OD
insert_len = 3.5;

bat_xy = [post_in + post_r + 0.4, wall + 0.1];
div_x = bat_xy[0] + bat[0] + 0.1;       // spring tabs push the battery against the divider
spring_preload = 0.4;                   // how far the spring tabs reach into the battery's space (0 for the fit check)
z_div1 = z_cr0;                         // the divider stops at the battery's front: wires pass over it
div_t = 1.6;                            // the divider's thickness (toward the board side)

// board: USB end against the right wall, centred in height (so the lens is too)
board_xy = [W - port_t - clr - usb_over - board[0], H / 2 - board[1] / 2];
x_b1 = board_xy[0] + board[0];
lens_c = [board_xy[0] + lens_from_end, board_xy[1] + board[1] / 2];
row_g = board_xy[1] + pad_edge;                 // TXD ... GND row (bottom)
row_v = board_xy[1] + board[1] - pad_edge;      // 3V3 ... 5V row (top)
function pad_x(k) = board_xy[0] + pad0 + (k - 1) * pitch;   // pad k = 1..20 from the module end
board_holes = [for (s = [0, 1]) [x_b1 - board_hole_at[0], s ? board_xy[1] + board[1] - board_hole_at[1] : board_xy[1] + board_hole_at[1]]];
usb_ttl_y = board_xy[1] + usb_ttl;
usb_otg_y = board_xy[1] + usb_otg;   // the board's second socket: an opening too, for power if the other fails
z_usb = z_b0 + usb_top - usb_c[2] / 2;

// screen: turned round, pins at the left (by the board's module end and its 3V3 pad), under the board
// set from the board: its pins 4 mm clear of the board's module end, so the wires soldered to them
// rise beside the ESP32 module's overhang (not under it); just above the deck's bottom bosses
scr_xy = [x_b1 - 71.9, post_in + 3.2 + 0.2];
x_s1 = scr_xy[0] + scr[0];
win_dx = -1.0;              // the picture as seen on the real screen: 1 mm toward its pins from the measured offset
win_xy = [scr_xy[0] + scr_act_from_pins + win_dx, scr_xy[1] + (scr[1] - scr_active[1]) / 2];
win_c = win_xy + scr_active / 2;
glass_xy = [scr_xy[0] + scr_glass_in, scr_xy[1] + (scr[1] - scr_glass[1]) / 2];
scr_holes = [for (i = [0, 1], j = [0, 1]) [i ? x_s1 - scr_hole_at[0] : scr_xy[0] + scr_hole_at[0],
                                           j ? scr_xy[1] + scr[1] - scr_hole_at[1] : scr_xy[1] + scr_hole_at[1]]];
scr_pads = [for (i = [0 : 7]) [scr_xy[0] + scr_pin_in, scr_xy[1] + scr[1] / 2 + (3.5 - i) * pitch]];   // BLK ... GND, top to bottom (turned round)

// back buttons, centred over the screen's picture
cap_ds = [5.5, 6.5, 5.5];
btn_y = scr_xy[1] + scr[1] + 0.2 + (cap_ds[1] + 2.4) / 2;   // the caps' flanges just clear the screen's top edge
btn_pitch = 14;             // 14 mm apart (it was 11): room for 26 AWG wire holes, well clear of the next switch's legs
btn_xs = [for (i = [-1 : 1]) win_c[0] - win_dx + btn_pitch * i];   // centred on the picture as printed (the window's shift doesn't move them)
sleeve = [3.0, 1.0];
flange = 1.0;
z_flange0 = z_bi + sleeve[0];
cap_top = -bump - 0.4;      // the caps stand 0.4 mm proud of the back covering, in its holes (the wells)
z_plunger = z_flange0 + flange + 0.1;
z_btn_base = z_plunger + btn_h;
carrier_t = 1.4;
carrier_wall = 3.0;
carrier_bosses = [[btn_xs[0] - 8, btn_y], [btn_xs[2] + 8, btn_y]];
carrier_xy = [carrier_bosses[0][0] - 3.2, btn_y - 4.6];
carrier_sz = [carrier_bosses[1][0] - carrier_bosses[0][0] + 6.4, 8.6];

// top, for a left-handed user: shutter on the left, power switch on the right (seen from the back,
// i.e. as you hold it)
shutter_x = 20;
shutter_d = 9.0;
sw_x = W - 20;
up_x = 20.5;                // where the power wires go up from the cradle (its groove), then along the top to the switch
knob_cap = [6.0, 3.0, 3.4];
tp_ceiling = 2.0;
tp_screws = [div_x + 7.0, W - 11.0];   // clear of the speed dial and of the knob
pass = [10.0, 6.0];         // passages in the frame's top wall: a switch fits through with its wires on

// bottom plate: silver, like the top; two countersunk screws from below into inserts in the bottom wall
bp_h = 5.0;
bp_r = 4.5;
bp_screws = [W - 36, W - 11];

// the silver cover: the top plate comes down the front and the two ends to cap_y0, over the frame
cap_y0 = 44;
t_sk = 1.2;                 // its thickness down the front and the ends (the front covering's)
strap_y = 48.2;             // the strap holes: two through each end, joined inside
strap_z = [5.0, 11.0];
bp_peg_x = 20;

// power cradle: the charge module against the left wall, its USB-C through it
chg_xy = [port_t + clr + chg_usb_over, 36.0 - chg[1] / 2];   // its USB-C below the silver cover's edge
chg_c = chg_xy + chg / 2;
z_chg_usb = z_chg0 + chg_usb_z;

// deck: the frame bosses its two bottom tabs screw to
deck_tabs = [[x_b1 - 51.9, post_in], [x_b1 - 15.9, post_in]];   // where the printed frame's bosses are
deck_box = [div_x + 1.6, scr_xy[1], W - wall - clr, scr_xy[1] + scr[1] - 0.2];   // x0 y0 x1 y1 (from the divider: the wire tray; up to the screen's top edge)

// ================================================================ helpers
module rrect(w, h, r) { offset(r) offset(-r) square([w, h]); }
// square corners: the sides run straight on into the top and bottom plates, which carry the round corners
module outline() { square([W, H]); }
module plate_outline() { offset(-lip - 0.2) outline(); }   // the front plate, inside the rim's rebate
module profiled(z0, z1, back = edge_back, front = edge_front) {
    hull() {
        for (p = back) translate([0, 0, z0 + p[1]]) linear_extrude(0.01) offset(-p[0]) children();
        for (p = front) translate([0, 0, z1 - p[1] - 0.01]) linear_extrude(0.01) offset(-p[0]) children();
    }
}
module body_shape(z0, z1, back, front) {   // profiled, top and bottom edges square
    intersection() {
        profiled(z0, z1, back, front) translate([0, -10]) square([W, H + 20]);
        translate([-1, 0, z0 - 1]) cube([W + 2, H, z1 - z0 + 2]);
    }
}
module stadium(sz) { hull() for (s = [-1, 1]) translate([s * (sz[0] - sz[1]) / 2, 0]) circle(d = sz[1]); }
module box(p, s) { translate(p) cube(s); }
module zbox(x, y, w, h, z0, z1) { box([x, y, z0], [w, h, z1 - z0]); }
module zcyl(c, d, z0, z1) { translate([c[0], c[1], z0]) cylinder(d = d, h = z1 - z0); }
module real() { translate([W, 0, 0]) mirror([1, 0, 0]) children(); }
// M2 countersunk (flat head, 90 deg) through a plate whose outer face is at z0 (facing -z if up = false)
module csk(c, z0, up, len) {
    translate([c[0], c[1], 0]) {
        translate([0, 0, up ? z0 - len : z0 - 0.01]) cylinder(d = 2.4, h = len + 0.02);
        if (up) translate([0, 0, z0 - 1.0]) cylinder(d1 = 2.2, d2 = 4.2, h = 1.01);
        else translate([0, 0, z0 - 0.01]) cylinder(d1 = 4.2, d2 = 2.2, h = 1.01);
    }
}

// ================================================================ frame (printed standing on its back edge)
module frame() {
    difference() {
        union() {
            rim();
            // the corner posts, filled out to the corner so each is joined to both walls
            for (p = posts) hull() { zcyl(p, 2 * post_r, z_bi, z_fi); zbox(p[0] < W / 2 ? wall - 0.5 : p[0], p[1] < H / 2 ? wall - 0.5 : p[1], p[0] < W / 2 ? p[0] - wall + 0.5 : W - wall + 0.5 - p[0], p[1] < H / 2 ? p[1] - wall + 0.5 : H - wall + 0.5 - p[1], z_bi, z_fi); }
            // battery bay: divider (only as high as the battery), a stop above it with a gap for the leads, fingers
            // (1.6 thick, with a foot and three gussets on its board side: a thin free wall, it lifted
            // and wobbled in wood PLA)
            zbox(div_x, wall - 0.5, div_t, bat_xy[1] + bat[1] - wall + 0.5, z_bi, z_div1);
            zbox(div_x, wall - 0.5, div_t + 2.0, bat_xy[1] + bat[1] - wall + 0.5, z_bi, z_bi + 0.6);
            for (y = [12, 27, 42]) hull() {
                zbox(div_x + div_t - 0.01, y, 0.01, 1.2, z_bi, z_bi + 4.0);
                zbox(div_x + div_t + 2.5, y, 0.01, 1.2, z_bi, z_bi + 0.6);
            }
            battery_springs();
            for (s = [-1, 1]) strap_boss(s);
            // deck: two bottom bosses, and two under the board's holes (the board's screws go through the deck into them)
            for (t = deck_tabs) zbox(t[0] - 3.5, wall - 0.5, 7, t[1] + 3.2 - wall + 0.5, z_bi, z_deck0);
            for (h = board_holes) hull() { zcyl(h, 6.0, z_bi, z_deck0); zbox(W - wall - 0.5, h[1] - 3, 0.5, 6, z_bi, z_deck0); }
            // top-plate screw bosses under the top wall, and the bottom plate's above the bottom wall
            for (x = tp_screws) zbox(x - 3, H - wall - 4.5, 6, 4.6, z_bi, z_fi);
            for (x = bp_screws) hull() {   // 45 deg underneath: it prints without support
                zbox(x - 3, wall - 0.5, 6, 7.4 - wall + 0.5, z_mid - 2.85, z_mid + 3);
                zbox(x - 3, wall - 0.5, 6, 0.01, z_mid - 2.85 - (7.4 - wall), z_mid + 3);
            }
        }
        // plate screws: inserts from both faces
        for (p = posts) {
            zcyl(p, insert_d, z_bi - 1, z_bi + insert_len);
            zcyl(p, insert_d, z_fi - insert_len, z_fi + 1);
            zcyl(p, 1.8, 0, D);
        }
        for (t = deck_tabs) { zcyl(t, insert_d, z_deck0 - insert_len, z_deck0 + 1); zcyl(t, 1.8, z_bi - 1, z_deck0); }
        for (h = board_holes) { zcyl(h, insert_d, z_deck0 - insert_len, z_deck0 + 1); zcyl(h, 1.8, z_bi - 1, z_deck0); }
        for (x = tp_screws) {
            translate([x, H + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = insert_d, h = insert_len + 1);
            translate([x, H + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = 1.8, h = wall + 5);
        }
        // USB-C: the board's TTL socket through the right wall, the charge module's through the left
        for (y = [usb_ttl_y, usb_otg_y]) usb_port([W, y, z_usb], 1, [board_xy[1] - 0.5, board_xy[1] + board[1] + 0.5], [z_b0 - 0.4, z_b0 + usb_top + 0.5]);
        usb_port([0, chg_c[1], z_chg_usb], -1, [chg_xy[1] - 1.0, chg_xy[1] + chg[1] + 1.0], [z_chg0 - 0.4, z_chg0 + chg_t + 0.4]);
        // passages up into the top plate: the switch and the shutter go through, wires and all
        for (x = [sw_x, shutter_x]) zbox(x - pass[0] / 2, H - wall - 1, pass[0], wall + 2, z_mid - pass[1] / 2, z_mid + pass[1] / 2);
        for (x = bp_screws) {
            translate([x, -1, z_mid]) rotate([-90, 0, 0]) cylinder(d = insert_d, h = insert_len + 1);
            translate([x, -1, z_mid]) rotate([-90, 0, 0]) cylinder(d = 1.8, h = 7.4);
        }
        translate([bp_peg_x, -1, z_mid]) rotate([-90, 0, 0]) cylinder(d = 2.6, h = 2.6);   // the bottom plate's locating peg
        for (s = [-1, 1]) strap_tunnel(s);
        cap_cut();
    }
    for (s = [-1, 1]) end_leather(s);
}
// where the silver cover wraps the body: the frame and back plate are cut back by its thickness
module cap_cut() {
    difference() {
        translate([-1, cap_y0, -1]) cube([W + 2, H - cap_y0 + 1, D + bump + 2]);
        translate([t_sk + 0.1, cap_y0 - 1, -2]) cube([W - 2 * t_sk - 0.2, H - cap_y0 + 3, D + 2]);
    }
}
// battery: it rests on the bottom wall and against the divider; spring tabs (thin cantilevers with
// a round nub) push it there from the left and from above, about 2 N each. It can't rattle, a
// slightly bigger cell still fits, and nothing presses hard on the pouch. A gap above the right
// half of its top lets the leads out.
leaf_t = 1.3;               // three lines of a 0.4 nozzle (0.9 was too thin to print cleanly in wood PLA)
module spring_x(y0) {   // pushes +x, from the left wall
    x1 = bat_xy[0] - 0.8;
    zbox(wall - 0.5, y0, x1 - wall + 0.5, 3, z_bi, z_bi + 6.6);                    // anchor
    zbox(x1 - leaf_t, y0 + 2.99, leaf_t, 10.5, z_bi, z_bi + 6.6);                   // the leaf
    hull() { zbox(x1 - 0.01, y0 + 10.6, 0.01, 2.8, z_bi, z_bi + 6.6); zcyl([bat_xy[0] + spring_preload - 0.8, y0 + 12.0], 1.6, z_bi, z_bi + 6.6); }
}
module spring_y(x0) {   // pushes -y, from the top wall
    y1 = bat_xy[1] + bat[1] + 0.6;
    zbox(x0, y1, 3, H - wall - y1 + 0.5, z_bi, z_bi + 6.0);
    zbox(x0 + 2.99, y1, 10.5, leaf_t, z_bi, z_bi + 6.0);
    hull() { zbox(x0 + 10.6, y1, 2.8, 0.01, z_bi, z_bi + 6.0); zcyl([x0 + 12.0, bat_xy[1] + bat[1] - spring_preload + 0.8], 1.6, z_bi, z_bi + 6.0); }
}
module battery_springs() {
    for (y = [bat_xy[1] + 9, bat_xy[1] + 27]) spring_x(y);
    spring_y(bat_xy[0] + 3);
}
// strap holes: two holes through each end, joined by a U inside a boss, for a wrist strap's cord
module strap_boss(s) {
    x0 = s < 0 ? wall - 0.5 : W - 8.8;
    zbox(x0, strap_y - 1.8, 8.8 - wall + 0.5, 3.6, z_bi, z_bi + 11.0);
}
module strap_tunnel(s) {
    zc = (strap_z[0] + strap_z[1]) / 2;
    r = (strap_z[1] - strap_z[0]) / 2;
    multmatrix(s < 0 ? [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0]] : [[-1, 0, 0, W], [0, 1, 0, 0], [0, 0, 1, 0]]) {
        for (z = strap_z) translate([-1, strap_y, z]) rotate([0, 90, 0]) cylinder(d = 2.2, h = 4.0 + 1, $fn = 24);
        translate([4.0, strap_y, zc]) rotate([90, 0, 0]) rotate_extrude(angle = 180, $fn = 32) translate([r, 0]) circle(d = 2.2, $fn = 16);
    }
}
// leather grain on the body's two ends, as the M6's covering runs round them. Smooth round the
// USB openings and the strap lugs; it stops short of the front fillet and the top and bottom plates.
end_t = 0.35;                       // the grain's height on the end faces
module end_leather_2d(side) {       // in (z, y) on the end face
    difference() {
        translate([z_bi + 0.8, 1.0]) square([D + bump - edge_r - 0.6 - z_bi - 0.8, cap_y0 - 2.0]);   // up to the silver cover
        if (side > 0) for (y = [usb_ttl_y, usb_otg_y]) translate([z_usb, y]) rotate(90) stadium([9.6 + 3.2, 3.9 + 3.2]);
        else translate([z_chg_usb, chg_c[1]]) rotate(90) stadium([9.6 + 3.2, 3.9 + 3.2]);
    }
}
end_grain = true;                   // false: plain panels (the guide's light meshes)
module end_leather(side) {
    multmatrix(side < 0 ? [[0, 0, -1, 0], [0, 1, 0, 0], [1, 0, 0, 0]] : [[0, 0, 1, W], [0, 1, 0, 0], [1, 0, 0, 0]])
        if (!end_grain) linear_extrude(end_t) end_leather_2d(side);
        else intersection() {
            translate([0, 0, -0.3]) linear_extrude(0.3 + end_t) end_leather_2d(side);
            translate([0, 0, -0.3]) scale([tex_px, tex_px, (0.3 + end_t) / 100]) surface(file = "art/leather.png");
        }
}
// a slab of the body's outside between two depths, with the edge profiles
module body_slab(z0, z1) intersection() { body_shape(0, D + bump, edge_back, edge_front); translate([-1, -1, z0]) cube([W + 2, H + 2, z1 - z0]); }
// the rim: the front edge profile all round, proud of the front plate, square top edge
module rim() {
    difference() {
        body_slab(z_bi, D + bump);
        translate([0, 0, z_bi - 0.01]) linear_extrude(cav + 0.02) offset(-wall) outline();
        translate([0, 0, z_fi]) linear_extrude(t_front + bump + 1) offset(-lip) outline();
    }
}
// a USB-C opening: the wall thinned from inside to port_t over the socket's end, a rounded slot,
// and a chamfer outside so any cable's moulding fits. side +1 = right wall
module usb_port(c, side, ys, zs) {
    x_in = side > 0 ? W - wall - 0.01 : port_t;
    translate([x_in, ys[0], zs[0]]) cube([wall - port_t + 0.01, ys[1] - ys[0], zs[1] - zs[0]]);
    translate([c[0], c[1], c[2]]) rotate([0, 90, 0]) translate([0, 0, -wall - 1]) linear_extrude(2 * wall + 2) rotate(90) stadium([9.6, 3.9]);
    translate([c[0], c[1], c[2]]) rotate([0, side > 0 ? -90 : 90, 0]) translate([0, 0, -0.6]) rotate(90)
        hull() { linear_extrude(0.01) offset(0.8) stadium([9.6, 3.9]); translate([0, 0, 0.6]) linear_extrude(0.01) stadium([9.6, 3.9]); }
}
bottom_line = "digicam  ·  ryan lim";
text_font = "Futura:style=Medium";

// ================================================================ wiring deck (printed base down)
// Sits on the screen's back (0.5 mm foam pad between), on two frame bosses at its bottom tabs and
// two under the board's holes. The board rests on its two ribs, between the pad rows, so nothing
// is under a pad. Along each row a lane, open at the side: under the board's edge strip (3.3 mm
// wide, 2.4 deep) and on beside it on the deck (as tall as you like), about 9 mm wide along the
// bottom row and 6 mm along the top, so a row's 26 AWG wires run side by side and each comes up
// through its pad from underneath. The screen's eight wires rise through the notch at its pin end,
// just past the board's module end; the notch is open at the deck's bottom edge, so the soldered
// bundle slides in from the side. Wires that change rows cross at the board's USB end, past the ribs.
rib_in = 4.5;               // the ribs' outer faces, in from the board's long edges
ch_x1 = pad_x(n_pads) + 1.6;   // the ribs stop here: wires change rows beyond
notch = [scr_xy[0] - 2.0, scr_xy[0] + scr_pin_in + 2.2, scr_pads[0][1] + 1.6];   // x0, x1, y1 (open to the left and bottom edges)
module deck_2d() {
    difference() {
        union() {
            translate([deck_box[0], deck_box[1]]) square([deck_box[2] - deck_box[0], deck_box[3] - deck_box[1]]);
            for (t = deck_tabs) translate([t[0] - 3.5, t[1] - 3.2]) square([7, deck_box[1] - t[1] + 3.2 + 0.01]);
        }
        translate([notch[0], deck_box[1] - 1]) square([notch[1] - notch[0], notch[2] - deck_box[1] + 1]);
        // clear of the screen's back: its flex and small parts by the pins, and the middle (between the
        // ribs, from just past the pins to under the middle of the board)
        translate([scr_xy[0] + scr_pin_in + 3.2, board_xy[1] + rib_in + 0.5]) rrect(board_xy[0] + 44 - scr_xy[0] - scr_pin_in - 3.2, board[1] - 2 * rib_in - 1.0, 2);
    }
}
module deck() {
    difference() {
        union() {
            translate([0, 0, z_deck0]) linear_extrude(deck_t) deck_2d();
            // the two ribs the board rests on
            for (s = [0, 1]) let(y = s ? board_xy[1] + board[1] - rib_in : board_xy[1] + rib_in - 1.2)
                zbox(board_xy[0] + 0.5, y, ch_x1 - board_xy[0] - 0.5, 1.2, z_deck1 - 0.01, z_b0);
            // the wire tray beside the screen's pins, toward the battery: room for the screen's wires
            // to bend from the pins (they rise clear of the ESP32 module's overhang) and for the power
            // wires from the cradle. A low wall on its far side keeps them off the divider.
            zbox(deck_box[0], deck_box[1], 1.2, deck_box[3] - deck_box[1], z_deck1 - 0.01, z_b0 - 0.4);
            // bosses under the board's holes
            for (h = board_holes) intersection() {
                zcyl(h, 5.0, z_deck1 - 0.01, z_b0);
                translate([0, 0, z_deck0]) linear_extrude(z_b0) deck_2d();
            }
        }
        // the board's two screws: slots open to the deck's end (the holes would leave a 0.2 mm wall
        // at the edge, too thin to print; the screw still clamps the deck)
        for (h = board_holes) hull() { zcyl(h, 2.4, z_deck0 - 1, z_b0 + 1); zcyl([h[0] + 5, h[1]], 2.4, z_deck0 - 1, z_b0 + 1); }
        for (t = deck_tabs) translate([t[0], t[1], 0]) csk_hole_up(z_deck1);
        // let the channels' walls pass the board-hole bosses' screw heads
    }
}
module csk_hole_up(z_top) {   // a plain hole for an M2 x 4 button head (the deck is too thin to countersink)
    translate([0, 0, z_deck0 - 1]) cylinder(d = 2.4, h = deck_t + 2);
}

// ================================================================ power cradle (printed base down)
// A block that fills the space between the battery's front and the front plate, on the battery
// and the divider's top. It wraps snugly round the bottom corner post beside the battery and sits
// against the walls, so it can only sit one way, and the charge module's USB-C lines up with its
// opening. Its top edge stops short of the top corner: the battery's leads come out of the
// battery's top edge there, by the module, and rise into the open lane along the top. The module sits
// in a pocket (0.15 mm clearance, an end stop at its pads); the wires lie in grooves cut into the
// block, so nothing loops over the module:
//   - a porch at the module's pad end (B+ B- and the 5V + -), with room for the two resistors of
//     the battery-level divider (B+ - 100k - GPIO 1 - 100k - GND);
//   - a groove up from the porch to the open lane along the top, for the battery's leads (they come
//     out of the battery's top edge into that lane) and the 5V out (+) to the power switch;
//   - a groove down and along the bottom to the divider, for the - out (GND) and the GPIO 1 wire,
//     which then run on along the deck beside the board.
// The front plate presses on the block round the module, so it holds the module and the battery.
cr_h = chg_t + 0.2;         // the block's top: just past the module's front
cr_top = z_chg0 + cr_h;
cr_lane_y = H - wall - 6.5; // the block stops here: above it, an open lane along the top
cr_floor = z_chg0 + 1.0;    // the porch's floor: level with the module's board, so wires leave its pads flat
cr_groove = cr_top - 2.8;   // the grooves' floor
res_box = [chg_xy[0] + chg[0] + 2.0, chg_c[1] - 3.5, 9.0, 7.0];   // x, y, w, h: the two resistors, in the porch
cr_porch = [chg_xy[0] + chg[0] + 0.15, chg_xy[1] - 0.15, 30.5, chg_xy[1] + chg[1] + 0.15];   // x0 y0 x1 y1
cr_up = [18.0, 23.0];       // the groove up to the top lane (x range)
cr_down = [26.5, 30.5];     // the groove down (x range), then along the bottom (y 4.5 to 8.5) to the divider
module cradle_2d() {
    difference() {
        translate([wall + 0.2, wall + 0.2]) square([div_x + 1.2 - wall - 0.2, cr_lane_y - wall - 0.2]);
        // the corner posts: notches that fit round them (0.15 clearance); the bottom one locates the block
        for (p = posts) if (p[0] < W / 2) offset(0.15) hull() {
            translate(p) circle(r = post_r);
            translate([0, p[1] < H / 2 ? 0 : p[1]]) square([p[0], p[1] < H / 2 ? p[1] : H - p[1]]);
        }
    }
}
module cradle() {
    difference() {
        translate([0, 0, z_cr0]) linear_extrude(cr_top - z_cr0) cradle_2d();
        // the module's pocket (its USB-C end overhangs the block toward the wall)
        zbox(chg_xy[0] - 1, chg_xy[1] - 0.15, chg[0] + 1.15, chg[1] + 0.3, z_chg0, cr_top + 1);
        // the porch at its pads, with the resistors
        zbox(cr_porch[0] - 0.01, cr_porch[1], cr_porch[2] - cr_porch[0], cr_porch[3] - cr_porch[1], cr_floor, cr_top + 1);
        // up to the top lane, and down and along the bottom to the divider
        zbox(cr_up[0], cr_porch[3] - 0.01, cr_up[1] - cr_up[0], cr_lane_y - cr_porch[3] + 1, cr_groove, cr_top + 1);
        zbox(cr_down[0], 4.5, cr_down[1] - cr_down[0], cr_porch[1] - 4.5 + 0.01, cr_groove, cr_top + 1);
        zbox(cr_down[0], 4.5, div_x + 2 - cr_down[0], 4.0, cr_groove, cr_top + 1);
    }
}

// ================================================================ back plate (printed outer face down)
module back_plate() {
    difference() {
        union() {
            body_slab(0, t_back);
            // guide sleeves for the button caps, and the posts the carrier screws to
            for (i = [0 : 2]) zcyl([btn_xs[i], btn_y], cap_ds[i] + 0.4 + 2 * sleeve[1], t_back - 0.01, z_flange0);
            for (b = carrier_bosses) zcyl(b, 6.0, t_back - 0.01, z_btn_base);
            // four pins through the screen's corner holes locate it exactly over the window
            // (a short base only: the screen rests on its glass, in the pocket, not on these)
            for (h = scr_holes) { zcyl(h, scr_hole_d - 0.35, t_back - 0.01, z_scr1 - 0.1); zcyl(h, scr_hole_d + 1.2, t_back - 0.01, t_back + 0.4); }
        }
        // countersunk screws into the frame's posts; the left two hide under the covering
        for (p = posts) csk(p, 0, false, t_back + 1);
        // the glass's pocket, and the window: a gentle bevel out from the picture's edge to the outer face
        // as long as the pins allow and the screen's full width, so any glass or panel drops in
        zbox(scr_xy[0] + scr_hole_at[0] + 2.3, scr_xy[1] - 0.1, scr[0] - 2 * (scr_hole_at[0] + 2.3), scr[1] + 0.2, t_back - scr_sink, t_back + 1);
        hull() {
            translate([0, 0, t_back - scr_sink - 0.01]) linear_extrude(t_back) win_rect(0, 0);
            translate([0, 0, -0.01]) linear_extrude(0.01) win_rect(bev[0], bev[1]);
        }
        for (i = [0 : 2]) {
            c = [btn_xs[i], btn_y];
            translate([c[0], c[1], -1]) cylinder(d = cap_ds[i] + 0.4, h = z_flange0 + 2);
            if (i != 1) zbox(c[0] - 0.6, c[1] + cap_ds[i] / 2 - 0.5, 1.2, 1.4, t_back, z_flange0 + 1);   // key slot
        }
        for (b = carrier_bosses) zcyl(b, 1.7, t_back + 1.0, z_btn_base + 1);
        cap_cut();
    }
}

// ================================================================ button carrier (printed floor down)
// The three switches snap into its pockets, plungers toward the caps; it screws to the back
// plate's two posts (M2 x 6, self-tapping).
// Pockets for the 6 x 6 four-leg switches, after Allen's v3 carrier (PR #2): the body in a 6.2 pocket,
// snap fingers on the two walls without legs, each leg out through a notch in the side wall (room to
// solder), its foot sunk into the floor so the body sits flat, and a wire hole just past each foot's tip.
pk = 0.2;                   // clearance round the switch body
pi_ = bbtn_w / 2 + pk;      // pocket half-width
po_ = pi_ + 1.2;            // outer half-width
snap_reach = pk + 0.35;     // how far each finger's catch reaches in from the pocket wall (0.35 mm over the switch)
snap_w = 3.0;
snap_t = 0.9;
z_snap = z_btn_base - bbtn_body - 0.05;   // the catch face, just past the switch's top
leg_y0 = 1.5;               // the legs' notch: wider than a leg (1.9-2.6) so either reading of the drawing fits
wire_x0 = bbtn_feet / 2 + 0.2;            // the wire holes start just past the foot tips
wire_w = 1.8;               // and are 1.8 x 2.25 mm: a 26 AWG wire (1.6 mm over its insulation) goes through
wire_y = [1.15, 3.4];       // their extent across, from the switch's centre line (round each leg's centre, 2.25)
module carrier() {
    difference() {
        union() {
            zbox(carrier_xy[0], carrier_xy[1], carrier_sz[0], carrier_sz[1], z_btn_base, z_btn_base + carrier_t);
            for (x = btn_xs) zbox(x - po_, btn_y - po_, 2 * po_, 2 * po_, z_btn_base - carrier_wall, z_btn_base + 0.01);
            // snap fingers on the two walls without legs: run on past the switch's top, a catch with a lead-in
            for (x = btn_xs, s = [-1, 1]) let(yi = btn_y + s * pi_) {
                zbox(x - snap_w / 2, s < 0 ? yi - snap_t : yi, snap_w, snap_t, z_snap - 0.7, z_btn_base - carrier_wall + 0.01);
                hull() {
                    zbox(x - snap_w / 2, s < 0 ? yi - 0.01 : yi - snap_reach, snap_w, snap_reach + 0.01, z_snap - 0.01, z_snap);
                    zbox(x - snap_w / 2, yi - 0.01, snap_w, 0.02, z_snap - 0.7, z_snap - 0.69);
                }
            }
        }
        // slits either side of each finger, down to the floor, so it can flex
        for (x = btn_xs, s = [-1, 1], dx = [-1, 1]) let(yi = btn_y + s * pi_)
            zbox(x + dx * (snap_w / 2 + 0.25) - 0.25, s < 0 ? yi - 1.3 : yi - 0.1, 0.5, 1.4, z_snap - 1, z_btn_base + 0.01);
        // the finger is thinner than the wall
        for (x = btn_xs, s = [-1, 1]) let(yi = btn_y + s * pi_)
            zbox(x - snap_w / 2, s < 0 ? yi - 1.3 : yi + snap_t, snap_w, 1.3 - snap_t, z_snap - 1, z_btn_base + 0.01);
        for (x = btn_xs) {
            // the switch body, stopping at the catches
            zbox(x - pi_, btn_y - pi_, 2 * pi_, 2 * pi_, z_snap, z_btn_base + 0.01);
            for (sx = [-1, 1], sy = [-1, 1]) {
                // each leg leaves through a notch in the side wall, over its full height, so there is room to solder...
                zbox(sx < 0 ? x - po_ - 0.01 : x + pi_ - 0.01, sy < 0 ? btn_y - pi_ : btn_y + leg_y0, po_ - pi_ + 0.02, pi_ - leg_y0,
                     z_btn_base - carrier_wall - 1, z_btn_base + 0.01);
                // ...its foot sinks into the floor, so the body's base sits flat on it...
                zbox(sx < 0 ? x - bbtn_feet / 2 - 0.35 : x + bbtn_w / 2 - 0.05, sy < 0 ? btn_y - pi_ : btn_y + leg_y0,
                     bbtn_feet / 2 + 0.35 - bbtn_w / 2 + 0.05, pi_ - leg_y0, z_btn_base - 0.01, z_btn_base + bbtn_leg_drop + 0.15);
                // ...and the wire comes through a hole just past its tip, to fold back onto the foot
                zbox(sx < 0 ? x - wire_x0 - wire_w : x + wire_x0, sy < 0 ? btn_y - wire_y[1] : btn_y + wire_y[0], wire_w, wire_y[1] - wire_y[0],
                     z_btn_base - 1, z_btn_base + carrier_t + 1);
            }
        }
        for (b = carrier_bosses) zcyl(b, 2.4, z_btn_base - 1, z_btn_base + carrier_t + 1);
    }
}

// ================================================================ front plate (printed outer face down)
barrel_d = 44;
barrel_screw_r = 11.2;
module front_plate() {   // in its own frame: inner face at z = 0, outer at t_front (placed at z_fi)
    difference() {
        union() {
            linear_extrude(t_front) plate_outline();
            // camera collar: centres the lens holder and keeps it on the module
            translate([0, 0, -2.0]) linear_extrude(2.01) difference() {
                translate(lens_c) square(cam_holder + 2 * clr + 2.4, center = true);
                translate(lens_c) square(cam_holder + 2 * clr, center = true);
            }
            // presses on the charge module and the cradle's walls, so the cradle and battery can't move
            translate([0, 0, -(z_fi - z_chg0 - cr_h)]) linear_extrude(z_fi - z_chg0 - cr_h + 0.01) difference() {
                translate([wall + clr, chg_xy[1] - clr - 1.0]) square([chg_xy[0] + chg[0] + clr - wall - clr, chg[1] + 2 * clr + 2 * 1.0]);
                translate([chg_xy[0] + 1.2, chg_xy[1] + 1.2]) square([chg[0] - 2.4, chg[1] - 2.4]);
            }
        }
        // countersunk from the front: the heads sit flush, under the leather
        for (p = posts) translate([p[0], p[1], 0]) {
            translate([0, 0, -1]) cylinder(d = 2.4, h = t_front + 2);
            translate([0, 0, t_front - 1.0]) cylinder(d1 = 2.2, d2 = 4.2, h = 1.01);
        }
        translate([lens_c[0], lens_c[1], -3]) cylinder(d = cam_barrel[0] + 0.6, h = t_front + 4);
        for (a = [90, 210, 330]) translate([lens_c[0] + barrel_screw_r * cos(a), lens_c[1] + barrel_screw_r * sin(a), -1]) cylinder(d = 2.4, h = t_front + 2);
        // charge LED peep hole
        translate([chg_xy[0] + chg_led[0], chg_c[1] + chg_led[1], -3]) cylinder(d = 2.0, h = t_front + 4);
    }
}

// ================================================================ caps and small parts
module button_cap(i) {   // standing on its top face (printing orientation)
    d = cap_ds[i];
    len = z_flange0 - cap_top;
    difference() {
        union() {
            // a softly domed top
            intersection() { cylinder(d = d, h = len); translate([0, 0, d * 1.6]) sphere(d = d * 3.4, $fn = 64); }
            translate([0, 0, len - 0.01]) cylinder(d = d + 2.4, h = flange);
            if (i != 1) translate([-0.5, d / 2 - 0.6, z_bi + 0.2 - cap_top]) cube([1.0, 1.2, len - (z_bi + 0.2 - cap_top) + 0.01]);
        }
        if (i != 1) translate([0, 0, -0.01]) linear_extrude(0.6) rotate(i == 0 ? 180 : 0) polygon([[1.6, 0], [-1.0, 1.6], [-1.0, -1.6]]);
        else translate([0, 0, -0.01]) cylinder(d = 2.2, h = 0.6);
    }
}
sh_proud = 3.4;                                    // the shutter's top above the top plate (through the lever's hub)
function shutter_shaft() = sh_proud + tp_ceiling;   // its flange sits right under the ceiling
// The button: a domed top with a fine ring, tapering (45 deg, so it prints flange down) to a 5 mm
// stem through the ceiling, and a 6 mm stop flange under it. It goes in from inside, up through the
// cradle's pocket, before the switch; the switch's plunger then holds it up against the ceiling.
sh_stem_d = 5.0;
sh_flange_d = 6.0;
module shutter_cap() {   // its top at z = 0, shaft toward +z
    shaft = shutter_shaft();
    zc = sh_proud - 0.4;                      // the taper ends 0.4 above the top plate: room to press
    difference() {
        union() {
            scale([1, 1, 0.4]) difference() { sphere(d = shutter_d); translate([0, 0, 5]) cube(10, center = true); }
            translate([0, 0, zc - (shutter_d - sh_stem_d) / 2]) cylinder(d1 = shutter_d, d2 = sh_stem_d, h = (shutter_d - sh_stem_d) / 2);
            cylinder(d = shutter_d, h = zc - (shutter_d - sh_stem_d) / 2 + 0.01);
            cylinder(d = sh_stem_d, h = shaft);
        }
        translate([0, 0, -2.2]) difference() { cylinder(d = 5.4, h = 1.0); translate([0, 0, -1]) cylinder(d = 4.6, h = 3); }   // the fine ring, in the dome
    }
    translate([0, 0, shaft - 0.01]) cylinder(d = sh_flange_d, h = flange);
}
// a round knob like the M6's rewind knob, over the slot (it slides with the switch); the stem
// below it fits the switch's knob as before
knob_d = 11;
knob_top = 4.0;                                  // above the top plate
knob_stem_end = knob_top + tp_ceiling - 0.1;
module knob_cap_part() {   // standing on its top face
    difference() {
        union() {
            knurl(knob_d, knob_top - 0.4, 36);
            translate([-knob_cap[0] / 2, -knob_cap[2] / 2, 0]) cube([knob_cap[0], knob_cap[2], knob_stem_end]);
        }
        translate([-sw_knob[0] / 2 - 0.1, -sw_knob[2] / 2 - 0.1, knob_stem_end - 1.4]) cube([sw_knob[0] + 0.2, sw_knob[2] + 0.2, 2]);
        // the folded rewind crank, engraved in its top
        translate([0, 0, -0.01]) linear_extrude(0.4) { translate([-0.8, -3.6]) square([1.6, 6.0]); translate([0, 2.6]) circle(d = 2.6); }
    }
}

// lens barrel: stands on its back face; three M2 inserts from the back, screws through the front
// plate. Its base flange is the mount ring, with two lobes carrying the lens release button and
// the frame selector lever (on the right of the lens seen from the front, as on the M6). A front
// ring carries its lettering, as on a real lens (paint-fill it white).
lens_words = ["digicam", "ryan lim"];   // round the front ring: one over the top, one along the bottom
barrel_h = 10;
flange_d = 48;
rel_l = [-22.0, -13.5];     // lens release and frame selector, in the barrel's own coords (mirrored onto the camera):
sel_l = [-25.0, 7.0];       // left of the lens seen from the front, the M6 mirrored
module flange_2d() {
    circle(d = flange_d);
    for (p = [rel_l, sel_l]) hull() { translate(p * 0.8) circle(d = 6.4); translate(p * 1.08) circle(d = 6.4); }
}
module flange_model_2d() translate(lens_c) mirror([1, 0]) flange_2d();   // where it sits on the camera
module lens_barrel() {
    cone_r = 4.6;
    difference() {
        union() {
            linear_extrude(1.2) flange_2d();
            cylinder(d = barrel_d, h = barrel_h - 0.8);
            translate([0, 0, barrel_h - 0.81]) cylinder(d1 = barrel_d, d2 = barrel_d - 1.6, h = 0.8);
            translate([0, 0, 2.4]) knurl(barrel_d + 0.8, 3.2, 90);      // focus ring
            translate([rel_l[0], rel_l[1], 1.19]) cylinder(d1 = 5.2, d2 = 4.4, h = 1.6);   // lens release
            let(u = sel_l / norm(sel_l)) hull() {                                         // frame selector
                translate([sel_l[0], sel_l[1], 1.19]) cylinder(d = 4.4, h = 1.4);
                translate([sel_l[0] + 4.6 * u[0], sel_l[1] + 4.6 * u[1], 1.19]) cylinder(d = 2.4, h = 1.4);
            }
        }
        translate([0, 0, -0.01]) cylinder(r1 = cone_r, r2 = cone_r + barrel_h * 1.109, h = barrel_h + 0.02);
        for (a = [90, 210, 330]) translate([barrel_screw_r * cos(a), barrel_screw_r * sin(a), -1]) cylinder(d = insert_d, h = insert_len + 1);
        for (a = [45 : 90 : 315]) translate([23 * cos(a), 23 * sin(a), 0.8]) cylinder(d = 1.0, h = 1, $fn = 12);   // the mount's screws
        translate([-0.4, barrel_d / 2 - 2.6, barrel_h - 0.4]) cube([0.8, 1.4, 1]);     // index mark
        ring_arc(lens_words[0], 18.4, 2.2, barrel_h - 0.4, 90);
        ring_arc(lens_words[1], 18.4, 2.2, barrel_h - 0.4, 270);
    }
}
// a word along an arc of radius r, centred at angle a, upright from +z (at the bottom it reads
// left to right too, as on a lens's front ring)
module ring_arc(t, r, size, z, a, pitch = 1.9) {
    n = len(t);
    step = pitch / r * 180 / PI;
    top = sin(a) > 0;
    for (i = [0 : n - 1]) let(ai = top ? a + ((n - 1) / 2 - i) * step : a + (i - (n - 1) / 2) * step)
        rotate(ai) translate([r, 0, z]) rotate(top ? -90 : 90)
            linear_extrude(1) text(t[i], size = size, font = text_font, halign = "center", valign = "center");
}
module ring_text(t, r, size, z) {   // letters round a circle, reading clockwise from the top, seen from +z
    n = len(t);
    for (i = [0 : n - 1]) rotate(90 - i * 360 / n) translate([r, 0, z]) rotate(-90)
        linear_extrude(1) text(t[i], size = size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
}
module knurl(d, h, n) {
    linear_extrude(h) for (i = [0 : n - 1]) rotate(i * 360 / n) translate([d / 2 - 1.0, -0.45]) square([1.0, 0.9]);
    cylinder(d = d - 1.6, h = h);
}

// ================================================================ coverings
cover_t = 0.8;
grain_t = bump - cover_t;
tex_px = 0.2;
cover_x1 = win_xy[0] - 4.2;
module leatherette_2d() {   // the whole front, inside the rim: the screws are under it
    difference() {
        intersection() { offset(-lip - 0.4) outline(); square([W, cap_y0 - 0.2]); }   // up to the silver cover
        offset(0.3) flange_model_2d();
        translate([chg_xy[0] + chg_led[0], chg_c[1] + chg_led[1]]) circle(d = 2.6);
    }
}
module leatherette() { grain() leatherette_2d(); }
module back_leatherette_2d() {   // the whole back: it hides all four screws
    difference() {
        offset(-2.0) outline();
        bezel_in_2d();
        for (i = [0 : 2]) translate([btn_xs[i], btn_y]) circle(d = cap_ds[i] + 1.2);
    }
}
// From the glass to the leather in a gentle slope: the back plate's short 45 deg bevel, then the
// covering's smooth frame round the screen, which carries it on up at about 22 deg and stands 0.2 proud.
// Steeper along the top edge, where the buttons leave less room. Widths [sides and bottom, top]:
bev = [0.6, 0.6];           // the back plate's bevel (0.6 deep, the pocket's floor): 45 deg, as it prints face down over the window
bev_c = [3.4, 1.7];         // the covering's (1.4 deep), printed face up: the gentle part
flat_c = [0.8, 0.6];        // the frame's flat top
module win_rect(s, t) {     // the picture's edge (plus 0.3), grown s at the sides and bottom and t at the top
    translate([win_xy[0] - 0.3 - s, win_xy[1] - 0.3 - s]) rrect(scr_active[0] + 0.6 + 2 * s, scr_active[1] + 0.6 + s + t, 1.0 + s / 2);
}
bezel_w = bev_c[0] + flat_c[0];
module bezel_in_2d() win_rect(bev[0], bev[1]);   // the covering's opening: the back plate's at its face
module bezel_out_2d() win_rect(bev[0] + bev_c[0] + flat_c[0], bev[1] + bev_c[1] + flat_c[1]);
module bezel_frame() {   // in 0.1 mm slices (the covering's layers): a cove from the opening, flat at the top
    h = bump + 0.2;
    n = 14;
    for (i = [0 : n - 1]) let(z = (i + 1) * h / n, f = 1 - sqrt(1 - z / h), r = max(0, z - (h - 0.4)))
        translate([0, 0, i * h / n]) linear_extrude(h / n + 0.001) difference() {
            offset(-r) bezel_out_2d();                                    // the outer edge rounds off
            win_rect(bev[0] + bev_c[0] * f, bev[1] + bev_c[1] * f);
        }
}
portrait_svg = "art/portrait.svg";
portrait_size = [46.81, 44.0];
portrait_h = 44.0;
portrait_at = [(1.4 + cover_x1) / 2, 8.0];
ink_depth = 0.4;
module portrait(layer) {
    k = portrait_h / portrait_size[1];
    translate([portrait_at[0] - portrait_size[0] * k / 2, portrait_at[1]]) scale(k) import(portrait_svg, id = layer);
}
module portrait_ink() intersection() { difference() { portrait("ink"); portrait("cut"); } offset(-0.3) back_leatherette_2d(); }
module portrait_figure() intersection() { union() { portrait("figure"); portrait("ink"); } back_leatherette_2d(); }
module back_leatherette() {
    difference() {
        union() {
            linear_extrude(cover_t) back_leatherette_2d();
            difference() {
                grain_relief() back_leatherette_2d();
                translate([0, 0, cover_t - 1]) linear_extrude(2) offset(0.4) portrait_figure();
                translate([0, 0, cover_t - 1]) linear_extrude(2) offset(0.4) bezel_out_2d();
            }
            linear_extrude(bump) portrait_figure();
            bezel_frame();
        }
        translate([0, 0, bump - ink_depth]) linear_extrude(1) portrait_ink();
    }
}
module portrait_inlay() translate([0, 0, bump - ink_depth]) linear_extrude(ink_depth) portrait_ink();
module grain() { linear_extrude(cover_t) children(); grain_relief() children(); }
module grain_relief() {
    intersection() {
        translate([0, 0, cover_t - 0.01]) linear_extrude(grain_t + 0.02) offset(-0.5) children();
        translate([0, 0, cover_t]) scale([tex_px, tex_px, grain_t / 100]) surface(file = "art/leather.png");
    }
}

// ================================================================ top plate (printed upside down)
// windows: the viewfinder and the rangefinder open through the front wall, with one dark card glued
// behind both; the eyepiece at the back and the frame counter on top are shallow recesses (a black
// marker); the M6's frosted frame-line window is ribbed, in the plate itself
// (mirrored for the left hand: the viewfinder and eyepiece by the knob on the right, the rangefinder
// window by the shutter on the left, seen from the back)
tp_wins = [[W - 31, 2.6, 15, 5.4, "front"], [29, 3.2, 7, 4.2, "front"], [W - 27, 2.6, 11, 5.4, "back"]];
frost_win = [W - 41, 2.6, 8, 5.4];
counter_c = [10, 17.0];          // the frame counter's window, on top (x, z)
module window_card() zbox(27.5, H + 1.9, W - 27.5 - 14.5, tp_h - tp_ceiling - 1.9, D + bump - 2.0 - 0.8, D + bump - 2.0);
tp_r = 8;                   // round corners, seen from the front
tp_chamfer = 2 * edge_r * (1 - cos(45));
function td_arc(cx, cy, r, s) = [for (a = [0 : 7.5 : 45]) [cx + s * r * cos(a), cy + r * sin(a)]];
module top_plate_2d() {
    yt = H + tp_h;
    polygon(concat([[0, H - 10], [W, H - 10]],
        td_arc(W - tp_r, yt - tp_r, tp_r, 1), [[W - tp_r + 0.414 * tp_r, yt]],
        [[tp_r - 0.414 * tp_r, yt]], [for (p = [6 : -1 : 0]) td_arc(tp_r, yt - tp_r, tp_r, -1)[p]]));
}
function xz_section(z1) = concat(
    [for (p = edge_back) [p[0], p[1]]], [for (i = [len(edge_back) - 1 : -1 : 0]) [W - edge_back[i][0], edge_back[i][1]]],
    [for (p = edge_front) [W - p[0], z1 - p[1]]], [for (i = [len(edge_front) - 1 : -1 : 0]) [edge_front[i][0], z1 - edge_front[i][1]]]);
module top_plate_foot() {
    translate([0, H + tp_h, 0]) rotate([90, 0, 0]) linear_extrude(0.01) intersection() {
        offset(delta = -tp_chamfer) polygon(xz_section(D + bump));
        translate([tp_r * (1 - 0.414), -1]) square([W - 2 * tp_r * (1 - 0.414), D + bump + 2]);
    }
}
// the name, engraved like the M6's LEICA / M6: Futura (as close as it gets), two lines. The M6 has it
// right-aligned beside the rangefinder window; mirrored, it's left-aligned beside it, at the right end
name_lines = ["RYAN", "LIM"];
name_font = "Futura:style=Medium";
name_x = W - 26;            // its left edge, from the left end seen from the front
module name_engraving() {
    for (i = [0, 1]) translate([name_x, H + 5.4 - i * 4.6]) scale([1.15, 1])
        text(name_lines[i], size = 3.2, font = name_font, halign = "left", valign = "center", spacing = 1.22);
}
// The M6's front is busy; these fill ours the same way. Raised rims (0.4) round the three front
// windows, like the M6's chrome bezels; a round badge where the M6 has its red dot, "digicam" standing
// in a shallow recess (paint the recess red); the rewind lever with its slotted pivot and an R, at
// the leather line under the name; and a small "No. 01" under the viewfinder, where the M6 has 0.58.
badge = [62, H + 3.0];      // seen from the front (x from the left end)
r_lever = [107, cap_y0 + 4.2];
module front_details() {
    rim = 0.9;
    for (w = concat([for (w = tp_wins) if (w[4] == "front") w], [concat(frost_win, ["front"])]))
        translate([0, 0, D + bump - 1]) linear_extrude(1.4) difference() {
            translate([w[0] - rim, H + w[1] - rim]) rrect(w[2] + 2 * rim, w[3] + 2 * rim, rim);
            translate([w[0], H + w[1]]) square([w[2], w[3]]);
        }
    real() translate([r_lever[0], r_lever[1], D + bump - 0.5]) {   // the rewind lever
        cylinder(d = 4.6, h = 1.3);
        hull() { cylinder(d = 2.8, h = 1.0); translate([5.2, -2.4, 0]) cylinder(d = 2.2, h = 1.0); }
    }
}
module front_engraving() {
    real() translate([0, 0, D + bump - 0.5]) linear_extrude(2) {
        translate(badge) difference() { circle(d = 7.4); text("digicam", size = 1.35, font = "Futura:style=Bold", halign = "center", valign = "center"); }
        translate(r_lever + [9.0, 0]) text("R", size = 2.4, font = text_font, halign = "center", valign = "center");
        let(vf = tp_wins[0]) translate([W - vf[0], H + vf[1] - 1.4]) text("No. 01", size = 1.3, font = text_font, halign = "right", valign = "center");
    }
    real() translate([r_lever[0], r_lever[1], D + bump + 0.6]) rotate(40) cube([3.6, 0.5, 1], center = true);   // the pivot's slot
}
module cap_band() {   // the cover down the front and the ends, round the frame
    difference() {
        intersection() {
            body_shape(0, D + bump, edge_back, edge_front);
            translate([-1, cap_y0, -1]) cube([W + 2, H - cap_y0 + 0.01, D + bump + 2]);
        }
        translate([t_sk, cap_y0 - 1, -1]) cube([W - 2 * t_sk, H - cap_y0 + 2, D + 1]);
        translate([0, 0, D - 1]) linear_extrude(3) offset(0.3) flange_model_2d();
        for (x = [-1, W - 3], z = strap_z) translate([x, strap_y, z]) rotate([0, 90, 0]) cylinder(d = 2.6, h = 4, $fn = 24);
    }
}
y_sh_base = H + tp_h - tp_ceiling - flange - 0.1 - btn_h;   // the shutter switch's base, in its cradle
// The shutter switch's cradle hangs from the ceiling (it prints rising from it): the same 6 x 6
// four-leg switch as the back buttons, pushed up into an open-bottomed pocket, plunger first, until
// two snap fingers click under its base; ledges in the corners stop its metal top. Each leg leaves
// through a notch in a side wall, and the wires drop past into the frame's passage. The cap's
// flange travels in the pocket above the switch.
module shutter_cradle() {
    y_c = H + tp_h - tp_ceiling;               // the ceiling's underside
    y_b = y_sh_base - 1.0;                     // the walls' lower end, below the switch's base
    difference() {
        union() {
            zbox(shutter_x - po_, y_b, 2 * po_, y_c - y_b + 0.01, z_mid - po_, z_mid + po_);
            // snap fingers on the two walls without legs (+-z): a catch under the base, with a lead-in
            for (s = [-1, 1]) let(zi = z_mid + s * pi_) hull() {
                zbox(shutter_x - snap_w / 2, y_sh_base - 0.06, snap_w, 0.01, s < 0 ? zi - 0.01 : zi - snap_reach, s < 0 ? zi + snap_reach : zi + 0.01);
                zbox(shutter_x - snap_w / 2, y_sh_base - 0.8, snap_w, 0.01, s < 0 ? zi - 0.01 : zi - 0.01, s < 0 ? zi + 0.01 : zi + 0.01);
            }
        }
        // the pocket, open at the bottom, up to the ceiling (the cap's flange moves in its top)
        difference() {
            zbox(shutter_x - pi_, y_b - 1, 2 * pi_, y_c - y_b + 1, z_mid - pi_, z_mid + pi_);
            // corner ledges that stop the switch's metal top (clear of the cap's flange in the middle)
            for (sx = [-1, 1], sz = [-1, 1]) zbox(sx < 0 ? shutter_x - pi_ : shutter_x + pi_ - 0.9, y_sh_base + bbtn_body + 0.05, 0.9, 0.8,
                                                  sz < 0 ? z_mid - pi_ : z_mid + pi_ - 0.9, sz < 0 ? z_mid - pi_ + 0.9 : z_mid + pi_);
        }
        // the fingers: slits either side, and thinner than the wall, from the bottom up to just past the base
        for (s = [-1, 1], dx = [-1, 1]) let(zi = z_mid + s * pi_)
            zbox(shutter_x + dx * (snap_w / 2 + 0.25) - 0.25, y_b - 1, 0.5, y_sh_base + 2.0 - y_b + 1, s < 0 ? zi - 1.3 : zi - 0.1, s < 0 ? zi + 0.1 : zi + 1.3);
        for (s = [-1, 1]) let(zi = z_mid + s * pi_)
            zbox(shutter_x - snap_w / 2, y_b - 1, snap_w, y_sh_base + 2.0 - y_b + 1, s < 0 ? zi - 1.3 : zi + snap_t, s < 0 ? zi - snap_t : zi + 1.3);
        // a notch through the side wall for each leg
        for (sx = [-1, 1], sz = [-1, 1]) let(z0 = sz < 0 ? z_mid - pi_ : z_mid + leg_y0)
            zbox(sx < 0 ? shutter_x - po_ - 0.01 : shutter_x + pi_ - 0.01, y_b - 1, po_ - pi_ + 0.02, y_sh_base + 1.5 - y_b + 1, z0, z0 + pi_ - leg_y0);
    }
}
module top_plate() {
    y0 = H;
    y1 = H + tp_h;
    difference() {
        union() {
            difference() {
                intersection() {
                    hull() { profiled(0, D + bump) top_plate_2d(); top_plate_foot(); }
                    translate([-1, y0, -1]) cube([W + 2, tp_h + 1, D + bump + 2]);
                }
                translate([0, 0, 2.0]) linear_extrude(D + bump - 4.0)
                    intersection() { offset(-2.0) top_plate_2d(); translate([0, y0 - 11]) square([W, tp_h + 11 - tp_ceiling]); }
            }
            shutter_cradle();
            // power switch pocket, hanging from the ceiling
            zbox(sw_x - sw[0] / 2 - clr - 1.2, y1 - tp_ceiling - sw[1] - 0.6, sw[0] + 2 * clr + 2.4, sw[1] + 0.61,
                 z_mid - sw[2] / 2 - clr - 1.2, z_mid + sw[2] / 2 + clr + 1.2);
            for (x = tp_screws) translate([x, y1 - 0.01, z_mid]) rotate([90, 0, 0]) cylinder(d = 5.4, h = tp_h - 0.2);
            cap_band();
            front_details();
        }
        translate([shutter_x, y1 + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = sh_stem_d + 0.4, h = tp_ceiling + 2.2);
        zbox(sw_x - sw[0] / 2 - clr, y1 - tp_ceiling - sw[1] - 1, sw[0] + 2 * clr, sw[1] + 1.01, z_mid - sw[2] / 2 - clr, z_mid + sw[2] / 2 + clr);
        knob_slot(y1 - tp_ceiling - 0.5, tp_ceiling + 1);
        for (x = tp_screws) {
            translate([x, y1 + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = 2.4, h = tp_h + 2);
            translate([x, y1 + 0.01, z_mid]) rotate([90, 0, 0]) cylinder(d1 = 4.4, d2 = 2.4, h = 1.0);
        }
        win_depth = 0.6;
        for (w = tp_wins) if (w[4] == "front") zbox(w[0], y0 + w[1], w[2], w[3], D + bump - 3, D + bump + 2);   // through: the card behind
                          else zbox(w[0], y0 + w[1], w[2], w[3], -2, win_depth);
        difference() {   // frosted window: ribs standing in a recess
            zbox(frost_win[0], y0 + frost_win[1], frost_win[2], frost_win[3], D + bump - win_depth, D + bump + 2);
            for (x = [frost_win[0] + 0.8 : 1.0 : frost_win[0] + frost_win[2] - 0.6]) zbox(x, y0, 0.5, tp_h, D + bump - win_depth - 1, D + bump - 0.1);
        }
        translate([counter_c[0], y1 - win_depth, counter_c[1]]) rotate([-90, 0, 0]) cylinder(d = 5.0, h = 2);
        translate([W / 2 - 2, y1 + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = 3.0, h = tp_ceiling + 2);      // shoe peg
        translate([dial_x, y1 + 1, z_mid]) rotate([90, 0, 0]) cylinder(d = 3.0, h = tp_ceiling + 2);  // dial peg
        // the name, engraved in the front face left of the windows (reads right way round from the front)
        real() translate([0, 0, D + bump - 0.4]) linear_extrude(1) name_engraving();
        front_engraving();
    }
}
// ================================================================ bottom plate (printed bottom face down)
function td_arc_dn(cx, cy, r, s) = [for (a = [0 : 7.5 : 45]) [cx + s * r * cos(a), cy - r * sin(a)]];
module bottom_plate_2d() {
    polygon(concat([[W, 10]], td_arc_dn(W - bp_r, -bp_h + bp_r, bp_r, 1),
        [[W - bp_r + 0.414 * bp_r, -bp_h], [bp_r - 0.414 * bp_r, -bp_h]],
        [for (p = [6 : -1 : 0]) td_arc_dn(bp_r, -bp_h + bp_r, bp_r, -1)[p]], [[0, 10]]));
}
module bottom_plate_foot() {
    translate([0, -bp_h + 0.01, 0]) rotate([90, 0, 0]) linear_extrude(0.01) intersection() {
        offset(delta = -tp_chamfer) polygon(xz_section(D + bump));
        translate([bp_r * (1 - 0.414), -1]) square([W - 2 * bp_r * (1 - 0.414), D + bump + 2]);
    }
}
bp_key_x = (bp_screws[0] + bp_screws[1]) / 2;   // the base-plate lock key, between the screws
module bottom_plate() {
    difference() {
        union() {
            intersection() {
                hull() { profiled(0, D + bump) bottom_plate_2d(); bottom_plate_foot(); }
                translate([-1, -bp_h, -1]) cube([W + 2, bp_h, D + bump + 2]);
            }
            translate([bp_peg_x, -0.01, z_mid]) rotate([-90, 0, 0]) cylinder(d = 2.2, h = 1.4);   // locating peg
        }
        for (x = bp_screws) {
            translate([x, -bp_h - 1, z_mid]) rotate([-90, 0, 0]) cylinder(d = 2.4, h = bp_h + 2);
            translate([x, -bp_h - 0.01, z_mid]) rotate([-90, 0, 0]) cylinder(d1 = 4.4, d2 = 2.4, h = 1.0);
        }
        // engraved underneath: the lock key, and the maker's line (reads from below, lens away from you)
        translate([bp_key_x, -bp_h + 0.4, z_mid]) rotate([90, 0, 0]) linear_extrude(1) {
            difference() { circle(d = 10); circle(d = 8.8); }
            square([6.4, 1.4], center = true);
        }
        translate([40, -bp_h + 0.4, z_mid]) rotate([90, 0, 0]) mirror([1, 0, 0])
            linear_extrude(1) text(bottom_line, size = 3.2, font = text_font, halign = "center", valign = "center", spacing = 1.12);
    }
}
module knob_slot(y0, h) {
    zbox(sw_x - (knob_cap[0] + sw_travel) / 2 - 0.3, y0, knob_cap[0] + sw_travel + 0.6, h,
         z_mid - knob_cap[2] / 2 - 0.3, z_mid + knob_cap[2] / 2 + 0.3);
}
dial_x = shutter_x + 17.5;
dial_d = 15;
dial_marks = ["B", "1", "2", "4", "8", "15", "30", "60", "125", "250", "500", "1000"];
module dial() {   // the speed dial: knurled, numbers engraved round its top
    cylinder(d = 2.8, h = 2.0);
    translate([0, 0, 2.0]) difference() {
        union() { knurl(dial_d, 3.0, 48); translate([0, 0, 3.0]) cylinder(d = dial_d - 1.6, h = 0.8); }
        mirror([1, 0, 0]) for (i = [0 : len(dial_marks) - 1]) rotate(90 - i * 360 / len(dial_marks)) {   // reads right way round in the real camera
            translate([4.5, 0, 3.4]) linear_extrude(1) text(dial_marks[i], size = 1.2, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
        }
        translate([0, 0, 3.4]) cylinder(d = 2.4, h = 1);
    }
}
module shoe() {
    cylinder(d = 2.8, h = 2.0);
    translate([-9, -6, 2.0]) difference() { cube([18, 12, 2.4]); translate([2, -1, 1.0]) cube([14, 14, 2]); }
    translate([-9, -6, 2.0 + 2.4 - 0.6]) for (s = [0, 1]) translate([s * 14.6, 0, 0]) cube([3.4, 12, 0.6]);
}
// the advance lever: a hub round the shutter, its arm lying back along the top's rear edge (glued on)
lever_tip = [dial_x - 6.0, 2.8];   // (x, z) on the top
module advance_lever() {   // flat side down, in the top plate's (x, z) as seen from above
    t = [lever_tip[0] - shutter_x, lever_tip[1] - z_mid];
    difference() {
        union() {
            cylinder(d = shutter_d + 4.4, h = 1.6);
            hull() { cylinder(d = 4.0, h = 1.2); translate([t[0], t[1], 0]) cylinder(d = 2.8, h = 1.2); }
            translate([t[0], t[1], 0]) cylinder(d = 3.4, h = 2.8);   // its tip
        }
        translate([0, 0, -1]) cylinder(d = shutter_d + 0.6, h = 4);
    }
}
module top_bits_placed() {
    y1 = H + tp_h;
    translate([dial_x, y1 - 2.0, z_mid]) rotate([-90, 0, 0]) dial();
    translate([W / 2 - 2, y1 - 2.0, z_mid]) rotate([-90, 0, 0]) rotate(90) shoe();
    translate([shutter_x, y1, z_mid]) multmatrix([[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0]]) advance_lever();
}

// ================================================================ electronics (ghosts, for fit)
e = 0.02;
module ghost(name) {
    if (name == "battery") zbox(bat_xy[0] + e, bat_xy[1] + e, bat[0] - 2 * e, bat[1] - 2 * e, z_bat0, z_bat0 + bat[2]);
    if (name == "board") {
        zbox(board_xy[0] + e, board_xy[1] + e, board[0] - 2 * e, board[1] - 2 * e, z_b0 + e, z_b1);
        // the module and its antenna, from the module end
        zbox(board_xy[0] - board_ant + e, lens_c[1] - board_mod[1] / 2, board_mod[0], board_mod[1], z_b1, z_b1 + board_mod[2]);
        // microSD socket under the module end, and the smaller parts under the rest
        zbox(board_xy[0] + 2, lens_c[1] - 7.5, 15, 15, z_b0 - 1.5, z_b0 + e);
        zbox(board_xy[0] + 30, lens_c[1] - 7, 26, 14, z_b0 - board_under, z_b0 + e);
        // the two USB-C sockets
        for (y = [usb_ttl, usb_otg]) zbox(x_b1 + usb_over - usb_c[1], board_xy[1] + y - usb_c[0] / 2, usb_c[1] - e, usb_c[0], z_b0 + usb_top - usb_c[2], z_b0 + usb_top);
        // the other parts on top (CH340, buttons, FPC socket): up to 2 mm
        zbox(board_xy[0] + 24, board_xy[1] + 4, 28, board[1] - 8, z_b1, z_b1 + 2.0);
    }
    if (name == "camera") translate([lens_c[0], lens_c[1], 0]) {
        zbox(-cam_holder / 2 - 0.5 + e, -cam_holder / 2 - 2 + e, cam_holder + 1 - 2 * e, cam_holder + 2.5 - 2 * e, z_cam0, z_cam0 + cam_pcb_t);
        zbox(-cam_holder / 2 + e, -cam_holder / 2 + e, cam_holder - 2 * e, cam_holder - 2 * e, z_cam0 + cam_pcb_t, z_lens - cam_barrel[1]);
        translate([0, 0, z_lens - cam_barrel[1] - e]) cylinder(d = cam_barrel[0] - e, h = cam_barrel[1]);
    }
    if (name == "screen") {
        zbox(glass_xy[0] + e, glass_xy[1] + e, scr_glass[0] - 2 * e, scr_glass[1] - 2 * e, z_bi - scr_sink + e, z_scr1 - scr_pcb);
        difference() {
            zbox(scr_xy[0] + e, scr_xy[1] + e, scr[0] - 2 * e, scr[1] - 2 * e, z_scr1 - scr_pcb, z_scr1);
            for (h = scr_holes) zcyl(h, scr_hole_d, z_bi, z_scr1 + 1);
        }
    }
    if (name == "charger") zbox(chg_xy[0] + e, chg_xy[1] + e, chg[0] - 2 * e, chg[1] - 2 * e, z_chg0 + e, z_chg0 + chg_t);
    if (name == "buttons") for (x = btn_xs) {   // the 6 x 6 four-leg switches
        zbox(x - bbtn_w / 2 + e, btn_y - bbtn_w / 2 + e, bbtn_w - 2 * e, bbtn_w - 2 * e, z_btn_base - bbtn_body, z_btn_base - e);
        // the legs' feet, out from the body's two sides
        for (sx = [-1, 1], sy = [-1, 1]) zbox(sx < 0 ? x - bbtn_feet / 2 + e : x + bbtn_w / 2, btn_y + sy * bbtn_leg_y - bbtn_leg_w / 2,
                                              (bbtn_feet - bbtn_w) / 2 - e, bbtn_leg_w, z_btn_base, z_btn_base + bbtn_leg_drop - e);
        translate([x, btn_y, z_plunger + e]) cylinder(d = 2.5, h = btn_h - bbtn_body - e);
    }
    if (name == "shutter") {   // the same 6 x 6 four-leg switch, plunger up
        zbox(shutter_x - bbtn_w / 2 + e, y_sh_base + e, bbtn_w - 2 * e, bbtn_body, z_mid - bbtn_w / 2 + e, z_mid + bbtn_w / 2 - e);
        for (sx = [-1, 1], sz = [-1, 1]) zbox(sx < 0 ? shutter_x - bbtn_feet / 2 + e : shutter_x + bbtn_w / 2, y_sh_base - bbtn_leg_drop + e, (bbtn_feet - bbtn_w) / 2 - e, bbtn_leg_drop,
                                              z_mid + sz * bbtn_leg_y - bbtn_leg_w / 2, z_mid + sz * bbtn_leg_y + bbtn_leg_w / 2);
        translate([shutter_x, y_sh_base + bbtn_body - e, z_mid]) rotate([-90, 0, 0]) cylinder(d = 2.5, h = btn_h - bbtn_body);
    }
    if (name == "switch") {
        yt = H + tp_h - tp_ceiling;
        zbox(sw_x - sw[0] / 2 + e, yt - sw[1] + e, sw[0] - 2 * e, sw[1] - 2 * e, z_mid - sw[2] / 2 + e, z_mid + sw[2] / 2 - e);
    }
    if (name == "knob") translate([sw_x, H + tp_h + knob_top, z_mid]) rotate([90, 0, 0]) knob_cap_part();
    if (name == "caps" || name == "btncaps") for (i = [0 : 2]) translate([btn_xs[i], btn_y, cap_top]) button_cap(i);
    if (name == "caps" || name == "shuttercap") translate([shutter_x, H + tp_h + sh_proud - 0.05, z_mid]) rotate([90, 0, 0]) shutter_cap();
}
ghost_names = ["battery", "board", "screen", "charger", "camera", "buttons", "shutter", "switch"];
module electronics() {
    cols = ["#e0c060", "#2a6b4a", "#1a1a22", "#5b8def", "#333", "#444", "#444", "#888"];
    for (i = [0 : len(ghost_names) - 1]) color(cols[i]) ghost(ghost_names[i]);
}

// ================================================================ colours and assembly
leather_col = "#7a4a2e";
body_col = leather_col;     // frame, back and front plates print in the leather's brown
inner_col = "#f2efe8";
silver = "#d8d6d0";
inlay_col = "#2a1a12";
inlay_shown = true;
module assembly(gap = 0) {
    translate([0, 0, -gap]) color(body_col) back_plate();
    translate([0, 0, z_fi + gap]) color(body_col) front_plate();
    translate([0, 0, D + 1.5 * gap]) color(leather_col) leatherette();
    translate([0, 0, -1.5 * gap]) mirror([0, 0, 1]) {
        color(leather_col) back_leatherette();
        if (inlay_shown) color(inlay_col) portrait_inlay();
    }
    translate([0, -gap, 0]) color(silver) bottom_plate();
    translate([0, 0.6 * gap, 0]) color("#1c1b20") window_card();
    // the eyepiece and frame counter, blacked in with a marker
    translate([0, gap, 0]) color("#1c1b20") {
        translate([counter_c[0], H + tp_h - 0.58, counter_c[1]]) rotate([-90, 0, 0]) cylinder(d = 4.96, h = 0.56);
        for (w = tp_wins) if (w[4] == "back") zbox(w[0] + 0.02, H + w[1] + 0.02, w[2] - 0.04, w[3] - 0.04, 0.02, 0.58);
    }
    translate([lens_c[0], lens_c[1], D + 2.2 * gap]) mirror([1, 0, 0]) color(silver) lens_barrel();
    translate([0, gap, 0]) color(silver) top_plate();
    translate([0, 1.6 * gap, 0]) color(silver) top_bits_placed();
    color(body_col) frame();
    translate([0, 0, gap * 0.4]) color(inner_col) deck();
    translate([0, 0, gap * 0.8]) color("#b8b4aa") cradle();
    translate([0, 0, -gap * 0.5]) color(silver) carrier();
    translate([0, 0, -2.6 * gap]) color(silver) ghost("caps");
    translate([0, 2 * gap, 0]) color(silver) ghost("knob");
    if (show_parts) translate([0, 0, gap * 0.4]) electronics();
}
module view(gap = 0) { rotate([90, 0, 0]) translate([W, 0, 0]) mirror([1, 0, 0]) assembly(gap); }

module solid(name) {
    if (name == "frame") frame();
    else if (name == "deck") deck();
    else if (name == "cradle") cradle();
    else if (name == "carrier") carrier();
    else if (name == "back_plate") back_plate();
    else if (name == "front_plate") translate([0, 0, z_fi]) front_plate();
    else if (name == "top_plate") top_plate();
    else if (name == "bottom_plate") bottom_plate();
    else if (name == "top_bits") top_bits_placed();
    else if (name == "window_card") window_card();
    else if (name == "lens_barrel") translate([lens_c[0], lens_c[1], D]) lens_barrel();
    else ghost(name);
}
check_a = "";
check_b = "";

// ================================================================ parts
if (part == "assembly") view(0);
else if (part == "exploded") view(14);
else if (part == "frame") real() translate([0, 0, -z_bi]) frame();
else if (part == "deck") real() translate([0, 0, -z_deck0]) deck();
else if (part == "cradle") real() translate([0, 0, -z_cr0]) cradle();
else if (part == "carrier") real() translate([0, 0, z_btn_base + carrier_t]) mirror([0, 0, 1]) carrier();
else if (part == "back_plate") real() back_plate();
else if (part == "front_plate") real() translate([0, 0, t_front]) mirror([0, 0, 1]) front_plate();
else if (part == "caps_light") {
    for (i = [0 : 2]) translate([i * 12, 0, 0]) button_cap(i);
    translate([40, 0, shutter_shaft() + flange]) mirror([0, 0, 1]) shutter_cap();
}
else if (part == "knob_cap") knob_cap_part();
else if (part == "lens_barrel") lens_barrel();
else if (part == "leatherette") real() leatherette();
else if (part == "back_leatherette") back_leatherette();
else if (part == "portrait_inlay") portrait_inlay();
else if (part == "window_card") translate([-14.5, -H - 1.9, -(D + bump - 2.8)]) window_card();
else if (part == "top_plate") real() rotate([-90, 0, 0]) translate([0, -H - tp_h, 0]) top_plate();
else if (part == "top_bits") {   // dial and shoe top down, the lever flat side down
    translate([0, 0, 5.8]) mirror([0, 0, 1]) dial();
    translate([20, 0, 4.4]) mirror([0, 0, 1]) shoe();
    translate([50, 18, 0]) advance_lever();
}
else if (part == "bottom_plate") real() rotate([90, 0, 0]) translate([0, bp_h, 0]) bottom_plate();
else if (part == "check") intersection() { solid(check_a); solid(check_b); }
else if (part == "inside") rotate([90, 0, 0]) translate([W, 0, 0]) mirror([1, 0, 0]) {
    color(body_col) frame(); color(inner_col) deck(); color("#b8b4aa") cradle(); color(silver) carrier(); electronics();
}
else if (part == "inside_back") rotate([90, 0, 0]) translate([W, 0, 0]) mirror([1, 0, 0]) {   // without the board: the deck's channels
    color(body_col) frame(); color(inner_col) deck(); color("#b8b4aa") cradle(); color("#1a1a22") ghost("screen"); color("#e0c060") ghost("battery");
}
else if (part == "coords") {
    echo(str("COORDS {\"W\":", W, ",\"H\":", H, ",\"board\":", [board_xy[0], board_xy[1], board[0], board[1]],
        ",\"rows\":", [row_g, row_v], ",\"pad0\":", pad_x(1), ",\"pitch\":", pitch, ",\"screen\":", [scr_xy[0], scr_xy[1], scr[0], scr[1]],
        ",\"scr_pads\":", scr_pads, ",\"charger\":", [chg_xy[0], chg_xy[1], chg[0], chg[1]], ",\"battery\":", [bat_xy[0], bat_xy[1], bat[0], bat[1]],
        ",\"buttons\":", [for (x = btn_xs) [x, btn_y]], ",\"shutter\":", [shutter_x, H], ",\"switch\":", [sw_x, H],
        ",\"res\":", res_box, ",\"lens\":", lens_c, ",\"notch\":", notch, ",\"div_x\":", div_x, "}"));
    cube(1);
}
