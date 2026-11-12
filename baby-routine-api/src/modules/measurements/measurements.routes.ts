import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createMeasurementSchema,
  measurementParamsSchema,
} from './measurements.schemas';
import * as measurementsController from './measurements.controller';

/**
 * @swagger
 * tags:
 *   name: Measurements
 *   description: Growth measurements tracking (weight, height, head circumference)
 *
 * components:
 *   schemas:
 *     CreateMeasurement:
 *       type: object
 *       required:
 *         - measuredAt
 *       properties:
 *         measuredAt:
 *           type: string
 *           format: date-time
 *         weightKg:
 *           type: number
 *         heightCm:
 *           type: number
 *         headCircumferenceCm:
 *           type: number
 *         notes:
 *           type: string
 *     GrowthMeasurement:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         measuredAt:
 *           type: string
 *           format: date-time
 *         weightKg:
 *           type: number
 *           nullable: true
 *         heightCm:
 *           type: number
 *           nullable: true
 *         headCircumferenceCm:
 *           type: number
 *           nullable: true
 *         notes:
 *           type: string
 *           nullable: true
 *         createdAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/measurements:
 *   post:
 *     tags: [Measurements]
 *     summary: Record a new growth measurement
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
 *             $ref: '#/components/schemas/CreateMeasurement'
 *     responses:
 *       '201':
 *         description: Measurement recorded
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/GrowthMeasurement'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Measurements]
 *     summary: List growth measurements for a baby (ordered by date desc)
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
 *         description: List of measurements
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/GrowthMeasurement'
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/measurements/{id}:
 *   delete:
 *     tags: [Measurements]
 *     summary: Delete a growth measurement
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
 *         description: Measurement ID
 *     responses:
 *       '204':
 *         description: Measurement deleted
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '404':
 *         description: Measurement not found
 *       '500':
 *         description: Internal server error
 */

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
