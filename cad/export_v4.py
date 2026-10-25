"""Export camera1_v4.scad: every printable part, the renders, and the fit check.

    python3 export_v4.py      ->  export/v4/*.stl / *.3mf, renders/v4/*.png

Each file is already in its printing orientation (flat face down, no supports needed).
The frame (leather grain on its ends) and the coverings are 3MF (an indexed mesh stays exactly manifold, a quarter the size of STL);
load portrait_inlay.3mf with back_leatherette.3mf as one object for a two-colour print.
"""
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "camera1_v4.scad")
OUT = os.path.join(HERE, "export", "v4")
REN = os.path.join(HERE, "renders", "v4")
PARTS = ["frame", "back_plate", "front_plate", "deck", "cradle", "carrier", "caps_light", "knob_cap", "top_plate", "top_bits",
         "lens_barrel", "leatherette", "back_leatherette", "portrait_inlay", "window_card", "bottom_plate"]
TEXTURED = {"frame", "leatherette", "back_leatherette", "portrait_inlay"}
# camera eye and centre for each render (the assembled camera faces -Y in the views)
VIEWS = {
    "front": ("assembly", "165,-190,100,64,-10,36"),
    "back": ("assembly", "-60,210,85,64,-10,36"),
    "exploded": ("exploded", "260,-230,170,64,-10,40"),
    "inside": ("inside", "70,-170,150,64,0,30"),
    "deck": ("inside_back", "70,-170,150,64,0,30"),
}


def run(args):
    r = subprocess.run(["openscad", "--backend=manifold", *args, SCAD], capture_output=True, text=True)
    bad = [l for l in (r.stdout + r.stderr).splitlines() if "ERROR" in l or "WARNING" in l]
    return (args[-1], bad)


def jobs():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(REN, exist_ok=True)
    for p in PARTS:
        ext = ".3mf" if p in TEXTURED else ".stl"
        fmt = [] if p in TEXTURED else ["--export-format=binstl"]
        yield ["-D", f'part="{p}"', *fmt, "-o", os.path.join(OUT, p + ext)]
    for name, (part, cam) in VIEWS.items():
        yield ["-D", f'part="{part}"', "--render", "--imgsize=1600,1100", "--colorscheme=Tomorrow",
               f"--camera={cam}", "-o", os.path.join(REN, f"{name}.png")]


with ThreadPoolExecutor(8) as ex:
    results = list(ex.map(run, list(jobs())))
for out, bad in results:
    print(("PROBLEM " if bad else "ok      ") + os.path.relpath(out, HERE), *bad, sep="\n  " if bad else "")
sys.exit(subprocess.call([sys.executable, os.path.join(HERE, "check_v4.py")]))
