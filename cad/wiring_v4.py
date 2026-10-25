"""Wiring pictures for the v4 body, drawn from the model's own positions.

    python3 wiring_v4.py

  diagrams/wiring-v4.png         every wire, part pin to board pad (v4 pin plan)
  diagrams/routes-v4.png         where each wire runs, seen from the front, and how long to cut it
  diagrams/wire-lengths-v4.json  the cut lengths, for the guide

Rule for v4: every wire reaches the board from UNDERNEATH (through its pad, soldered on top),
in the deck's channels; the board's top stays clear. Wires that change rows cross at the USB
end, past the ribs' ends.
"""
import json
import math
import os
import re
import subprocess

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "diagrams")
FONT = "/System/Library/Fonts/Helvetica.ttc"
RED, BLACK, GREY, SIG = (214, 48, 49), (30, 30, 34), (150, 150, 160), (66, 110, 220)
SLACK = 15   # mm added to every route, then rounded up to 5 mm

# the board's pads, numbered from the module end (seen on the board's silkscreen)
ROW_G = ["TXD", "RXD", "GPIO 1", "GPIO 2", "GPIO 42", "GPIO 41", "GPIO 40", "GPIO 39", "GPIO 38", "GPIO 37",
         "GPIO 36", "GPIO 35", "GPIO 0", "GPIO 45", "GPIO 48", "GPIO 47", "GPIO 21", "GPIO 20", "GPIO 19", "GND"]
ROW_V = ["3V3", "EN", "GPIO 4", "GPIO 5", "GPIO 6", "GPIO 7", "GPIO 15", "GPIO 16", "GPIO 17", "GPIO 18",
         "GPIO 8", "GPIO 3", "GPIO 46", "GPIO 9", "GPIO 10", "GPIO 11", "GPIO 12", "GPIO 13", "GPIO 14", "5V"]
# screen pads, bottom to top as fitted (pins at the board's USB end)
SCR = ["BLK", "CS", "DC", "RES", "SDA", "SCL", "VCC", "GND"]
SCR_TO = {"BLK": "GPIO 20", "CS": "GPIO 19", "DC": "GPIO 45", "RES": "EN", "SDA": "GPIO 47", "SCL": "GPIO 21", "VCC": "3V3", "GND": "GND"}


def font(size, bold=False):
    return ImageFont.truetype(FONT, size, index=1 if bold else 0)


def coords():
    r = subprocess.run(["openscad", "--backend=manifold", "-D", 'part="coords"', "-o", "/dev/null", "--export-format", "stl",
                        os.path.join(HERE, "camera1_v4.scad")], capture_output=True, text=True)
    return json.loads(re.search(r'COORDS (\{.*\})"', r.stdout + r.stderr).group(1).replace("\\", ""))


def pad(c, name):
    """(x, y) of a board pad by its label, in model coordinates."""
    for row, names in (("g", ROW_G), ("v", ROW_V)):
        if name in names:
            k = names.index(name)
            return (c["pad0"] + k * c["pitch"], c["rows"][0 if row == "g" else 1]), row
    raise KeyError(name)


