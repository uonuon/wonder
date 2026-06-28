#!/usr/bin/env python
"""3D wonder structures (one polished image per wonder). The engine reveals each
from the ground up as stones are placed, so it looks like a real 3D pyramid
rising — not a flat triangle of blocks. Isolated for overlay on the scene bg."""
from gen import gen
M = "gemini-3-pro-image"
SP = ("A single 3D structure, slight 3/4 view showing depth (a sunlit face and a "
      "shaded face), grounded flat at the bottom, isolated on a PLAIN PURE WHITE "
      "background, generous margin, square 1:1, crisp clean edges for cutout, warm "
      "cozy storybook mobile-game style, no people, no text. ")

STRUCTS = {
    "s_great": "the Great Pyramid of Giza in smooth pale limestone with a small gold "
        "capstone, clean blocky courses, monumental.",
    "s_djoser": "the Step Pyramid of Djoser — six receding sandstone tiers, stepped.",
    "s_red": "the Red Pyramid — a smooth pyramid of warm reddish-brown granite with a "
        "gold capstone.",
    "s_obelisk": "a tall slender Egyptian obelisk of dark polished granite carved with "
        "hieroglyphs, topped by a gold pyramidion.",
    "s_pylon": "an Egyptian temple Pylon gateway — two tall trapezoidal sandstone towers "
        "flanking a central doorway, carved reliefs.",
    "s_ziggurat": "a grand Mesopotamian-style ziggurat — wide square stepped tiers of "
        "tan mudbrick with a central stairway.",
    "s_giza": "the three Giza pyramids together in pale limestone, one large and two "
        "smaller, golden capstones.",
    "s_grand": "three towering golden pyramids of polished limestone with gleaming gold "
        "capstones, grand and majestic.",
}

def main():
    for name, desc in STRUCTS.items():
        gen(SP + desc, name + ".png", model=M)
    print("done wonder structures")

if __name__ == "__main__":
    main()
