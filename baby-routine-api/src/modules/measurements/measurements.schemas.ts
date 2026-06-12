import { z } from 'zod';

export const createMeasurementSchema = z.object({
  measuredAt: z.coerce.date(),
  weightKg: z.number().positive().optional(),
  heightCm: z.number().positive().optional(),
  headCircumferenceCm: z.number().positive().optional(),
  notes: z.string().optional(),
});

export const measurementParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
  id: z.string().uuid('Invalid measurement ID'),
});

export type CreateMeasurementInput = z.infer<typeof createMeasurementSchema>;
