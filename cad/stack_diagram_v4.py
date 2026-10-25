"""How the board, the screen and their wiring sit in the v4 body: diagrams/stack-v4.png.

    python3 stack_diagram_v4.py

Three views, cut from the model itself (guide_parts_v4.scad pieces):
  A. exploded: the screen, the wiring deck with the screen's wires in its channels, the board above
  B. a section across the body, through the pad rows, with the layers and the channel space dimensioned
  C. a section along the GND pad row: one wire's path, up from the screen, along the channel, into its pad
"""
import os
import re
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "diagrams", "stack-v4.png")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP = tempfile.mkdtemp()

# the model's own numbers (camera1_v4.scad); checked by echo below
NUM = {}


def numbers():
    scad = os.path.join(TMP, "n.scad")
    open(scad, "w").write(f'include <{HERE}/camera1_v4.scad>\npart = "none";\n'
                          'echo(str("NUM ", z_bi, " ", z_scr1, " ", z_deck0, " ", z_deck1, " ", z_b0, " ", z_b1, " ", z_fi, " ", D, " ", '
                          'row_g, " ", row_v, " ", board_xy[1], " ", board_xy[0], " ", notch[0], " ", notch[1], " ", pad_x(14), " ", pad_x(20), " ", '
                          'scr_xy[0] + scr[0], " ", z_b1 + board_mod[2], " ", z_lens));\n')
    r = subprocess.run(["openscad", "-o", os.path.join(TMP, "n.echo"), scad], capture_output=True, text=True)
    vals = open(os.path.join(TMP, "n.echo")).read().split('"NUM ')[1].split('"')[0].split()
    keys = "z_bi z_scr1 z_deck0 z_deck1 z_b0 z_b1 z_fi D row_g row_v board_y0 board_x0 notch0 notch1 pad14 pad20 scr_x1 z_mod z_lens".split()
    NUM.update({k: float(v) for k, v in zip(keys, vals)})


# section pieces: name -> fill colour
PIECES = [("back_plate", "#3a393e"), ("front_plate", "#3a393e"), ("frame", "#56545b"), ("screen_glass", "#14141c"),
          ("screen_pcb", "#2a4a9b"), ("screen_pad", "#ece6ef"), ("deck", "#e2b98f"), ("board_pcb", "#1f6a4c"),
          ("board_parts", "#a8acb5"), ("board_module", "#b9bdc6"), ("camera", "#24232a"), ("carrier", "#8d8b93"), ("caps", "#cfcdc6"),
          ("buttons", "#2b2a30")]
WIRES = [(f"w_screen_{i}", "#d6393b" if i == 6 else "#26232b" if i == 7 else "#2f6fd6") for i in range(8)]


def svg_paths(piece, matrix, cut=True, slab=None):
    """2D outline of a piece in a section plane, as SVG path data (OpenSCAD's own SVG export)."""
    scad = os.path.join(TMP, f"{piece}_{abs(hash(str(matrix))) % 10**8}.scad")
    body = f'part_named("{piece}");'
    if slab:
        body = f'intersection() {{ {body} translate([{slab[0]}, {slab[1]}, {slab[2]}]) cube([{slab[3]}, {slab[4]}, {slab[5]}]); }}'
    open(scad, "w").write(f'include <{HERE}/guide_parts_v4.scad>\ngpart = "none";\n'
                          f'projection(cut = {"true" if cut else "false"}) multmatrix({matrix}) {body}\n')
    out = scad.replace(".scad", ".svg")
    subprocess.run(["openscad", "--backend=manifold", "-o", out, scad], capture_output=True, text=True)
    if not os.path.exists(out):
        return []
    return re.findall(r'<path d="([^"]+)"', open(out).read())


def section(matrix, pieces, wires, wire_slab):
    jobs = [(p, c, True, None) for p, c in pieces] + [(w, c, False, wire_slab) for w, c in wires]
    with ThreadPoolExecutor(8) as ex:
        res = list(ex.map(lambda j: (j[1], svg_paths(j[0], matrix, j[2], j[3])), jobs))
    return res


