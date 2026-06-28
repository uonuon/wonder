import { ReactNode } from 'react';
import { Image, Pressable, StyleProp, Text, TextStyle, View, ViewStyle } from 'react-native';
import { C, FONT, FONT_BLACK, FONT_BOLD, R, STROKE, shadow } from '@/lib/theme';

function fam(weight?: TextStyle['fontWeight']) {
  if (weight === '900' || weight === '800') return FONT_BLACK;
  if (weight === '400' || weight === '500' || weight === '300') return FONT;
  return FONT_BOLD;
}

export function Txt({ children, size = 16, color = C.ink, weight = '700', style, center, upper, numberOfLines }: {
  children: ReactNode; size?: number; color?: string; weight?: TextStyle['fontWeight'];
  style?: StyleProp<TextStyle>; center?: boolean; upper?: boolean; numberOfLines?: number;
}) {
  return (
    <Text
      numberOfLines={numberOfLines}
      style={[{ fontFamily: fam(weight), fontSize: size, color, textAlign: center ? 'center' : undefined }, upper ? { textTransform: 'uppercase', letterSpacing: 0.5 } : null, style]}>
      {children}
    </Text>
  );
}

// Chunky hand-drawn "sticker" button: cream/colored face with a thick maroon outline
// and a maroon bottom lip that compresses on press.
export function Btn({ label, onPress, kind = 'cream', bg, color, size = 'lg', style, disabled, upper = true }: {
  label: string; onPress?: () => void; kind?: 'cream' | 'primary' | 'danger' | 'plain';
  bg?: string; color?: string; size?: 'sm' | 'md' | 'lg'; style?: StyleProp<ViewStyle>; disabled?: boolean; upper?: boolean;
}) {
  const h = size === 'lg' ? 60 : size === 'md' ? 48 : 38;
  const fs = size === 'lg' ? 21 : size === 'md' ? 17 : 14;
  const face = bg ?? (kind === 'primary' ? C.green : kind === 'danger' ? C.coral : kind === 'plain' ? C.white : C.cream);
  const ink = color ?? (kind === 'cream' || kind === 'plain' ? C.maroon : C.white);
  const depth = size === 'sm' ? 3 : 5;
  return (
    <Pressable onPress={onPress} disabled={disabled} style={[{ opacity: disabled ? 0.55 : 1 }, style]}>
      {({ pressed }) => (
        <View style={[{ borderRadius: R.lg, backgroundColor: C.maroon }, shadow]}>
          <View style={{
            transform: [{ translateY: pressed ? depth : 0 }],
            marginBottom: depth,
            height: h,
            borderRadius: R.lg,
            backgroundColor: face,
            borderWidth: STROKE,
            borderColor: C.maroon,
            alignItems: 'center',
            justifyContent: 'center',
            paddingHorizontal: 24,
          }}>
            <Txt size={fs} weight="900" color={ink} upper={upper}>{label}</Txt>
          </View>
        </View>
      )}
    </Pressable>
  );
}

export function Card({ children, style }: { children?: ReactNode; style?: StyleProp<ViewStyle> }) {
  return (
    <View style={[{ backgroundColor: C.card, borderRadius: R.lg, borderWidth: STROKE, borderColor: C.maroon, padding: 16 }, shadow, style]}>
      {children}
    </View>
  );
}

// Green pill toggle with a cream knob (Focus-Friend settings style).
export function Toggle({ on, onPress }: { on: boolean; onPress?: () => void }) {
  return (
    <Pressable onPress={onPress} style={{
      width: 64, height: 36, borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon,
      backgroundColor: on ? C.toggleOn : C.toggleOff, justifyContent: 'center', paddingHorizontal: 4,
    }}>
      <View style={{
        width: 24, height: 24, borderRadius: 12, backgroundColor: C.toggleKnob,
        borderWidth: 2, borderColor: C.maroon, alignSelf: on ? 'flex-end' : 'flex-start',
      }} />
    </Pressable>
  );
}

// White rounded resource counter (currency / streak) with a leading icon or emoji.
export function Pill({ icon, value, style }: { icon: ReactNode; value: ReactNode; style?: StyleProp<ViewStyle> }) {
  return (
    <View style={[{
      flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: C.white,
      borderRadius: R.pill, borderWidth: STROKE, borderColor: C.maroon, paddingHorizontal: 12, height: 38,
    }, shadow, style]}>
      {typeof icon === 'string' ? <Txt size={16}>{icon}</Txt> : icon}
      <Txt size={16} weight="900" color={C.maroon}>{value}</Txt>
    </View>
  );
}

// tinted silhouette icon
export function Icon({ src, size = 24, color = C.ink }: { src: any; size?: number; color?: string }) {
  return <Image source={src} style={{ width: size, height: size, tintColor: color, resizeMode: 'contain' }} />;
}

export function ProgressBar({ frac, color = C.green, bg = C.cream, height = 18 }: { frac: number; color?: string; bg?: string; height?: number }) {
  return (
    <View style={{ height, borderRadius: 999, backgroundColor: bg, borderWidth: STROKE, borderColor: C.maroon, overflow: 'hidden', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${Math.max(0, Math.min(1, frac)) * 100}%`, backgroundColor: color }} />
    </View>
  );
}
