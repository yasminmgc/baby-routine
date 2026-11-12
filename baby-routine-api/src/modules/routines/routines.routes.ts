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

/**
 * @swagger
 * tags:
 *   name: Routines
 *   description: Baby routine configuration and management
 *
 * components:
 *   schemas:
 *     CreateRoutine:
 *       type: object
 *       required:
 *         - activityType
 *       properties:
 *         activityType:
 *           type: string
 *           description: Type of routine activity
 *         intervalMinutes:
 *           type: integer
 *         defaultStartTime:
 *           type: string
 *           pattern: ^\d{2}:\d{2}$
 *           example: "08:00"
 *     UpdateRoutine:
 *       type: object
 *       properties:
 *         activityType:
 *           type: string
 *         intervalMinutes:
 *           type: integer
 *         defaultStartTime:
 *           type: string
 *           pattern: ^\d{2}:\d{2}$
 *     ToggleRoutine:
 *       type: object
 *       required:
 *         - active
 *       properties:
 *         active:
 *           type: boolean
 *     Routine:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         activityType:
 *           type: string
 *         intervalMinutes:
 *           type: integer
 *           nullable: true
 *         defaultStartTime:
 *           type: string
 *           nullable: true
 *         active:
 *           type: boolean
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/routines:
 *   post:
 *     tags: [Routines]
 *     summary: Create a new routine for a baby
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
 *             $ref: '#/components/schemas/CreateRoutine'
 *     responses:
 *       '201':
 *         description: Routine created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Routine'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Routines]
 *     summary: List all routines for a baby
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
 *         description: List of routines
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Routine'
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/routines/{id}:
 *   put:
 *     tags: [Routines]
 *     summary: Update a routine
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
 *         description: Routine ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateRoutine'
 *     responses:
 *       '200':
 *         description: Routine updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Routine'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '404':
 *         description: Routine not found
 *       '500':
 *         description: Internal server error
 *   delete:
 *     tags: [Routines]
 *     summary: Delete a routine
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
 *         description: Routine ID
 *     responses:
 *       '204':
 *         description: Routine deleted
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Routine not found
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/routines/{id}/toggle:
 *   patch:
 *     tags: [Routines]
 *     summary: Toggle a routine active/inactive
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
 *         description: Routine ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ToggleRoutine'
 *     responses:
 *       '200':
 *         description: Routine toggled
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Routine'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Routine not found
 *       '500':
 *         description: Internal server error
 */

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
