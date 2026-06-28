export type Item = { id: string; en: string; ar: string; price: number; premium: boolean };
export type Character = Item & { tex: string };
export type Scene = Item & { bg: string };

export const CHARACTERS: Character[] = [
  { id: 'pharaoh', en: 'Pharaoh', ar: 'فرعون', tex: 'char_pharaoh', price: 0, premium: false },
  { id: 'builder', en: 'Builder', ar: 'بنّاء', tex: 'char_builder', price: 0, premium: false },
  { id: 'scribe', en: 'Scribe', ar: 'كاتب', tex: 'char_scribe', price: 160, premium: false },
  { id: 'nubian', en: 'Nubian Prince', ar: 'أمير نوبي', tex: 'char_nubian', price: 240, premium: false },
  { id: 'farmer', en: 'Farmer', ar: 'فلّاح', tex: 'char_farmer', price: 120, premium: false },
  { id: 'merchant', en: 'Merchant', ar: 'تاجر', tex: 'char_merchant', price: 150, premium: false },
  { id: 'dancer', en: 'Dancer', ar: 'راقصة', tex: 'char_dancer', price: 200, premium: false },
  { id: 'archer', en: 'Archer', ar: 'رامي', tex: 'char_archer', price: 220, premium: false },
  { id: 'mummy', en: 'Mummy', ar: 'مومياء', tex: 'char_mummy', price: 300, premium: false },
  { id: 'footballer', en: 'The Striker ⚽', ar: 'النجم صلاح', tex: 'char_footballer', price: 280, premium: false },
  { id: 'comedian', en: 'El Lemby 😄', ar: 'اللمبي', tex: 'char_comedian', price: 280, premium: false },
  { id: 'priest', en: 'High Priest', ar: 'كبير الكهنة', tex: 'char_priest', price: 300, premium: true },
  { id: 'warrior', en: 'Warrior', ar: 'محارب', tex: 'char_warrior', price: 330, premium: true },
  { id: 'star', en: 'Cinema Star', ar: 'نجم السينما', tex: 'char_star', price: 360, premium: true },
  { id: 'royal', en: 'Golden Royal', ar: 'الملكي الذهبي', tex: 'char_royal', price: 420, premium: true },
  { id: 'diva', en: 'The Diva 🎤', ar: 'الديفا', tex: 'char_diva', price: 430, premium: true },
  { id: 'queen', en: 'Queen', ar: 'ملكة', tex: 'char_queen', price: 450, premium: true },
  { id: 'anubis', en: 'Anubis', ar: 'أنوبيس', tex: 'char_anubis', price: 420, premium: true },
  { id: 'horus', en: 'Horus', ar: 'حورس', tex: 'char_horus', price: 450, premium: true },
  { id: 'ra', en: 'Ra', ar: 'رع', tex: 'char_ra', price: 520, premium: true },
];

export const SCENES: Scene[] = [
  { id: 'auto', en: 'Auto', ar: 'تلقائي', bg: 'bg_giza', price: 0, premium: false },
  { id: 'giza', en: 'Giza Day', ar: 'الجيزة نهارًا', bg: 'bg_giza', price: 0, premium: false },
  { id: 'sunset', en: 'Giza Sunset', ar: 'غروب الجيزة', bg: 'bg_giza_sunset', price: 150, premium: false },
  { id: 'nile', en: 'The Nile', ar: 'النيل', bg: 'bg_nile', price: 220, premium: false },
  { id: 'temple', en: 'Karnak Temple', ar: 'معبد الكرنك', bg: 'bg_temple', price: 260, premium: true },
  { id: 'night', en: 'Starry Night', ar: 'ليلة النجوم', bg: 'bg_giza_night', price: 320, premium: true },
];

export const character = (id: string) => CHARACTERS.find((c) => c.id === id) ?? CHARACTERS[0];
export const scene = (id: string) => SCENES.find((s) => s.id === id) ?? SCENES[0];
