# Godot prototype (archived) — the original Tarkeez

This folder is the **original prototype** of Tarkeez, built in **Godot 4.7**. It is now
**superseded by the React Native app at the repository root**, but is kept because:

- It is the **design + logic reference** for the RN port (state machine, growth/economy,
  i18n/RTL, the Build-a-Wonder mechanic were all worked out here first).
- It contains the **art-generation pipeline** (`art_gen/`) that produced every PNG the RN
  app uses.

> You pivoted from Godot to React Native (you're an RN expert; native polish + notifications
> + IAP + your toolchain). The live app to develop is at the repo root — treat this folder as
> read-only history.

## What's here
- `*.gd` + `lib/` + `screens/` — GDScript source (autoloads: `AppState`, `Loc`, `Audio`,
  `Notify`; screens: Home/Stats/Shop/Settings/Onboarding + `World`/`FocusView`).
- `Main.tscn`, `project.godot`, `export_presets.cfg` — Godot project files.
- `PLAN.md`, `README.md`, `ANDROID.md` — the prototype's own design notes & Android export guide.
- `PLAY*.bat`, `BUILD_APK.bat` — Windows launchers (paths are Windows-specific).
- `art_gen/` — the **Gemini image-generation pipeline** (see below).

## What was intentionally NOT committed (regenerable / secret / large)
Grab these from the original Windows machine (`C:\Users\pc\tarkeez`) if ever needed:
- `assets/` (~16 MB) — the binary art. **The final cut PNGs already live in the RN app at
  `../assets/game/`**, so they're not duplicated here.
- `art_raw/` (~32 MB) — raw, pre-cut Gemini outputs (intermediate; re-cuttable with `art_gen/cut.py`).
- `build/` (~33 MB) — exported APKs.
- `.godot/` — Godot's import cache (regenerated on first open).
- `_shots/` — prototype screenshots.
- `art_gen/.key` — **the Gemini API key** (secret; never committed). `*.key` is gitignored.

## Art-generation pipeline (`art_gen/`)
Python scripts that call **Gemini `gemini-3-pro-image`** (needs a *billed* key) to generate art,
then border-flood-fill the white background to transparent and autocrop. Roughly:
- `gen.py` — core request helper. Reads the API key from `art_gen/.key` (you must create this
  file yourself: a single line with your Gemini key).
- `build_*.py` — batch generators (`build_chars*`, `build_wardrobe`, `build_wonders`,
  `build_decor`, `build_env`, `build_icons`, `build_extra`, `build_all`).
- `cut.py` — background removal (white-key flood-fill → transparent) + autocrop.
- `critique.py` — sends a screenshot to Gemini for a UI critique (used to iterate on design).

To regenerate or extend the art on your Mac:
```bash
cd prototype-godot/art_gen
echo "YOUR_GEMINI_API_KEY" > .key   # billed key; .key is gitignored
python3 build_wonders.py            # or any build_*.py
python3 cut.py                      # remove backgrounds + crop
```

## Running the prototype (optional, Windows-only as written)
Install Godot 4.7, restore `assets/` from the original machine, open `project.godot`.
The `.bat` launchers hardcode the Windows project path; on macOS run from the Godot editor
or `godot --path . res://Main.tscn`. This is reference only — the RN app is the product.
