// Build-a-Wonder: focus time → stones → wonders rise. Like Focus Friend's socks,
// but you're building monuments. 1 stone per STONE_MINUTES of focus.
export const STONE_MINUTES = 5;

export type Wonder = {
  id: string;
  en: string;
  ar: string;
  struct: string; // 3D structure image key
  bg: string;     // default scene
  tint: string;   // stone tint (for the build-line / accents)
  stones: number; // total stones to complete
};

export const WONDERS: Wonder[] = [
  { id: 'great', en: 'Great Pyramid', ar: 'الهرم الأكبر', struct: 's_great', bg: 'bg_giza', tint: '#F2E6C8', stones: 22 },
  { id: 'djoser', en: 'Step Pyramid', ar: 'الهرم المدرّج', struct: 's_djoser', bg: 'bg_giza', tint: '#ECD6AA', stones: 30 },
  { id: 'red', en: 'Red Pyramid', ar: 'الهرم الأحمر', struct: 's_red', bg: 'bg_giza_sunset', tint: '#D78863', stones: 29 },
  { id: 'obelisk', en: 'Great Obelisk', ar: 'المسلّة الكبرى', struct: 's_obelisk', bg: 'bg_temple', tint: '#8C8C9A', stones: 26 },
  { id: 'pylon', en: 'Temple Pylon', ar: 'صرح المعبد', struct: 's_pylon', bg: 'bg_temple', tint: '#E8C9A0', stones: 34 },
  { id: 'ziggurat', en: 'Grand Ziggurat', ar: 'الزقورة الكبرى', struct: 's_ziggurat', bg: 'bg_nile', tint: '#D2A878', stones: 40 },
  { id: 'giza', en: 'Giza Complex', ar: 'أهرامات الجيزة', struct: 's_giza', bg: 'bg_giza_sunset', tint: '#F5E8C0', stones: 49 },
  { id: 'grand', en: 'Eternal Giza', ar: 'الجيزة الخالدة', struct: 's_grand', bg: 'bg_giza_night', tint: '#F4DEA8', stones: 60 },
];

export function stonesFromSeconds(sec: number): number {
  return Math.floor(sec / (STONE_MINUTES * 60));
}

export function wonderName(w: Wonder, lang: string) {
  return lang === 'ar' ? w.ar : w.en;
}

// which wonder index a given total-stone count is currently building
export function wonderForStones(stones: number): number {
  let acc = 0;
  for (let i = 0; i < WONDERS.length; i++) {
    acc += WONDERS[i].stones;
    if (stones < acc) return i;
  }
  return WONDERS.length - 1;
}

export function stonesBefore(i: number): number {
  let acc = 0;
  for (let k = 0; k < i; k++) acc += WONDERS[k].stones;
  return acc;
}

// derived progress for a total-stone count
export function progressFor(totalStones: number) {
  const idx = wonderForStones(totalStones);
  const w = WONDERS[idx];
  const inWonder = Math.min(w.stones, totalStones - stonesBefore(idx));
  return { idx, wonder: w, inWonder, needed: w.stones, frac: inWonder / w.stones };
}
