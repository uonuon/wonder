# Tarkeez (تركيز) — focus & grow an oasis

An Arabic-first focus/productivity app. You start a focus session and a **baby
camel + a desert oasis grow** as you stay in the app; leave mid-session and the
focus "breaks." Cozy, premium, Forest/Finch-class, with a Middle-East / Gulf
identity as the differentiator.

Engine: **Godot 4.7**. **Landscape 960×540** with a persistent left control rail
(timer/presets/Start on Home + nav icons); the oasis scene fills the right.
Mobile (Android/iOS) export-ready — see `ANDROID.md`.

**Just play it:** double-click `PLAY.bat` (fresh), `PLAY_DEMO.bat` (pre-grown),
or `PLAY_TEST.bat` (fast mode — sessions run in seconds + a "+session" button).

## Run / test
```bash
GODOT=".../Godot_v4.7-stable_win64_console.exe"

# headless logic tests (must print: LOGICTEST RESULT: ALL PASS)
"$GODOT" --headless --path . res://Main.tscn --logictest --noob --quit-after 30

# import assets after adding art/fonts
"$GODOT" --headless --path . --import

# capture screenshots of each screen (writes _shots/*.png, 960x540)
"$GODOT" --path . res://Main.tscn --demo --day --stage=7 --shot=home,stats,shop,settings,onboarding,paywall,celebration --quit-after 340
```
Useful flags: `--demo` seeds nice data, `--stage=N` jumps the world to stage N,
`--lang=ar` Arabic, `--coins=N`, `--noob` skip onboarding, `--day`/`--night`,
`--theme=<id>`, `--skin=<id>`, `--fast` (sessions in seconds + +session button).

## Architecture
| File | Role |
|---|---|
| `AppState.gd` (autoload) | persistence, growth, streaks, economy, unlocks, history, settings |
| `Loc.gd` (autoload) | EN/AR strings, RTL, Cairo font, Arabic-Indic numerals |
| `Audio.gd` (autoload) | procedural ambient pad + chimes (no audio files) |
| `lib/Catalog.gd` | growth stages, camel skins, oasis themes (shared data) |
| `lib/Art.gd` | procedural vector art (fallback when no AI art present) |
| `lib/Assets.gd` | loads generated raster art from `assets/gen/`, falls back to Art |
| `lib/UI.gd` | shared draw helpers + styled buttons |
| `screens/World.gd` | the living oasis (bg + camel + day/night + animation) |
| `screens/*Screen.gd` | Home, Stats, Shop, Settings, Onboarding |
| `Main.gd` | router, bottom nav, onboarding, screenshot + test harness |

## Growth system
World has 9 stages (barren dune → grand oasis) keyed to total completed sessions
(`Catalog.STAGE_THRESHOLDS`). The camel grows across 4 stages. Each session banks
permanent growth + "water drops" currency, recorded per day for the heatmap.

## Art pipeline (Gemini)
High-end art is AI-generated and dropped into `assets/gen/`; the engine uses it
automatically (else procedural fallback).
```bash
cd art_gen
echo "<BILLED_GEMINI_KEY>" > .key           # needs billing enabled (image gen)
python build_all.py --model gemini-3-pro-image   # reference-chained, resumable
python cut.py                                # white-key sprites → assets/gen/
python critique.py ../_shots/home.png "home screen"   # Gemini design review
```
`build_all.py` makes one style-key camel + base oasis, then chains them as
reference images so every stage/skin/background stays on-model.

## Store / monetization (later — needs the user's accounts)
- Free core + **Tarkeez+** subscription: premium skins/themes (flagged
  `premium` in `Catalog.gd`), insights, cloud sync, soundscapes.
- Targets: Gulf (Saudi/UAE) + Arab diaspora + global.
- Submission needs Apple ($99/yr) + Google Play ($25) accounts, real-device
  testing, and store review — out of scope for the build sprint.
