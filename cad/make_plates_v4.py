"""Bambu Studio project for camera 1 v4: one plate per colour, ready to slice.

    python3 make_plates_v4.py      ->  export/v4/camera1_v4_plates.3mf

Run export_v4.py first (it writes the parts). For the Bambu Lab P2S, 0.4 mm nozzle.

THE REAL CAMERA, plates 1 to 4 (the newest version of every part):
    1  brown   frame, back plate, front plate, wiring deck, power cradle, button carrier (the deck,
               cradle and carrier are hidden inside, so they print in the body's brown)
    2  white   top cover, bottom plate, lens barrel, button caps and shutter cap, rewind knob, speed
               dial, shoe, advance lever; 0.12 mm layers for a finer finish on their curves
    3  brown   the front covering (0.1 mm layers for the grain)
    4  brown   the back covering with the portrait inlay (black part, AMS) and the dark window card
               (black), 0.1 mm layers. Print it once the portrait is final.
THE TEST PRINTS, plates 5 to 10, kept for reference: the first body test, the reprint, the battery
test, the button test, and the two overnight plates.
The filaments carry the tuned flow ratios (0.931 for both, from the flow rate test); the white is
Bambu PLA Basic, the brown Bambu PLA Wood. Every plate has a scarf seam on the outer walls and
slower outer walls (150 mm/s).
Filaments: 1 black, 2 white, 3 brown (your PLA Matte black, PLA Basic white, PLA Wood).
The print settings come from Bambu Studio's own system presets, flattened, with 3 walls.
"""
import glob
import json
import os
import re
import subprocess
import sys
import tempfile
import uuid
import zipfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PARTS = os.path.join(HERE, "export", "v4")
OUT = os.path.join(PARTS, "camera1_v4_plates.3mf")
SCAD = os.path.join(HERE, "camera1_v4.scad")
BAMBU = "/Applications/BambuStudio.app/Contents/MacOS/BambuStudio"
SYS = os.path.expanduser("~/Library/Application Support/BambuStudio/system/BBL")
PRINTER, PROCESS = "Bambu Lab P2S 0.4 nozzle", "0.20mm Standard @BBL P2S"
# (system preset, colour, your tuned values on top of it): the flow ratios from the flow rate test (27 Oct)
TUNED_WHITE = {"name": "PLA Basic White - tuned", "filament_settings_id": ["PLA Basic White - tuned"], "filament_flow_ratio": ["0.931", "0.98"]}
TUNED_WOOD = {"name": "PLA Wood - tuned", "filament_settings_id": ["PLA Wood - tuned"], "filament_flow_ratio": ["0.931", "0.98"]}
FILAMENTS = [("Bambu PLA Matte @BBL P2S", "#000000", {}), ("Bambu PLA Basic @BBL P2S", "#FFFFFF", TUNED_WHITE),
             ("Bambu PLA Wood @BBL P2S", "#3F231C", TUNED_WOOD)]
BED, MARGIN, GAP = 256.0, 12.0, 7.0
STRIDE = BED * 1.2            # Bambu lays plates out 1/5 of a bed apart, in rows of ceil(sqrt(n))

