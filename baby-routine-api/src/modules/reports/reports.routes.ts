import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  reportsParamsSchema,
  dateRangeQuerySchema,
  checklistQuerySchema,
} from './reports.schemas';
import * as reportsController from './reports.controller';

/**
 * @swagger
 * tags:
 *   name: Reports
 *   description: Aggregated reports (sleep, feeding, diapers, growth, medication) and daily checklist
 *
 * components:
 *   schemas:
 *     SleepReportItem:
 *       type: object
 *       properties:
 *         date:
 *           type: string
 *           format: date
 *         totalDurationMin:
 *           type: number
 *         eventsCount:
 *           type: integer
 *     FeedingReportItem:
 *       type: object
 *       properties:
 *         date:
 *           type: string
 *           format: date
 *         bottle:
 *           type: integer
 *         breast:
 *           type: integer
 *         solids:
 *           type: integer
 *     DiapersReportItem:
 *       type: object
 *       properties:
 *         date:
 *           type: string
 *           format: date
 *         pee:
 *           type: integer
 *         poop:
 *           type: integer
 *         both:
 *           type: integer
 *     GrowthReportItem:
 *       type: object
 *       properties:
 *         id:
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
 *     MedicationReportItem:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         occurredAt:
 *           type: string
 *           format: date-time
 *           nullable: true
 *         medicationName:
 *           type: string
 *         dose:
 *           type: string
 *         reason:
 *           type: string
 *           nullable: true
 *         notes:
 *           type: string
 *           nullable: true
 *     ChecklistItem:
 *       type: object
 *       properties:
 *         routineId:
 *           type: string
 *           format: uuid
 *           nullable: true
 *         activityType:
 *           type: string
 *         scheduledTime:
 *           type: string
 *         status:
 *           type: string
 *           enum: [completed, pending, missed]
 *         eventId:
 *           type: string
 *           format: uuid
 *           nullable: true
 *
 * /babies/{babyId}/reports/sleep:
 *   get:
 *     tags: [Reports]
 *     summary: Get sleep report — daily sleep duration totals
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
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *           example: "2026-01-01"
 *         description: Filter from this date (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *           example: "2026-01-31"
 *         description: Filter until this date (YYYY-MM-DD)
 *     responses:
 *       '200':
 *         description: Sleep report data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/SleepReportItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/reports/feeding:
 *   get:
 *     tags: [Reports]
 *     summary: Get feeding report — daily feeding counts by type
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
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter from this date (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter until this date (YYYY-MM-DD)
 *     responses:
 *       '200':
 *         description: Feeding report data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/FeedingReportItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/reports/diapers:
 *   get:
 *     tags: [Reports]
 *     summary: Get diapers report — daily diaper change counts by type
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
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter from this date (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter until this date (YYYY-MM-DD)
 *     responses:
 *       '200':
 *         description: Diapers report data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/DiapersReportItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/reports/growth:
 *   get:
 *     tags: [Reports]
 *     summary: Get growth report — measurements over time
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
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter from this date (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter until this date (YYYY-MM-DD)
 *     responses:
 *       '200':
 *         description: Growth report data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/GrowthReportItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/reports/medication:
 *   get:
 *     tags: [Reports]
 *     summary: Get medication report — list of medication events with drug details
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
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter from this date (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter until this date (YYYY-MM-DD)
 *     responses:
 *       '200':
 *         description: Medication report data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MedicationReportItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 *
 * /babies/{babyId}/checklist:
 *   get:
 *     tags: [Reports]
 *     summary: Get the daily checklist — routine items with status + orphan events for a given date
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
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *           example: "2026-01-15"
 *         description: Date to fetch checklist for (YYYY-MM-DD, defaults to today)
 *     responses:
 *       '200':
 *         description: Checklist items for the date
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ChecklistItem'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized
 *       '403':
 *         description: Forbidden
 *       '500':
 *         description: Internal server error
 */

const router = Router({ mergeParams: true });

router.use(authMiddleware);

// Sleep report
router.get(
  '/reports/sleep',
  validate({ params: reportsParamsSchema, query: dateRangeQuerySchema }),
  reportsController.getSleepReport
);

// Feeding report
router.get(
  '/reports/feeding',
  validate({ params: reportsParamsSchema, query: dateRangeQuerySchema }),
  reportsController.getFeedingReport
);

// Diapers report
router.get(
  '/reports/diapers',
  validate({ params: reportsParamsSchema, query: dateRangeQuerySchema }),
  reportsController.getDiapersReport
);

// Growth report
router.get(
  '/reports/growth',
  validate({ params: reportsParamsSchema, query: dateRangeQuerySchema }),
  reportsController.getGrowthReport
);

// Medication report
router.get(
  '/reports/medication',
  validate({ params: reportsParamsSchema, query: dateRangeQuerySchema }),
  reportsController.getMedicationReport
);

// Daily checklist
router.get(
  '/checklist',
  validate({ params: reportsParamsSchema, query: checklistQuerySchema }),
  reportsController.getChecklist
);

export default router;
