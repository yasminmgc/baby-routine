import { env } from './config/env';
import app from './app';

app.listen(env.PORT, () => {
  console.log(`Server running on port ${env.PORT}`);
  console.log(`Swagger docs available at http://localhost:${env.PORT}/api/v1/docs`);
});

// Start the notification cron job (only in production)
if (env.NODE_ENV !== 'test') {
  import('./jobs/notification.job').then(({ startNotificationCron }) => {
    startNotificationCron();
  });
}

export default app;