# plate: (name, [(part file, filament, object settings)]); a part may carry extra volumes
GRAIN = {"layer_height": "0.1"}
FINE = {"layer_height": "0.12"}   # the silver parts: their curves and rounded corners show the layers at 0.2
PLATES = [
    # ---- the real camera: the newest version of every part, with the tuned filaments
    ("FINAL 1: brown body and inside", [("frame.3mf", 3, {}), ("back_plate.stl", 3, {}), ("front_plate.stl", 3, {}),
                                        ("deck.stl", 3, {}), ("cradle.stl", 3, {}), ("carrier.stl", 3, {})]),
    ("FINAL 2: silver", [("top_plate.stl", 2, FINE), ("bottom_plate.stl", 2, FINE), ("lens_barrel.stl", 2, FINE),
                         ("caps_light.stl", 2, FINE), ("top_bits.stl", 2, FINE), ("knob_cap.stl", 2, FINE)]),
    ("FINAL 3: front covering", [("leatherette.3mf", 3, GRAIN)]),
    ("FINAL 4: back covering with the portrait, window card", [("back_leatherette.3mf", 3, GRAIN), ("window_card.stl", 1, GRAIN)]),
    # ---- the test prints, kept as they were (the same parts, now at their newest version)
    ("Test: body and inside (first test)", [("frame.3mf", 3, {}), ("back_plate.stl", 3, {}), ("front_plate.stl", 3, {}),
                                            ("deck.stl", 3, {}), ("cradle.stl", 3, {}), ("carrier.stl", 3, {})]),
    ("Test: reprint frame, back plate, deck, carrier", [("frame.3mf", 3, {}), ("back_plate.stl", 3, {}), ("deck.stl", 3, {}), ("carrier.stl", 3, {})]),
    ("Test: battery (power cradle, front plate)", [("cradle.stl", 3, {}), ("front_plate.stl", 3, {})]),
    ("Test: buttons (back plate, carrier)", [("back_plate.stl", 3, {}), ("carrier.stl", 3, {})]),
    ("Test: overnight silver (bottom plate, lens, caps, dial, shoe, lever)", [("bottom_plate.stl", 2, {}), ("lens_barrel.stl", 2, {}),
                                                                             ("caps_light.stl", 2, {}), ("top_bits.stl", 2, {})]),
    ("Test: overnight front covering", [("leatherette.3mf", 3, GRAIN)]),
]
EXTRA_VOLUMES = {"back_leatherette.3mf": [("portrait_inlay.3mf", 1, "portrait inlay")]}


