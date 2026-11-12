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

/**
 * @swagger
 * tags:
 *   name: Events
 *   description: Routine events tracking (feeding, sleep, diaper, etc.)
 *
 * components:
 *   schemas:
 *     CreateEvent:
 *       type: object
 *       required:
 *         - eventType
 *       properties:
 *         eventType:
 *           type: string
 *           enum: [feeding, sleep, diaper, bath, appointment, vaccination, medication]
 *         details:
 *           type: object
 *           description: JSON object with event-type-specific fields
 *         occurredAt:
 *           type: string
 *           format: date-time
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *         status:
 *           type: string
 *           enum: [completed, missed, cancelled]
 *         routineId:
 *           type: string
 *           format: uuid
 *         notes:
 *           type: string
 *     UpdateEvent:
 *       type: object
 *       properties:
 *         details:
 *           type: object
 *         occurredAt:
 *           type: string
 *           format: date-time
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *         status:
 *           type: string
 *           enum: [completed, missed, cancelled]
 *         notes:
 *           type: string
 *     RoutineEvent:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         eventType:
 *           type: string
 *           enum: [feeding, sleep, diaper, bath, appointment, vaccination, medication]
 *         details:
 *           type: object
 *         occurredAt:
 *           type: string
 *           format: date-time
 *           nullable: true
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *           nullable: true
 *         status:
 *           type: string
 *           enum: [completed, missed, cancelled]
 *         routineId:
 *           type: string
 *           format: uuid
 *           nullable: true
 *         notes:
 *           type: string
 *           nullable: true
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/events:
 *   post:
 *     tags: [Events]
 *     summary: Create a new event for a baby
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
 *             $ref: '#/components/schemas/CreateEvent'
 *     responses:
 *       '201':
 *         description: Event created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RoutineEvent'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not a caregiver of this baby
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Events]
 *     summary: List events for a baby with optional filters
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
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [feeding, sleep, diaper, bath, appointment, vaccination, medication]
 *         description: Filter by event type
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter events from this date
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter events until this date
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *         description: Items per page
 *     responses:
 *       '200':
 *         description: Paginated list of events
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/RoutineEvent'
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/events/{id}:
 *   get:
 *     tags: [Events]
 *     summary: Get a single event by ID
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
 *         description: Event ID
 *     responses:
 *       '200':
 *         description: Event details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RoutineEvent'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '404':
 *         description: Event not found
 *       '500':
 *         description: Internal server error
 *   put:
 *     tags: [Events]
 *     summary: Update an event
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
 *         description: Event ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateEvent'
 *     responses:
 *       '200':
 *         description: Event updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RoutineEvent'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '404':
 *         description: Event not found
 *       '500':
 *         description: Internal server error
 *   delete:
 *     tags: [Events]
 *     summary: Delete an event
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
 *         description: Event ID
 *     responses:
 *       '204':
 *         description: Event deleted successfully
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '404':
 *         description: Event not found
 *       '500':
 *         description: Internal server error
 */

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
