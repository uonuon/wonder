// Animated companion built on our character art. Three out-of-phase sine waves
// (bob, breathe, sway) read as "alive" without flipbook frames; a grounding
// shadow pulses with the bob so the character feels planted, not floating.
// Rive upgrade slot: drop a .riv into assets, `expo install rive-react-native`,
// and swap the <AImage> body for <Rive resourceName=... />. The props/celebrate
// contract here is designed to map straight onto a Rive state machine input.
import { useEffect } from 'react';
import { Image, View } from 'react-native';
import Animated, {
  Easing, interpolate, useAnimatedStyle, useSharedValue, withDelay, withRepeat, withSequence, withTiming,
} from 'react-native-reanimated';
import { img } from '@/lib/assets';
import { character } from '@/lib/catalog';
import { useStore } from '@/lib/store';

const AImage = Animated.createAnimatedComponent(Image);

export function Companion({ size = 240, celebrate = false }: { size?: number; celebrate?: boolean }) {
  const id = useStore((s) => s.equippedCharacter);
  const tex = character(id).tex;

  const bob = useSharedValue(0);      // vertical hover (0..1)
  const breathe = useSharedValue(0);  // chest rise (0..1), slightly faster than bob
  const sway = useSharedValue(0);     // gentle lean (-1..1)
  const pop = useSharedValue(0);      // celebrate impulse (0..1)

  useEffect(() => {
    bob.value = withRepeat(withTiming(1, { duration: 1900, easing: Easing.inOut(Easing.sin) }), -1, true);
    breathe.value = withRepeat(withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.sin) }), -1, true);
    // a longer, offset sway so the motion never looks like a single loop
    sway.value = withDelay(400, withRepeat(withTiming(1, { duration: 2600, easing: Easing.inOut(Easing.sin) }), -1, true));
  }, []);

  useEffect(() => {
    if (celebrate) {
      pop.value = withSequence(
        withTiming(1, { duration: 150, easing: Easing.out(Easing.back(2.2)) }),
        withTiming(0, { duration: 420, easing: Easing.inOut(Easing.quad) })
      );
    }
  }, [celebrate]);

  const charStyle = useAnimatedStyle(() => {
    const lift = interpolate(bob.value, [0, 1], [2, -6]);
    const sy = 1 + breathe.value * 0.03 + pop.value * 0.14;   // chest rise + celebrate stretch
    const sx = 2 - sy;                                         // preserve volume (squash/stretch)
    const rot = interpolate(sway.value, [0, 1], [-1.6, 1.6]) + pop.value * 0; // subtle lean
    return {
      transform: [
        { translateY: lift - pop.value * 10 },
        { rotateZ: `${rot}deg` },
        { scaleY: sy },
        { scaleX: sx },
      ],
    };
  });

  // shadow shrinks/lightens as the character rises — sells the hover
  const shadowStyle = useAnimatedStyle(() => {
    const s = interpolate(bob.value, [0, 1], [1, 0.84]);
    return { transform: [{ scaleX: s }], opacity: interpolate(bob.value, [0, 1], [0.22, 0.13]) };
  });

  return (
    <View style={{ width: size, height: size * 1.04, alignItems: 'center', justifyContent: 'flex-end' }}>
      <Animated.View
        style={[
          { position: 'absolute', bottom: size * 0.015, width: size * 0.52, height: size * 0.08, borderRadius: size * 0.04, backgroundColor: '#000' },
          shadowStyle,
        ]}
      />
      <AImage source={img(tex)} style={[{ width: size, height: size, resizeMode: 'contain' }, charStyle]} />
    </View>
  );
}
