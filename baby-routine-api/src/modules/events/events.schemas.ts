import { z } from 'zod';

export const eventTypeEnum = z.enum([
  'feeding',
  'sleep',
  'diaper',
  'bath',
  'appointment',
  'vaccination',
  'medication',
]);

export const eventStatusEnum = z.enum(['completed', 'missed', 'cancelled']);

// ── Detail schemas per eventType ──

const feedingDetailsSchema = z.object({
  feedingType: z.enum(['bottle', 'breast', 'solids']),
  amountMl: z.number().positive().optional(),
  durationMin: z.number().positive().optional(),
});

const sleepDetailsSchema = z.object({
  startTime: z.string().datetime({ message: 'Invalid start time' }),
  endTime: z.string().datetime({ message: 'Invalid end time' }),
  durationMin: z.number().positive(),
  location: z.enum(['crib', 'bed', 'arms']),
});

const diaperDetailsSchema = z.object({
  type: z.enum(['pee', 'poop', 'both']),
  color: z.enum(['yellow', 'green', 'brown']).optional(),
  consistency: z.enum(['normal', 'pasty', 'liquid']).optional(),
  rash: z.boolean().optional(),
});

const bathDetailsSchema = z.object({
  temperature: z.string().optional(),
});

const appointmentDetailsSchema = z.object({
  professional: z.string().min(1),
  specialty: z.string().optional(),
  appointmentType: z.enum(['routine', 'urgent']).optional(),
  recommendations: z.string().optional(),
  requestedExams: z.array(z.string()).optional(),
});

const vaccinationDetailsSchema = z.object({
  vaccineName: z.string().min(1),
  lot: z.string().optional(),
  site: z.enum(['left thigh', 'right thigh', 'left arm', 'right arm']).optional(),
  appliedBy: z.string().optional(),
  reactions: z.string().optional(),
});

const medicationDetailsSchema = z.object({
  medicationName: z.string().min(1),
  dose: z.string().min(1),
  reason: z.string().optional(),
});

// ── Discriminated union for details validation ──

export const eventDetailsSchema = z.discriminatedUnion('eventType', [
  z.object({ eventType: z.literal('feeding'), details: feedingDetailsSchema }),
  z.object({ eventType: z.literal('sleep'), details: sleepDetailsSchema }),
  z.object({ eventType: z.literal('diaper'), details: diaperDetailsSchema }),
  z.object({ eventType: z.literal('bath'), details: bathDetailsSchema }),
  z.object({ eventType: z.literal('appointment'), details: appointmentDetailsSchema }),
  z.object({ eventType: z.literal('vaccination'), details: vaccinationDetailsSchema }),
  z.object({ eventType: z.literal('medication'), details: medicationDetailsSchema }),
]);

// ── Request schemas ──

export const createEventSchema = z.object({
  eventType: eventTypeEnum,
  details: z.record(z.unknown()).optional(),
  occurredAt: z.coerce.date({ message: 'Invalid occurred date' }).optional(),
  scheduledAt: z.coerce.date({ message: 'Invalid scheduled date' }).optional(),
  status: eventStatusEnum.optional(),
  routineId: z.string().uuid().optional(),
  notes: z.string().optional(),
});

export const updateEventSchema = z.object({
  details: z.record(z.unknown()).optional(),
  occurredAt: z.coerce.date({ message: 'Invalid occurred date' }).optional(),
  scheduledAt: z.coerce.date({ message: 'Invalid scheduled date' }).optional(),
  status: eventStatusEnum.optional(),
  notes: z.string().optional(),
});

export const listEventsQuerySchema = z.object({
  type: eventTypeEnum.optional(),
  startDate: z.coerce.date({ message: 'Invalid start date' }).optional(),
  endDate: z.coerce.date({ message: 'Invalid end date' }).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export const eventIdParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
  id: z.string().uuid('Invalid event ID'),
});

export const eventBabyIdParamsSchema = z.object({
  babyId: z.string().uuid('Invalid baby ID'),
});

export type CreateEventInput = z.infer<typeof createEventSchema>;
export type UpdateEventInput = z.infer<typeof updateEventSchema>;
export type ListEventsQuery = z.infer<typeof listEventsQuerySchema>;
