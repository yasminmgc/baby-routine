import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface CreateUserData {
  name: string;
  email: string;
  passwordHash: string;
}

export async function findByEmail(email: string) {
  return prisma.user.findUnique({ where: { email } });
}

export async function createUser(data: CreateUserData) {
  return prisma.user.create({ data });
}

export async function updateFcmToken(userId: string, fcmToken: string) {
  return prisma.user.update({
    where: { id: userId },
    data: { fcmToken },
  });
}
