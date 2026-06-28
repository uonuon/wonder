import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { CloudBase, SkyBackground } from '@/components/Sky';
import { Btn, Pill, Txt } from '@/components/ui';
import { num, t } from '@/lib/i18n';
import { useProgress, useStore } from '@/lib/store';
import { wonderName } from '@/lib/wonders';
import { C, R, STROKE } from '@/lib/theme';

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
      <Pressable key={key} onPress={onPress} style={{
        height: 46, minWidth: 52, paddingHorizontal: 16, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center',
        backgroundColor: on ? C.green : C.cream, borderWidth: STROKE, borderColor: C.maroon,
      }}>
        <Txt size={16} weight="900" color={C.maroon}>{label}</Txt>
      </Pressable>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      <SkyBackground>
        <SafeAreaView style={{ flex: 1 }} edges={['top']}>
          {/* header: streak + drops */}
          <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingTop: 6 }}>
            <Pill icon="🔥" value={num(streak)} />
            <View style={{ flex: 1 }} />
            <Pill icon="💧" value={num(coins)} />
          </View>

          {/* wonder banner */}
          <View style={{ alignItems: 'center', marginTop: 10 }}>
            <View style={{ backgroundColor: C.white, borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon, paddingHorizontal: 16, height: 40, flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              <Txt size={15} weight="900" color={C.maroon}>🏛️ {wonderName(prog.wonder, lang)}</Txt>
              <Txt size={14} weight="900" color={C.greenDk}>{num(prog.inWonder)}/{num(prog.needed)}</Txt>
            </View>
          </View>

          {/* companion standing on a cloud */}
          <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
            <View style={{ alignItems: 'center', justifyContent: 'flex-end' }}>
              <View style={{ position: 'absolute', bottom: -8 }}>
                <CloudBase width={260} />
              </View>
              <Companion size={250} shadow={false} />
            </View>
          </View>

          {/* controls */}
          <View style={{ alignItems: 'center', paddingBottom: 14 }}>
            <Txt size={56} weight="900" color={C.ink}>{String(minutes).padStart(2, '0')}:00</Txt>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, marginTop: 2, marginBottom: 14 }}>
              <Txt size={14} weight="700" color={C.maroonSoft}>{pomo ? `25 / 5 ${t('min_short')}` : t('pick_len')}</Txt>
              <Pressable onPress={() => setPomo(!pomo)} style={{ flexDirection: 'row', alignItems: 'center', gap: 4, opacity: pomo ? 1 : 0.6 }}>
                <Txt size={14} weight="900" color={pomo ? C.coral : C.maroonSoft}>⏳ {t('pomodoro')}</Txt>
              </Pressable>
            </View>
            {!pomo && (
              <View style={{ flexDirection: 'row', gap: 8, marginBottom: 16, flexWrap: 'wrap', justifyContent: 'center', paddingHorizontal: 16 }}>
                {PRESETS.map((m) => chip('p' + m, num(m), !custom && sel === m, () => { setSel(m); setCustom(0); }))}
                {chip('custom', t('custom'), custom > 0, () => setCustom(custom ? 0 : 30))}
              </View>
            )}
            {custom > 0 && !pomo && (
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 14, marginBottom: 14 }}>
                <Btn label="−" size="sm" onPress={() => setCustom(Math.max(5, custom - 5))} style={{ width: 48 }} />
                <Txt size={20} weight="900" color={C.greenDk}>{num(custom)} {t('min_short')}</Txt>
                <Btn label="+" size="sm" onPress={() => setCustom(Math.min(120, custom + 5))} style={{ width: 48 }} />
              </View>
            )}
            <Btn label={t('start')} kind="primary" onPress={() => router.push({ pathname: '/focus', params: { min: String(minutes), pomo: pomo ? '1' : '0' } })} style={{ width: 320 }} />
          </View>
        </SafeAreaView>
      </SkyBackground>
    </View>
  );
}
