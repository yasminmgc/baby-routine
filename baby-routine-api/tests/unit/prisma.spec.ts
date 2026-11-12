import { PrismaClient } from '@prisma/client';

describe('Database setup', () => {
  it('should export all expected model types from Prisma client', () => {
    const prisma = new PrismaClient();
    
    // Verify Prisma client has all 9 models
    expect(prisma.user).toBeDefined();
    expect(prisma.baby).toBeDefined();
    expect(prisma.babyCaregiver).toBeDefined();
    expect(prisma.routineEvent).toBeDefined();
    expect(prisma.routine).toBeDefined();
    expect(prisma.reminder).toBeDefined();
    expect(prisma.healthRecord).toBeDefined();
    expect(prisma.growthMeasurement).toBeDefined();
    expect(prisma.note).toBeDefined();
  });
});
