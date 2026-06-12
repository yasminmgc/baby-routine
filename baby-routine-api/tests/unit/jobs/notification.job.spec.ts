// Mock PrismaClient
const mockReminderFindMany = jest.fn();
const mockReminderUpdate = jest.fn();

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    reminder: {
      findMany: mockReminderFindMany,
      update: mockReminderUpdate,
    },
  })),
}));

// Mock sendPushNotification
const mockSendPushNotification = jest.fn();
jest.mock('src/shared/utils/notifications', () => ({
  sendPushNotification: mockSendPushNotification,
}));

// Mock node-cron (just to avoid importing the real module)
jest.mock('node-cron', () => ({
  schedule: jest.fn(),
}));

// Dynamic import the module under test
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { processPendingReminders, startNotificationCron } = require('src/jobs/notification.job');

describe('processPendingReminders', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(console, 'log').mockImplementation(() => {});
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  it('should query reminders where triggerAt <= now, sent=false, active=true', async () => {
    mockReminderFindMany.mockResolvedValue([]);

    await processPendingReminders();

    expect(mockReminderFindMany).toHaveBeenCalledWith({
      where: {
        triggerAt: { lte: expect.any(Date) },
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
  });

  it('should not send notifications when there are no pending reminders', async () => {
    mockReminderFindMany.mockResolvedValue([]);

    await processPendingReminders();

    expect(mockReminderUpdate).not.toHaveBeenCalled();
    expect(mockSendPushNotification).not.toHaveBeenCalled();
  });

  it('should send push notification and mark as sent for pending reminders', async () => {
    const mockReminder = {
      id: 'reminder-1',
      reminderType: 'feeding',
      description: 'Hora da mamadeira',
      user: {
        id: 'user-1',
        fcmToken: 'fcm-token-abc',
      },
    };

    mockReminderFindMany.mockResolvedValue([mockReminder]);
    mockReminderUpdate.mockResolvedValue({ ...mockReminder, sent: true });
    mockSendPushNotification.mockResolvedValue(undefined);

    await processPendingReminders();

    expect(mockSendPushNotification).toHaveBeenCalledWith(
      'fcm-token-abc',
      'Hora da mamadeira',
      'Lembrete: feeding'
    );

    expect(mockReminderUpdate).toHaveBeenCalledWith({
      where: { id: 'reminder-1' },
      data: { sent: true },
    });
  });

  it('should handle reminders for users without FCM token (mark as sent, skip notification)', async () => {
    const mockReminder = {
      id: 'reminder-1',
      reminderType: 'feeding',
      description: 'Hora da mamadeira',
      user: {
        id: 'user-1',
        fcmToken: null,
      },
    };

    mockReminderFindMany.mockResolvedValue([mockReminder]);
    mockReminderUpdate.mockResolvedValue({ ...mockReminder, sent: true });

    await processPendingReminders();

    expect(mockSendPushNotification).not.toHaveBeenCalled();
    // Should still mark as sent to avoid retrying
    expect(mockReminderUpdate).toHaveBeenCalledWith({
      where: { id: 'reminder-1' },
      data: { sent: true },
    });
    expect(console.warn).toHaveBeenCalledWith(
      expect.stringContaining('No FCM token')
    );
  });

  it('should continue to next reminder when sendPushNotification fails', async () => {
    const reminder1 = {
      id: 'reminder-1',
      reminderType: 'feeding',
      description: 'Mamadeira',
      user: { id: 'user-1', fcmToken: 'token-1' },
    };
    const reminder2 = {
      id: 'reminder-2',
      reminderType: 'sleep',
      description: 'Hora da soneca',
      user: { id: 'user-2', fcmToken: 'token-2' },
    };

    mockReminderFindMany.mockResolvedValue([reminder1, reminder2]);

    // First notification fails
    mockSendPushNotification
      .mockRejectedValueOnce(new Error('Firebase error'))
      // Second notification succeeds
      .mockResolvedValueOnce(undefined);

    mockReminderUpdate.mockResolvedValue({ ...reminder2, sent: true });

    await processPendingReminders();

    // Both reminders should be attempted
    expect(mockSendPushNotification).toHaveBeenCalledTimes(2);
    // First failed — should log error
    expect(console.error).toHaveBeenCalledWith(
      expect.stringContaining('Failed to send notification for reminder reminder-1'),
      'Firebase error'
    );
    // Second succeeded — should be marked as sent
    expect(mockReminderUpdate).toHaveBeenCalledWith({
      where: { id: 'reminder-2' },
      data: { sent: true },
    });
  });

  it('should not crash the cron job when querying reminders fails', async () => {
    mockReminderFindMany.mockRejectedValue(new Error('Database connection error'));

    // Should not throw
    await expect(processPendingReminders()).resolves.toBeUndefined();

    expect(console.error).toHaveBeenCalledWith(
      expect.stringContaining('Error querying pending reminders'),
      'Database connection error'
    );
  });

  it('should handle multiple pending reminders', async () => {
    const reminders = [
      {
        id: 'reminder-1',
        reminderType: 'feeding',
        description: 'Mamadeira',
        user: { id: 'user-1', fcmToken: 'token-1' },
      },
      {
        id: 'reminder-2',
        reminderType: 'sleep',
        description: 'Soneca',
        user: { id: 'user-2', fcmToken: 'token-2' },
      },
      {
        id: 'reminder-3',
        reminderType: 'medication',
        description: 'Vitamina D',
        user: { id: 'user-3', fcmToken: 'token-3' },
      },
    ];

    mockReminderFindMany.mockResolvedValue(reminders);
    mockSendPushNotification.mockResolvedValue(undefined);
    mockReminderUpdate.mockResolvedValue({ sent: true });

    await processPendingReminders();

    expect(mockSendPushNotification).toHaveBeenCalledTimes(3);
    expect(mockReminderUpdate).toHaveBeenCalledTimes(3);
  });
});

describe('startNotificationCron', () => {
  it('should export startNotificationCron function', () => {
    expect(typeof startNotificationCron).toBe('function');
  });
});
