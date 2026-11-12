import admin from 'firebase-admin';
import { env } from './env';

let firebaseInitialized = false;

function getFirebaseApp(): admin.app.App {
  if (!firebaseInitialized) {
    if (admin.apps.length > 0) {
      firebaseInitialized = true;
      return admin.apps[0] as admin.app.App;
    }

    // In test environments, firebase-admin may not have valid credentials.
    // Instead of crashing, initialize with a mock app that won't actually send.
    if (env.NODE_ENV === 'test') {
      admin.initializeApp({
        projectId: 'test-project',
      });
      firebaseInitialized = true;
      return admin.apps[0] as admin.app.App;
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.FIREBASE_PROJECT_ID,
        clientEmail: env.FIREBASE_CLIENT_EMAIL,
        privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
    firebaseInitialized = true;
  }
  return admin.apps[0] as admin.app.App;
}

export function getMessaging(): admin.messaging.Messaging {
  const app = getFirebaseApp();
  return app.messaging();
}

export default getFirebaseApp;
