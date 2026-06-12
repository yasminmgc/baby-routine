import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import { registerSchema, loginSchema, fcmTokenSchema } from './auth.schemas';
import * as authController from './auth.controller';

const router = Router();

router.post(
  '/register',
  validate({ body: registerSchema }),
  authController.register
);

router.post(
  '/login',
  validate({ body: loginSchema }),
  authController.login
);

router.patch(
  '/fcm-token',
  authMiddleware,
  validate({ body: fcmTokenSchema }),
  authController.updateFcmToken
);

export default router;
