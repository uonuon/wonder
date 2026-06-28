import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Image, Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { Pill, Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { CHARACTERS, SCENES } from '@/lib/catalog';
import { num, t } from '@/lib/i18n';
import { useStore } from '@/lib/store';
import { progressFor, stonesFromSeconds } from '@/lib/wonders';
import { C, R, STROKE, shadow } from '@/lib/theme';

export default function Style() {
  const router = useRouter();
  const lang = useStore((s) => s.lang);
  const coins = useStore((s) => s.coins);
  const st = useStore();
  const [mode, setMode] = useState<'chars' | 'scenes'>('chars');

  const items = mode === 'chars' ? CHARACTERS : (SCENES as any[]);

  function act(id: string) {
    if (mode === 'chars') {
      if (st.ownedCharacters.includes(id)) return st.equipCharacter(id);
      const r = st.buyCharacter(id);
      if (r === 'ok') st.equipCharacter(id);
      else if (r === 'plus') router.push('/paywall');
    } else {
      if (st.ownedScenes.includes(id)) return st.equipScene(id);
      const r = st.buyScene(id);
      if (r === 'ok') st.equipScene(id);
      else if (r === 'plus') router.push('/paywall');
    }
  }

  function toggle(label: string, on: boolean, onPress: () => void) {
    return (
      <Pressable onPress={onPress} style={{ flex: 1, height: 44, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center', backgroundColor: on ? C.green : C.cream, borderWidth: STROKE, borderColor: C.maroon }}>
        <Txt size={16} weight="900" color={C.maroon}>{label}</Txt>
      </Pressable>
    );
  }

  const sceneBg = st.equippedScene === 'auto' ? progressFor(stonesFromSeconds(st.totalFocusSec)).wonder.bg : SCENES.find((s) => s.id === st.equippedScene)!.bg;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.sky }} edges={['top']}>
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 18, paddingTop: 6 }}>
        <Txt size={30} weight="900" color={C.ink} style={{ flex: 1, marginLeft: 4 }}>{t('nav_style')}</Txt>
        <Pill icon="💧" value={num(coins)} />
      </View>

      {/* preview */}
      <View style={{ marginHorizontal: 16, marginTop: 14, height: 210, borderRadius: R.xl, backgroundColor: C.white, borderWidth: STROKE, borderColor: C.maroon, alignItems: 'center', justifyContent: 'center', overflow: 'hidden', ...shadow }}>
        {mode === 'chars' ? <Companion size={180} /> : <Image source={img(sceneBg)} style={{ width: '100%', height: '100%' }} resizeMode="cover" />}
      </View>

      <View style={{ flexDirection: 'row', gap: 10, paddingHorizontal: 16, marginVertical: 12 }}>
        {toggle(t('characters'), mode === 'chars', () => setMode('chars'))}
        {toggle(t('scenes'), mode === 'scenes', () => setMode('scenes'))}
      </View>

      <ScrollView contentContainerStyle={{ flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 16, gap: 12, paddingBottom: 20 }}>
        {items.map((it) => {
          const owned = mode === 'chars' ? st.ownedCharacters.includes(it.id) : st.ownedScenes.includes(it.id);
          const equipped = mode === 'chars' ? st.equippedCharacter === it.id : st.equippedScene === it.id;
          const nm = lang === 'ar' ? it.ar : it.en;
          return (
            <Pressable key={it.id} onPress={() => act(it.id)} style={{ width: '47.5%', height: 110, borderRadius: R.lg, backgroundColor: equipped ? '#EAF3D6' : C.cream, flexDirection: 'row', alignItems: 'center', padding: 10, borderWidth: STROKE, borderColor: equipped ? C.greenDk : C.maroon, ...shadow }}>
              <View style={{ width: 74, height: 88, borderRadius: 12, overflow: 'hidden', alignItems: 'center', justifyContent: 'flex-end', backgroundColor: mode === 'scenes' ? C.white : 'transparent', borderWidth: mode === 'scenes' ? 2 : 0, borderColor: C.maroon }}>
                {mode === 'chars'
                  ? <Image source={img(it.tex)} style={{ width: 80, height: 88 }} resizeMode="contain" />
                  : <Image source={img(it.bg)} style={{ width: '100%', height: '100%' }} resizeMode="cover" />}
              </View>
              <View style={{ flex: 1, paddingLeft: 8 }}>
                <Txt size={14} weight="900" color={C.ink} numberOfLines={1}>{nm}</Txt>
                {owned
                  ? <Txt size={13} weight="900" color={C.greenDk} style={{ marginTop: 4 }}>{equipped ? `✓ ${t('equipped')}` : t('owned')}</Txt>
                  : it.premium && !st.plus
                    ? <Txt size={13} weight="900" color={C.goldDk} style={{ marginTop: 4 }}>✦ {t('plus_only')}</Txt>
                    : <Txt size={15} weight="900" color={C.greenDk} style={{ marginTop: 4 }}>💧 {num(it.price)}</Txt>}
              </View>
              {it.premium && (
                <View style={{ position: 'absolute', top: 6, right: 6, backgroundColor: C.gold, borderRadius: 999, borderWidth: 2, borderColor: C.maroon, paddingHorizontal: 7, paddingVertical: 1 }}>
                  <Txt size={10} weight="900" color={C.maroon}>✦</Txt>
                </View>
              )}
            </Pressable>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}
