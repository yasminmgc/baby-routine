import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function findById(id: string) {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      email: true,
      createdAt: true,
    },
  });
}
