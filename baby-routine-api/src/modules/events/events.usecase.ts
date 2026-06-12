import { AppError } from '../../shared/errors/AppError';
import * as eventsRepository from './events.repository';
import * as babiesRepository from '../babies/babies.repository';
import {
  eventDetailsSchema,
  CreateEventInput,
  UpdateEventInput,
  ListEventsQuery,
} from './events.schemas';

export class CreateEventUseCase {
  async execute(babyId: string, userId: string, input: CreateEventInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    // Validate details against the discriminated union schema
    if (input.details) {
      const parsed = eventDetailsSchema.safeParse({
        eventType: input.eventType,
        details: input.details,
      });

      if (!parsed.success) {
        throw new AppError(
          parsed.error.errors.map((e) => e.message).join('; '),
          400,
          'VALIDATION_ERROR'
        );
      }
    }

    const event = await eventsRepository.create({
      babyId,
      userId,
      eventType: input.eventType,
      occurredAt: input.occurredAt ?? new Date(),
      scheduledAt: input.scheduledAt,
      status: input.status ?? 'completed',
      details: input.details as any,
      notes: input.notes,
      routineId: input.routineId,
    });

    return this.formatEvent(event);
  }

  private formatEvent(event: any) {
    return {
      id: event.id,
      babyId: event.babyId,
      userId: event.userId,
      eventType: event.eventType,
      occurredAt: event.occurredAt,
      scheduledAt: event.scheduledAt,
      status: event.status,
      details: event.details,
      notes: event.notes,
      routineId: event.routineId,
      createdAt: event.createdAt,
    };
  }
}

export class ListEventsUseCase {
  async execute(babyId: string, userId: string, query: ListEventsQuery) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    return eventsRepository.findAllByBaby(babyId, {
      type: query.type,
      startDate: query.startDate,
      endDate: query.endDate,
      page: query.page,
      limit: query.limit,
    });
  }
}

export class GetEventUseCase {
  async execute(babyId: string, eventId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const event = await eventsRepository.findById(eventId);

    if (!event) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    if (event.babyId !== babyId) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    return event;
  }
}

export class UpdateEventUseCase {
  async execute(babyId: string, eventId: string, userId: string, input: UpdateEventInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await eventsRepository.findById(eventId);

    if (!existing) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    return eventsRepository.update(eventId, input as any);
  }
}

export class DeleteEventUseCase {
  async execute(babyId: string, eventId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await eventsRepository.findById(eventId);

    if (!existing) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Event not found', 404, 'NOT_FOUND');
    }

    await eventsRepository.remove(eventId);
  }
}
