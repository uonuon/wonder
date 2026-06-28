import { Tabs } from 'expo-router';
import { Pressable, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Icon, Txt } from '@/components/ui';
import { img } from '@/lib/assets';
import { t } from '@/lib/i18n';
import { C, STROKE } from '@/lib/theme';

const TABS = [
  { name: 'home', icon: 'ic_home', label: 'nav_home' },
  { name: 'stats', icon: 'ic_stats', label: 'nav_stats' },
  { name: 'style', icon: 'ic_shop', label: 'nav_style' },
  { name: 'settings', icon: 'ic_settings', label: 'nav_settings' },
];

function TabBar({ state, navigation }: any) {
  const insets = useSafeAreaInsets();
  return (
    <View style={{ flexDirection: 'row', backgroundColor: C.cream, borderTopWidth: STROKE, borderTopColor: C.maroon, paddingBottom: insets.bottom, paddingTop: 8 }}>
      {state.routes.map((route: any, i: number) => {
        const meta = TABS.find((tb) => tb.name === route.name);
        if (!meta) return null;
        const active = state.index === i;
        const col = active ? C.maroon : C.mute;
        return (
          <Pressable
            key={route.key}
            onPress={() => navigation.navigate(route.name as never)}
            style={{ flex: 1, alignItems: 'center', justifyContent: 'center', paddingVertical: 4 }}>
            {active && <View style={{ position: 'absolute', top: 0, width: 30, height: 5, borderRadius: 5, backgroundColor: C.green }} />}
            <Icon src={img(meta.icon)} size={active ? 26 : 23} color={col} />
            <Txt size={11} weight="900" color={col} style={{ marginTop: 2 }}>{t(meta.label)}</Txt>
          </Pressable>
        );
      })}
    </View>
  );
}

export default function TabsLayout() {
  return (
    <Tabs tabBar={(p) => <TabBar {...p} />} screenOptions={{ headerShown: false, sceneStyle: { backgroundColor: C.bg } }}>
      <Tabs.Screen name="home" />
      <Tabs.Screen name="stats" />
      <Tabs.Screen name="style" />
      <Tabs.Screen name="settings" />
    </Tabs>
  );
}
