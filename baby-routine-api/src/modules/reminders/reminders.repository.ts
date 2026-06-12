import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export async function create(data: {
  babyId: string;
  userId: string;
  reminderType: string;
  description: string;
  triggerAt: Date;
  recurrence?: string;
  routineId?: string;
}) {
  return prisma.reminder.create({ data });
}

export async function findByBaby(babyId: string) {
  return prisma.reminder.findMany({
    where: { babyId },
    orderBy: { triggerAt: 'asc' },
    include: {
      routine: { select: { id: true, activityType: true } },
    },
  });
}

export async function findById(id: string) {
  return prisma.reminder.findUnique({
    where: { id },
    include: {
      baby: true,
      user: { select: { id: true, name: true, email: true } },
      routine: { select: { id: true, activityType: true } },
    },
  });
}

export async function update(id: string, data: Prisma.ReminderUpdateInput) {
  return prisma.reminder.update({ where: { id }, data });
}

export async function remove(id: string) {
  return prisma.reminder.delete({ where: { id } });
}
