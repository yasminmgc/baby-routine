import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createNoteSchema,
  updateNoteSchema,
  noteParamsSchema,
} from './notes.schemas';
import * as notesController from './notes.controller';

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createNoteSchema }),
  notesController.create
);

router.get(
  '/',
  notesController.list
);

router.put(
  '/:id',
  validate({ params: noteParamsSchema, body: updateNoteSchema }),
  notesController.update
);

router.delete(
  '/:id',
  validate({ params: noteParamsSchema }),
  notesController.remove
);

export default router;
