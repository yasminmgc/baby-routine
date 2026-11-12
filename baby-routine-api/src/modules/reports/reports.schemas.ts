import { z } from 'zod';

export const dateRangeQuerySchema = z.object({
  startDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'startDate must be YYYY-MM-DD')
    .optional(),
  endDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'endDate must be YYYY-MM-DD')
    .optional(),
});

export const checklistQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD')
    .optional(),
});

export const reportsParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
});

export type DateRangeQuery = z.infer<typeof dateRangeQuerySchema>;
export type ChecklistQuery = z.infer<typeof checklistQuerySchema>;