def load_mesh(path):
    """(vertices, triangles) from a binary STL or an OpenSCAD 3MF."""
    if path.endswith(".3mf"):
        s = zipfile.ZipFile(path).read("3D/3dmodel.model").decode()
        v = np.array(re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', s), float)
        t = np.array(re.findall(r'<triangle v1="(\d+)" v2="(\d+)" v3="(\d+)"', s), int)
        return v, t
    d = open(path, "rb").read()
    n = int.from_bytes(d[80:84], "little")
    tri = np.frombuffer(d[84:84 + n * 50], np.uint8).reshape(n, 50)[:, 12:48].copy().view(np.float32).reshape(-1, 3)
    v, inv = np.unique(tri.astype(float), axis=0, return_inverse=True)
    return v, inv.reshape(-1, 3)


def pack(items):
    """First-fit shelf packing of footprints (w, d) on one bed; tries each part both ways round, on
    every shelf so far before opening a new one. -> [(x, y, rot)]"""
    order = sorted(range(len(items)), key=lambda i: -max(items[i]))
    place = [None] * len(items)
    shelves = []                # [y, height, x cursor]
    for i in order:
        w, d = items[i]
        ways = sorted([(w, d, 0), (d, w, 90)], key=lambda c: c[1])   # the lower way round first
        for sh in shelves:
            fit = [c for c in ways if sh[2] + c[0] <= BED - MARGIN and c[1] <= sh[1]]
            if fit:
                ww, dd, rot = fit[0]
                place[i] = (sh[2], sh[0], rot)
                sh[2] += ww + GAP
                break
        else:
            y = shelves[-1][0] + shelves[-1][1] + GAP if shelves else MARGIN
            ww, dd, rot = (w, d, 0) if w >= d else (d, w, 90)
            if y + dd > BED - MARGIN:
                sys.exit(f"plate full: part {i} doesn't fit")
            shelves.append([y, dd, MARGIN + ww + GAP])
            place[i] = (MARGIN, y, rot)
    return place


def settings():
    """The system presets, flattened, through Bambu Studio's CLI: gives a complete project_settings."""
    index = {}
    for kind in ["machine", "process", "filament"]:
        for f in glob.glob(f"{SYS}/{kind}/*.json"):
            try:
                d = json.load(open(f))
            except ValueError:
                continue
            if "name" in d:
                index[(kind, d["name"])] = d

    def flat(kind, name):
        d = index[(kind, name)]
        out = dict(flat(kind, d["inherits"])) if d.get("inherits") else {}
        out.update(d)
        out.pop("inherits", None)
        return out

    with tempfile.TemporaryDirectory() as tmp:
        files = []
        for kind, name, over in [("machine", PRINTER, {}), ("process", PROCESS, {})] + [("filament", f, o) for f, _, o in FILAMENTS]:
            d = flat(kind, name)
            d["from"] = "system"
            d.update(over)
            files.append(os.path.join(tmp, f"{len(files)}.json"))
            json.dump(d, open(files[-1], "w"))
        cube = os.path.join(tmp, "c.stl")
        subprocess.run(["openscad", "-o", cube, "-"], input="cube(5);", text=True, check=True, capture_output=True)
        subprocess.run([BAMBU, "--load-settings", ";".join(files[:2]), "--load-filaments", ";".join(files[2:]),
                        "--export-3mf", "s.3mf", "--outputdir", tmp, cube], check=True, capture_output=True, cwd=tmp)
        z = zipfile.ZipFile(os.path.join(tmp, "s.3mf"))
        project = json.loads(z.read("Metadata/project_settings.config"))
        static = {n: z.read(n) for n in ["[Content_Types].xml", "_rels/.rels"]}
    project["filament_colour"] = [c for _, c, _ in FILAMENTS]
    # the CLI leaves the per-filament lists and the flush table at their one/four-filament defaults
    n = len(FILAMENTS)
    for k, v in list(project.items()):
        if k.startswith("filament_") and isinstance(v, list) and len(v) == 1 and k != "filament_change_length_nc":
            project[k] = v * n
    # purge (mm3) from row to column: black, white, brown. Dark to light needs the most.
    project["flush_volumes_matrix"] = [str(x) for x in [0, 700, 250, 120, 0, 150, 140, 600, 0]]
    project["flush_volumes_vector"] = ["140"] * (2 * n)
    project["wall_loops"] = "3"
    # for the finish: a scarf seam on the outer walls (no seam bump), and slower outer walls
    project["seam_slope_type"] = "external"
    project["outer_wall_speed"] = ["150"] + list(project["outer_wall_speed"][1:])
    # the prime tower (only the coverings plate needs one): in the open space at the back right,
    # well inside the bed (the default sits so far back that a tall tower runs off it)
    project["wipe_tower_x"] = ["165"] * len(PLATES)
    project["wipe_tower_y"] = ["150"] * len(PLATES)
    project["enable_support"] = "0"
    return project, static


def mesh_xml(oid, v, t):
    vs = "\n".join(f'     <vertex x="{a:.5f}" y="{b:.5f}" z="{c:.5f}"/>' for a, b, c in v)
    ts = "\n".join(f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in t)
    return (f'  <object id="{oid}" p:UUID="{uuid.uuid4()}" type="model">\n   <mesh>\n    <vertices>\n{vs}\n    </vertices>\n'
            f'    <triangles>\n{ts}\n    </triangles>\n   </mesh>\n  </object>\n')


NS = ('xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
      'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p"')


def main():
    project, static = settings()
    cols = int(np.ceil(np.sqrt(len(PLATES)) - 1e-9))
    files, resources, build, cfg_objects, cfg_plates = {}, [], [], [], []
    next_id = 1
    for pi, (pname, parts) in enumerate(PLATES):
        meshes = []
        for fname, fil, extra in parts:
            v, t = load_mesh(os.path.join(PARTS, fname))
            vols = [(fname, fil, fname.rsplit(".", 1)[0], v, t)]
            for xf, xfil, xname in EXTRA_VOLUMES.get(fname, []):
                xv, xt = load_mesh(os.path.join(PARTS, xf))
                vols.append((xf, xfil, xname, xv, xt))
            lo = np.min([q[3].min(0) for q in vols], axis=0)
            hi = np.max([q[3].max(0) for q in vols], axis=0)
            meshes.append((fname, fil, extra, vols, lo, hi))
        place = pack([(m[5][0] - m[4][0], m[5][1] - m[4][1]) for m in meshes])
        ox, oy = (pi % cols) * STRIDE, -(pi // cols) * STRIDE
        instances = []
        for (fname, fil, extra, vols, lo, hi), (x, y, rot) in zip(meshes, place):
            comps, parts_cfg = [], []
            centre = (lo + hi) / 2
            for vf, vfil, vname, v, t in vols:
                mid = next_id; next_id += 1
                path = f"3D/Objects/object_{mid}.model"
                files[path] = (f'<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" {NS}>\n'
                               f' <metadata name="BambuStudio:3mfVersion">1</metadata>\n <resources>\n'
                               + mesh_xml(mid, v - centre, t) + ' </resources>\n <build/>\n</model>\n')
                comps.append(f'    <component p:path="/{path}" objectid="{mid}" p:UUID="{uuid.uuid4()}" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>')
                parts_cfg.append(f'    <part id="{mid}" subtype="normal_part">\n      <metadata key="name" value="{vname}"/>\n'
                                 f'      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n'
                                 f'      <metadata key="extruder" value="{vfil}"/>\n    </part>')
            oid = next_id; next_id += 1
            resources.append(f'  <object id="{oid}" p:UUID="{uuid.uuid4()}" type="model">\n   <components>\n' + "\n".join(comps) + '\n   </components>\n  </object>')
            # place: rotate about Z round the part's centre, then put its footprint at (x, y) on plate pi
            w, d = (hi - lo)[:2] if rot == 0 else (hi - lo)[[1, 0]]
            cx, cy, cz = ox + x + w / 2, oy + y + d / 2, (hi[2] - lo[2]) / 2
            c, s = (1, 0) if rot == 0 else (0, 1)
            build.append(f'  <item objectid="{oid}" p:UUID="{uuid.uuid4()}" transform="{c} {s} 0 {-s} {c} 0 0 0 1 {cx:.4f} {cy:.4f} {cz:.4f}" printable="1"/>')
            meta = "".join(f'\n    <metadata key="{k}" value="{val}"/>' for k, val in extra.items())
            cfg_objects.append(f'  <object id="{oid}">\n    <metadata key="name" value="{fname.rsplit(".", 1)[0]}"/>\n'
                               f'    <metadata key="extruder" value="{fil}"/>{meta}\n' + "\n".join(parts_cfg) + '\n  </object>')
            instances.append(f'    <model_instance>\n      <metadata key="object_id" value="{oid}"/>\n      <metadata key="instance_id" value="0"/>\n    </model_instance>')
        cfg_plates.append(f'  <plate>\n    <metadata key="plater_id" value="{pi + 1}"/>\n    <metadata key="plater_name" value="{pname}"/>\n'
                          f'    <metadata key="locked" value="false"/>\n' + "\n".join(instances) + '\n  </plate>')

    files["3D/3dmodel.model"] = (f'<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" {NS}>\n'
                                 ' <metadata name="Application">BambuStudio-02.06.00.51</metadata>\n'
                                 ' <metadata name="BambuStudio:3mfVersion">1</metadata>\n'
                                 ' <metadata name="Title">Digicam camera 1, retro</metadata>\n <resources>\n'
                                 + "\n".join(resources) + f'\n </resources>\n <build p:UUID="{uuid.uuid4()}">\n' + "\n".join(build) + '\n </build>\n</model>\n')
    files["3D/_rels/3dmodel.model.rels"] = ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                                           + "\n".join(f' <Relationship Target="/{p}" Id="rel-{i + 1}" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>'
                                                       for i, p in enumerate(k for k in files if k.startswith("3D/Objects/")))
                                           + '\n</Relationships>\n')
    files["Metadata/model_settings.config"] = '<?xml version="1.0" encoding="UTF-8"?>\n<config>\n' + "\n".join(cfg_objects + cfg_plates) + '\n</config>\n'
    files["Metadata/project_settings.config"] = json.dumps(project, indent=4)
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for name, data in static.items():
            z.writestr(name, data)
        for name, data in files.items():
            z.writestr(name, data)
    print(OUT, f"{os.path.getsize(OUT) / 1e6:.1f} MB,", len(PLATES), "plates")


if __name__ == "__main__":
    main()
