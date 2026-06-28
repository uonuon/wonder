// Bilingual strings (EN / AR). Arabic uses the Cairo font; RTL handled per-screen.
import { useStore } from './store';

type Pair = [string, string];
const S: Record<string, Pair> = {
  app_name: ['Tarkeez', 'تركيز'],
  tagline: ['build a wonder by focusing', 'ابنِ أثرًا بالتركيز'],
  // onboarding
  welcome: ['Meet your builder', 'تعرّف على بنّائك'],
  ob1: ['Focus, and your builder lays the stones of an ancient wonder — one block at a time.',
        'ركّز، وسيضع بنّاؤك أحجار أثرٍ قديم — حجرًا تلو الآخر.'],
  ob2: ['Leave the app mid-session and the work stops. Stay, and the pyramid rises.',
        'غادر أثناء الجلسة فيتوقف العمل. ابقَ، فيرتفع الهرم.'],
  ob3: ['Dress your builder, switch scenes, and build wonder after wonder.',
        'لبّس بنّاءك، بدّل المشاهد، وابنِ أثرًا بعد أثر.'],
  name_you: ['Name your builder', 'سمِّ بنّاءك'],
  set_goal: ['Daily focus goal', 'هدف التركيز اليومي'],
  begin: ['Begin', 'ابدأ'],
  next: ['Next', 'التالي'],
  // home / focus
  pick_len: ['Choose a focus length', 'اختر مدة التركيز'],
  start: ['Start Focus', 'ابدأ التركيز'],
  focusing: ['focusing…', 'جارٍ التركيز…'],
  keep_focus: ["Stay focused. Don't leave the app!", 'ابقَ مركزًا. لا تغادر التطبيق!'],
  give_up: ['Give Up', 'استسلام'],
  left_app: ['You left — work stopped. Stay next time.', 'غادرت — توقّف العمل. ابقَ في المرة القادمة.'],
  custom: ['Custom', 'مخصص'],
  pomodoro: ['Pomodoro', 'بومودورو'],
  min_short: ['min', 'د'],
  hr_short: ['h', 'س'],
  // build
  stones: ['stones', 'حجر'],
  wonder: ['Wonder', 'أثر'],
  now_building: ['Now building', 'نبني الآن'],
  wonder_done: ['A wonder is complete! 🏛️', 'اكتمل أثر عظيم! 🏛️'],
  // nav
  nav_home: ['Home', 'الرئيسية'],
  nav_stats: ['Stats', 'إحصائيات'],
  nav_style: ['Style', 'تنميق'],
  nav_settings: ['Settings', 'الإعدادات'],
  // style
  characters: ['Characters', 'الشخصيات'],
  scenes: ['Scenes', 'المشاهد'],
  owned: ['Owned', 'مملوك'],
  equipped: ['Equipped', 'مُجهَّز'],
  equip: ['Equip', 'تجهيز'],
  buy: ['Buy', 'شراء'],
  plus_only: ['Tarkeez+', 'تركيز+'],
  need_more: ['Not enough drops', 'قطرات غير كافية'],
  // stats
  total_focus: ['Total focus', 'إجمالي التركيز'],
  streak: ['Streak', 'السلسلة'],
  best_streak: ['Best streak', 'أطول سلسلة'],
  day_goal: ['Daily goal', 'الهدف اليومي'],
  this_weeks: ['Last 5 weeks', 'آخر ٥ أسابيع'],
  achievements: ['Achievements', 'الإنجازات'],
  // settings
  sound: ['Sound', 'الصوت'],
  notifications: ['Notifications', 'الإشعارات'],
  haptics: ['Haptics', 'الاهتزاز'],
  language: ['Language', 'اللغة'],
  reset: ['Reset progress', 'إعادة ضبط التقدم'],
  reset_confirm: ['Tap again to confirm', 'اضغط مرة أخرى للتأكيد'],
  about: ['Tarkeez — focus to build wonders.', 'تركيز — ركّز لتبني الآثار.'],
  version: ['Version', 'الإصدار'],
  on: ['On', 'تشغيل'],
  off: ['Off', 'إيقاف'],
  // plus
  plus_title: ['Tarkeez+', 'تركيز+'],
  plus_tag: ['Build faster. Unlock more.', 'ابنِ أسرع. افتح المزيد.'],
  plus_b1: ['Premium characters & scenes', 'شخصيات ومشاهد مميزة'],
  plus_b2: ['Detailed insights & achievements', 'إحصاءات وإنجازات مفصلة'],
  plus_b3: ['Custom soundscapes & cloud sync', 'أصوات مخصصة ومزامنة سحابية'],
  plus_price: ['$3.99 / month', '٣٫٩٩$ / شهر'],
  subscribe: ['Start Tarkeez+', 'ابدأ تركيز+'],
  maybe_later: ['Maybe later', 'لاحقًا'],
  restore: ['Restore', 'استعادة'],
};

const AR_DIGITS = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

export function isRTL() {
  return useStore.getState().lang === 'ar';
}

export function t(key: keyof typeof S | string): string {
  const p = S[key as string];
  if (!p) return key as string;
  return useStore.getState().lang === 'ar' ? p[1] : p[0];
}

export function num(n: number | string): string {
  const s = String(n);
  if (useStore.getState().lang !== 'ar') return s;
  return s.replace(/[0-9]/g, (d) => AR_DIGITS[+d]);
}

export const QUOTES: Pair[] = [
  ['Stone by stone, a wonder rises.', 'حجرًا حجرًا، يرتفع الأثر.'],
  ['Focus is a quiet kind of strength.', 'التركيز قوة هادئة.'],
  ['Patience builds pyramids.', 'الصبر يبني الأهرام.'],
  ['You showed up. That matters.', 'لقد حضرت. وهذا مهم.'],
  ['Every session lays a stone.', 'كل جلسة تضع حجرًا.'],
];
export function quote(i: number): string {
  const q = QUOTES[((i % QUOTES.length) + QUOTES.length) % QUOTES.length];
  return useStore.getState().lang === 'ar' ? q[1] : q[0];
}
