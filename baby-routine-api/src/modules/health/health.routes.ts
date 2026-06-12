import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import { listHealthSchema, healthParamsSchema } from './health.schemas';
import * as healthController from './health.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.get(
  '/',
  validate({ params: healthParamsSchema, query: listHealthSchema }),
  healthController.list
);

export default router;
