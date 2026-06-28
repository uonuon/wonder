import { Redirect } from 'expo-router';
import { useStore } from '@/lib/store';

export default function Gate() {
  const onboarded = useStore((s) => s.onboarded);
  return <Redirect href={onboarded ? '/home' : '/onboarding'} />;
}
