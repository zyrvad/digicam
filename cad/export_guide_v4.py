"""Export every piece of the v4 interactive guide, and bundle them for the page.

    python3 export_guide_v4.py   ->  ../guide-v4/models.json  ({"frame": base64 STL, ...})

The artifact host serves JSON but not STL, so the page loads one bundle.
"""
import base64
import json
import os
import re
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "guide_parts_v4.scad")
OUT = os.path.join(HERE, "..", "guide-v4")

PARTS = """frame deck cradle carrier back_plate front_plate caps shutter_cap knob lens_barrel top_plate top_bits
covering_front covering_back windows bottom_plate screws_bottom battery foam screen_glass screen_active screen_pcb screen_pads screen_pad
board_pcb board_pads board_module board_parts camera camera_glass camera_tape ribbon charger_pcb charger_parts resistors
buttons shutter_sw slide_sw inserts inserts_barrel screws_back screws_front screws_deck screws_board screws_carrier
screws_top screws_barrel w_bat_red w_bat_black w_out_plus w_5v w_gnd w_sense w_btn_left w_btn_ok w_btn_right w_shutter w_bgnd_chain w_bgnd_shutter w_bgnd_board""".split()
PARTS += [f"w_screen_{i}" for i in range(8)]


def export(job):
    name = job
    with tempfile.TemporaryDirectory() as d:
        out = os.path.join(d, "p.stl")
        r = subprocess.run(["openscad", "--backend=manifold", "--export-format=binstl", "-o", out,
                            "-D", f'gpart="{name}"', SCAD], capture_output=True, text=True)
        log = r.stdout + r.stderr
        bad = [l for l in log.splitlines() if "ERROR" in l or "WARNING" in l or "empty" in l]
        data = open(out, "rb").read() if os.path.exists(out) else b""
    return name, data, bad


jobs = PARTS
with ThreadPoolExecutor(8) as ex:
    results = list(ex.map(export, jobs))
bundle, failed = {}, False
for key, data, bad in results:
    if bad or not data:
        print("PROBLEM", key, *bad[:2])
        failed = True
    else:
        bundle[key] = base64.b64encode(data).decode()
# each wire's two ends (for the page's wire-by-wire walkthrough), and the cut lengths from wiring_v4.py
with tempfile.TemporaryDirectory() as d:
    out = os.path.join(d, "ends.echo")
    subprocess.run(["openscad", "-o", out, "-D", 'gpart="_ends"', SCAD], capture_output=True, text=True)
    ends = {}
    for line in open(out):
        m = re.match(r'ECHO: "WIRE (\S+) \[(.+?)\] \[(.+?)\]"', line.strip())
        if m:
            ends[m.group(1)] = [[round(float(v), 2) for v in g.split(",")] for g in (m.group(2), m.group(3))]
bundle["_wires"] = ends
bundle["_lengths"] = json.load(open(os.path.join(HERE, "..", "diagrams", "wire-lengths-v4.json")))
os.makedirs(OUT, exist_ok=True)
with open(os.path.join(OUT, "models.json"), "w") as f:
    json.dump(bundle, f)
print(f"{len(bundle) - 2} pieces, {len(ends)} wire ends, models.json {os.path.getsize(os.path.join(OUT, 'models.json')) / 1e6:.1f} MB")
sys.exit(1 if failed else 0)
