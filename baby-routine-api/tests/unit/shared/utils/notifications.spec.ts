describe('Utils - Notifications', () => {
  it('should export sendPushNotification function', () => {
    const { sendPushNotification } = require('src/shared/utils/notifications');
    expect(typeof sendPushNotification).toBe('function');
  });

  it('should not throw when fcmToken is empty', async () => {
    const { sendPushNotification } = require('src/shared/utils/notifications');
    await expect(
      sendPushNotification('', 'Test Title', 'Test Body')
    ).resolves.toBeUndefined();
  });
});
