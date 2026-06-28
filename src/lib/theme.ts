// Focus-Friend-inspired palette: sky-blue world, white clouds, cream "sticker"
// cards/buttons with thick hand-drawn maroon outlines, lime-green primary action,
// coral-red destructive. Old key names are kept (remapped) so screens don't break.
export const C = {
  // sky world
  sky: '#A9E2F0',
  skyDk: '#93D7E9',
  skySoft: '#C6ECF5',
  cloud: '#FFFFFF',
  cloudLine: '#E0F1F7',
  bg: '#A9E2F0',          // was parchment → now sky
  bgSoft: '#C6ECF5',

  // cream stickers (cards + buttons)
  cream: '#F5E9C8',
  creamDk: '#E8D7AC',
  card: '#F6ECCD',        // cards are cream now (was white)
  cardDk: '#E8D7AC',

  // hand-drawn maroon outline + ink
  maroon: '#5B2A20',
  maroonSoft: '#7C4A38',
  ink: '#4C2319',         // primary text = dark maroon
  text: '#7C4A38',
  mute: '#AE8C77',
  line: '#E1CEA8',

  // accents
  gold: '#EBBB4C',
  goldDk: '#D29A2E',
  green: '#8FC63D',       // primary action (Start / Focus)
  greenDk: '#5E8E2A',
  terra: '#E5705F',       // remapped to coral (destructive)
  terraDk: '#D2543F',
  coral: '#E5705F',
  coralDk: '#D2543F',
  teal: '#3A9A96',
  pink: '#E89A82',
  white: '#FFFFFF',

  // toggles
  toggleOn: '#C3D85B',
  toggleOff: '#CDBA9A',
  toggleKnob: '#FBF3DC',

  // frosted HUD over scenes
  hudBg: 'rgba(60,40,32,0.5)',
  hudFg: '#FCF7EE',
};

export const R = { sm: 12, md: 16, lg: 22, xl: 28, pill: 999 };
export const SP = { xs: 6, sm: 10, md: 16, lg: 24, xl: 32 };

// Cairo family (loaded in root layout) — carries Latin + Arabic glyphs.
export const FONT = 'Cairo';         // 400 — body
export const FONT_BOLD = 'CairoBold';   // 700
export const FONT_BLACK = 'CairoBlack'; // 900 — headings, buttons, the chunky marker look

// thick hand-drawn outline width for the sticker look
export const STROKE = 3;

// soft drop shadow for cards/floating elements
export const shadow = {
  shadowColor: '#2A5560',
  shadowOpacity: 0.18,
  shadowRadius: 8,
  shadowOffset: { width: 0, height: 4 },
  elevation: 4,
};
