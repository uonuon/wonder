import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card, Icon, Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { t } from '@/lib/i18n';
import { cancelDailyReminder, scheduleDailyReminder } from '@/lib/notifications';
import { useStore } from '@/lib/store';
import { C, R } from '@/lib/theme';

export default function Settings() {
  const router = useRouter();
  const s = useStore();
  const [armed, setArmed] = useState(false);

  // Toggle notifications: enabling schedules the daily reminder and reverts if the OS
  // denies permission, so the switch never lies about its state.
  async function toggleNotifications() {
    if (s.notificationsOn) {
      s.set({ notificationsOn: false });
      await cancelDailyReminder();
    } else {
      s.set({ notificationsOn: true });
      const ok = await scheduleDailyReminder();
      if (!ok) s.set({ notificationsOn: false });
    }
  }

  function row(icon: string, label: string, right: React.ReactNode) {
    return (
      <Card style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 10, paddingVertical: 14 }}>
        <Txt size={17} color={C.ink} style={{ flex: 1 }}>{icon} {label}</Txt>
        {right}
      </Card>
    );
  }
  function toggle(on: boolean, onPress: () => void) {
    return (
      <Pressable onPress={onPress} style={{ width: 84, height: 34, borderRadius: R.pill, backgroundColor: on ? C.greenDk : C.cardDk, alignItems: 'center', justifyContent: 'center' }}>
        <Txt size={15} color={on ? '#FFFBF2' : C.mute}>{on ? t('on') : t('off')}</Txt>
      </Pressable>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }} edges={['top']}>
      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 24 }}>
        <Txt size={28} color={C.ink} style={{ marginBottom: 14 }}>{t('nav_settings')}</Txt>

        {row('🔊', t('sound'), toggle(s.soundOn, () => s.set({ soundOn: !s.soundOn })))}
        {row('🔔', t('notifications'), toggle(s.notificationsOn, toggleNotifications))}
        {row('📳', t('haptics'), toggle(s.hapticsOn, () => s.set({ hapticsOn: !s.hapticsOn })))}
        {row('🌐', t('language'), (
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Pressable onPress={() => s.set({ lang: 'en', langPicked: true })} style={{ paddingHorizontal: 16, height: 34, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center', backgroundColor: s.lang === 'en' ? C.gold : C.cardDk }}><Txt size={14} color={C.ink}>EN</Txt></Pressable>
            <Pressable onPress={() => s.set({ lang: 'ar', langPicked: true })} style={{ paddingHorizontal: 16, height: 34, borderRadius: R.pill, alignItems: 'center', justifyContent: 'center', backgroundColor: s.lang === 'ar' ? C.gold : C.cardDk }}><Txt size={16} color={C.ink}>ع</Txt></Pressable>
          </View>
        ))}
        {row('🎯', t('day_goal'), (
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
            <Pressable onPress={() => s.set({ dailyGoalMin: Math.max(15, s.dailyGoalMin - 15) })} style={{ width: 40, height: 34, borderRadius: 10, backgroundColor: C.cardDk, alignItems: 'center', justifyContent: 'center' }}><Txt size={20} color={C.ink}>−</Txt></Pressable>
            <Txt size={15} color={C.greenDk}>{s.dailyGoalMin}{t('min_short')}</Txt>
            <Pressable onPress={() => s.set({ dailyGoalMin: Math.min(480, s.dailyGoalMin + 15) })} style={{ width: 40, height: 34, borderRadius: 10, backgroundColor: C.cardDk, alignItems: 'center', justifyContent: 'center' }}><Txt size={20} color={C.ink}>+</Txt></Pressable>
          </View>
        ))}

        {/* Tarkeez+ */}
        <Pressable onPress={() => !s.plus && router.push('/paywall')}>
          <Card style={{ flexDirection: 'row', alignItems: 'center', marginTop: 6, backgroundColor: '#FCF6E8' }}>
            <Icon src={img('ic_crown')} size={28} color={C.goldDk} />
            <View style={{ flex: 1, paddingLeft: 12 }}>
              <Txt size={18} color={C.ink}>{t('plus_title')}</Txt>
              <Txt size={12} color={C.mute} style={{ marginTop: 2 }}>{s.plus ? `${t('plus_title')} ✦` : t('plus_tag')}</Txt>
            </View>
            {!s.plus && <View style={{ backgroundColor: C.goldDk, borderRadius: R.pill, paddingHorizontal: 16, height: 38, alignItems: 'center', justifyContent: 'center' }}><Txt size={15} color="#FFF8E6">{t('subscribe')}</Txt></View>}
          </Card>
        </Pressable>

        <Pressable
          onPress={() => { if (!armed) setArmed(true); else { s.reset(); setArmed(false); } }}
          style={{ marginTop: 24, alignSelf: 'center', backgroundColor: C.terra, borderRadius: R.pill, paddingHorizontal: 28, height: 46, alignItems: 'center', justifyContent: 'center' }}>
          <Txt size={16} color="#FFFBF2">{armed ? t('reset_confirm') : t('reset')}</Txt>
        </Pressable>

        <Txt size={13} color={C.mute} center style={{ marginTop: 22 }}>{t('about')}</Txt>
        <Txt size={12} color={C.mute} center style={{ marginTop: 4 }}>{t('version')} 1.0</Txt>
      </ScrollView>
    </SafeAreaView>
  );
}
