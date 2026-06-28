import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Btn, Card, Icon, Toggle, Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { num, t } from '@/lib/i18n';
import { cancelDailyReminder, scheduleDailyReminder } from '@/lib/notifications';
import { useStore } from '@/lib/store';
import { C, R, STROKE } from '@/lib/theme';

function fmtTime(h: number, m: number, ar: boolean) {
  let hh = h % 12; if (hh === 0) hh = 12;
  const mm = String(m).padStart(2, '0');
  if (ar) return `${num(hh)}:${num(mm)} ${h < 12 ? 'ص' : 'م'}`;
  return `${hh}:${mm} ${h < 12 ? 'AM' : 'PM'}`;
}

export default function Settings() {
  const router = useRouter();
  const s = useStore();
  const [armed, setArmed] = useState(false);

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

  function stepReminder(delta: number) {
    const total = (s.reminderHour * 60 + s.reminderMinute + delta + 1440) % 1440;
    s.set({ reminderHour: Math.floor(total / 60), reminderMinute: total % 60 });
    if (s.notificationsOn) scheduleDailyReminder();
  }

  // a labelled row inside a card
  function Row({ icon, label, right, sub }: { icon: string; label: string; right: React.ReactNode; sub?: string }) {
    return (
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingVertical: 12 }}>
        <View style={{ flex: 1 }}>
          <Txt size={17} color={C.ink}>{icon}  {label}</Txt>
          {sub ? <Txt size={12} weight="400" color={C.mute} style={{ marginTop: 2 }}>{sub}</Txt> : null}
        </View>
        {right}
      </View>
    );
  }
  function Divider() {
    return <View style={{ height: STROKE, backgroundColor: C.line, marginHorizontal: -4, borderRadius: 2 }} />;
  }
  function Stepper({ onMinus, onPlus, children }: { onMinus: () => void; onPlus: () => void; children: React.ReactNode }) {
    return (
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
        <Btn label="−" size="sm" onPress={onMinus} style={{ width: 44 }} />
        <View style={{ minWidth: 78, alignItems: 'center' }}>{children}</View>
        <Btn label="+" size="sm" onPress={onPlus} style={{ width: 44 }} />
      </View>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.sky }} edges={['top']}>
      <ScrollView contentContainerStyle={{ padding: 18, paddingBottom: 28 }}>
        <Txt size={30} weight="900" color={C.ink} style={{ marginBottom: 14, marginLeft: 4 }}>{t('nav_settings')}</Txt>

        <Card style={{ marginBottom: 14 }}>
          <Row icon="🔊" label={t('sound')} right={<Toggle on={s.soundOn} onPress={() => s.set({ soundOn: !s.soundOn })} />} />
          <Divider />
          <Row icon="🔔" label={t('notifications')} right={<Toggle on={s.notificationsOn} onPress={toggleNotifications} />} />
          {s.notificationsOn && (
            <>
              <Divider />
              <Row icon="⏰" label={t('reminder_time')} right={
                <Stepper onMinus={() => stepReminder(-30)} onPlus={() => stepReminder(30)}>
                  <Txt size={16} weight="900" color={C.greenDk}>{fmtTime(s.reminderHour, s.reminderMinute, s.lang === 'ar')}</Txt>
                </Stepper>
              } />
            </>
          )}
          <Divider />
          <Row icon="📳" label={t('haptics')} right={<Toggle on={s.hapticsOn} onPress={() => s.set({ hapticsOn: !s.hapticsOn })} />} />
        </Card>

        <Card style={{ marginBottom: 14 }}>
          <Row icon="🌐" label={t('language')} right={
            <View style={{ flexDirection: 'row', gap: 8 }}>
              <Pressable onPress={() => s.set({ lang: 'en', langPicked: true })} style={{ paddingHorizontal: 16, height: 36, borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon, alignItems: 'center', justifyContent: 'center', backgroundColor: s.lang === 'en' ? C.toggleOn : C.cream }}><Txt size={14} weight="900" color={C.maroon}>EN</Txt></Pressable>
              <Pressable onPress={() => s.set({ lang: 'ar', langPicked: true })} style={{ paddingHorizontal: 16, height: 36, borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon, alignItems: 'center', justifyContent: 'center', backgroundColor: s.lang === 'ar' ? C.toggleOn : C.cream }}><Txt size={16} weight="900" color={C.maroon}>ع</Txt></Pressable>
            </View>
          } />
          <Divider />
          <Row icon="🎯" label={t('day_goal')} right={
            <Stepper onMinus={() => s.set({ dailyGoalMin: Math.max(15, s.dailyGoalMin - 15) })} onPlus={() => s.set({ dailyGoalMin: Math.min(480, s.dailyGoalMin + 15) })}>
              <Txt size={16} weight="900" color={C.greenDk}>{num(s.dailyGoalMin)} {t('min_short')}</Txt>
            </Stepper>
          } />
        </Card>

        {/* Tarkeez+ */}
        <Pressable onPress={() => !s.plus && router.push('/paywall')}>
          <Card style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 20, backgroundColor: '#FBF1D4' }}>
            <Icon src={img('ic_crown')} size={30} color={C.goldDk} />
            <View style={{ flex: 1, paddingLeft: 12 }}>
              <Txt size={18} weight="900" color={C.ink}>{t('plus_title')}</Txt>
              <Txt size={12} weight="400" color={C.mute} style={{ marginTop: 2 }}>{s.plus ? `${t('plus_title')} ✦` : t('plus_tag')}</Txt>
            </View>
            {!s.plus && <Btn label={t('subscribe')} size="sm" kind="primary" upper={false} onPress={() => router.push('/paywall')} />}
          </Card>
        </Pressable>

        <View style={{ alignSelf: 'center' }}>
          <Btn label={armed ? t('reset_confirm') : t('reset')} kind="danger" size="md"
            onPress={() => { if (!armed) setArmed(true); else { s.reset(); setArmed(false); } }} />
        </View>

        <Txt size={13} weight="400" color={C.maroonSoft} center style={{ marginTop: 22 }}>{t('about')}</Txt>
        <Txt size={12} weight="400" color={C.mute} center style={{ marginTop: 4 }}>{t('version')} 1.0</Txt>
      </ScrollView>
    </SafeAreaView>
  );
}
