import { useLocalSearchParams, useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import * as ScreenOrientation from 'expo-screen-orientation';
import { useEffect, useRef, useState } from 'react';
import { AppState, Platform, Pressable, useWindowDimensions, View } from 'react-native';
import { BuildScene } from '@/components/BuildScene';
import { Txt } from '@/components/ui';
import { num, quote, t } from '@/lib/i18n';
import { scene as sceneCat } from '@/lib/catalog';
import { useStore } from '@/lib/store';
import { progressFor, stonesFromSeconds, STONE_MINUTES, WONDERS } from '@/lib/wonders';
import { C, R } from '@/lib/theme';

function daylight() {
  const h = new Date().getHours() + new Date().getMinutes() / 60;
  return Math.max(0, Math.min(1, Math.cos(((h - 13) / 24) * Math.PI * 2) * 0.5 + 0.5));
}

export default function Focus() {
  const router = useRouter();
  const { width, height } = useWindowDimensions();
  const params = useLocalSearchParams<{ min: string; pomo: string }>();
  const minutes = Math.max(1, parseInt(params.min ?? '25', 10));
  const lenSec = minutes * 60;

  const totalFocusSec = useStore((s) => s.totalFocusSec);
  const equippedScene = useStore((s) => s.equippedScene);
  const equippedChar = useStore((s) => s.equippedCharacter);
  const hapticsOn = useStore((s) => s.hapticsOn);
  const completeSession = useStore((s) => s.completeSession);

  const [timeLeft, setTimeLeft] = useState(lenSec);
  const [done, setDone] = useState<null | { drops: number; wonderUp: boolean; wonderIdx: number }>(null);
  const endRef = useRef(Date.now() + lenSec * 1000);
  const finishedRef = useRef(false);

  // lock landscape for the immersive scene
  useEffect(() => {
    ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.LANDSCAPE).catch(() => {});
    return () => { ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {}); };
  }, []);

  // countdown
  useEffect(() => {
    const id = setInterval(() => {
      const left = Math.max(0, Math.round((endRef.current - Date.now()) / 1000));
      setTimeLeft(left);
      if (left <= 0 && !finishedRef.current) finish();
    }, 250);
    return () => clearInterval(id);
  }, []);

  // leave-app = work stops
  useEffect(() => {
    const sub = AppState.addEventListener('change', (s) => {
      if (s !== 'active' && !finishedRef.current) giveUp();
    });
    return () => sub.remove();
  }, []);

  function finish() {
    finishedRef.current = true;
    const r = completeSession(minutes);
    if (hapticsOn && Platform.OS !== 'web') Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    setDone({ drops: r.dropsEarned, wonderUp: r.wonderUp, wonderIdx: r.wonderIdx });
  }
  function giveUp() {
    finishedRef.current = true;
    router.back();
  }

  // live build fraction (grows as the session runs)
  const committed = progressFor(stonesFromSeconds(totalFocusSec));
  const sessionStones = Math.floor(minutes / STONE_MINUTES);
  const elapsedFrac = 1 - timeLeft / lenSec;
  const liveFrac = Math.min(1, (committed.inWonder + sessionStones * elapsedFrac) / committed.needed);

  const wonder = committed.wonder;
  const bgKey = equippedScene === 'auto' ? wonder.bg : sceneCat(equippedScene).bg;
  const night = bgKey.endsWith('night') ? 0.3 : 1 - daylight();

  const mm = String(Math.floor(timeLeft / 60)).padStart(2, '0');
  const ss = String(timeLeft % 60).padStart(2, '0');

  return (
    <View style={{ flex: 1, backgroundColor: '#1a1e3a' }}>
      <BuildScene width={width} height={height} bgKey={bgKey} structKey={wonder.struct} frac={liveFrac} charTex={`char_${equippedChar}`} night={night} />

      {/* timer HUD */}
      <View style={{ position: 'absolute', top: 24, width: '100%', alignItems: 'center' }}>
        <View style={{ backgroundColor: C.hudBg, borderRadius: R.lg, paddingHorizontal: 26, paddingVertical: 8 }}>
          <Txt size={52} color={C.hudFg}>{mm}:{ss}</Txt>
        </View>
        <Txt size={14} color="rgba(245,240,230,0.9)" style={{ marginTop: 6 }}>{t('keep_focus')}</Txt>
      </View>

      {!done && (
        <Pressable onPress={giveUp} style={{ position: 'absolute', bottom: 28, alignSelf: 'center', backgroundColor: C.hudBg, borderRadius: R.pill, paddingHorizontal: 32, paddingVertical: 12 }}>
          <Txt size={16} color={C.hudFg}>{t('give_up')}</Txt>
        </Pressable>
      )}

      {done && (
        <View style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(20,16,28,0.6)', alignItems: 'center', justifyContent: 'center' }}>
          <View style={{ backgroundColor: C.card, borderRadius: R.lg, padding: 28, alignItems: 'center', width: 360 }}>
            <Txt size={26} color={C.ink} center>{done.wonderUp ? t('wonder_done') : '✨'}</Txt>
            <Txt size={17} color={C.greenDk} center style={{ marginTop: 6 }}>
              {done.wonderUp ? `${t('now_building')}: ${useStore.getState().lang === 'ar' ? WONDERS[done.wonderIdx].ar : WONDERS[done.wonderIdx].en}` : `+${num(done.drops)} 💧`}
            </Txt>
            <Txt size={14} color={C.mute} center style={{ marginTop: 8 }}>{quote(useStore.getState().sessionsTotal)}</Txt>
            <Pressable onPress={() => router.back()} style={{ marginTop: 18, backgroundColor: C.greenDk, borderRadius: R.pill, paddingHorizontal: 40, paddingVertical: 14 }}>
              <Txt size={18} color="#FFFBF2">{t('next')}</Txt>
            </Pressable>
          </View>
        </View>
      )}
    </View>
  );
}
