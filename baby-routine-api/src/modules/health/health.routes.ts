import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import { listHealthSchema, healthParamsSchema } from './health.schemas';
import * as healthController from './health.controller';

/**
 * @swagger
 * tags:
 *   name: Health
 *   description: Health records (read-only, populated from events)
 *
 * components:
 *   schemas:
 *     HealthRecord:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         babyId:
 *           type: string
 *           format: uuid
 *         recordType:
 *           type: string
 *           enum: [appointment, vaccination, medication, exam]
 *         title:
 *           type: string
 *         description:
 *           type: string
 *           nullable: true
 *         occurredAt:
 *           type: string
 *           format: date-time
 *         createdAt:
 *           type: string
 *           format: date-time
 *
 * /babies/{babyId}/health:
 *   get:
 *     tags: [Health]
 *     summary: List health records for a baby, optionally filtered by type
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
 *           enum: [appointment, vaccination, medication, exam]
 *         description: Filter by health record type
 *     responses:
 *       '200':
 *         description: List of health records
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/HealthRecord'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 */

const router = Router({ mergeParams: true });

router.use(authMiddleware);

router.get(
  '/',
  validate({ params: healthParamsSchema, query: listHealthSchema }),
  healthController.list
);

export default router;
