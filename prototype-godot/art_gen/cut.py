#!/usr/bin/env python
"""Post-process raw Gemini art into game-ready assets in assets/gen/.

- Sprites (camel_*, skin_*, drop, icon_raw): key out the white background to
  transparency, autocrop, and downscale to a sane size.
- Backgrounds (bg_*): just resize/center-crop to the scene aspect, no keying.
"""
import os, glob
from PIL import Image, ImageFilter, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "art_raw")
OUT = os.path.join(HERE, "..", "assets", "gen")
os.makedirs(OUT, exist_ok=True)

KEY = (255, 0, 255)     # sentinel color flooded into the background
FLOOD_THRESH = 56       # tolerance for "white-ish" while flood filling
EDGE_FEATHER = 1.1

def key_white(im):
    """Remove ONLY the white background connected to the image border, so
    interior near-white areas (snow fur, water glints, white petals) stay."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    seeds = []
    step = max(1, w // 16)
    for x in range(0, w, step):
        seeds += [(x, 0), (x, h - 1)]
    for y in range(0, h, step):
        seeds += [(0, y), (w - 1, y)]
    for s in seeds:
        if sum(rgb.getpixel(s)) > 3 * 200:        # only flood from white-ish edge
            ImageDraw.floodfill(rgb, s, KEY, thresh=FLOOD_THRESH)
    src = im.convert("RGBA")
    out = Image.new("RGBA", (w, h))
    sp = src.load(); rp = rgb.load(); op = out.load()
    for y in range(h):
        for x in range(w):
            if rp[x, y] == KEY:
                op[x, y] = (0, 0, 0, 0)
            else:
                op[x, y] = sp[x, y]
    alpha = out.split()[3].filter(ImageFilter.GaussianBlur(EDGE_FEATHER))
    out.putalpha(alpha)
    return out

def autocrop(im, pad=8):
    bbox = im.split()[3].getbbox()
    if not bbox:
        return im
    l, t, r, b = bbox
    l = max(0, l - pad); t = max(0, t - pad)
    r = min(im.size[0], r + pad); b = min(im.size[1], b + pad)
    return im.crop((l, t, r, b))

def fit(im, maxdim):
    w, h = im.size
    s = maxdim / max(w, h)
    if s < 1:
        im = im.resize((int(w * s), int(h * s)), Image.LANCZOS)
    return im

# hats that wrap the head have a baked-in dark interior hole — flood it out
HEAD_HOLE = {"w_nemes", "w_khepresh", "w_wig"}

def key_interior(im):
    """Remove the contiguous dark interior region (the head-hole) so the face
    shows through when the hat is layered."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    seeds = [(w // 2, int(h * 0.5)), (w // 2, int(h * 0.6)), (w // 2, int(h * 0.68)),
             (int(w * 0.42), int(h * 0.6)), (int(w * 0.58), int(h * 0.6))]
    hit = False
    for s in seeds:
        r, g, b = rgb.getpixel(s)
        if r + g + b < 360:                     # dark-ish -> it's the hole
            ImageDraw.floodfill(rgb, s, KEY, thresh=72)
            hit = True
    if not hit:
        return im
    src = im.convert("RGBA"); rp = rgb.load(); sp = src.load()
    for y in range(h):
        for x in range(w):
            if rp[x, y] == KEY:
                sp[x, y] = (0, 0, 0, 0)
    return src

def whiten(im):
    """Recolor all opaque pixels to white (keep alpha) so the engine can tint
    the silhouette to any color via modulate."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            a = px[x, y][3]
            if a > 0:
                px[x, y] = (255, 255, 255, a)
    return im

def do_sprite(path, maxdim=420):
    name = os.path.splitext(os.path.basename(path))[0]
    im = key_white(Image.open(path))
    im = autocrop(im)
    im = fit(im, maxdim)
    if name.startswith("ic_"):
        im = whiten(im)
    if name in HEAD_HOLE:
        im = key_interior(im)
    im.save(os.path.join(OUT, name + ".png"))
    print("sprite", name, im.size)

def do_bg(path, size=(1024, 1024)):
    im = Image.open(path).convert("RGBA")
    im = im.resize(size, Image.LANCZOS)
    name = os.path.splitext(os.path.basename(path))[0]
    im.save(os.path.join(OUT, name + ".png"))
    print("bg", name, im.size)

def main():
    for p in sorted(glob.glob(os.path.join(RAW, "*.png"))):
        base = os.path.basename(p)
        # the layered world uses ONE base desert + decor sprites; the chained
        # full-scene bg_s0..bg_s7 paintings are kept as raw refs but not shipped.
        if base.startswith("bg_s") or base.startswith("test_pyramid"):
            continue
        if base in ("bg_desert.png", "bg_giza.png"):
            do_bg(p)
        else:
            do_sprite(p)
    print("\nDONE. Game assets in assets/gen/")

if __name__ == "__main__":
    main()
