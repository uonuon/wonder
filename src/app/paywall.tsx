import { useRouter } from 'expo-router';
import { Pressable, View } from 'react-native';
import { Icon, Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { t } from '@/lib/i18n';
import { useStore } from '@/lib/store';
import { C, R, shadow } from '@/lib/theme';

export default function Paywall() {
  const router = useRouter();
  const subscribe = useStore((s) => s.subscribePlus);
  return (
    <View style={{ flex: 1, backgroundColor: 'rgba(20,16,28,0.6)', alignItems: 'center', justifyContent: 'center', padding: 24 }}>
      <View style={{ backgroundColor: C.card, borderRadius: 26, padding: 28, width: '100%', maxWidth: 440, alignItems: 'center', ...shadow }}>
        <Icon src={img('ic_crown')} size={50} color={C.goldDk} />
        <Txt size={30} color={C.ink} style={{ marginTop: 8 }}>{t('plus_title')}</Txt>
        <Txt size={15} color={C.teal} style={{ marginTop: 4 }}>{t('plus_tag')}</Txt>
        <View style={{ alignSelf: 'stretch', marginTop: 20, gap: 14 }}>
          {(['plus_b1', 'plus_b2', 'plus_b3'] as const).map((k) => (
            <View key={k} style={{ flexDirection: 'row', alignItems: 'center' }}>
              <View style={{ width: 8, height: 8, borderRadius: 8, backgroundColor: C.gold, marginRight: 12 }} />
              <Txt size={15} color={C.text}>{t(k)}</Txt>
            </View>
          ))}
        </View>
        <Txt size={19} color={C.greenDk} style={{ marginTop: 22 }}>{t('plus_price')}</Txt>
        <Pressable onPress={() => { subscribe(); router.back(); }} style={{ marginTop: 14, alignSelf: 'stretch', backgroundColor: C.goldDk, borderRadius: R.pill, height: 56, alignItems: 'center', justifyContent: 'center' }}>
          <Txt size={20} color="#FFF8E6">{t('subscribe')}</Txt>
        </Pressable>
        <Pressable onPress={() => router.back()} style={{ marginTop: 12, padding: 8 }}>
          <Txt size={15} color={C.mute}>{t('maybe_later')}</Txt>
        </Pressable>
      </View>
    </View>
  );
}
