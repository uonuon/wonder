#!/usr/bin/env python
"""Wardrobe art: a bare base chibi character + layerable cosmetic pieces
(hats, cloth/capes, hand props, sandals). Pieces are isolated for compositing."""
import sys
from gen import gen
M = "gemini-3-pro-image"
SP = ("Single item centered, isolated on a PLAIN PURE WHITE background, generous margin, "
      "square 1:1, crisp clean edges for cutout, cute storybook mobile-game style, "
      "consistent with a chibi ancient-Egyptian character. ")

def main():
    # base body — bare head, plain kilt, barefoot, neutral standing pose
    gen("A cute chibi ancient-Egyptian boy character, BARE HEAD (no hat, short dark hair), "
        "big friendly eyes, plain white linen kilt, barefoot, standing front-facing slightly "
        "3/4 with arms relaxed at the sides, isolated on a PLAIN PURE WHITE background, "
        "storybook mobile-game style, full body centered, square.", "c_base.png", model=M)
    items = {
        # hats (hat only, hollow underside, no head)
        "w_nemes": "an ancient-Egyptian Nemes headdress HAT ONLY (blue and gold stripes, "
            "cobra at front), no head or face, hollow underside, sized to sit on a small round head.",
        "w_crown_white": "the ancient-Egyptian White Crown (Hedjet) hat only, smooth white bowling-pin shape.",
        "w_wig": "a black ancient-Egyptian wig hat only, blunt bob with a gold band.",
        "w_straw": "a simple woven straw worker's cap, hat only.",
        "w_khepresh": "the royal Blue War Crown (Khepresh) hat only, blue with gold studs.",
        # cloth / capes
        "w_cape_red": "a short red royal cape/cloak as worn over shoulders, isolated, gold trim.",
        "w_leopard": "a leopard-skin priest's sash/cape as worn over one shoulder, isolated.",
        # hand props
        "w_ankh": "a golden ancient-Egyptian ankh symbol on a short handle, held upright.",
        "w_crook": "the pharaoh's crook and flail held together, gold and blue.",
        "w_staff": "a simple wooden walking staff topped with a small gold sun disc.",
        # feet
        "w_sandals": "a pair of simple brown ancient-Egyptian leather sandals, side by side.",
        "w_sandals_gold": "a pair of ornate golden ancient-Egyptian sandals, side by side.",
    }
    for name, p in items.items():
        gen(SP + p, name + ".png", model=M)
    print("done wardrobe art")

if __name__ == "__main__":
    main()
