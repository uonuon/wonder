import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { Btn, Txt } from '@/components/ui';
import { num, t } from '@/lib/i18n';
import { useProgress, useStore } from '@/lib/store';
import { wonderName } from '@/lib/wonders';
import { C, R } from '@/lib/theme';

const PRESETS = [5, 15, 25, 50];

export default function Home() {
  const router = useRouter();
  const lang = useStore((s) => s.lang);
  const streak = useStore((s) => s.streak);
  const coins = useStore((s) => s.coins);
  const prog = useProgress();

  const [sel, setSel] = useState(25);
  const [custom, setCustom] = useState(0); // 0 = off
  const [pomo, setPomo] = useState(false);
  const minutes = pomo ? 25 : custom || sel;

  function chip(key: string, label: string, on: boolean, onPress: () => void) {
    return (
      <Pressable key={key} onPress={onPress} style={{ height: 44, paddingHorizontal: 16, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center', backgroundColor: on ? C.gold : C.card, borderWidth: 1.5, borderColor: on ? C.goldDk : C.line }}>
        <Txt size={16} color={on ? C.ink : C.text}>{label}</Txt>
      </Pressable>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }} edges={['top']}>
      {/* header */}
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 22, paddingTop: 8 }}>
        <Txt size={17} color={C.terra}>🔥 {num(streak)}</Txt>
        <View style={{ flex: 1, alignItems: 'center' }}>
          <View style={{ backgroundColor: C.card, borderRadius: R.pill, paddingHorizontal: 14, paddingVertical: 6 }}>
            <Txt size={14} color={C.ink}>{wonderName(prog.wonder, lang)} · {num(prog.inWonder)}/{num(prog.needed)}</Txt>
          </View>
        </View>
        <Txt size={17} color={C.teal}>💧 {num(coins)}</Txt>
      </View>

      {/* companion */}
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <Companion size={290} />
      </View>

      {/* controls */}
      <View style={{ alignItems: 'center', paddingBottom: 18 }}>
        <Txt size={50} color={C.ink}>{String(minutes).padStart(2, '0')}:00</Txt>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 4, marginBottom: 14 }}>
          <Txt size={15} color={C.teal}>{pomo ? `25 / 5 ${t('min_short')}` : t('pick_len')}</Txt>
          <Pressable onPress={() => setPomo(!pomo)}>
            <Txt size={14} color={pomo ? C.terra : C.mute}>⏳ {t('pomodoro')}</Txt>
          </Pressable>
        </View>
        {!pomo && (
          <View style={{ flexDirection: 'row', gap: 8, marginBottom: 18, flexWrap: 'wrap', justifyContent: 'center' }}>
            {PRESETS.map((m) => chip('p' + m, String(m), !custom && sel === m, () => { setSel(m); setCustom(0); }))}
            {chip('custom', t('custom'), custom > 0, () => setCustom(custom ? 0 : 30))}
          </View>
        )}
        {custom > 0 && !pomo && (
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16, marginBottom: 14 }}>
            <Btn label="−" size="md" bg={C.cardDk} color={C.ink} onPress={() => setCustom(Math.max(5, custom - 5))} style={{ width: 48 }} />
            <Txt size={20} color={C.greenDk}>{custom} {t('min_short')}</Txt>
            <Btn label="+" size="md" bg={C.cardDk} color={C.ink} onPress={() => setCustom(Math.min(120, custom + 5))} style={{ width: 48 }} />
          </View>
        )}
        <Btn label={t('start')} onPress={() => router.push({ pathname: '/focus', params: { min: String(minutes), pomo: pomo ? '1' : '0' } })} style={{ width: 320 }} />
      </View>
    </SafeAreaView>
  );
}
