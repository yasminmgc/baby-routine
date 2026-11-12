import { z } from 'zod';

export const createBabySchema = z.object({
  name: z.string().min(1, 'Name is required'),
  birthDate: z.coerce.date({ message: 'Invalid birth date' }),
  gender: z.enum(['male', 'female', 'other']).optional(),
  initialWeightKg: z.number().positive('Weight must be positive').optional(),
  initialHeightCm: z.number().positive('Height must be positive').optional(),
  allergies: z.string().optional(),
});

export const updateBabySchema = z.object({
  name: z.string().min(1).optional(),
  birthDate: z.coerce.date({ message: 'Invalid birth date' }).optional(),
  gender: z.enum(['male', 'female', 'other']).optional(),
  initialWeightKg: z.number().positive('Weight must be positive').optional(),
  initialHeightCm: z.number().positive('Height must be positive').optional(),
  allergies: z.string().optional(),
});

export const babyIdParamsSchema = z.object({
  id: z.string().uuid('Invalid baby ID'),
});

export const addCaregiverSchema = z.object({
  email: z.string().email('Invalid email'),
});

export const caregiverParamsSchema = z.object({
  id: z.string().uuid('Invalid baby ID'),
  userId: z.string().uuid('Invalid user ID'),
});

export type CreateBabyInput = z.infer<typeof createBabySchema>;
export type UpdateBabyInput = z.infer<typeof updateBabySchema>;
export type AddCaregiverInput = z.infer<typeof addCaregiverSchema>;
