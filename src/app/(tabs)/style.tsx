import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Image, Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { CHARACTERS, SCENES } from '@/lib/catalog';
import { num, t } from '@/lib/i18n';
import { useStore } from '@/lib/store';
import { progressFor } from '@/lib/wonders';
import { stonesFromSeconds } from '@/lib/wonders';
import { C, R, shadow } from '@/lib/theme';

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
      <Pressable onPress={onPress} style={{ flex: 1, height: 38, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center', backgroundColor: on ? C.gold : C.card, borderWidth: 1.5, borderColor: on ? C.goldDk : C.line }}>
        <Txt size={16} color={on ? C.ink : C.text}>{label}</Txt>
      </Pressable>
    );
  }

  const sceneBg = st.equippedScene === 'auto' ? progressFor(stonesFromSeconds(st.totalFocusSec)).wonder.bg : SCENES.find((s) => s.id === st.equippedScene)!.bg;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }} edges={['top']}>
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 22, paddingTop: 6 }}>
        <Txt size={26} color={C.ink} style={{ flex: 1 }}>{t('nav_style')}</Txt>
        <Txt size={20} color={C.teal}>💧 {num(coins)}</Txt>
      </View>

      {/* preview */}
      <View style={{ margin: 16, height: 210, borderRadius: R.lg, backgroundColor: C.card, alignItems: 'center', justifyContent: 'center', overflow: 'hidden', ...shadow }}>
        {mode === 'chars' ? <Companion size={180} /> : <Image source={img(sceneBg)} style={{ width: '100%', height: '100%' }} resizeMode="cover" />}
      </View>

      <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginBottom: 10 }}>
        {toggle(t('characters'), mode === 'chars', () => setMode('chars'))}
        {toggle(t('scenes'), mode === 'scenes', () => setMode('scenes'))}
      </View>

      <ScrollView contentContainerStyle={{ flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 16, gap: 12, paddingBottom: 20 }}>
        {items.map((it) => {
          const owned = mode === 'chars' ? st.ownedCharacters.includes(it.id) : st.ownedScenes.includes(it.id);
          const equipped = mode === 'chars' ? st.equippedCharacter === it.id : st.equippedScene === it.id;
          const nm = lang === 'ar' ? it.ar : it.en;
          return (
            <Pressable key={it.id} onPress={() => act(it.id)} style={{ width: '47.5%', height: 108, borderRadius: R.md, backgroundColor: C.card, flexDirection: 'row', alignItems: 'center', padding: 10, borderTopWidth: equipped ? 4 : 0, borderTopColor: C.green, ...shadow }}>
              <View style={{ width: 76, height: 86, borderRadius: 10, overflow: 'hidden', alignItems: 'center', justifyContent: 'flex-end' }}>
                {mode === 'chars'
                  ? <Image source={img(it.tex)} style={{ width: 80, height: 86 }} resizeMode="contain" />
                  : <Image source={img(it.bg)} style={{ width: '100%', height: '100%' }} resizeMode="cover" />}
              </View>
              <View style={{ flex: 1, paddingLeft: 8 }}>
                <Txt size={14} color={C.ink} numberOfLines={1}>{nm}</Txt>
                {owned
                  ? <Txt size={13} color={C.greenDk} style={{ marginTop: 4 }}>{equipped ? t('equipped') : t('owned')}</Txt>
                  : it.premium && !st.plus
                    ? <Txt size={13} color={C.goldDk} style={{ marginTop: 4 }}>✦ {t('plus_only')}</Txt>
                    : <Txt size={15} color={C.teal} style={{ marginTop: 4 }}>💧 {num(it.price)}</Txt>}
              </View>
              {it.premium && (
                <View style={{ position: 'absolute', top: 6, right: 6, backgroundColor: C.goldDk, borderRadius: 999, paddingHorizontal: 7, paddingVertical: 2 }}>
                  <Txt size={10} color="#FFF8E6">{t('plus_only')}</Txt>
                </View>
              )}
            </Pressable>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}
