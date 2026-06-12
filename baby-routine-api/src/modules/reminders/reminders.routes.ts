import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createReminderSchema,
  updateReminderSchema,
  reminderParamsSchema,
} from './reminders.schemas';
import * as remindersController from './reminders.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createReminderSchema }),
  remindersController.create
);

router.get(
  '/',
  remindersController.list
);

router.put(
  '/:id',
  validate({ params: reminderParamsSchema, body: updateReminderSchema }),
  remindersController.update
);

router.delete(
  '/:id',
  validate({ params: reminderParamsSchema }),
  remindersController.remove
);

export default router;
