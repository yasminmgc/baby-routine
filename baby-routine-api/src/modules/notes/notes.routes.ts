import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createNoteSchema,
  updateNoteSchema,
  noteParamsSchema,
} from './notes.schemas';
import * as notesController from './notes.controller';

/**
 * @swagger
 * tags:
 *   name: Notes
 *   description: Free-text notes for a baby
 *
 * components:
 *   schemas:
 *     CreateNote:
 *       type: object
 *       required:
 *         - content
 *       properties:
 *         content:
 *           type: string
 *     UpdateNote:
 *       type: object
 *       required:
 *         - content
 *       properties:
 *         content:
 *           type: string
 *     Note:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         content:
 *           type: string
 *         createdAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/notes:
 *   post:
 *     tags: [Notes]
 *     summary: Create a new note for a baby
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: babyId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateNote'
 *     responses:
 *       '201':
 *         description: Note created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Note'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Notes]
 *     summary: List all notes for a baby (ordered by creation date desc)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: babyId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     responses:
 *       '200':
 *         description: List of notes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Note'
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/notes/{id}:
 *   put:
 *     tags: [Notes]
 *     summary: Update a note's content
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: babyId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Note ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateNote'
 *     responses:
 *       '200':
 *         description: Note updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Note'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Note not found
 *       '500':
 *         description: Internal server error
 *   delete:
 *     tags: [Notes]
 *     summary: Delete a note
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: babyId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Note ID
 *     responses:
 *       '204':
 *         description: Note deleted
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Note not found
 *       '500':
 *         description: Internal server error
 */

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
