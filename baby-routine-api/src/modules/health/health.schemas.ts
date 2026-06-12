import { z } from 'zod';

export const listHealthSchema = z.object({
  type: z
    .enum(['appointment', 'vaccination', 'medication', 'exam'])
    .optional(),
});

export const healthParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
});

export type ListHealthQuery = z.infer<typeof listHealthSchema>;
