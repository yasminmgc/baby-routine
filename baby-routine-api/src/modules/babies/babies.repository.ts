import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export async function create(data: Prisma.BabyCreateInput) {
  return prisma.baby.create({ data });
}

export async function findById(id: string) {
  return prisma.baby.findUnique({ where: { id } });
}

export async function update(id: string, data: Prisma.BabyUpdateInput) {
  return prisma.baby.update({ where: { id }, data });
}

export async function remove(id: string) {
  return prisma.baby.delete({ where: { id } });
}

export async function findCaregiver(babyId: string, userId: string) {
  return prisma.babyCaregiver.findUnique({
    where: { babyId_userId: { babyId, userId } },
  });
}

export async function findAllByUser(userId: string) {
  return prisma.babyCaregiver.findMany({
    where: { userId },
    include: { baby: true },
  });
}

export function getClient() {
  return prisma;
}
