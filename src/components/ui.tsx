import { ReactNode } from 'react';
import { Image, Pressable, StyleProp, Text, TextStyle, View, ViewStyle } from 'react-native';
import { C, FONT, R, shadow } from '@/lib/theme';

export function Txt({ children, size = 16, color = C.text, weight = '700', style, center, numberOfLines }: {
  children: ReactNode; size?: number; color?: string; weight?: TextStyle['fontWeight'];
  style?: StyleProp<TextStyle>; center?: boolean; numberOfLines?: number;
}) {
  return (
    <Text numberOfLines={numberOfLines} style={[{ fontFamily: FONT, fontSize: size, color, fontWeight: weight, textAlign: center ? 'center' : undefined }, style]}>
      {children}
    </Text>
  );
}

export function Btn({ label, onPress, bg = C.greenDk, color = '#FFFBF2', size = 'lg', style, disabled, border }: {
  label: string; onPress?: () => void; bg?: string; color?: string;
  size?: 'sm' | 'md' | 'lg'; style?: StyleProp<ViewStyle>; disabled?: boolean; border?: string;
}) {
  const h = size === 'lg' ? 58 : size === 'md' ? 44 : 36;
  const fs = size === 'lg' ? 20 : size === 'md' ? 16 : 14;
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [
        { height: h, borderRadius: R.pill, backgroundColor: bg, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 22, opacity: disabled ? 0.5 : pressed ? 0.88 : 1, borderWidth: border ? 2 : 0, borderColor: border },
        size === 'lg' ? shadow : null,
        style,
      ]}>
      <Txt size={fs} color={color}>{label}</Txt>
    </Pressable>
  );
}

export function Card({ children, style }: { children?: ReactNode; style?: StyleProp<ViewStyle> }) {
  return <View style={[{ backgroundColor: C.card, borderRadius: R.md, padding: 14 }, shadow, style]}>{children}</View>;
}

// tinted silhouette icon
export function Icon({ src, size = 24, color = C.ink }: { src: any; size?: number; color?: string }) {
  return <Image source={src} style={{ width: size, height: size, tintColor: color, resizeMode: 'contain' }} />;
}

export function ProgressBar({ frac, color = C.green, bg = C.cardDk, height = 14 }: { frac: number; color?: string; bg?: string; height?: number }) {
  return (
    <View style={{ height, borderRadius: 999, backgroundColor: bg, overflow: 'hidden' }}>
      <View style={{ height, width: `${Math.max(0, Math.min(1, frac)) * 100}%`, borderRadius: 999, backgroundColor: color }} />
    </View>
  );
}
