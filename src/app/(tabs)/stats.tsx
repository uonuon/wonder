import { ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card, ProgressBar, Txt, Icon } from '@/components/ui';
import { img } from '@/lib/assets';
import { num, t } from '@/lib/i18n';
import { dateOffset, today, useStore } from '@/lib/store';
import { progressFor, stonesFromSeconds, wonderForStones, WONDERS, wonderName } from '@/lib/wonders';
import { C, STROKE } from '@/lib/theme';

function fmt(sec: number) {
  const m = Math.floor(sec / 60);
  return m >= 60 ? `${Math.floor(m / 60)}${t('hr_short')} ${m % 60}${t('min_short')}` : `${m}${t('min_short')}`;
}

export default function Stats() {
  const s = useStore();
  const prog = progressFor(stonesFromSeconds(s.totalFocusSec));

  const ach = [
    { id: 'first', en: 'First Focus', ar: 'أول تركيز', icon: 'ic_flame', on: s.sessionsTotal >= 1 },
    { id: 'streak7', en: '7-Day Streak', ar: 'سلسلة ٧', icon: 'ic_flame', on: s.bestStreak >= 7 },
    { id: 'hours10', en: '10 Hours', ar: '١٠ ساعات', icon: 'ic_trophy', on: s.totalFocusSec >= 36000 },
    { id: 'w1', en: 'First Wonder', ar: 'أول أثر', icon: 'ic_moon', on: wonderForStones(stonesFromSeconds(s.totalFocusSec)) >= 1 },
    { id: 'wall', en: 'All Wonders', ar: 'كل الآثار', icon: 'ic_trophy', on: wonderForStones(stonesFromSeconds(s.totalFocusSec)) >= WONDERS.length - 1 },
  ];

  let maxSec = 1;
  Object.values(s.history).forEach((v) => (maxSec = Math.max(maxSec, v)));
  const days = Array.from({ length: 35 }, (_, i) => dateOffset(34 - i));

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }} edges={['top']}>
      <ScrollView contentContainerStyle={{ padding: 18, paddingBottom: 24 }}>
        <Txt size={30} weight="900" color={C.ink} style={{ marginBottom: 14, marginLeft: 4 }}>{t('nav_stats')}</Txt>

        <View style={{ flexDirection: 'row', gap: 10 }}>
          {[[t('total_focus'), fmt(s.totalFocusSec), C.greenDk], [t('streak'), `${num(s.streak)}🔥`, C.coralDk], [t('best_streak'), num(s.bestStreak), C.goldDk]].map(([label, val, col], i) => (
            <Card key={i} style={{ flex: 1, alignItems: 'center', paddingVertical: 14 }}>
              <Txt size={21} weight="900" color={col as string}>{val}</Txt>
              <Txt size={12} weight="700" color={C.mute} style={{ marginTop: 4 }}>{label}</Txt>
            </Card>
          ))}
        </View>

        <Card style={{ marginTop: 12 }}>
          <Txt size={18} weight="900" color={C.ink}>{t('wonder')} {num(prog.idx + 1)} · {wonderName(prog.wonder, s.lang)}</Txt>
          <View style={{ height: 10 }} />
          <ProgressBar frac={prog.frac} />
          <Txt size={13} color={C.mute} style={{ marginTop: 8 }}>{num(prog.inWonder)} / {num(prog.needed)} {t('stones')}</Txt>
        </Card>

        <Card style={{ marginTop: 12 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
            <Txt size={15} color={C.text}>{t('day_goal')}</Txt>
            <Txt size={14} color={C.greenDk}>{fmt(s.todayFocusSec)} / {s.dailyGoalMin}{t('min_short')}</Txt>
          </View>
          <View style={{ height: 8 }} />
          <ProgressBar frac={s.dailyGoalMin ? s.todayFocusSec / (s.dailyGoalMin * 60) : 1} color={C.gold} />
        </Card>

        <Txt size={17} weight="900" color={C.ink} style={{ marginTop: 18, marginBottom: 10, marginLeft: 4 }}>{t('this_weeks')}</Txt>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
          {days.map((d) => {
            const sec = s.history[d] ?? 0;
            const lv = sec > 0 ? Math.max(0.18, Math.min(1, sec / maxSec)) : 0;
            const bg = sec > 0 ? mix('#DDEBC4', C.greenDk, lv) : C.cream;
            return <View key={d} style={{ width: '12%', aspectRatio: 1, borderRadius: 8, backgroundColor: bg, borderWidth: 2, borderColor: d === today() ? C.coral : C.maroon, opacity: sec > 0 || d === today() ? 1 : 0.45 }} />;
          })}
        </View>

        <Txt size={17} weight="900" color={C.ink} style={{ marginTop: 18, marginBottom: 10, marginLeft: 4 }}>{t('achievements')}</Txt>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
          {ach.map((a) => (
            <View key={a.id} style={{ alignItems: 'center', width: '19%' }}>
              <View style={{ width: 50, height: 50, borderRadius: 999, backgroundColor: a.on ? C.green : C.cream, borderWidth: STROKE, borderColor: C.maroon, alignItems: 'center', justifyContent: 'center' }}>
                <Icon src={img(a.icon)} size={24} color={a.on ? C.white : C.mute} />
              </View>
              <Txt size={10} weight="700" color={a.on ? C.ink : C.mute} center style={{ marginTop: 5 }}>{s.lang === 'ar' ? a.ar : a.en}</Txt>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function mix(a: string, b: string, t: number) {
  const pa = [parseInt(a.slice(1, 3), 16), parseInt(a.slice(3, 5), 16), parseInt(a.slice(5, 7), 16)];
  const pb = [parseInt(b.slice(1, 3), 16), parseInt(b.slice(3, 5), 16), parseInt(b.slice(5, 7), 16)];
  const c = pa.map((x, i) => Math.round(x + (pb[i] - x) * t));
  return `rgb(${c[0]},${c[1]},${c[2]})`;
}
