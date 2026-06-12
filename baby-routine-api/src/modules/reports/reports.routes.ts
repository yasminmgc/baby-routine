import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  reportsParamsSchema,
  dateRangeQuerySchema,
  checklistQuerySchema,
} from './reports.schemas';
import * as reportsController from './reports.controller';

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
