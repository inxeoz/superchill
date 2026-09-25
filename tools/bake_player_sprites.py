#!/usr/bin/env python3
"""Bake the Tiny Questers player sprites into the procedural GDScript const.

Reads the 64x64 PNGs under assets/player/isometric/ (4 facings x 4 walk
frames + one sword per facing), extracts a shared colour palette and the
content grid of every frame, and prints the `PLAYER_PIXELS` const plus the
`PLAYER_PIXELS_CHARS` line that faceted_depths.gd uses to draw the player
procedurally (no runtime PNG load).

Usage:
    python3 tools/bake_player_sprites.py > player_art.txt
    # then replace the PLAYER_PIXELS const in faceted_depths.gd with the output.

Requires: Pillow, numpy.
"""
from PIL import Image
import numpy as np
import os

BASE = os.path.join(os.path.dirname(__file__), "..", "assets", "player", "isometric")
PIXEL_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
FACES = ["ne", "se", "sw", "nw"]


def rgba(path):
    return np.array(Image.open(os.path.join(BASE, path)).convert("RGBA"))


def collect(path):
    a = rgba(path)
    for c in np.unique(a[a[..., 3] > 0][:, :3], axis=0):
        allcols.add(tuple(int(x) for x in c))


allcols = set()
for face in FACES:
    for i in range(1, 5):
        collect(f"{face}/{face}{i}.png")
for face in FACES:
    collect(f"sword_{face}.png")
palette = sorted(allcols)
index = {c: i for i, c in enumerate(palette)}
assert len(palette) <= len(PIXEL_CHARS), len(palette)


def grid(path):
    a = rgba(path)
    alpha = a[..., 3]
    ys, xs = np.nonzero(alpha > 0)
    x0, y0, x1, y1 = int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1
    rows = []
    for r in range(y0, y1):
        row = ""
        for c in range(x0, x1):
            if alpha[r, c] == 0:
                row += "."
            else:
                row += PIXEL_CHARS[index[tuple(int(v) for v in a[r, c][:3])]]
        rows.append(row)
    return x0, y0, rows


out = []
out.append('const PLAYER_PIXELS := {')
out.append('	"palette": [' + ", ".join('Color("%02x%02x%02x")' % c for c in palette) + '],')
for face in FACES:
    out.append(f'\t"{face}": [')
    for i in range(1, 5):
        x0, y0, rows = grid(f"{face}/{face}{i}.png")
        out.append(f'\t\t{{"ox": {x0}, "oy": {y0}, "rows": [')
        for row in rows:
            out.append(f'\t\t\t"{row}",')
        out.append("\t\t]},")
    out.append("\t],")
for face in FACES:
    x0, y0, rows = grid(f"sword_{face}.png")
    out.append(f'\t"sword_{face}": {{"ox": {x0}, "oy": {y0}, "rows": [')
    for row in rows:
        out.append(f'\t\t"{row}",')
    out.append("\t]},")
out.append("}")
print('const PLAYER_PIXELS_CHARS := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"')
print("\n".join(out))
