// Screenshot Expo-web screens with Playwright. Seeds the zustand store so the
// tabs render, then captures each route.  usage: node scripts/shot.mjs <route> <out>
import { chromium } from 'playwright';

// Expo web port varies (8081/8082/...). Override with SHOT_BASE if needed:
//   SHOT_BASE=http://localhost:8082 node scripts/shot.mjs home shots/home.png
const BASE = process.env.SHOT_BASE ?? 'http://localhost:8081';
const route = process.argv[2] ?? 'onboarding';
const out = process.argv[3] ?? `shots/${route.replace(/\//g, '_') || 'home'}.png`;

const seed = {
  state: {
    totalFocusSec: 9 * 3600, todayFocusSec: 35 * 60, sessionsTotal: 40, streak: 4, bestStreak: 7,
    coins: 9000, lastDay: '', history: {},
    onboarded: true, builderName: 'Imhotep', dailyGoalMin: 60,
    equippedCharacter: 'royal',
    ownedCharacters: ['pharaoh', 'builder', 'royal', 'queen', 'anubis', 'footballer'],
    equippedScene: 'auto', ownedScenes: ['auto', 'giza', 'sunset'],
    plus: true, lang: 'en', soundOn: true, notificationsOn: true, hapticsOn: true,
  },
  version: 0,
};

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 2 });
page.on('console', (m) => { if (m.type() === 'error') console.log('PAGE ERR:', m.text().slice(0, 200)); });
page.on('pageerror', (e) => console.log('PAGE EXC:', String(e).slice(0, 300)));

// preload localStorage before the app boots
await page.addInitScript((s) => { localStorage.setItem('tarkeez-store', s); }, JSON.stringify(seed));

await page.goto(`${BASE}/${route}`, { waitUntil: 'load', timeout: 120000 });
await page.waitForTimeout(5000); // let Metro bundle + animations settle
await page.screenshot({ path: out });
console.log('shot saved:', out);
await browser.close();
