"""Pebble-grain leather heightmap for the retro coverings: art/leather.png.

    python3 art/make_leather.py

One pixel = tex_px mm in camera1_v4.scad (0.2 mm), so the 660 x 400 image covers 132 x 80 mm,
enough for the coverings and the ends of the 128 mm body. White is the top of a pebble, black
the bottom of a groove.

Made for a 0.4 mm nozzle (25 Oct, after the first print came out flaky): the pebbles are big,
about 3 mm across, with FLAT tops, so the covering's top is one flat surface that prints clean
and feels smooth; the grain is in the grooves between them, about 0.7 mm wide and as deep as the
relief (0.4 mm), which is what you see and feel. (The first version had 1.4 mm rounded pebbles:
too fine for the nozzle, so they printed as loose terraces.)
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage as ndi
from scipy.spatial import cKDTree

PX = 0.2                    # mm per pixel
SIZE = (132.0, 80.0)        # mm: the 128 mm body, front, back and ends
CELL = 3.0                  # mean pebble size, mm
GROOVE = 0.7                # groove width at the top, mm
rng = np.random.default_rng(31)

w, h = int(SIZE[0] / PX), int(SIZE[1] / PX)
# jittered grid of pebble centres (more even than pure random, like real grain), every other row offset
gx, gy = np.meshgrid(np.arange(-1, SIZE[0] / CELL + 2), np.arange(-1, SIZE[1] / CELL + 2))
pts = np.column_stack([gx.ravel(), gy.ravel()]) * CELL
pts[:, 0] += (gy.ravel() % 2) * CELL / 2
pts += rng.uniform(-0.38, 0.38, pts.shape) * CELL
tree = cKDTree(pts)

yy, xx = np.mgrid[0:h, 0:w]
q = np.column_stack([(xx.ravel() + 0.5) * PX, (yy.ravel() + 0.5) * PX])
d, idx = tree.query(q, k=2)
edge = (d[:, 1] - d[:, 0]).reshape(h, w)           # about twice the distance to the groove's centre line

# flat tops; a groove with rounded shoulders between pebbles
t = np.clip(edge / GROOVE, 0, 1)
height = np.sin(t * np.pi / 2) ** 0.8
height = ndi.gaussian_filter(height, 0.5)
height = (height - height.min()) / (height.max() - height.min())

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "leather.png")
Image.fromarray((height * 255).astype(np.uint8)).save(out)
print(out, w, "x", h, "px")
