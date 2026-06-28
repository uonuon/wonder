#!/usr/bin/env python
"""Layered-world art: one barren base desert + transparent decor sprites.

This is what powers the *growth*: World reveals more decor each stage on a
fixed ground line, so barren dune -> lush oasis reads clearly and the camel
always sits correctly. Run after build_all.py:
    python build_decor.py [--model gemini-3-pro-image]
"""
import os, sys
from gen import gen, RAW

MODEL = "gemini-3-pro-image"
if "--model" in sys.argv:
    MODEL = sys.argv[sys.argv.index("--model") + 1]

SPRITE = ("Full object, centered, isolated on a PLAIN FLAT PURE WHITE "
          "background (#ffffff), generous empty margin, no ground shadow, no "
          "extra props, crisp clean edges for cutout, square 1:1. ")

def main():
    # base barren desert (the canvas every stage builds on)
    gen("A wide mobile-game background of a BARREN empty Arabian desert at warm "
        "afternoon: smooth rolling sand dunes, soft hazy warm sky with a gentle "
        "gradient, a large clear open foreground of sand. Absolutely NO plants, "
        "NO trees, NO water, NO buildings, NO animals, NO people, NO text. Calm, "
        "minimal, painterly, horizontal composition.",
        "bg_desert.png", model=MODEL, tries=4)

    # transparent decor sprites, all in the same storybook style
    decor = {
        "d_palm.png": "a single tall lush date palm tree with green fronds and "
            "ripe date clusters, slight graceful curve to the trunk.",
        "d_palm_small.png": "a small young date palm sapling, a few fronds.",
        "d_pond.png": "a small oval turquoise oasis water pond seen at a low "
            "3/4 angle, soft light reflections, a thin sandy and grassy rim.",
        "d_tent.png": "a cozy Bedouin desert tent with terracotta-and-cream "
            "stripes and an open dark entrance, small flag on top.",
        "d_house.png": "a small sandstone domed desert house with an arched "
            "wooden door, warm beige walls.",
        "d_arch.png": "an ancient weathered sandstone archway ruin.",
        "d_fire.png": "a small warm campfire: a few logs and gentle orange "
            "flames, soft glow.",
        "d_bush.png": "a small round leafy green desert shrub.",
        "d_flowers.png": "a small cluster of colorful desert wildflowers (pink, "
            "gold, teal) with green leaves.",
        "d_lantern.png": "an ornate golden Arabian hanging lantern (fanous) "
            "glowing with warm light.",
        "d_cactus.png": "a small round green barrel cactus with two arms and "
            "tiny pink flowers.",
        "d_sprout.png": "a tiny fresh green sprout seedling with two little "
            "leaves poking from a small mound of sand.",
        "d_grass.png": "a small tuft of green desert grass.",
        "d_rock.png": "two smooth rounded sandstone desert rocks.",
    }
    for out, p in decor.items():
        gen(SPRITE + p, out, model=MODEL, tries=4)

    print("\nDONE decor. Next: python cut.py")

if __name__ == "__main__":
    main()
