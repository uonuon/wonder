#!/usr/bin/env python
"""Generate the full Tarkeez art set with character/scene consistency.

Strategy: make ONE style-key camel + ONE base oasis, then chain them as
reference images so every stage and skin stays on-model. Run once billing is
enabled on the Gemini key:  python build_all.py [--model gemini-3-pro-image]
"""
import os, sys, time
from gen import gen, RAW

MODEL = "gemini-3-pro-image"
if "--model" in sys.argv:
    MODEL = sys.argv[sys.argv.index("--model") + 1]

SPRITE = ("Full body, centered, isolated subject on a PLAIN FLAT PURE WHITE "
          "background (#ffffff) with generous empty margin, no shadow on the "
          "ground, no props, square 1:1, crisp edges for easy cutout. ")

def R(name): return os.path.join(RAW, name)

def main():
    # 1) style-key camel — the canonical adult Sahari camel
    gen(SPRITE + "A friendly adult Arabian dromedary camel (single hump), cute "
        "rounded chibi-but-elegant proportions, warm tan fur, long eyelashes, "
        "calm happy expression, a simple terracotta-and-gold woven saddle "
        "blanket on its back, standing in profile facing right.",
        "camel_adult.png", model=MODEL)
    key = [R("camel_adult.png")]

    # 2) camel growth stages, kept on-model via the style key
    stages = {
        "camel_s0.png": "the SAME camel but as a tiny baby calf, extra chibi, "
            "bigger head and eyes, stubby legs, small hump, sitting cutely.",
        "camel_s1.png": "the SAME camel as a young juvenile, slightly small, "
            "playful, standing.",
        "camel_s2.png": "the SAME adult camel, standing proud.",
        "camel_s3.png": "the SAME camel as a majestic elder, slightly larger, "
            "richer decorated saddle with small gold tassels, regal calm pose.",
    }
    for out, p in stages.items():
        gen(SPRITE + p + " Match the art style, colors and character design of "
            "the reference image exactly.", out, refs=key, model=MODEL)

    # 3) camel skins (recolors of the adult, on-model)
    skins = {
        "skin_rose.png": "Recolor: soft cream fur with a rose-pink and white "
            "floral saddle blanket.",
        "skin_bedouin.png": "Recolor: warm tan fur with a dark brown and beige "
            "geometric Bedouin woven blanket.",
        "skin_snow.png": "Recolor: fluffy white/cream winter fur with a "
            "sky-blue saddle, tiny snow sparkle.",
        "skin_royal.png": "Recolor: golden fur with a deep royal-crimson and "
            "gold-embroidered luxurious Gulf saddle, small jewels.",
        "skin_midnight.png": "Recolor: dusky blue-grey starry fur with a deep "
            "indigo saddle and faint glowing constellations.",
    }
    for out, p in skins.items():
        gen(SPRITE + "The SAME adult camel character and pose. " + p +
            " Keep identical shape and style to the reference.",
            out, refs=key, model=MODEL)

    # 4) base oasis background (defines camera + composition for all stages)
    gen("A wide mobile-game background of an empty Arabian desert at warm "
        "afternoon: smooth rolling sand dunes, soft hazy sky, gentle gradient, "
        "lots of open foreground sand where a character will stand, NO "
        "characters, NO text, calm cozy painterly style, horizontal composition.",
        "bg_s0.png", model=MODEL)
    bg_key = [R("bg_s0.png")]

    # 5) growth-stage backgrounds — same camera, progressively a lush oasis
    bgs = {
        "bg_s1.png": "Add one tiny green sprout and a small cactus on the sand.",
        "bg_s2.png": "Add a single young date palm tree on the left and a little "
            "more grass.",
        "bg_s3.png": "Add a small turquoise oasis pond in the middle background "
            "with gentle reflections.",
        "bg_s4.png": "A blooming oasis: the pond is bigger, more date palms, "
            "patches of green grass and small desert wildflowers.",
        "bg_s5.png": "Add a cozy striped Bedouin tent and a small campfire "
            "beside the oasis.",
        "bg_s6.png": "A lively oasis camp with several palms, hanging lanterns, "
            "and a small caravan path.",
        "bg_s7.png": "A lush thriving oasis village at warm dusk: many palms, a "
            "big pond, glowing lanterns strung between trees, flowers everywhere, "
            "magical cozy atmosphere.",
    }
    for out, p in bgs.items():
        gen("Same desert scene, same camera angle and horizon as the reference "
            "background. " + p + " Still NO characters and NO text. Keep the "
            "open foreground sand clear for a character.",
            out, refs=bg_key, model=MODEL)

    # 6) app icon + small props
    gen(SPRITE + "App icon: a cute Arabian camel head with a date palm and a "
        "small sun, inside a rounded-square emblem, warm desert colors, flat, "
        "no text.", "icon_raw.png", model=MODEL)
    gen(SPRITE + "A single glossy turquoise water droplet game currency icon.",
        "drop.png", model=MODEL)

    print("\nDONE. Raw art in art_raw/. Next: python cut.py to key-out sprites.")

if __name__ == "__main__":
    main()
