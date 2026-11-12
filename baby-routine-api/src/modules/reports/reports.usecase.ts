import { PrismaClient } from '@prisma/client';
import { AppError } from '../../shared/errors/AppError';
import * as babiesRepository from '../babies/babies.repository';

const prisma = new PrismaClient();

interface DateRange {
  startDate?: string;
  endDate?: string;
}

function buildDateFilter(range: DateRange) {
  const occurredAt: Record<string, Date> = {};
  if (range.startDate) {
    // Start of day in UTC
    occurredAt.gte = new Date(range.startDate + 'T00:00:00.000Z');
  }
  if (range.endDate) {
    // End of day in UTC
    occurredAt.lte = new Date(range.endDate + 'T23:59:59.999Z');
  }
  return Object.keys(occurredAt).length > 0 ? occurredAt : undefined;
}

function buildMeasuredAtFilter(range: DateRange) {
  const measuredAt: Record<string, Date> = {};
  if (range.startDate) {
    measuredAt.gte = new Date(range.startDate + 'T00:00:00.000Z');
  }
  if (range.endDate) {
    measuredAt.lte = new Date(range.endDate + 'T23:59:59.999Z');
  }
  return Object.keys(measuredAt).length > 0 ? measuredAt : undefined;
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export class SleepReportUseCase {
  async execute(babyId: string, userId: string, range: DateRange) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const occurredAtFilter = buildDateFilter(range);

    const events = await prisma.routineEvent.findMany({
      where: {
        babyId,
        eventType: 'sleep',
        ...(occurredAtFilter ? { occurredAt: occurredAtFilter as any } : {}),
      },
      orderBy: { occurredAt: 'asc' },
    });

    // Group by date and sum duration
    const dailyTotals: Record<string, number> = {};

    for (const event of events) {
      if (!event.occurredAt) continue;
      const date = formatDate(event.occurredAt);
      const details = event.details as Record<string, unknown> | null;
      const durationMin = details?.durationMin as number | undefined;
      if (durationMin && typeof durationMin === 'number') {
        dailyTotals[date] = (dailyTotals[date] || 0) + durationMin;
      }
    }

    return Object.entries(dailyTotals)
      .map(([date, totalDurationMin]) => ({ date, totalDurationMin }))
      .sort((a, b) => a.date.localeCompare(b.date));
  }
}

export class FeedingReportUseCase {
  async execute(babyId: string, userId: string, range: DateRange) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const occurredAtFilter = buildDateFilter(range);

    const events = await prisma.routineEvent.findMany({
      where: {
        babyId,
        eventType: 'feeding',
        ...(occurredAtFilter ? { occurredAt: occurredAtFilter as any } : {}),
      },
      orderBy: { occurredAt: 'asc' },
    });

    // Group by date and count by feeding type
    const dailyCounts: Record<string, { bottle: number; breast: number; solids: number }> = {};

    for (const event of events) {
      if (!event.occurredAt) continue;
      const date = formatDate(event.occurredAt);
      const details = event.details as Record<string, unknown> | null;
      const feedingType = (details?.feedingType as string) || 'other';

      if (!dailyCounts[date]) {
        dailyCounts[date] = { bottle: 0, breast: 0, solids: 0 };
      }

      if (feedingType === 'bottle') dailyCounts[date].bottle++;
      else if (feedingType === 'breast') dailyCounts[date].breast++;
      else if (feedingType === 'solids') dailyCounts[date].solids++;
    }

    return Object.entries(dailyCounts)
      .map(([date, counts]) => ({ date, ...counts }))
      .sort((a, b) => a.date.localeCompare(b.date));
  }
}

export class DiapersReportUseCase {
  async execute(babyId: string, userId: string, range: DateRange) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const occurredAtFilter = buildDateFilter(range);

    const events = await prisma.routineEvent.findMany({
      where: {
        babyId,
        eventType: 'diaper',
        ...(occurredAtFilter ? { occurredAt: occurredAtFilter as any } : {}),
      },
      orderBy: { occurredAt: 'asc' },
    });

