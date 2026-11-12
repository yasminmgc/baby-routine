import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export async function create(data: {
  babyId: string;
  userId: string;
  activityType: string;
  intervalMinutes?: number;
  defaultStartTime?: string;
}) {
  return prisma.routine.create({ data });
}

export async function findByBaby(babyId: string) {
  return prisma.routine.findMany({
    where: { babyId },
    orderBy: { createdAt: 'asc' },
  });
}

export async function findById(id: string) {
  return prisma.routine.findUnique({
    where: { id },
    include: { baby: true, user: { select: { id: true, name: true, email: true } } },
  });
}

export async function update(id: string, data: Prisma.RoutineUpdateInput) {
  return prisma.routine.update({ where: { id }, data });
}

export async function remove(id: string) {
  return prisma.routine.delete({ where: { id } });
}

export async function toggleActive(id: string, active: boolean) {
  return prisma.routine.update({
    where: { id },
    data: { active },
  });
}
