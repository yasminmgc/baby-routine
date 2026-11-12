import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export interface CreateEventData {
  babyId: string;
  userId: string;
  eventType: string;
  occurredAt?: Date;
  scheduledAt?: Date;
  status?: string;
  details?: Prisma.InputJsonValue;
  notes?: string;
  routineId?: string;
}

export async function create(data: CreateEventData) {
  return prisma.routineEvent.create({ data });
}

export async function findById(id: string) {
  return prisma.routineEvent.findUnique({
    where: { id },
    include: { baby: true, user: { select: { id: true, name: true, email: true } } },
  });
}

export interface EventFilters {
  type?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
}

export async function findAllByBaby(babyId: string, filters: EventFilters) {
  const where: Prisma.RoutineEventWhereInput = { babyId };

  if (filters.type) {
    where.eventType = filters.type;
  }

  if (filters.startDate || filters.endDate) {
    where.occurredAt = {};
    if (filters.startDate) {
      (where.occurredAt as Prisma.DateTimeNullableFilter).gte = filters.startDate;
    }
    if (filters.endDate) {
      (where.occurredAt as Prisma.DateTimeNullableFilter).lte = filters.endDate;
    }
  }

  const page = filters.page ?? 1;
  const limit = Math.min(filters.limit ?? 20, 100);
  const skip = (page - 1) * limit;

  const [events, total] = await Promise.all([
    prisma.routineEvent.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, email: true } },
        routine: { select: { id: true, activityType: true } },
      },
      orderBy: { occurredAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.routineEvent.count({ where }),
  ]);

  return {
    data: events,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}

export async function update(id: string, data: Prisma.RoutineEventUpdateInput) {
  return prisma.routineEvent.update({ where: { id }, data });
}

export async function remove(id: string) {
  return prisma.routineEvent.delete({ where: { id } });
}
