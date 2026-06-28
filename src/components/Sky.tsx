// The sky world: a soft cyan background with hand-drawn puffy white clouds, drawn
// with SVG so it scales crisply at any size (no image assets). Used as the backdrop
// for Home / Onboarding / Style, mirroring Focus Friend's cozy sky.
import { ReactNode } from 'react';
import { useWindowDimensions, View } from 'react-native';
import Svg, { Circle, G, Path, Rect } from 'react-native-svg';
import { C } from '@/lib/theme';

// one puffy cloud in a 120×70 box, made of overlapping blobs + a flat base
function Cloud({ x, y, scale = 1, opacity = 1 }: { x: number; y: number; scale?: number; opacity?: number }) {
  return (
    <G x={x} y={y} scale={scale} opacity={opacity}>
      <Rect x={14} y={40} width={92} height={24} rx={14} fill={C.cloud} />
      <Circle cx={34} cy={46} r={20} fill={C.cloud} />
      <Circle cx={60} cy={36} r={28} fill={C.cloud} />
      <Circle cx={88} cy={44} r={22} fill={C.cloud} />
      <Circle cx={54} cy={28} r={17} fill={C.cloud} />
      {/* faint hand-drawn detail swirls */}
      <Path d="M40 50 q5 -6 11 -1" stroke={C.cloudLine} strokeWidth={2} fill="none" strokeLinecap="round" />
      <Path d="M70 46 q5 -6 11 -1" stroke={C.cloudLine} strokeWidth={2} fill="none" strokeLinecap="round" />
    </G>
  );
}

// Full-screen sky backdrop. Place screen content on top (zIndex above this).
export function SkyBackground({ children }: { children?: ReactNode }) {
  const { width, height } = useWindowDimensions();
  return (
    <View style={{ flex: 1, backgroundColor: C.sky }}>
      <Svg width={width} height={height} style={{ position: 'absolute', top: 0, left: 0 }}>
        <Cloud x={width * 0.42} y={height * 0.06} scale={1.25} />
        <Cloud x={-width * 0.12} y={height * 0.2} scale={0.95} opacity={0.96} />
        <Cloud x={width * 0.55} y={height * 0.74} scale={1.35} opacity={0.95} />
        <Cloud x={-width * 0.1} y={height * 0.86} scale={1.1} opacity={0.9} />
      </Svg>
      <View style={{ flex: 1 }}>{children}</View>
    </View>
  );
}

// A single cloud for a character to stand on. width sets the footprint.
export function CloudBase({ width = 220 }: { width?: number }) {
  const h = width * 0.5;
  return (
    <Svg width={width} height={h} viewBox="0 0 120 70">
      <Rect x={14} y={40} width={92} height={24} rx={14} fill={C.cloud} />
      <Circle cx={32} cy={46} r={20} fill={C.cloud} />
      <Circle cx={60} cy={38} r={26} fill={C.cloud} />
      <Circle cx={90} cy={46} r={20} fill={C.cloud} />
      <Path d="M38 52 q5 -6 11 -1" stroke={C.cloudLine} strokeWidth={2} fill="none" strokeLinecap="round" />
      <Path d="M72 50 q5 -6 11 -1" stroke={C.cloudLine} strokeWidth={2} fill="none" strokeLinecap="round" />
    </Svg>
  );
}