    // Group by date and count by type
    const dailyCounts: Record<string, { pee: number; poop: number; both: number }> = {};

    for (const event of events) {
      if (!event.occurredAt) continue;
      const date = formatDate(event.occurredAt);
      const details = event.details as Record<string, unknown> | null;
      const type = (details?.type as string) || 'other';

      if (!dailyCounts[date]) {
        dailyCounts[date] = { pee: 0, poop: 0, both: 0 };
      }

      if (type === 'pee') dailyCounts[date].pee++;
      else if (type === 'poop') dailyCounts[date].poop++;
      else if (type === 'both') dailyCounts[date].both++;
    }

    return Object.entries(dailyCounts)
      .map(([date, counts]) => ({ date, ...counts }))
      .sort((a, b) => a.date.localeCompare(b.date));
  }
}

export class GrowthReportUseCase {
  async execute(babyId: string, userId: string, range: DateRange) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const measuredAtFilter = buildMeasuredAtFilter(range);

    const measurements = await prisma.growthMeasurement.findMany({
      where: {
        babyId,
        ...(measuredAtFilter ? { measuredAt: measuredAtFilter as any } : {}),
      },
      orderBy: { measuredAt: 'asc' },
    });

    return measurements.map((m) => ({
      id: m.id,
      date: formatDate(m.measuredAt),
      weightKg: m.weightKg ? Number(m.weightKg) : null,
      heightCm: m.heightCm ? Number(m.heightCm) : null,
      headCircumferenceCm: m.headCircumferenceCm ? Number(m.headCircumferenceCm) : null,
      notes: m.notes,
    }));
  }
}

export class MedicationReportUseCase {
  async execute(babyId: string, userId: string, range: DateRange) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const occurredAtFilter = buildDateFilter(range);

    const events = await prisma.routineEvent.findMany({
      where: {
        babyId,
        eventType: 'medication',
        ...(occurredAtFilter ? { occurredAt: occurredAtFilter as any } : {}),
      },
      orderBy: { occurredAt: 'desc' },
    });

    return events.map((event) => {
      const details = event.details as Record<string, unknown> | null;
      return {
        id: event.id,
        date: event.occurredAt ? formatDate(event.occurredAt) : null,
        medicationName: (details?.medicationName as string) || null,
        dose: (details?.dose as string) || null,
        reason: (details?.reason as string) || null,
        notes: event.notes,
      };
    });
  }
}

export class ChecklistUseCase {
  async execute(babyId: string, userId: string, date?: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);
    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const targetDate = date || formatDate(new Date());
    const dayStart = new Date(targetDate + 'T00:00:00.000Z');
    const dayEnd = new Date(targetDate + 'T23:59:59.999Z');

    // Get active routines for this baby
    const routines = await prisma.routine.findMany({
      where: { babyId, active: true },
      orderBy: { createdAt: 'asc' },
    });

    // Get events that occurred on the target date
    const events = await prisma.routineEvent.findMany({
      where: {
        babyId,
        occurredAt: {
          gte: dayStart,
          lte: dayEnd,
        },
      },
      orderBy: { occurredAt: 'asc' },
    });

    // Build checklist items from routines
    const routineItems = routines.map((routine) => {
      // Check if any event of matching type exists for this routine on the date
      const matchingEvent = events.find(
        (e) =>
          e.eventType === routine.activityType &&
          e.routineId === routine.id
      );

      return {
        type: 'routine' as const,
        routineId: routine.id,
        activityType: routine.activityType,
        scheduledTime: routine.defaultStartTime || null,
        status: matchingEvent ? matchingEvent.status : 'pending',
        eventId: matchingEvent?.id || null,
      };
    });

    // Include events that aren't tied to a routine
    const orphanEventItems = events
      .filter((e) => !e.routineId)
      .map((event) => ({
        type: 'event' as const,
        eventId: event.id,
        eventType: event.eventType,
        occurredAt: event.occurredAt,
        status: event.status,
        notes: event.notes,
      }));

    return {
      date: targetDate,
      items: [...routineItems, ...orphanEventItems],
    };
  }
}
