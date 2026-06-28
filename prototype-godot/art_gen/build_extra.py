#!/usr/bin/env python
"""Extra stone types + fun cultural chibi characters (homages, not exact likeness)."""
import os
from gen import gen, RAW
M = "gemini-3-pro-image"
KEY = [os.path.join(RAW, "c_base.png")]
SP = ("Single object centered, isolated on PLAIN PURE WHITE background, generous margin, "
      "square 1:1, crisp edges, storybook mobile-game style. ")
POSE = ("Use the SAME cute chibi proportions, SAME front-facing standing pose and art style "
        "as the reference. Full body, centered, isolated on PLAIN PURE WHITE background, "
        "square 1:1, crisp edges. ")

def main():
    # alternate building stones (same shape/style as p_stone, different stone)
    gen(SP + "a single rounded ancient-Egyptian building block of WHITE polished limestone, "
        "cool white-grey, soft top highlight, gentle shadow, flat 3/4 view so it stacks.",
        "p_stone_white.png", model=M)
    gen(SP + "a single rounded ancient-Egyptian building block of RED granite, warm "
        "reddish-brown speckled stone, soft top highlight, flat 3/4 view so it stacks.",
        "p_stone_red.png", model=M)
    gen(SP + "a single rounded ancient-Egyptian building block of DARK basalt, charcoal "
        "grey-black stone with subtle sparkle, soft top highlight, flat 3/4 view so it stacks.",
        "p_stone_dark.png", model=M)

    # fun cultural chibi characters (cute homages, NOT photoreal likeness)
    fun = {
        "char_footballer": "a cheerful chibi Egyptian football superstar: a RED team "
            "jersey with white number 10, curly dark hair and a short beard, football boots, "
            "joyfully holding a soccer ball.",
        "char_comedian": "a goofy lovable chibi Egyptian comedy guy: messy short hair, a "
            "plain white sleeveless undershirt and casual trousers, a big silly cheeky grin, "
            "very expressive and funny.",
        "char_diva": "a glamorous chibi classic Egyptian singing diva: elegant dark updo, "
            "big retro sunglasses, a flowing emerald evening gown, holding a microphone.",
        "char_star": "a charming chibi golden-age Egyptian cinema star: a sharp black suit "
            "with a bow tie and a red tarboosh (fez), a confident smile.",
    }
    for name, desc in fun.items():
        gen(POSE + desc, name + ".png", refs=KEY, model=M)
    print("done extras")

if __name__ == "__main__":
    main()
