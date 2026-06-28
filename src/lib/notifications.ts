// Local notifications: a single daily focus reminder, gated by the Settings toggle.
// Local-only (no push server). Web is a no-op. Requires a dev build to actually fire
// (Expo Go can't run this SDK). See README "Descoped → next steps".
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import { t } from './i18n';
import { useStore } from './store';

const DAILY_ID = 'tarkeez-daily-reminder';

// Surface notifications even while the app is foregrounded.
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: false,
    shouldSetBadge: false,
  }),
});

export async function ensurePermission(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  try {
    const current = await Notifications.getPermissionsAsync();
    if (current.granted) return true;
    if (!current.canAskAgain) return false;
    const req = await Notifications.requestPermissionsAsync();
    return req.granted;
  } catch {
    return false;
  }
}

// Schedule (or re-schedule) the daily reminder. Returns false if permission was denied
// so the caller can revert the Settings toggle.
export async function scheduleDailyReminder(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  const ok = await ensurePermission();
  if (!ok) return false;
  try {
    const { reminderHour, reminderMinute } = useStore.getState();
    await cancelDailyReminder();
    await Notifications.scheduleNotificationAsync({
      identifier: DAILY_ID,
      content: { title: t('notif_title'), body: t('notif_body') },
      trigger: {
        type: Notifications.SchedulableTriggerInputTypes.DAILY,
        hour: reminderHour,
        minute: reminderMinute,
      },
    });
    return true;
  } catch {
    return false;
  }
}

export async function cancelDailyReminder(): Promise<void> {
  if (Platform.OS === 'web') return;
  try {
    await Notifications.cancelScheduledNotificationAsync(DAILY_ID);
  } catch {}
}

// Called on app launch: keep the OS schedule in sync with the persisted preference
// WITHOUT prompting (re-asserting at startup shouldn't trigger a permission dialog).
// Only schedules when permission is already granted; otherwise leaves it to the user
// to (re)enable from Settings.
export async function syncReminder(enabled: boolean): Promise<void> {
  if (Platform.OS === 'web') return;
  if (!enabled) {
    await cancelDailyReminder();
    return;
  }
  try {
    const current = await Notifications.getPermissionsAsync();
    if (current.granted) await scheduleDailyReminder();
  } catch {}
}
