import { chromium } from 'playwright';
const BASE = process.env.SHOT_BASE ?? 'http://localhost:8081';
const seed = { state: {
  totalFocusSec: 4200, todayFocusSec: 0, sessionsTotal: 14, streak: 4, bestStreak: 7,
  coins: 9000, lastDay: '', history: {}, onboarded: true, builderName: 'Imhotep', dailyGoalMin: 60,
  equippedCharacter: 'royal', ownedCharacters: ['pharaoh','builder','royal'],
  equippedScene: 'auto', ownedScenes: ['auto','giza'],
  plus: true, lang: 'en', soundOn: true, notificationsOn: true, hapticsOn: true,
}, version: 0 };
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 2 });
page.on('pageerror', (e) => console.log('PAGE EXC:', String(e).slice(0,300)));
await page.addInitScript((s) => { localStorage.setItem('tarkeez-store', s); }, JSON.stringify(seed));
await page.goto(`${BASE}/focus?min=25&pomo=0`, { waitUntil: 'load', timeout: 120000 });
await page.waitForTimeout(5000);
await page.screenshot({ path: 'shots/focus-build.png' });
console.log('saved focus-build.png');
await browser.close();
