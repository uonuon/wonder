import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { Btn, Txt } from '@/components/ui';
import { t } from '@/lib/i18n';
import { scheduleDailyReminder } from '@/lib/notifications';
import { useStore } from '@/lib/store';
import { C, R } from '@/lib/theme';

export default function Onboarding() {
  const router = useRouter();
  const set = useStore((s) => s.set);
  const lang = useStore((s) => s.lang);
  const [step, setStep] = useState(0);
  const [name, setName] = useState('');
  const [goal, setGoal] = useState(60);

  function next() {
    if (step < 2) setStep(step + 1);
    else {
      set({ builderName: name.trim() || (lang === 'ar' ? 'بنّاء' : 'Builder'), dailyGoalMin: goal, onboarded: true });
      // ask for notification permission at this natural moment; revert the pref if denied
      scheduleDailyReminder().then((ok) => { if (!ok) set({ notificationsOn: false }); });
      router.replace('/home');
    }
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: C.bg }}>
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 28 }}>
        <Pressable onPress={() => set({ lang: lang === 'ar' ? 'en' : 'ar', langPicked: true })} style={{ position: 'absolute', top: 8, right: 16, padding: 10 }}>
          <Txt color={C.terra} size={16}>{lang === 'ar' ? 'English' : 'العربية'}</Txt>
        </Pressable>

        <Companion size={210} />
        <View style={{ height: 24 }} />

        {step === 0 && (
          <>
            <Txt size={28} color={C.ink} center>{t('welcome')}</Txt>
            <View style={{ height: 12 }} />
            <Txt size={16} color={C.text} center style={{ lineHeight: 24, maxWidth: 320 }}>{t('ob1')}</Txt>
          </>
        )}
        {step === 1 && (
          <>
            <Txt size={24} color={C.ink} center>{t('name_you')}</Txt>
            <View style={{ height: 16 }} />
            <TextInput
              value={name}
              onChangeText={setName}
              placeholder="Imhotep"
              placeholderTextColor={C.mute}
              maxLength={16}
              style={{ fontFamily: 'Cairo', fontSize: 22, color: C.ink, backgroundColor: C.card, borderRadius: R.md, paddingHorizontal: 20, height: 54, width: 280, textAlign: 'center' }}
            />
          </>
        )}
        {step === 2 && (
          <>
            <Txt size={24} color={C.ink} center>{t('set_goal')}</Txt>
            <View style={{ height: 16 }} />
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 18 }}>
              <Btn label="−" size="md" bg={C.cardDk} color={C.ink} onPress={() => setGoal(Math.max(15, goal - 15))} style={{ width: 56 }} />
              <Txt size={26} color={C.greenDk}>{goal} {t('min_short')}</Txt>
              <Btn label="+" size="md" bg={C.cardDk} color={C.ink} onPress={() => setGoal(Math.min(240, goal + 15))} style={{ width: 56 }} />
            </View>
          </>
        )}

        <View style={{ flex: 1 }} />
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: 18 }}>
          {[0, 1, 2].map((i) => (
            <View key={i} style={{ width: 9, height: 9, borderRadius: 9, backgroundColor: i === step ? C.gold : C.cardDk }} />
          ))}
        </View>
        <Btn label={step === 2 ? t('begin') : t('next')} onPress={next} style={{ width: 260 }} />
      </View>
    </SafeAreaView>
  );
}
