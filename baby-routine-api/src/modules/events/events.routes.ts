import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createEventSchema,
  updateEventSchema,
  eventIdParamsSchema,
  eventBabyIdParamsSchema,
} from './events.schemas';
import * as eventsController from './events.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createEventSchema }),
  eventsController.create
);

router.get(
  '/',
  eventsController.list
);

router.get(
  '/:id',
  validate({ params: eventIdParamsSchema }),
  eventsController.getById
);

router.put(
  '/:id',
  validate({ params: eventIdParamsSchema, body: updateEventSchema }),
  eventsController.update
);

router.delete(
  '/:id',
  validate({ params: eventIdParamsSchema }),
  eventsController.remove
);

export default router;
