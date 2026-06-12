import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createReminderSchema,
  updateReminderSchema,
  reminderParamsSchema,
} from './reminders.schemas';
import * as remindersController from './reminders.controller';

/**
 * @swagger
 * tags:
 *   name: Reminders
 *   description: Push notification reminder configuration
 *
 * components:
 *   schemas:
 *     CreateReminder:
 *       type: object
 *       required:
 *         - reminderType
 *         - description
 *         - triggerAt
 *       properties:
 *         reminderType:
 *           type: string
 *           enum: [feeding, sleep, diaper, bath, appointment, vaccination, medication, custom]
 *         description:
 *           type: string
 *         triggerAt:
 *           type: string
 *           format: date-time
 *         recurrence:
 *           type: string
 *           enum: [none, daily, interval]
 *         routineId:
 *           type: string
 *           format: uuid
 *     UpdateReminder:
 *       type: object
 *       properties:
 *         reminderType:
 *           type: string
 *           enum: [feeding, sleep, diaper, bath, appointment, vaccination, medication, custom]
 *         description:
 *           type: string
 *         triggerAt:
 *           type: string
 *           format: date-time
 *         recurrence:
 *           type: string
 *           enum: [none, daily, interval]
 *         routineId:
 *           type: string
 *           format: uuid
 *     Reminder:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         reminderType:
 *           type: string
 *         description:
 *           type: string
 *         triggerAt:
 *           type: string
 *           format: date-time
 *         recurrence:
 *           type: string
 *           nullable: true
 *         routineId:
 *           type: string
 *           format: uuid
 *           nullable: true
 *         active:
 *           type: boolean
 *         sent:
 *           type: boolean
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/reminders:
 *   post:
 *     tags: [Reminders]
 *     summary: Create a new reminder for a baby
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
 *             $ref: '#/components/schemas/CreateReminder'
 *     responses:
 *       '201':
 *         description: Reminder created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reminder'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Reminders]
 *     summary: List all reminders for a baby
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
 *         description: List of reminders
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Reminder'
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/reminders/{id}:
 *   put:
 *     tags: [Reminders]
 *     summary: Update a reminder
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
 *         description: Reminder ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateReminder'
 *     responses:
 *       '200':
 *         description: Reminder updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reminder'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Reminder not found
 *       '500':
 *         description: Internal server error
 *   delete:
 *     tags: [Reminders]
 *     summary: Delete a reminder
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
 *         description: Reminder ID
 *     responses:
 *       '204':
 *         description: Reminder deleted
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Reminder not found
 *       '500':
 *         description: Internal server error
 */

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