def render_iso():
    """A: an OpenSCAD render, exploded: screen, deck with the wires, board lifted off."""
    scad = os.path.join(TMP, "iso.scad")
    lift = 24
    open(scad, "w").write(f'''include <{HERE}/guide_parts_v4.scad>
gpart = "none";
rotate([90, 0, 0]) translate([W, 0, 0]) mirror([1, 0, 0]) {{
    color("#14141c") part_named("screen_glass");
    color("#2a4a9b") part_named("screen_pcb");
    color("#d9ad4f") part_named("screen_pads");
    color("#e2b98f") part_named("deck");
    for (i = [0 : 7]) color(i == 6 ? "#d6393b" : i == 7 ? "#26232b" : "#2f6fd6") part_named(str("w_screen_", i));
    translate([0, 0, {lift}]) {{
        color("#1f6a4c") part_named("board_pcb");
        color("#d9ad4f") part_named("board_pads");
        color("#b9bdc6") part_named("board_module");
        color("#a8acb5") part_named("board_parts");
        color("#24232a") part_named("camera");
    }}
    // dashed guides: where each screen wire meets its pad when the board comes down
    for (k = [14, 16, 17, 18, 19, 20]) color("#2f6fd6") for (s = [0 : 5]) translate([pad_x(k), row_g, z_w + 0.6 + s * 2.6]) cylinder(d = 0.5, h = 1.3);
    for (k = [1, 2]) color("#2f6fd6") for (s = [0 : 5]) translate([pad_x(k), row_v, z_w + 0.6 + s * 2.6]) cylinder(d = 0.5, h = 1.3);
}}
''')
    out = os.path.join(TMP, "iso.png")
    subprocess.run(["openscad", "--backend=manifold", "--render", "--imgsize=1500,760", "--colorscheme=Tomorrow",
                    "--camera=0,0,0,58,0,32,0", "--viewall", "--autocenter", "-o", out, scad], capture_output=True, text=True)
    from PIL import Image, ImageChops
    im = Image.open(out).convert("RGB")
    bbox = ImageChops.difference(im, Image.new("RGB", im.size, im.getpixel((2, 2)))).getbbox()
    im.crop((max(bbox[0] - 30, 0), max(bbox[1] - 30, 0), min(bbox[2] + 30, im.width), min(bbox[3] + 30, im.height))).save(out)
    return out


