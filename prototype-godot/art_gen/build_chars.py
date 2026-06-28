#!/usr/bin/env python
"""Full character looks — each a COMPLETE, well-fitted chibi character in one
image (no fragile layering). Reference-chained from c_base for a consistent
pose & style. The Wardrobe picks a whole look."""
import os, sys
from gen import gen, RAW
M = "gemini-3-pro-image"
KEY = [os.path.join(RAW, "c_base.png")]
POSE = ("Use the SAME cute chibi character, SAME front-facing standing pose, SAME "
        "proportions and art style as the reference image. Full body, centered, "
        "isolated on a PLAIN PURE WHITE background, generous margin, square 1:1, "
        "crisp edges for cutout. ")

LOOKS = {
    "char_pharaoh": "A young pharaoh: blue-and-gold Nemes headdress with a cobra, "
        "white linen kilt, a simple broad gold collar. Cheerful.",
    "char_builder": "A little desert builder/worker: simple woven straw cap, plain "
        "linen kilt, a small tool belt. Friendly.",
    "char_scribe": "A scribe: short black wig, a white linen robe over one shoulder, "
        "holding a small papyrus scroll. Calm and clever.",
    "char_priest": "A high priest: shaved head, a leopard-skin sash over a white robe, "
        "holding a tall staff. Dignified.",
    "char_warrior": "A warrior pharaoh: blue Khepresh war crown, leather-and-gold "
        "armor over a kilt. Brave.",
    "char_royal": "A golden royal pharaoh: ornate Nemes, a red royal cape with gold "
        "trim, holding the crook and flail, lots of gold jewelry. Majestic.",
    "char_queen": "An Egyptian queen (Cleopatra style): black bob wig with a gold "
        "vulture crown, white pleated dress, broad jeweled collar. Elegant.",
    "char_nubian": "A Nubian prince: short curly hair with a beaded gold headband, "
        "colorful patterned sash, gold arm bands. Vibrant.",
}

def main():
    for name, desc in LOOKS.items():
        gen(POSE + desc, name + ".png", refs=KEY, model=M)
    print("done character looks")

if __name__ == "__main__":
    main()
