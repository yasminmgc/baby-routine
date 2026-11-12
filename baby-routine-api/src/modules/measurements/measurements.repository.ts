import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function create(data: {
  babyId: string;
  userId: string;
  measuredAt: Date;
  weightKg?: number;
  heightCm?: number;
  headCircumferenceCm?: number;
  notes?: string;
}) {
  return prisma.growthMeasurement.create({ data });
}

export async function findByBaby(babyId: string) {
  return prisma.growthMeasurement.findMany({
    where: { babyId },
    orderBy: { measuredAt: 'desc' },
  });
}

export async function findById(id: string) {
  return prisma.growthMeasurement.findUnique({
    where: { id },
    include: { baby: true, user: { select: { id: true, name: true, email: true } } },
  });
}

export async function remove(id: string) {
  return prisma.growthMeasurement.delete({ where: { id } });
}
