import { useFonts } from 'expo-font';
import { getLocales } from 'expo-localization';
import { Stack } from 'expo-router';
import * as ScreenOrientation from 'expo-screen-orientation';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { syncReminder } from '@/lib/notifications';
import { useStore } from '@/lib/store';
import { C } from '@/lib/theme';

SplashScreen.preventAutoHideAsync().catch(() => {});

export default function RootLayout() {
  const [loaded] = useFonts({ Cairo: require('../../assets/fonts/Cairo-Regular.ttf') });
  const initLocale = useStore((s) => s.initLocale);
  // app is portrait everywhere; the focus scene locks landscape for itself and restores this on exit
  useEffect(() => {
    ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
    // follow the device language on first launch (MENA-first) — only after persisted state has
    // rehydrated, so a returning user's saved choice is never overwritten
    const onHydrated = () => {
      try {
        const code = getLocales()[0]?.languageCode ?? 'en';
        initLocale(code === 'ar' ? 'ar' : 'en');
      } catch {}
      // re-assert the daily reminder for returning users (no permission prompt at launch)
      const s = useStore.getState();
      if (s.onboarded) syncReminder(s.notificationsOn);
    };
    if (useStore.persist.hasHydrated()) onHydrated();
    else return useStore.persist.onFinishHydration(onHydrated);
  }, [initLocale]);
  useEffect(() => {
    if (loaded) SplashScreen.hideAsync().catch(() => {});
  }, [loaded]);
  if (!loaded) return null;
  return (
    <GestureHandlerRootView style={{ flex: 1, backgroundColor: C.bg }}>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: C.bg } }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="onboarding" />
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="focus" options={{ presentation: 'fullScreenModal', animation: 'fade' }} />
        <Stack.Screen name="paywall" options={{ presentation: 'transparentModal', animation: 'fade' }} />
      </Stack>
    </GestureHandlerRootView>
  );
}
