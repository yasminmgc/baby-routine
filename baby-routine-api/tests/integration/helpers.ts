import { PrismaClient } from '@prisma/client';
import { signToken } from 'src/shared/utils/jwt';
import { hashPassword } from 'src/shared/utils/bcrypt';

const prisma = new PrismaClient();

export async function cleanDatabase() {
  await prisma.routineEvent.deleteMany();
  await prisma.reminder.deleteMany();
  await prisma.healthRecord.deleteMany();
  await prisma.growthMeasurement.deleteMany();
  await prisma.note.deleteMany();
  await prisma.routine.deleteMany();
  await prisma.babyCaregiver.deleteMany();
  await prisma.baby.deleteMany();
  await prisma.user.deleteMany();
}

export async function createTestUser(name: string, email: string, password: string = 'Password1') {
  const passwordHash = await hashPassword(password);
  return prisma.user.create({
    data: { name, email, passwordHash },
  });
}

export function generateToken(userId: string, email: string): string {
  return signToken({ sub: userId, email });
}

export async function createTestUserWithToken(name: string, email: string, password: string = 'Password1') {
  const user = await createTestUser(name, email, password);
  const token = generateToken(user.id, user.email);
  return { user, token };
}

export async function createTestBaby(userId: string, babyName: string = 'Test Baby') {
  const baby = await prisma.baby.create({
    data: {
      name: babyName,
      birthDate: new Date('2025-06-01'),
      gender: 'female',
      initialWeightKg: 3.5,
      initialHeightCm: 50,
    },
  });

  await prisma.babyCaregiver.create({
    data: {
      babyId: baby.id,
      userId,
      role: 'owner',
    },
  });

  return baby;
}

export async function disconnectPrisma() {
  await prisma.$disconnect();
}

export { prisma };
