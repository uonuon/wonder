#!/usr/bin/env python
"""More full character looks (batch 2), reference-chained from c_base."""
import os
from gen import gen, RAW
M = "gemini-3-pro-image"
KEY = [os.path.join(RAW, "c_base.png")]
POSE = ("Use the SAME cute chibi character, SAME front-facing standing pose, SAME "
        "proportions and art style as the reference image. Full body, centered, "
        "isolated on a PLAIN PURE WHITE background, generous margin, square 1:1, "
        "crisp edges for cutout. ")

LOOKS = {
    "char_farmer": "A cheerful Egyptian farmer: simple cloth headscarf, plain beige "
        "tunic, holding a small bundle of golden wheat.",
    "char_dancer": "An Egyptian dancer girl: a beaded white dress, a lotus-flower "
        "headband, gold bangles, a graceful happy pose.",
    "char_archer": "An Egyptian soldier-archer: leather kilt, a headband, a quiver on "
        "the back, holding a small bow. Brave.",
    "char_merchant": "A friendly Egyptian merchant: a colorful striped robe, a small "
        "coin pouch on the belt, carrying a little sack of goods.",
    "char_mummy": "A cute friendly cartoon mummy wrapped in cream bandages, one big "
        "eye peeking out, small and adorable (not scary).",
    "char_anubis": "Anubis: a chibi with a sleek BLACK JACKAL head with tall pointed "
        "ears and gold trim, black-and-gold kilt, holding a golden was-scepter. Cool.",
    "char_horus": "Horus: a chibi with a noble FALCON head (white and grey, sharp "
        "eyes), a blue-and-gold kilt and broad collar. Regal.",
    "char_ra": "Ra the sun god: a radiant golden chibi king with a sun-disc crown "
        "encircled by a cobra, glowing warm aura, golden regalia. Divine.",
}

def main():
    for name, desc in LOOKS.items():
        gen(POSE + desc, name + ".png", refs=KEY, model=M)
    print("done batch 2")

if __name__ == "__main__":
    main()
