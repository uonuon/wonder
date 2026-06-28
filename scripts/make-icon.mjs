import { chromium } from 'playwright';
import { readFileSync } from 'fs';

// Pull the real pyramid art so the icon matches the in-app wonder
const pyramid = 'data:image/png;base64,' + readFileSync('assets/game/s_great.png').toString('base64');

const icon = (size, bleed) => `<!doctype html><html><body style="margin:0">
<svg width="${size}" height="${size}" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#F6D98A"/>
      <stop offset="0.45" stop-color="#F0C879"/>
      <stop offset="1" stop-color="#E8A85C"/>
    </linearGradient>
    <radialGradient id="sun" cx="0.5" cy="0.42" r="0.42">
      <stop offset="0" stop-color="#FFF3D0"/>
      <stop offset="0.5" stop-color="#FFE39A" stop-opacity="0.9"/>
      <stop offset="1" stop-color="#FFE39A" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#sky)"/>
  <circle cx="512" cy="430" r="360" fill="url(#sun)"/>
  <circle cx="512" cy="430" r="150" fill="#FFF6DC" opacity="0.95"/>
  <!-- desert ground -->
  <path d="M0 760 Q 260 700 512 740 T 1024 760 L1024 1024 L0 1024 Z" fill="#E2B473"/>
  <path d="M0 820 Q 300 770 512 800 T 1024 820 L1024 1024 L0 1024 Z" fill="#D9A862"/>
  <image href="${pyramid}" x="${bleed.x}" y="${bleed.y}" width="${bleed.w}" height="${bleed.h}" preserveAspectRatio="xMidYMax meet"/>
</svg></body></html>`;

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1024, height: 1024 }, deviceScaleFactor: 1 });

// full-bleed app icon
await page.setContent(icon(1024, { x: 232, y: 360, w: 560, h: 425 }));
await page.waitForTimeout(300);
await page.screenshot({ path: 'assets/images/icon.png', clip: { x: 0, y: 0, width: 1024, height: 1024 } });

// android adaptive foreground needs safe padding (subject in center ~66%)
await page.setContent(`<!doctype html><html><body style="margin:0"><svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"><image href="${pyramid}" x="312" y="430" width="400" height="300" preserveAspectRatio="xMidYMax meet"/><circle cx="512" cy="470" r="120" fill="#FFE39A" opacity="0"/></svg></body></html>`);
await page.waitForTimeout(200);
await page.screenshot({ path: 'assets/images/android-icon-foreground.png', clip: { x: 0, y: 0, width: 1024, height: 1024 }, omitBackground: true });

// splash icon (transparent bg, just the pyramid + sun mark)
await page.setContent(`<!doctype html><html><body style="margin:0"><svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="s" cx="0.5" cy="0.45" r="0.5"><stop offset="0" stop-color="#FFF3D0"/><stop offset="1" stop-color="#FFE39A" stop-opacity="0"/></radialGradient></defs><circle cx="256" cy="220" r="180" fill="url(#s)"/><image href="${pyramid}" x="86" y="150" width="340" height="260" preserveAspectRatio="xMidYMax meet"/></svg></body></html>`);
await page.waitForTimeout(200);
await page.screenshot({ path: 'assets/images/splash-icon.png', clip: { x: 0, y: 0, width: 512, height: 512 }, omitBackground: true });

// favicon
await page.setContent(icon(1024, { x: 232, y: 360, w: 560, h: 425 }));
await page.waitForTimeout(200);
await page.screenshot({ path: 'assets/images/favicon.png', clip: { x: 0, y: 0, width: 1024, height: 1024 } });

console.log('icons generated');
await browser.close();
