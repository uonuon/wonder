#!/usr/bin/env python
"""Tintable silhouette icons for nav + UI. Dark single-color shapes on white so
the engine can tint them per state. Run: python build_icons.py"""
import sys
from gen import gen

MODEL = "gemini-3-pro-image"
if "--model" in sys.argv:
    MODEL = sys.argv[sys.argv.index("--model") + 1]

SIL = ("A minimal flat ICON: a SOLID single-color dark charcoal-brown (#3a2f28) "
       "silhouette of {subj}, bold friendly simple shape, no gradient, no outline, "
       "no shading, no text, centered, isolated on a PLAIN PURE WHITE background "
       "with generous margin, square 1:1.")

ICONS = {
    "ic_home": "a cozy Bedouin desert tent",
    "ic_stats": "three rising bars with a small leaf sprouting on top",
    "ic_shop": "a simple woven market basket / shopping bag",
    "ic_settings": "a single rounded gear cog",
    "ic_bell": "a small notification bell",
    "ic_crown": "a small five-point royal crown",
    "ic_lock": "a small padlock",
    "ic_flame": "a small flame (for streaks)",
    "ic_trophy": "a small trophy cup (for achievements)",
    "ic_moon": "an Islamic crescent moon with a small star",
}

def main():
    for name, subj in ICONS.items():
        gen(SIL.format(subj=subj), name + ".png", model=MODEL, tries=4)
    print("\nDONE icons.")

if __name__ == "__main__":
    main()
