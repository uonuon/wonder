import { chromium } from 'playwright';
const BASE = process.env.SHOT_BASE ?? 'http://localhost:8081';
const route = process.argv[2] ?? 'home';
const out = process.argv[3] ?? 'shots/ar.png';
const seed = { state: {
  totalFocusSec: 32400, todayFocusSec: 2100, sessionsTotal: 40, streak: 4, bestStreak: 7,
  coins: 9000, lastDay: '', history: {}, onboarded: true, builderName: 'إمحوتب', dailyGoalMin: 60,
  equippedCharacter: 'royal', ownedCharacters: ['pharaoh','builder','royal','queen'],
  equippedScene: 'auto', ownedScenes: ['auto','giza'],
  plus: true, lang: 'ar', soundOn: true, notificationsOn: true, hapticsOn: true,
}, version: 0 };
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 2 });
page.on('pageerror', (e) => console.log('PAGE EXC:', String(e).slice(0,300)));
await page.addInitScript((s) => { localStorage.setItem('tarkeez-store', s); }, JSON.stringify(seed));
await page.goto(`${BASE}/${route}`, { waitUntil: 'load', timeout: 120000 });
await page.waitForTimeout(5000);
await page.screenshot({ path: out });
console.log('saved', out);
await browser.close();
