import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createRoutineSchema,
  updateRoutineSchema,
  toggleRoutineSchema,
  routineParamsSchema,
} from './routines.schemas';
import * as routinesController from './routines.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createRoutineSchema }),
  routinesController.create
);

router.get(
  '/',
  routinesController.list
);

router.put(
  '/:id',
  validate({ params: routineParamsSchema, body: updateRoutineSchema }),
  routinesController.update
);

router.delete(
  '/:id',
  validate({ params: routineParamsSchema }),
  routinesController.remove
);

router.patch(
  '/:id/toggle',
  validate({ params: routineParamsSchema, body: toggleRoutineSchema }),
  routinesController.toggle
);

export default router;
