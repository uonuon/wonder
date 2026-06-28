# Tarkeez — Production Plan (build blueprint)

**Tarkeez (تركيز, "focus")** — an Arabic-first focus/productivity app. A **camel in the
Sahara** that you **grow into a thriving oasis** as you focus. Forest/Finch category,
but with a unique desert-oasis identity and Arabic/Islamic warmth as the moat.

Engine: **Godot 4.7**, project at `C:\Users\pc\tarkeez\`. Mobile-first (portrait 460x820;
exports to Android/iOS). Validate every change headless before claiming done:
`godot --headless --path <proj> res://Main.tscn --logictest --quit-after 20` → look for ALL PASS.

---

## 1. Core concept & loop
- Companion: a cute **camel** (grows baby → adult across focus milestones).
- World: a **desert that blooms into an oasis** as cumulative focus grows.
- Loop: pick a focus length → stay in the app → camel + oasis grow; leave early → focus
  "breaks" (no growth). Completed sessions bank permanent growth + currency ("water"/coins).
- Retention: visible long-term world progress + streaks + gentle daily nudges.

## 2. The growth system (the heart — design carefully)
World evolves through **stages** keyed to total completed sessions / focus hours:
1. Barren dune (start) — just sand + the baby camel.
2. First sprout + a small cactus.
3. A young palm tree; camel grows.
4. **Oasis pond** appears (water shimmer).
5. Grass, desert flowers, more palms.
6. A **Bedouin tent / camp**, a campfire.
7. A small caravan / second camel; lanterns.
8. Night mode with stars + glowing lanterns; lush oasis village.
- Per session: also "plant" one item (palm/flower) so each session has a tangible result.
- Currency ("water" or coins) earned per focus minute → optional shop to place/buy decor.
- Gentle, non-punishing: long absence may dim the oasis slightly, never destroys it.

## 3. Art (Claude authors as SVG — consistent, scalable, no external deps)
Warm desert palette: sand `#dcc28e`, dune shadow `#c6a96f`, sky day `#f2e8cf`→dusk
`#e8b98a`→night `#2b2a4a`, oasis teal `#3a9a96`, palm green `#4f8a3e`, gold `#e6b34a`,
terracotta tent `#c8623c`, ink `#3a2f28`.
Asset set to build: camel (3–4 growth stages, idle bob/blink), palm tree (sway), cactus,
oasis pond (shimmer), dunes (layered parallax), Bedouin tent, campfire, flowers, lantern,
sun, moon + stars, caravan. Day/night tint over the whole scene.
(User may also drop Gemini art in `assets/`; reuse the cut pipeline from the old game if so.)

## 4. Features for a "well-made app"
- Onboarding / first-run welcome (set a daily goal, name your camel).
- Focus timer: presets + custom; optional **Pomodoro** (focus + break cycles).
- The living oasis scene (animated: camel idle, palm sway, water shimmer, day/night).
- Stats & history: total/today focus, streak, a **calendar heatmap** of focus days.
- Streaks + local **notifications** (come back, keep your streak).
- Settings: sound on/off, theme, **Arabic / English with RTL layout** (key differentiator).
- Ambient sound: calm desert/oud loop + soft chimes on complete (synth or royalty-free).
- Polish: scene-transition fades, particles, squash/stretch, haptics on mobile.

## 5. Monetization (design now, gate later — NOT in MVP)
Free core + **subscription** (Tarkeez+): extra biomes/skins (oasis themes, camel
outfits), detailed insights, cloud sync, custom soundscapes. Target Gulf (Saudi/UAE pay)
+ Arab diaspora + global. One-time "remove-nudges"/unlock packs as alt.

## 6. Build order (autonomous roadmap)
1. **Camel + desert oasis art** (SVG set) + stage-based world rendering — replace the
   placeholder sprout/garden. (Biggest visual win.)
2. Day/night + animations + particles (make the scene feel alive).
3. Stats/history screen + streak calendar.
4. Settings + **Arabic RTL localization**.
5. Ambient sound + SFX.
6. Onboarding + app icon + store screenshots.
7. Monetization scaffolding + Android export.

## 7. Honest scope note
4 hours of Claude work (across turns) can produce a **polished, charming, feature-rich
MVP** (loop + camel/oasis art + animation + stats + settings + Arabic + sound + onboarding).
True "on the store, monetized" also needs the user's accounts (Apple $99/yr, Google $25),
real-device testing, and store review — beyond pure build time. Goal for the sprint:
**near-submission, demoable, genuinely nice.** Flag store/account steps for the user.

## 8. Current state (MVP v0.1 already built)
`Main.gd` + `AppState.gd`: focus timer (presets 1/15/25/50), placeholder sprout buddy
(scales with sessions/3), garden fills per session, streak/coins/today/total stats,
"leave app = focus broken" (NOTIFICATION_APPLICATION_FOCUS_OUT). All logic tests pass.
NEXT: swap the sprout/garden for the **camel + Sahara oasis** per sections 2–3.
