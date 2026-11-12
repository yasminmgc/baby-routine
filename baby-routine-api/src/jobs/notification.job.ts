import cron from 'node-cron';
import { PrismaClient } from '@prisma/client';
import { sendPushNotification } from '../shared/utils/notifications';

const prisma = new PrismaClient();

export async function processPendingReminders(): Promise<void> {
  console.log('[NotificationJob] Checking pending reminders...');

  try {
    const now = new Date();

    const pendingReminders = await prisma.reminder.findMany({
      where: {
        triggerAt: { lte: now },
        sent: false,
        active: true,
      },
      include: {
        user: {
          select: {
            id: true,
            fcmToken: true,
          },
        },
      },
    });

    if (pendingReminders.length === 0) {
      return;
    }

    console.log(
      `[NotificationJob] Found ${pendingReminders.length} pending reminder(s)`
    );

    for (const reminder of pendingReminders) {
      try {
        const fcmToken = reminder.user.fcmToken;

        if (!fcmToken) {
          console.warn(
            `[NotificationJob] No FCM token for user ${reminder.user.id}, skipping reminder ${reminder.id}`
          );
          // Mark as sent to avoid retrying indefinitely for users without tokens
          await prisma.reminder.update({
            where: { id: reminder.id },
            data: { sent: true },
          });
          continue;
        }

        const title = reminder.description;
        const body = `Lembrete: ${reminder.reminderType}`;

        await sendPushNotification(fcmToken, title, body);

        await prisma.reminder.update({
          where: { id: reminder.id },
          data: { sent: true },
        });

        console.log(
          `[NotificationJob] Sent notification for reminder ${reminder.id} to user ${reminder.user.id}`
        );
      } catch (error) {
        console.error(
          `[NotificationJob] Failed to send notification for reminder ${reminder.id}:`,
          error instanceof Error ? error.message : error
        );
        // Continue to next reminder — do not crash the cron job
      }
    }
  } catch (error) {
    console.error(
      '[NotificationJob] Error querying pending reminders:',
      error instanceof Error ? error.message : error
    );
    // Do not crash the cron job
  }
}

export function startNotificationCron(): void {
  cron.schedule('* * * * *', processPendingReminders);

  console.log('[NotificationJob] Cron job started — checking reminders every minute');
}
