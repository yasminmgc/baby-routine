// Mock PrismaClient before any module loads
const mockRoutineEventFindMany = jest.fn();
const mockGrowthFindMany = jest.fn();
const mockRoutineFindMany = jest.fn();

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    routineEvent: {
      findMany: mockRoutineEventFindMany,
    },
    growthMeasurement: {
      findMany: mockGrowthFindMany,
    },
    routine: {
      findMany: mockRoutineFindMany,
    },
  })),
}));

jest.mock('src/modules/babies/babies.repository');

import {
  SleepReportUseCase,
  FeedingReportUseCase,
  DiapersReportUseCase,
  GrowthReportUseCase,
  MedicationReportUseCase,
  ChecklistUseCase,
} from 'src/modules/reports/reports.usecase';
import * as babiesRepository from 'src/modules/babies/babies.repository';

const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

const caregiver = {
  id: 'cg-1',
  babyId: 'baby-1',
  userId: 'user-1',
  role: 'owner' as const,
  createdAt: new Date(),
};

describe('SleepReportUseCase', () => {
  let useCase: SleepReportUseCase;

  beforeEach(() => {
    useCase = new SleepReportUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should aggregate sleep duration per day', async () => {
    const events = [
      {
        id: '1', babyId: 'baby-1', userId: 'user-1', eventType: 'sleep',
        occurredAt: new Date('2025-06-01T10:00:00Z'),
        details: { startTime: '2025-06-01T08:00:00Z', endTime: '2025-06-01T09:00:00Z', durationMin: 60, location: 'crib' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '2', babyId: 'baby-1', userId: 'user-1', eventType: 'sleep',
        occurredAt: new Date('2025-06-01T15:00:00Z'),
        details: { startTime: '2025-06-01T13:00:00Z', endTime: '2025-06-01T14:30:00Z', durationMin: 90, location: 'crib' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '3', babyId: 'baby-1', userId: 'user-1', eventType: 'sleep',
        occurredAt: new Date('2025-06-02T10:00:00Z'),
        details: { startTime: '2025-06-02T08:00:00Z', endTime: '2025-06-02T09:00:00Z', durationMin: 45, location: 'bed' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
    ];

    mockRoutineEventFindMany.mockResolvedValue(events);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toHaveLength(2);
    expect(result[0]).toEqual({ date: '2025-06-01', totalDurationMin: 150 });
    expect(result[1]).toEqual({ date: '2025-06-02', totalDurationMin: 45 });
  });

  it('should filter by date range', async () => {
    mockRoutineEventFindMany.mockResolvedValue([]);

    await useCase.execute('baby-1', 'user-1', { startDate: '2025-06-01', endDate: '2025-06-10' });

    expect(mockRoutineEventFindMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          babyId: 'baby-1',
          eventType: 'sleep',
          occurredAt: {
            gte: new Date('2025-06-01T00:00:00.000Z'),
            lte: new Date('2025-06-10T23:59:59.999Z'),
          },
        }),
      })
    );
  });

  it('should return empty array with no sleep events', async () => {
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toEqual([]);
  });

  it('should skip events without occurredAt', async () => {
    mockRoutineEventFindMany.mockResolvedValue([
      {
        id: '1', babyId: 'baby-1', userId: 'user-1', eventType: 'sleep',
        occurredAt: null,
        details: { durationMin: 60 },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
    ]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toEqual([]);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', {})).rejects.toThrow('Access denied');
  });
});

describe('FeedingReportUseCase', () => {
  let useCase: FeedingReportUseCase;

  beforeEach(() => {
    useCase = new FeedingReportUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should count feedings per day grouped by type', async () => {
    const events = [
      {
        id: '1', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-01T10:00:00Z'),
        details: { feedingType: 'bottle', amountMl: 120, durationMin: 15 },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '2', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-01T14:00:00Z'),
        details: { feedingType: 'breast', durationMin: 20 },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '3', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-02T10:00:00Z'),
        details: { feedingType: 'bottle', amountMl: 150 },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '4', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-02T12:00:00Z'),
        details: { feedingType: 'solids', amountMl: 80 },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
    ];

    mockRoutineEventFindMany.mockResolvedValue(events);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toHaveLength(2);
    expect(result[0]).toEqual({ date: '2025-06-01', bottle: 1, breast: 1, solids: 0 });
    expect(result[1]).toEqual({ date: '2025-06-02', bottle: 1, breast: 0, solids: 1 });
  });

  it('should return empty array with no feeding events', async () => {
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toEqual([]);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', {})).rejects.toThrow('Access denied');
  });
});

describe('DiapersReportUseCase', () => {
  let useCase: DiapersReportUseCase;

  beforeEach(() => {
    useCase = new DiapersReportUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should count diaper changes per day grouped by type', async () => {
    const events = [
      {
        id: '1', babyId: 'baby-1', userId: 'user-1', eventType: 'diaper',
        occurredAt: new Date('2025-06-01T10:00:00Z'),
        details: { type: 'pee', color: 'yellow' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '2', babyId: 'baby-1', userId: 'user-1', eventType: 'diaper',
        occurredAt: new Date('2025-06-01T14:00:00Z'),
        details: { type: 'poop', color: 'green', consistency: 'normal' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
      {
        id: '3', babyId: 'baby-1', userId: 'user-1', eventType: 'diaper',
        occurredAt: new Date('2025-06-01T18:00:00Z'),
        details: { type: 'both', color: 'brown' },
        status: 'completed', scheduledAt: null, routineId: null, notes: null, createdAt: new Date(),
      },
    ];

    mockRoutineEventFindMany.mockResolvedValue(events);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toHaveLength(1);
    expect(result[0]).toEqual({ date: '2025-06-01', pee: 1, poop: 1, both: 1 });
  });

  it('should return empty array with no diaper events', async () => {
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toEqual([]);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', {})).rejects.toThrow('Access denied');
  });
});

describe('GrowthReportUseCase', () => {
  let useCase: GrowthReportUseCase;

  beforeEach(() => {
    useCase = new GrowthReportUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should list growth measurements ordered by date', async () => {
    mockGrowthFindMany.mockResolvedValue([
      {
        id: '1', babyId: 'baby-1', userId: 'user-1',
        measuredAt: new Date('2025-06-01'),
        weightKg: { valueOf: () => 3.5 } as any,
        heightCm: { valueOf: () => 50.5 } as any,
        headCircumferenceCm: { valueOf: () => 35.0 } as any,
        notes: 'First measurement',
        createdAt: new Date(),
      },
      {
        id: '2', babyId: 'baby-1', userId: 'user-1',
        measuredAt: new Date('2025-07-01'),
        weightKg: { valueOf: () => 4.8 } as any,
        heightCm: { valueOf: () => 55.0 } as any,
        headCircumferenceCm: { valueOf: () => 37.5 } as any,
        notes: null,
        createdAt: new Date(),
      },
    ]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toHaveLength(2);
    expect(result[0]).toEqual({
      id: '1', date: '2025-06-01',
      weightKg: 3.5, heightCm: 50.5, headCircumferenceCm: 35.0,
      notes: 'First measurement',
    });
    expect(result[1]).toEqual({
      id: '2', date: '2025-07-01',
      weightKg: 4.8, heightCm: 55.0, headCircumferenceCm: 37.5,
      notes: null,
    });
  });

  it('should filter by date range', async () => {
    mockGrowthFindMany.mockResolvedValue([]);

    await useCase.execute('baby-1', 'user-1', { startDate: '2025-06-01', endDate: '2025-06-30' });

    expect(mockGrowthFindMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          babyId: 'baby-1',
          measuredAt: {
            gte: new Date('2025-06-01T00:00:00.000Z'),
            lte: new Date('2025-06-30T23:59:59.999Z'),
          },
        }),
      })
    );
  });

  it('should handle null Decimal fields', async () => {
    mockGrowthFindMany.mockResolvedValue([
      {
        id: '1', babyId: 'baby-1', userId: 'user-1',
        measuredAt: new Date('2025-06-01'),
        weightKg: null,
        heightCm: null,
        headCircumferenceCm: null,
        notes: null,
        createdAt: new Date(),
      },
    ]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result[0]).toEqual({
      id: '1', date: '2025-06-01',
      weightKg: null, heightCm: null, headCircumferenceCm: null,
      notes: null,
    });
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', {})).rejects.toThrow('Access denied');
  });
});

describe('MedicationReportUseCase', () => {
  let useCase: MedicationReportUseCase;

  beforeEach(() => {
    useCase = new MedicationReportUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should list medication events with drug details', async () => {
    const events = [
      {
        id: '1', babyId: 'baby-1', userId: 'user-1', eventType: 'medication',
        occurredAt: new Date('2025-06-01T10:00:00Z'),
        details: { medicationName: 'Paracetamol', dose: '5ml', reason: 'Fever' },
        status: 'completed', scheduledAt: null, routineId: null, notes: 'Every 6 hours',
        createdAt: new Date(),
      },
      {
        id: '2', babyId: 'baby-1', userId: 'user-1', eventType: 'medication',
        occurredAt: new Date('2025-06-02T08:00:00Z'),
        details: { medicationName: 'Vitamin D', dose: '1 drop', reason: null },
        status: 'completed', scheduledAt: null, routineId: null, notes: null,
        createdAt: new Date(),
      },
    ];

    mockRoutineEventFindMany.mockResolvedValue(events);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toHaveLength(2);
    expect(result[0]).toEqual({
      id: '1', date: '2025-06-01',
      medicationName: 'Paracetamol', dose: '5ml', reason: 'Fever',
      notes: 'Every 6 hours',
    });
    expect(result[1]).toEqual({
      id: '2', date: '2025-06-02',
      medicationName: 'Vitamin D', dose: '1 drop', reason: null,
      notes: null,
    });
  });

  it('should return empty array with no medication events', async () => {
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1', {});

    expect(result).toEqual([]);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', {})).rejects.toThrow('Access denied');
  });
});

describe('ChecklistUseCase', () => {
  let useCase: ChecklistUseCase;

  beforeEach(() => {
    useCase = new ChecklistUseCase();
    jest.clearAllMocks();
    mockedBabiesRepo.findCaregiver.mockResolvedValue(caregiver);
  });

  it('should combine routine items with events for a date', async () => {
    mockRoutineFindMany.mockResolvedValue([
      { id: 'r-1', babyId: 'baby-1', userId: 'user-1', activityType: 'feeding', active: true, intervalMinutes: 180, defaultStartTime: '08:00', createdAt: new Date() },
      { id: 'r-2', babyId: 'baby-1', userId: 'user-1', activityType: 'sleep', active: true, intervalMinutes: null, defaultStartTime: '13:00', createdAt: new Date() },
      { id: 'r-3', babyId: 'baby-1', userId: 'user-1', activityType: 'diaper', active: true, intervalMinutes: 120, defaultStartTime: null, createdAt: new Date() },
    ]);

    mockRoutineEventFindMany.mockResolvedValue([
      {
        id: 'e-1', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-01T10:00:00Z'),
        details: { feedingType: 'bottle' }, status: 'completed',
        routineId: 'r-1', notes: null, scheduledAt: null, createdAt: new Date(),
      },
      {
        id: 'e-2', babyId: 'baby-1', userId: 'user-1', eventType: 'bath',
        occurredAt: new Date('2025-06-01T15:00:00Z'),
        details: { temperature: 'warm' }, status: 'completed',
        routineId: null, notes: 'Nice bath', scheduledAt: null, createdAt: new Date(),
      },
    ]);

    const result = await useCase.execute('baby-1', 'user-1', '2025-06-01');

    expect(result.date).toBe('2025-06-01');
    expect(result.items).toHaveLength(4);

    const feedingItem = result.items.find(i => i.type === 'routine' && i.activityType === 'feeding');
    expect(feedingItem).toEqual({
      type: 'routine', routineId: 'r-1', activityType: 'feeding',
      scheduledTime: '08:00', status: 'completed', eventId: 'e-1',
    });

    const sleepItem = result.items.find(i => i.type === 'routine' && i.activityType === 'sleep');
    expect(sleepItem).toEqual({
      type: 'routine', routineId: 'r-2', activityType: 'sleep',
      scheduledTime: '13:00', status: 'pending', eventId: null,
    });

    const diaperItem = result.items.find(i => i.type === 'routine' && i.activityType === 'diaper');
    expect(diaperItem).toEqual({
      type: 'routine', routineId: 'r-3', activityType: 'diaper',
      scheduledTime: null, status: 'pending', eventId: null,
    });

    const orphanEvent = result.items.find(i => i.type === 'event');
    expect(orphanEvent).toEqual({
      type: 'event', eventId: 'e-2', eventType: 'bath',
      occurredAt: expect.any(Date), status: 'completed', notes: 'Nice bath',
    });
  });

  it('should default to today when no date provided', async () => {
    mockRoutineFindMany.mockResolvedValue([]);
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1');

    const today = new Date().toISOString().slice(0, 10);
    expect(result.date).toBe(today);
    expect(result.items).toEqual([]);
  });

  it('should show all routines as pending when no events exist', async () => {
    mockRoutineFindMany.mockResolvedValue([
      { id: 'r-1', babyId: 'baby-1', userId: 'user-1', activityType: 'feeding', active: true, intervalMinutes: null, defaultStartTime: '08:00', createdAt: new Date() },
    ]);
    mockRoutineEventFindMany.mockResolvedValue([]);

    const result = await useCase.execute('baby-1', 'user-1', '2025-06-01');

    expect(result.items).toHaveLength(1);
    expect(result.items[0].status).toBe('pending');
  });

  it('should use event status for matching routines', async () => {
    mockRoutineFindMany.mockResolvedValue([
      { id: 'r-1', babyId: 'baby-1', userId: 'user-1', activityType: 'feeding', active: true, intervalMinutes: null, defaultStartTime: '08:00', createdAt: new Date() },
    ]);
    mockRoutineEventFindMany.mockResolvedValue([
      {
        id: 'e-1', babyId: 'baby-1', userId: 'user-1', eventType: 'feeding',
        occurredAt: new Date('2025-06-01T10:00:00Z'), details: {}, status: 'missed',
        routineId: 'r-1', notes: null, scheduledAt: null, createdAt: new Date(),
      },
    ]);

    const result = await useCase.execute('baby-1', 'user-1', '2025-06-01');

    expect(result.items[0].status).toBe('missed');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2')).rejects.toThrow('Access denied');
  });
});
