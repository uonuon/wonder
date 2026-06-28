import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Companion } from '@/components/Companion';
import { CloudBase, SkyBackground } from '@/components/Sky';
import { Btn, Txt } from '@/components/ui';
import { num, t } from '@/lib/i18n';
import { scheduleDailyReminder } from '@/lib/notifications';
import { useStore } from '@/lib/store';
import { C, FONT_BOLD, R, STROKE } from '@/lib/theme';

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
    <View style={{ flex: 1 }}>
      <SkyBackground>
        <SafeAreaView style={{ flex: 1 }}>
          <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 28 }}>
            <Pressable onPress={() => set({ lang: lang === 'ar' ? 'en' : 'ar', langPicked: true })}
              style={{ position: 'absolute', top: 10, right: 16, backgroundColor: C.white, borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon, paddingHorizontal: 14, height: 38, justifyContent: 'center' }}>
              <Txt weight="900" color={C.maroon} size={14}>{lang === 'ar' ? 'English' : 'العربية'}</Txt>
            </Pressable>

            {/* companion on a cloud */}
            <View style={{ alignItems: 'center', justifyContent: 'flex-end', marginBottom: 24 }}>
              <View style={{ position: 'absolute', bottom: -6 }}><CloudBase width={230} /></View>
              <Companion size={210} shadow={false} />
            </View>

            {step === 0 && (
              <>
                <Txt size={30} weight="900" color={C.ink} center upper>{t('welcome')}</Txt>
                <View style={{ height: 14 }} />
                <Txt size={17} weight="700" color={C.maroonSoft} center style={{ lineHeight: 26, maxWidth: 330 }}>{t('ob1')}</Txt>
              </>
            )}
            {step === 1 && (
              <>
                <Txt size={26} weight="900" color={C.ink} center upper>{t('name_you')}</Txt>
                <View style={{ height: 18 }} />
                <TextInput
                  value={name}
                  onChangeText={setName}
                  placeholder="Imhotep"
                  placeholderTextColor={C.mute}
                  maxLength={16}
                  style={{ fontFamily: FONT_BOLD, fontSize: 22, color: C.ink, backgroundColor: C.white, borderRadius: R.lg, borderWidth: STROKE, borderColor: C.maroon, paddingHorizontal: 20, height: 58, width: 290, textAlign: 'center' }}
                />
              </>
            )}
            {step === 2 && (
              <>
                <Txt size={26} weight="900" color={C.ink} center upper>{t('set_goal')}</Txt>
                <View style={{ height: 18 }} />
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 18 }}>
                  <Btn label="−" size="md" onPress={() => setGoal(Math.max(15, goal - 15))} style={{ width: 58 }} />
                  <Txt size={28} weight="900" color={C.greenDk}>{num(goal)} {t('min_short')}</Txt>
                  <Btn label="+" size="md" onPress={() => setGoal(Math.min(240, goal + 15))} style={{ width: 58 }} />
                </View>
              </>
            )}

            <View style={{ flex: 1 }} />
            <View style={{ flexDirection: 'row', gap: 10, marginBottom: 20 }}>
              {[0, 1, 2].map((i) => (
                <View key={i} style={{ width: 11, height: 11, borderRadius: 11, borderWidth: 2, borderColor: C.maroon, backgroundColor: i === step ? C.green : C.cream }} />
              ))}
            </View>
            <Btn label={step === 2 ? t('begin') : t('next')} kind="primary" onPress={next} style={{ width: 270 }} />
          </View>
        </SafeAreaView>
      </SkyBackground>
    </View>
  );
}
