import { getMessaging } from '../../config/firebase';

export async function sendPushNotification(
  fcmToken: string,
  title: string,
  body: string
): Promise<void> {
  if (!fcmToken) {
    return;
  }

  await getMessaging().send({
    token: fcmToken,
    notification: { title, body },
    android: { priority: 'high' },
    apns: {
      payload: {
        aps: { sound: 'default' },
      },
    },
  });
}
