import { z } from 'zod';

export const createRoutineSchema = z.object({
  activityType: z.string().min(1, 'activityType is required'),
  intervalMinutes: z.number().int().positive().optional(),
  defaultStartTime: z.string().regex(/^\d{2}:\d{2}$/, 'Must be HH:MM format').optional(),
});

export const updateRoutineSchema = z.object({
  activityType: z.string().min(1).optional(),
  intervalMinutes: z.number().int().positive().optional(),
  defaultStartTime: z.string().regex(/^\d{2}:\d{2}$/, 'Must be HH:MM format').optional(),
});

export const toggleRoutineSchema = z.object({
  active: z.boolean(),
});

export const routineParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
  id: z.string().uuid('Invalid routine ID'),
});

export type CreateRoutineInput = z.infer<typeof createRoutineSchema>;
export type UpdateRoutineInput = z.infer<typeof updateRoutineSchema>;
export type ToggleRoutineInput = z.infer<typeof toggleRoutineSchema>;
