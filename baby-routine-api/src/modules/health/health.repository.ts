import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function findByBaby(babyId: string, type?: string) {
  return prisma.healthRecord.findMany({
    where: {
      babyId,
      ...(type ? { recordType: type } : {}),
    },
    orderBy: { occurredAt: 'desc' },
  });
}