def main():
    numbers()
    n = NUM
    # B: plane x = 92 (through the GND row's pads 15 to 16, across both rows); horizontal = y, vertical = z
    xb = n["pad14"] + 4.0
    mb = f"[[0,1,0,0],[0,0,1,0],[1,0,0,{-xb}]]"
    sec_b = section(mb, PIECES, WIRES, [xb - 0.6, -1, -1, 1.2, 70, 30])
    # C: plane y = GND row; horizontal = x, vertical = z
    yc = n["row_g"]
    mc = f"[[1,0,0,0],[0,0,1,0],[0,1,0,{-yc}]]"
    sec_c = section(mc, PIECES, WIRES, [40, yc - 4, -1, 80, 26, 30])
    iso = render_iso()

    def draw(sec, x0, x1, z0, z1, S):
        w, h = (x1 - x0) * S, (z1 - z0) * S
        g = [f'<g transform="translate({-x0 * S},{z1 * S}) scale({S},{-S})">']
        for col, paths in sec:
            for d in paths:
                g.append(f'<path d="{d}" transform="scale(1,-1)" fill="{col}" stroke="#111" stroke-width="{0.6 / S}"/>')
        g.append("</g>")
        return w, h, "\n".join(g)

    SB, SC = 22.0, 18.0
    bw, bh, bg = draw(sec_b, -1, 60, -1.5, 23.5, SB)
    cw, ch, cg = draw(sec_c, 42, 117, -1.5, 23.5, SC)
    S = SB

    def zt(z, S=SB):   # z in mm -> y pixel (sections run from z = 23.5 down)
        return (23.5 - z) * S

    def yx(y):   # B's horizontal: y mm -> x pixel
        return (y + 1) * SB

    def xx(x):   # C's horizontal: x mm -> x pixel
        return (x - 42) * SC

    lab = lambda x, y, t, a="start", w=600, size=15: f'<text x="{x}" y="{y}" font-size="{size}" font-weight="{w}" text-anchor="{a}">{t}</text>'
    line = lambda x1, y1, x2, y2, c="#222": f'<path d="M{x1} {y1} L{x2} {y2}" stroke="{c}" stroke-width="1.4" fill="none"/>'

    def dim(x, z_a, z_b, text, side=1):   # a vertical dimension at pixel x between two z values (B coordinates)
        ya, yb = zt(z_a), zt(z_b)
        return (f'<path d="M{x} {ya} L{x} {yb} M{x - 4} {ya} L{x + 4} {ya} M{x - 4} {yb} L{x + 4} {yb}" stroke="#8b4a28" stroke-width="1.4"/>'
                + lab(x + 8 * side, (ya + yb) / 2 + 5, text, "start" if side > 0 else "end", 600, 13))

    # annotations, section B
    ann_b = [
        lab(yx(30), zt(1.0) + 4, "back plate", "middle", 600, 13),
        lab(yx(30), zt(3.0) + 5, "screen glass", "middle", 600, 13, ),
        lab(yx(42.5), zt(5.2) + 5, "screen PCB", "middle", 600, 12),
        lab(yx(30), zt(10.4) + 5, "board", "middle", 700, 13),
        lab(yx(30), zt(19.7) + 5, "front plate", "middle", 600, 13),
        dim(yx(n["board_y0"] - 2.6), n["z_deck1"], n["z_b0"], "2.4 mm channel", -1),
        dim(yx(n["board_y0"] - 2.6) - 150, n["z_scr1"], n["z_deck0"], "0.3: foam pad", -1),
        line(yx(n["row_g"]), zt(n["z_b1"]) - 34, yx(n["row_g"]), zt(n["z_b1"]) - 2),
        lab(yx(n["row_g"]), zt(n["z_b1"]) - 40, "GND row pads", "middle", 700, 13),
        line(yx(n["row_v"]), zt(n["z_b1"]) - 34, yx(n["row_v"]), zt(n["z_b1"]) - 2),
        lab(yx(n["row_v"]), zt(n["z_b1"]) - 40, "3V3 row pads", "middle", 700, 13),
        line(yx(n["row_g"]), zt(n["z_deck1"] + 0.8) + 4, yx(n["row_g"]) + 20, zt(-1.2) + 30),
        lab(yx(n["row_g"]) + 24, zt(-1.2) + 36, "channel under each pad row: the wires lie here, the board is its lid", "start", 700, 14),
        line(yx(n["board_y0"] + 3.6), zt(n["z_deck1"] + 1.4), yx(n["board_y0"] + 6), zt(n["z_b1"] + 4.6)),
        lab(yx(n["board_y0"] + 6), zt(n["z_b1"] + 4.6) - 6, "rib: carries the board between the rows", "start", 600, 13),
    ]
    # annotations, section C
    zc = lambda z: zt(z, SC)
    ann_c = [
        lab(xx(66), zc(10.45) + 5, "board", "middle", 700, 13),
        lab(xx(66), zc(5.2) + 5, "screen PCB", "middle", 600, 12),
        lab(xx(66), zc(3.0) + 5, "screen glass", "middle", 600, 13),
        line(xx((n["notch0"] + n["notch1"]) / 2), zc(n["z_deck0"]) + 2, xx(112), zc(-1.2) + 30),
        lab(xx(114), zc(-1.2) + 46, "notch: the screen's 8 wires rise here", "end", 700, 14),
        line(xx(n["pad14"]), zc(n["z_b1"]) - 40, xx(n["pad14"]), zc(n["z_b1"]) - 2),
        lab(xx(n["pad14"]), zc(n["z_b1"]) - 46, "up through its pad (GND row, pads 14 to 20), soldered on top", "middle", 700, 14),
        line(xx(88), zc(n["z_deck1"] + 0.8) + 4, xx(84), zc(-1.2) + 30),
        lab(xx(84), zc(-1.2) + 46, "along the channel to its pad", "middle", 700, 14),
    ]
    W = max(bw, cw, 1500) + 100
    title = "Camera 1 (v4): how the board, the screen and their wires sit"
    sub = ("The screen lies glass-down on the back plate. The wiring deck sits on its back (0.5 mm foam between). The board rests on the "
           "deck's two ribs, so under each pad row there is a 2.4 mm channel with the board as its lid: every wire comes up through its pad "
           "from underneath, and the board's top stays clear.")
    import textwrap
    sublines = textwrap.wrap(sub, 150)
    y = 40
    parts = [f'<rect width="100%" height="100%" fill="#fafafa"/>', lab(40, y, title, "start", 800, 30)]
    for i, s in enumerate(sublines):
        parts.append(lab(40, y + 34 + i * 22, s, "start", 400, 16))
    y += 34 + len(sublines) * 22 + 20
    parts.append(lab(40, y, "A  Exploded: the screen, the deck with the screen's wires in its channels, the board lifted off", "start", 700, 18))
    from PIL import Image
    iw, ih = Image.open(iso).size
    k = min(1500 / iw, 760 / ih)
    parts.append(f'<image href="file://{iso}" x="40" y="{y + 10}" width="{iw * k:.0f}" height="{ih * k:.0f}"/>')
    iso_y = y + 10
    y += ih * k + 50
    parts.append(lab(40, y, "B  Section across the body (through the pad rows): the layers and the space for the wires", "start", 700, 18))
    parts.append(f'<g transform="translate(40,{y + 60})">{bg}{"".join(ann_b)}</g>')
    y += bh + 130
    parts.append(lab(40, y, "C  Section along the GND row: a screen wire's path, from the screen up into its pad", "start", 700, 18))
    parts.append(f'<g transform="translate(40,{y + 80})">{cg}{"".join(ann_c)}</g>')
    y += ch + 170
    legend = [("#2a4a9b", "screen"), ("#e2b98f", "wiring deck"), ("#1f6a4c", "board"), ("#3a393e", "plates and frame"),
              ("#2f6fd6", "signal wire"), ("#d6393b", "3V3"), ("#26232b", "GND")]
    for i, (c, t) in enumerate(legend):
        parts.append(f'<rect x="{40 + i * 190}" y="{y - 14}" width="22" height="16" fill="{c}" stroke="#111"/>' + lab(70 + i * 190, y, t, "start", 600, 15))
    H = y + 40
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" font-family="Helvetica, Arial, sans-serif">{"".join(parts)}</svg>'
    # labels on the exploded view (positions read off the render)
    open(os.path.join(TMP, "stack.svg"), "w").write(svg.replace("</svg>", ISO_LABELS + "</svg>"))
    html = os.path.join(TMP, "stack.html")
    open(html, "w").write(f'<html><body style="margin:0">{open(os.path.join(TMP, "stack.svg")).read()}</body></html>')
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--allow-file-access-from-files", "--hide-scrollbars",
                    f"--screenshot={OUT}", f"--window-size={int(W)},{int(H)}", "file://" + html], capture_output=True)
    print(OUT, int(W), "x", int(H))


