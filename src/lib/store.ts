import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import { character, scene } from './catalog';
import { progressFor, stonesFromSeconds } from './wonders';

function ymd(d: Date) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
export function today() { return ymd(new Date()); }
export function yesterday() { const d = new Date(); d.setDate(d.getDate() - 1); return ymd(d); }
export function dateOffset(n: number) { const d = new Date(); d.setDate(d.getDate() - n); return ymd(d); }

export type State = {
  // progress
  totalFocusSec: number;
  todayFocusSec: number;
  sessionsTotal: number;
  streak: number;
  bestStreak: number;
  coins: number;            // "drops" — the spendable currency
  lastDay: string;
  history: Record<string, number>;
  // profile
  onboarded: boolean;
  builderName: string;
  dailyGoalMin: number;
  // unlocks
  equippedCharacter: string;
  ownedCharacters: string[];
  equippedScene: string;
  ownedScenes: string[];
  plus: boolean;
  // settings
  lang: 'en' | 'ar';
  langPicked: boolean;      // true once locale auto-detected or user chose a language
  soundOn: boolean;
  notificationsOn: boolean;
  reminderHour: number;     // daily reminder time (0-23)
  reminderMinute: number;   // (0 or 30)
  hapticsOn: boolean;
  // actions
  initLocale: (deviceLang: 'en' | 'ar') => void;
  completeSession: (minutes: number) => { dropsEarned: number; wonderUp: boolean; wonderIdx: number };
  buyCharacter: (id: string) => 'ok' | 'owned' | 'plus' | 'coins';
  equipCharacter: (id: string) => void;
  buyScene: (id: string) => 'ok' | 'owned' | 'plus' | 'coins';
  equipScene: (id: string) => void;
  subscribePlus: () => void;
  set: (patch: Partial<State>) => void;
  reset: () => void;
  grantDev: () => void;
};

const initial = {
  totalFocusSec: 0, todayFocusSec: 0, sessionsTotal: 0, streak: 0, bestStreak: 0,
  coins: 0, lastDay: '', history: {} as Record<string, number>,
  onboarded: false, builderName: '', dailyGoalMin: 60,
  equippedCharacter: 'pharaoh', ownedCharacters: ['pharaoh', 'builder'],
  equippedScene: 'auto', ownedScenes: ['auto', 'giza'],
  plus: false, lang: 'en' as const, langPicked: false, soundOn: true, notificationsOn: true,
  reminderHour: 20, reminderMinute: 0, hapticsOn: true,
};

export const useStore = create<State>()(
  persist(
    (setState, get) => ({
      ...initial,

      // on first launch, follow the device language (MENA-first); never override a user's later choice
      initLocale: (deviceLang) => {
        if (!get().langPicked) setState({ lang: deviceLang, langPicked: true });
      },

      completeSession: (minutes) => {
        const s = get();
        const t = today();
        let { streak, bestStreak, todayFocusSec, sessionsTotal } = s;
        if (s.lastDay !== t) {
          streak = s.lastDay === yesterday() ? streak + 1 : 1;
          bestStreak = Math.max(bestStreak, streak);
          todayFocusSec = 0;
        }
        const secs = minutes * 60;
        const drops = minutes + Math.floor(minutes / 10);
        const prevStones = stonesFromSeconds(s.totalFocusSec);
        const totalFocusSec = s.totalFocusSec + secs;
        const newStones = stonesFromSeconds(totalFocusSec);
        const prevIdx = progressFor(prevStones).idx;
        const newIdx = progressFor(newStones).idx;
        const history = { ...s.history, [t]: (s.history[t] ?? 0) + secs };
        setState({
          totalFocusSec,
          todayFocusSec: todayFocusSec + secs,
          sessionsTotal: sessionsTotal + 1,
          streak, bestStreak: Math.max(bestStreak, streak),
          coins: s.coins + drops, lastDay: t, history,
        });
        return { dropsEarned: drops, wonderUp: newIdx > prevIdx, wonderIdx: newIdx };
      },

      buyCharacter: (id) => {
        const s = get();
        const c = character(id);
        if (s.ownedCharacters.includes(id)) return 'owned';
        if (c.premium && !s.plus) return 'plus';
        if (s.coins < c.price) return 'coins';
        setState({ coins: s.coins - c.price, ownedCharacters: [...s.ownedCharacters, id] });
        return 'ok';
      },
      equipCharacter: (id) => {
        if (get().ownedCharacters.includes(id)) setState({ equippedCharacter: id });
      },
      buyScene: (id) => {
        const s = get();
        const sc = scene(id);
        if (s.ownedScenes.includes(id)) return 'owned';
        if (sc.premium && !s.plus) return 'plus';
        if (s.coins < sc.price) return 'coins';
        setState({ coins: s.coins - sc.price, ownedScenes: [...s.ownedScenes, id] });
        return 'ok';
      },
      equipScene: (id) => {
        if (get().ownedScenes.includes(id)) setState({ equippedScene: id });
      },
      subscribePlus: () => setState({ plus: true }),
      set: (patch) => setState(patch),
      reset: () => setState({ ...initial, lang: get().lang, plus: get().plus }),
      grantDev: () => setState({ coins: get().coins + 5000 }),
    }),
    {
      name: 'tarkeez-store',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (s) => {
        const { initLocale, completeSession, buyCharacter, equipCharacter, buyScene, equipScene, subscribePlus, set, reset, grantDev, ...data } = s;
        return data as any;
      },
    }
  )
);

// derived selectors
export function useProgress() {
  const total = useStore((s) => s.totalFocusSec);
  return progressFor(stonesFromSeconds(total));
}