# ---------------------------------------------------------------- 1. part pin to board pad
def schematic():
    img = Image.new("RGB", (1760, 2200), "white")
    d = ImageDraw.Draw(img)
    d.text((40, 26), "Camera 1 (v4) wiring: part pin to board pad", fill=BLACK, font=font(34, True))
    d.text((40, 72), "Find each pad by the label printed beside it on the board. Every wire goes up through its pad from "
           "underneath and is soldered on top.", fill=(90, 90, 100), font=font(19))
    rows = [("3V3", "VCC", RED), ("GND", "GND", BLACK), ("GPIO 21", "SCL", SIG), ("GPIO 47", "SDA", SIG), ("EN", "RES", SIG),
            ("GPIO 45", "DC", SIG), ("GPIO 19", "CS", SIG), ("GPIO 20", "BLK", SIG), None,
            ("GPIO 3", "left button", SIG), ("GPIO 46", "OK button", SIG), ("GPIO 48", "right button", SIG),
            ("GPIO 14", "shutter", SIG), ("GND", "other foot of all four", BLACK), None,
            ("5V", "", RED), ("GND", "", BLACK), ("GPIO 1", "", SIG)]
    ys, y, gaps = [], 196, iter([100, 150])
    for r in rows:
        ys.append(y if r else None)
        y += 58 if r else next(gaps)
    bx = 1280
    d.rounded_rectangle([bx, 120, bx + 330, y + 4], 18, fill=(42, 107, 74))
    d.text((bx + 22, 128), "ESP32-S3-CAM board", fill="white", font=font(22, True))
    c = coords()
    for r, yy in zip(rows, ys):
        if r:
            d.ellipse([bx - 12, yy - 12, bx + 12, yy + 12], fill=(230, 200, 90), outline=BLACK, width=2)
            (px, _), row = pad(c, r[0])
            k = (ROW_G if row == "g" else ROW_V).index(r[0]) + 1
            d.text((bx + 30, yy - 14), r[0], fill="white", font=font(24, True))
            d.text((bx + 150, yy - 10), f"{'GND' if row == 'g' else '3V3'} row, pad {k}", fill=(200, 230, 210), font=font(16))

    def box(x0, y0, x1, y1, title, sub="", fill=(248, 247, 250)):
        d.rounded_rectangle([x0, y0, x1, y1], 14, outline=BLACK, width=3, fill=fill)
        d.text((x0 + 16, y0 + 10), title, fill=BLACK, font=font(22, True))
        if sub:
            d.text((x0 + 16, y0 + 40), sub, fill=(90, 90, 100), font=font(16))

    def dot(x, y):
        d.ellipse([x - 9, y - 9, x + 9, y + 9], fill=(230, 200, 90), outline=BLACK, width=2)

    box(40, 110, 420, ys[7] + 40, "Screen", "8 wires, 30 AWG, up through the deck's notch")
    box(40, ys[9] - 80, 420, ys[13] + 40, "Buttons and shutter", "tactile switches: use two diagonal feet")
    for i in list(range(8)) + list(range(9, 14)):
        p, pin, col = rows[i]
        d.text((60, ys[i] - 12), pin, fill=BLACK, font=font(21))
        dot(420, ys[i])
        d.line([(429, ys[i]), (bx - 12, ys[i])], fill=col, width=5)
    d.text((440, ys[13] + 12), "chain the other foot of all four together, then one wire to GND", fill=(90, 90, 100), font=font(15))

    y5, yg, y1 = ys[15], ys[16], ys[17]
    box(40, y5 - 70, 260, y5 + 80, "Battery", "plug cut off", fill=(250, 238, 200))
    box(360, y5 - 70, 620, y1 + 50, "Charge module", "", fill=(220, 232, 252))
    for lab, yy in [("B+", y5 - 10), ("B−", y5 + 40)]:
        d.text((376, yy - 12), lab, fill=BLACK, font=font(20))
        dot(360, yy)
    d.line([(260, y5 - 10), (351, y5 - 10)], fill=RED, width=6)
    d.line([(260, y5 + 40), (351, y5 + 40)], fill=BLACK, width=6)
    d.text((270, y5 - 40), "red", fill=RED, font=font(15)); d.text((270, y5 + 48), "black", fill=BLACK, font=font(15))
    for lab, yy in [("+  5V out", y5), ("−  GND out", yg)]:
        d.text((470, yy - 12), lab, fill=BLACK, font=font(20))
        dot(620, yy)
    box(700, y5 - 78, 900, y5 - 18, "Slide switch")
    for i, lab in enumerate(["end", "middle", "end"]):
        lx = 730 + i * 70
        dot(lx, y5 - 18)
        d.text((lx - 20, y5 - 112), lab, fill=(90, 90, 100), font=font(14))
    d.line([(629, y5), (800, y5), (800, y5 - 27)], fill=RED, width=6)
    d.line([(870, y5 - 27), (870, y5 + 12), (bx - 12, y5 + 12), (bx - 12, y5)], fill=RED, width=6)
    d.text((910, y5 - 70), "the other end leg: no wire", fill=(90, 90, 100), font=font(15))
    d.line([(629, yg), (bx - 12, yg)], fill=BLACK, width=6)
    # the divider sits at the charge module, in the cradle's porch: B+ - 100k - (to GPIO 1) - 100k - the module's - (GND)
    dy0 = y1 + 90
    d.rounded_rectangle([300, dy0, 780, dy0 + 80], 14, outline=BLACK, width=3, fill=(248, 247, 250))
    d.text((300, dy0 + 90), "Battery level: two 100 kΩ resistors in the cradle's porch beside the module, in heat-shrink:\n"
           "B+ to the first, the second to the module's − (GND out), one wire from their middle to GPIO 1", fill=BLACK, font=font(17, True))
    rr = dy0 + 40
    r1, r2 = (360, rr), (600, rr)
    d.line([(352, y5 - 10), (330, y5 - 10), (330, rr), (r1[0], rr)], fill=RED, width=3)
    for (x, yy) in (r1, r2):
        d.rectangle([x, yy - 10, x + 70, yy + 10], outline=BLACK, width=2, fill="white")
        d.text((x + 16, yy - 9), "100k", fill=BLACK, font=font(15))
    d.line([(r1[0] + 70, rr), (r2[0], rr)], fill=SIG, width=3)
    d.line([(515, rr), (515, rr - 22), (1000, rr - 22), (1000, y1), (bx - 12, y1)], fill=SIG, width=5)
    d.line([(r2[0] + 70, rr), (r2[0] + 110, rr), (r2[0] + 110, yg + 14), (640, yg + 14), (640, yg), (629, yg)], fill=BLACK, width=3)
    y = dy0 + 170
    ly = y + 20
    for i, (col, lab) in enumerate([(RED, "power +: 26 AWG from the battery through the module and switch to 5V; 30 AWG for the screen's VCC and the battery-level wire"),
                                    (BLACK, "GND: 26 AWG for the module's OUT−; 30 AWG elsewhere"), (SIG, "signals: 30 AWG, any light colour")]):
        d.line([(40, ly + i * 32), (110, ly + i * 32)], fill=col, width=7)
        d.text((124, ly + i * 32 - 12), lab, fill=BLACK, font=font(18))
    img.crop((0, 0, 1760, ly + 110)).save(os.path.join(OUT, "wiring-v4.png"))


