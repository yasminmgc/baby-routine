import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createMeasurementSchema,
  measurementParamsSchema,
} from './measurements.schemas';
import * as measurementsController from './measurements.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createMeasurementSchema }),
  measurementsController.create
);

router.get(
  '/',
  measurementsController.list
);

router.delete(
  '/:id',
  validate({ params: measurementParamsSchema }),
  measurementsController.remove
);

export default router;
