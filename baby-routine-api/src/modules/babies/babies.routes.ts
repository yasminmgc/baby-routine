import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createBabySchema,
  updateBabySchema,
  babyIdParamsSchema,
} from './babies.schemas';
import * as babiesController from './babies.controller';

const router = Router();

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createBabySchema }),
  babiesController.create
);

router.get(
  '/',
  babiesController.list
);

router.get(
  '/:id',
  validate({ params: babyIdParamsSchema }),
  babiesController.getById
);

router.put(
  '/:id',
  validate({ params: babyIdParamsSchema, body: updateBabySchema }),
  babiesController.update
);

router.delete(
  '/:id',
  validate({ params: babyIdParamsSchema }),
  babiesController.remove
);

export default router;