# ---------------------------------------------------------------- 2. routes, seen from the front
def routes():
    c = coords()
    W, H = c["W"], c["H"]
    S = 10.0
    pad_px = 60
    top_extra = 12
    img = Image.new("RGB", (int(W * S) + 2 * pad_px + 560, 1180), "white")
    d = ImageDraw.Draw(img)

    def P(x, y):   # model (seen from the back) -> picture seen from the FRONT
        return (pad_px + (W - x) * S, pad_px + (H + top_extra - y) * S + 40)

    def rect(r, **kw):
        x, y, w, h = r
        a, b = P(x + w, y + h), P(x, y)
        d.rounded_rectangle([a[0], a[1], b[0], b[1]], 6, **kw)

    def label(x, y, text, size=16, col=BLACK, bold=False):
        d.text(P(x, y), text, fill=col, font=font(size, bold), anchor="mm")

    d.text((pad_px, 14), "Camera 1 (v4): wire routes, seen from the front with the front plate off", fill=BLACK, font=font(26, True))
    rect([0, 0, W, H], outline=GREY, width=4)
    rect([0, H, W, top_extra], outline=GREY, width=3, fill=(240, 240, 236))
    label(W / 2, H + top_extra / 2, "top plate: shutter and power switch", 15, GREY)
    sx, sy, sw, sh = c["screen"]
    rect(c["screen"], outline=(80, 80, 90), width=2)
    rect(c["battery"], fill=(250, 238, 200), outline=(170, 140, 60), width=2)
    bx, by, bw, bh = c["board"]
    rect(c["board"], fill=(206, 232, 214), outline=(42, 107, 74), width=3)
    rect(c["charger"], fill=(205, 222, 250), outline=(60, 90, 200), width=2)
    rx, ry, rw, rh = c["res"]
    rect([rx, ry, rw, rh], fill=(255, 255, 255), outline=BLACK, width=2)
    label(rx + rw / 2, ry + rh / 2, "100k ×2", 12)
    n = c["notch"]
    rect([n[0], sy - 0.4, n[1] - n[0], n[2] - sy + 0.4], outline=(200, 110, 40), width=3)
    label((n[0] + n[1]) / 2, sy - 2.4, "deck notch", 13, (200, 110, 40))
    # deck channels (under the pad rows)
    for yrow in c["rows"]:
        rect([bx, yrow - 2.6, bw - 10.6, 5.2], outline=(200, 110, 40), width=1)   # from the module end to past pad 20
    q = P(*c["lens"]); d.ellipse([q[0] - 4 * S, q[1] - 4 * S, q[0] + 4 * S, q[1] + 4 * S], fill=(40, 40, 46))
    label(bx + bw / 2 + 6, by + bh / 2 + 7, "board, component side up", 15, (42, 107, 74), True)
    ba = c["battery"]; label(ba[0] + ba[2] / 2, ba[1] + 12, "battery, under the cradle", 15, (150, 120, 40), True)
    ch = c["charger"]; label(ch[0] + ch[2] / 2, ch[1] - 2.4, "charge module", 13, (60, 90, 200))
    # pads, labelled
    for names, yrow, up in ((ROW_G, c["rows"][0], -1), (ROW_V, c["rows"][1], 1)):
        for k, nm in enumerate(names):
            x = c["pad0"] + k * c["pitch"]
            q = P(x, yrow)
            d.ellipse([q[0] - 6, q[1] - 6, q[0] + 6, q[1] + 6], fill=(230, 200, 90), outline=BLACK)
            d.text((q[0], q[1] + up * -16), nm.replace("GPIO ", ""), fill=(42, 107, 74), font=font(11, True), anchor="mm")
    for i, nm in enumerate(SCR):
        q = P(*c["scr_pads"][i])
        d.ellipse([q[0] - 5, q[1] - 5, q[0] + 5, q[1] + 5], fill=(240, 240, 240), outline=BLACK)
        d.text((q[0] + 34, q[1]), nm, fill=(80, 80, 90), font=font(11, True), anchor="mm")
    for b in c["buttons"]:
        q = P(*b); d.ellipse([q[0] - 2.5 * S, q[1] - 2.5 * S, q[0] + 2.5 * S, q[1] + 2.5 * S], outline=(200, 110, 40), width=3)
    sh, swc = c["shutter"], c["switch"]
    q = P(sh[0], sh[1] + 6); d.rectangle([q[0] - 2.5 * S, q[1] - 2.5 * S, q[0] + 2.5 * S, q[1] + 2.5 * S], fill=(255, 140, 61))
    q = P(swc[0], swc[1] + 6); d.rectangle([q[0] - 4.3 * S, q[1] - 1.8 * S, q[0] + 4.3 * S, q[1] + 1.8 * S], fill=(150, 150, 160))

    g_row, v_row = c["rows"]
    lane_b, lane_t = sy + 2.0, c["buttons"][0][1] - 3.2     # beside the board: on the deck below, over the carrier above
    x_usb = n[0] + 1.6                                      # where the screen's wires turn into the channels (in the notch)
    cp = (ch[0] + ch[2] - 0.8, ch[1] + ch[3] / 2)           # the module's pad end
    guide_x = rx + rw + 3.0                                 # the cradle's lane, down its middle
    up_x, lane_top = 20.0, H - 2.4 - 6.0                    # power wires go up the cradle's guides here; the lane along the top
    P_ = lambda name: pad(c, name)[0]
    R = {}
    R["Battery + / − to module B+ / B− (the battery's own leads)"] = (RED, [(ba[0] + 1.5, ba[1] + ba[3]), (ba[0] + 1.5, H - 5), (cp[0] + 3, H - 5), (cp[0] + 3, cp[1] + 7), cp], 0)   # out of its top edge by the module
    R["Module OUT+ to the switch's middle leg (26 AWG red)"] = (RED, [cp, (up_x - 1, cp[1] + 6), (up_x - 1, lane_top), (swc[0] - 1, lane_top), (swc[0] - 1, H), (swc[0] - 1, H + 6)], 0)
    R["Switch end leg to 5V (26 AWG red)"] = (RED, [(swc[0] + 1, H + 6), (swc[0] + 1, lane_t), (P_("5V")[0], lane_t), P_("5V")], 6)
    R["Module OUT− to GND (26 AWG black)"] = (BLACK, [cp, (guide_x, cp[1] - 2), (guide_x, lane_b), (P_("GND")[0], lane_b), P_("GND")], 6)
    R["Battery level: resistors' middle to GPIO 1 (30 AWG)"] = (SIG, [(rx + rw, ry + rh / 2), (guide_x, ry + rh / 2 - 2), (guide_x, lane_b), (P_("GPIO 1")[0], lane_b), P_("GPIO 1")], 6)
    for i, nm in enumerate(SCR):
        to = P_(SCR_TO[nm]); row = pad(c, SCR_TO[nm])[1]
        sp = c["scr_pads"][i]
        col = RED if nm == "VCC" else BLACK if nm == "GND" else SIG
        R[f"Screen {nm} to {SCR_TO[nm]}"] = (col, [sp, (x_usb, sp[1]), (x_usb, to[1]), to], 6)
    btn = c["buttons"]
    R["Left button to GPIO 3"] = (SIG, [btn[0], (btn[0][0], lane_t), (btn[0][0], v_row + 3), (P_("GPIO 3")[0], v_row + 3), P_("GPIO 3")], 6)
    R["OK button to GPIO 46"] = (SIG, [btn[1], (btn[1][0], v_row + 3), (P_("GPIO 46")[0], v_row + 3), P_("GPIO 46")], 6)
    x_end = P_("GND")[0] + 2.8                              # other wires change rows at the USB end, past the ribs
    R["Right button to GPIO 48 (crosses at the USB end)"] = (SIG, [btn[2], (btn[2][0], v_row + 3), (x_end, v_row + 3), (x_end, g_row), P_("GPIO 48")], 6)
    R["Shutter to GPIO 14"] = (SIG, [(sh[0], H + 6), (sh[0], H), (sh[0] + 2, lane_top), (P_("GPIO 14")[0], lane_top), (P_("GPIO 14")[0], v_row + 3), P_("GPIO 14")], 6)
    R["Buttons' and shutter's GND chain to GND"] = (BLACK, [(btn[2][0] + 3, btn[2][1]), (btn[2][0] + 3, v_row + 3), (x_end + 0.8, v_row + 3), (x_end + 0.8, g_row), P_("GND")], 6)
    R["Buttons' GND chain on to the shutter's other leg"] = (BLACK, [(btn[0][0] + 3, btn[0][1]), (btn[0][0] + 3, lane_top - 1), (sh[0] + 3, lane_top - 1), (sh[0] + 3, H), (sh[0] + 3, H + 6)], 0)
    lengths = {}
    for name, (col, pts, z) in R.items():
        d.line([P(*p) for p in pts], fill=col, width=3 if name.startswith("Screen") else 5, joint="curve")
        q = P(*pts[-1]); d.ellipse([q[0] - 5, q[1] - 5, q[0] + 5, q[1] + 5], fill=col)
        mm = sum(math.dist(a, b) for a, b in zip(pts, pts[1:])) + z
        lengths[name] = int(math.ceil((mm + SLACK) / 5) * 5)
    lx = int(W * S) + 2 * pad_px
    d.text((lx, 70), "Cut lengths (route + 15 mm)", fill=BLACK, font=font(20, True))
    for i, (name, (col, _, _)) in enumerate(R.items()):
        y = 110 + i * 46
        d.line([(lx, y + 10), (lx + 34, y + 10)], fill=col, width=6)
        d.text((lx + 44, y), name, fill=BLACK, font=font(15))
        d.text((lx + 44, y + 19), f"{lengths[name]} mm", fill=(90, 90, 100), font=font(15))
    d.text((lx, 110 + len(R) * 46 + 10),
           "All board wires come up through their pad from\nunderneath, along the deck's channels (orange).\n"
           "The screen's wires rise through the deck notch\nat the module end; wires that change rows cross\nat the USB end. Pad positions are from the listing:\ncheck each label on your board.",
           fill=(90, 90, 100), font=font(14))
    img.save(os.path.join(OUT, "routes-v4.png"))
    return lengths


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    schematic()
    lengths = routes()
    json.dump(lengths, open(os.path.join(OUT, "wire-lengths-v4.json"), "w"), indent=1, ensure_ascii=False)
    print(json.dumps(lengths, indent=1, ensure_ascii=False))
