import { z } from 'zod';

export const createNoteSchema = z.object({
  content: z.string().min(1, 'Content is required'),
});

export const updateNoteSchema = z.object({
  content: z.string().min(1, 'Content is required'),
});

export const noteParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
  id: z.string().uuid('Invalid note ID'),
});

export type CreateNoteInput = z.infer<typeof createNoteSchema>;
export type UpdateNoteInput = z.infer<typeof updateNoteSchema>;
