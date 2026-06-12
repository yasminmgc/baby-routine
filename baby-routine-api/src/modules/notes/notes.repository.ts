import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export async function create(data: {
  babyId: string;
  userId: string;
  content: string;
}) {
  return prisma.note.create({ data });
}

export async function findByBaby(babyId: string) {
  return prisma.note.findMany({
    where: { babyId },
    orderBy: { createdAt: 'desc' },
  });
}

export async function findById(id: string) {
  return prisma.note.findUnique({
    where: { id },
    include: { baby: true, user: { select: { id: true, name: true, email: true } } },
  });
}

export async function update(id: string, data: Prisma.NoteUpdateInput) {
  return prisma.note.update({ where: { id }, data });
}

export async function remove(id: string) {
  return prisma.note.delete({ where: { id } });
}
