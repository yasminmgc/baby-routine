import { Router } from 'express';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import * as usersController from './users.controller';

const router = Router();

router.get(
  '/:id',
  authMiddleware,
  usersController.getUserProfile
);

export default router;
