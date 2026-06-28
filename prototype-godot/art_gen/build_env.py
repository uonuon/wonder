#!/usr/bin/env python
"""More environments — painted building-site backgrounds (cover-fit + tinted by
the engine). Each gives a distinct biome as you advance through wonders."""
from gen import gen
M = "gemini-3-pro-image"
BG = ("A wide painterly mobile-game BACKGROUND, lots of clear flat foreground to "
      "build on, NO pyramid/structure built yet, NO text, cozy storybook style. ")
ENVS = {
    "bg_giza_sunset": "the Giza desert at golden SUNSET, warm orange-pink sky, long "
        "shadows on the dunes, a faint distant town silhouette.",
    "bg_giza_night": "the Giza desert at NIGHT under a starry sky and a big moon, cool "
        "blue tones, a few warm lantern lights in a distant town.",
    "bg_nile": "a lush Nile riverside building site at warm afternoon: blue river, "
        "green reeds and date palms along the bank, sandy foreground.",
    "bg_temple": "a grand Karnak-style temple courtyard building site: huge carved "
        "sandstone columns along the sides, warm sun, open sandy foreground.",
}

def main():
    for name, desc in ENVS.items():
        gen(BG + desc, name + ".png", model=M)
    print("done environments")

if __name__ == "__main__":
    main()
