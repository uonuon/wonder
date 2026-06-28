// The focus-session scene: painted background + the 3D wonder revealed from the
// ground up (frac 0..1) + companion + worker. Pure RN (works web + native).
import { Image, View } from 'react-native';
import { aspect, img } from '@/lib/assets';

export function BuildScene({
  width, height, bgKey, structKey, frac, charTex, night = 0, showWorker = true,
}: {
  width: number; height: number; bgKey: string; structKey: string;
  frac: number; charTex: string; night?: number; showWorker?: boolean;
}) {
  const W = width, H = height;
  const groundY = H * 0.72;
  const f = Math.max(0, Math.min(1, frac));

  // structure placement
  const targetH = groundY * 0.82;
  const dh = targetH;
  const dw = aspect(structKey) * dh;
  const sx = W * 0.56 - dw / 2;
  const sBottom = groundY + H * 0.17;
  const sTop = sBottom - dh;
  const revH = f * dh;
  const revTop = sBottom - revH;

  // character placement (left)
  const chh = H * 0.34;
  const chw = aspect(charTex) * chh;
  const chx = W * 0.16 - chw / 2;
  const chy = groundY + H * 0.14 - chh;

  // worker
  const wh = H * 0.16;
  const ww = aspect('p_worker') * wh;
  const wx = W * 0.34 - ww / 2;
  const wy = groundY + H * 0.15 - wh;

  return (
    <View style={{ width: W, height: H, overflow: 'hidden', backgroundColor: '#2a2030' }}>
      <Image source={img(bgKey)} style={{ position: 'absolute', left: 0, top: 0, width: W, height: H }} resizeMode="cover" />

      {/* ghost of the finished wonder */}
      <Image source={img(structKey)} style={{ position: 'absolute', left: sx, top: sTop, width: dw, height: dh, opacity: 0.12 }} resizeMode="stretch" />
      {/* revealed portion, clipped from the ground up */}
      {f > 0.002 && (
        <View style={{ position: 'absolute', left: sx, top: revTop, width: dw, height: revH, overflow: 'hidden' }}>
          <Image source={img(structKey)} style={{ position: 'absolute', left: 0, top: -(dh - revH), width: dw, height: dh }} resizeMode="stretch" />
        </View>
      )}
      {f > 0.002 && f < 0.999 && (
        <View style={{ position: 'absolute', left: sx, top: revTop - 1.5, width: dw, height: 3, backgroundColor: 'rgba(255,235,150,0.55)', borderRadius: 2 }} />
      )}

      {showWorker && f < 0.999 && (
        <Image source={img('p_worker')} style={{ position: 'absolute', left: wx, top: wy, width: ww, height: wh }} resizeMode="contain" />
      )}
      <Image source={img(charTex)} style={{ position: 'absolute', left: chx, top: chy, width: chw, height: chh }} resizeMode="contain" />

      {night > 0.05 && (
        <View style={{ position: 'absolute', left: 0, top: 0, width: W, height: H, backgroundColor: `rgba(26,30,74,${night * 0.22})` }} />
      )}
    </View>
  );
}