ISO_LABELS = '<path d="M1030 392 L1150 330" stroke="#222" stroke-width="1.6" fill="none"/><text x="1158" y="326" font-size="16" font-weight="700" text-anchor="start">screen, glass down</text><path d="M1000 560 L1150 560" stroke="#222" stroke-width="1.6" fill="none"/><text x="1158" y="566" font-size="16" font-weight="700" text-anchor="start">wiring deck (on the screen)</text><path d="M700 360 L760 260" stroke="#222" stroke-width="1.6" fill="none"/><text x="768" y="255" font-size="16" font-weight="700" text-anchor="start">3V3 and EN wires in the top channel</text><path d="M392 390 L250 300" stroke="#222" stroke-width="1.6" fill="none"/><text x="60" y="290" font-size="16" font-weight="700" text-anchor="start">the screen\'s 8 wires</text><text x="60" y="310" font-size="16" font-weight="700" text-anchor="start">rise at the notch</text><path d="M870 470 L1150 470" stroke="#222" stroke-width="1.6" fill="none"/><text x="1158" y="476" font-size="16" font-weight="700" text-anchor="start">dashes: where the wires meet their pads</text><path d="M470 850 L470 905" stroke="#222" stroke-width="1.6" fill="none"/><text x="478" y="922" font-size="16" font-weight="700" text-anchor="start">board, lifted off: it comes down onto the ribs</text>'


if __name__ == "__main__":
    main()
