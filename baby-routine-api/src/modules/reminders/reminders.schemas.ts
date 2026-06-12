import { z } from 'zod';

export const reminderTypeEnum = z.enum([
  'feeding',
  'sleep',
  'diaper',
  'bath',
  'appointment',
  'vaccination',
  'medication',
  'custom',
]);

export const recurrenceEnum = z.enum(['none', 'daily', 'interval']);

export const createReminderSchema = z.object({
  reminderType: reminderTypeEnum,
  description: z.string().min(1, 'Description is required'),
  triggerAt: z.coerce.date({ message: 'Invalid trigger date' }),
  recurrence: recurrenceEnum.optional(),
  routineId: z.string().uuid().optional(),
});

export const updateReminderSchema = z.object({
  reminderType: reminderTypeEnum.optional(),
  description: z.string().min(1).optional(),
  triggerAt: z.coerce.date({ message: 'Invalid trigger date' }).optional(),
  recurrence: recurrenceEnum.optional(),
  routineId: z.string().uuid().optional(),
});

export const reminderParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
  id: z.string().uuid('Invalid reminder ID'),
});

export type CreateReminderInput = z.infer<typeof createReminderSchema>;
export type UpdateReminderInput = z.infer<typeof updateReminderSchema>;
