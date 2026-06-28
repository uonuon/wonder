# Agent guide — Tarkeez (Build-a-Wonder focus app)

## ⚠️ Expo HAS CHANGED — version discipline
This project targets **Expo SDK 56**. Read the exact versioned docs at
https://docs.expo.dev/versions/v56.0.0/ before writing any code. Do not assume older Expo APIs.
SDK 56 is newer than store Expo Go — phone testing needs a **dev build** (`npx expo run:ios` /
`run:android`), not Expo Go. Web (`npm run web`) needs nothing.

## What this is
Arabic-first focus app: focus → raise an Egyptian wonder stone by stone (1 stone / 5 min).
RN + Expo + TS. See `README.md` for the full picture, structure, and dev tooling.

## Where things live
- Logic & state: `src/lib/` (`store.ts` zustand+persist, `wonders.ts` build math, `i18n.ts`,
  `catalog.ts`, `assets.ts` require-map + baked `DIM`, `theme.ts`).
- Screens: `src/app/` (expo-router). Components: `src/components/`.
- Art: `assets/game/` (94 PNGs). Generated icons: `assets/images/` via `scripts/make-icon.mjs`.

## Conventions / gotchas (don't relearn these)
- `@/` alias → `src/`. TypeScript strict; keep `npm run typecheck` clean.
- **No Skia** in the build scene — it's pure RN `<Image>` layers (Skia broke on web). Don't reintroduce it.
- Add new art's `[w,h]` to the `DIM` map in `lib/assets.ts` (web has no `resolveAssetSource`).
- Keep `react-native-worklets/plugin` in `babel.config.js` (Reanimated 4).
- Home route is `(tabs)/home.tsx`, not `index` (root `index.tsx` is the gate).
- Match surrounding code style: terse, inline styles, single-line components are intentional.

## Self-verify visually
Run `npm run web`, then `scripts/shot.mjs` (Playwright) to screenshot routes and Read the PNGs.
Override the port with `SHOT_BASE` if web isn't on 8081.
