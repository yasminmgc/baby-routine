import {
  CreateEventUseCase,
  ListEventsUseCase,
  GetEventUseCase,
  UpdateEventUseCase,
  DeleteEventUseCase,
} from 'src/modules/events/events.usecase';
import * as eventsRepository from 'src/modules/events/events.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/events/events.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedEventsRepo = eventsRepository as jest.Mocked<typeof eventsRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateEventUseCase', () => {
  let useCase: CreateEventUseCase;

  beforeEach(() => {
    useCase = new CreateEventUseCase();
    jest.clearAllMocks();
  });

  it('should create a feeding event with valid details', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const input = {
      eventType: 'feeding' as const,
      details: { feedingType: 'bottle', amountMl: 120 },
      notes: 'Drank well',
    };

    const createdEvent = {
      id: 'event-1',
      babyId,
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      scheduledAt: null,
      status: 'completed',
      details: input.details,
      notes: input.notes,
      routineId: null,
      createdAt: new Date(),
    };

    mockedEventsRepo.create.mockResolvedValue(createdEvent as any);

    const result = await useCase.execute(babyId, userId, input);

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedEventsRepo.create).toHaveBeenCalled();
    expect(result.eventType).toBe('feeding');
    expect(result.status).toBe('completed');
  });

  it('should create a sleep event with valid details', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    const input = {
      eventType: 'sleep' as const,
      details: {
        startTime: '2026-05-08T14:00:00.000Z',
        endTime: '2026-05-08T15:30:00.000Z',
        durationMin: 90,
        location: 'crib',
      },
    };

    const createdEvent = {
      id: 'event-2',
      babyId,
      userId,
      eventType: 'sleep',
      occurredAt: new Date(),
      scheduledAt: null,
      status: 'completed',
      details: input.details,
      notes: null,
      routineId: null,
      createdAt: new Date(),
    };

    mockedEventsRepo.create.mockResolvedValue(createdEvent as any);

    const result = await useCase.execute(babyId, userId, input);

    expect(result.eventType).toBe('sleep');
  });

  it('should create a diaper event with valid details', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const input = {
      eventType: 'diaper' as const,
      details: {
        type: 'both' as const,
        color: 'yellow' as const,
        consistency: 'normal' as const,
        rash: false,
      },
    };

    const createdEvent = {
      id: 'event-3',
      babyId,
      userId,
      eventType: 'diaper',
      occurredAt: new Date(),
      scheduledAt: null,
      status: 'completed',
      details: input.details,
      notes: null,
      routineId: null,
      createdAt: new Date(),
    };

    mockedEventsRepo.create.mockResolvedValue(createdEvent as any);

    const result = await useCase.execute(babyId, userId, input);

    expect(result.eventType).toBe('diaper');
  });

  it('should throw 400 for invalid details per eventType', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    // feeding requires feedingType, but we pass invalid values
    const input = {
      eventType: 'feeding' as const,
      details: { wrongField: true },
    };

    await expect(useCase.execute(babyId, userId, input))
      .rejects.toThrow();

    expect(mockedEventsRepo.create).not.toHaveBeenCalled();
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    const input = {
      eventType: 'feeding' as const,
      details: { feedingType: 'bottle' as const },
    };

    await expect(useCase.execute('baby-1', 'unauthorized', input))
      .rejects.toThrow('Access denied');
    expect(mockedEventsRepo.create).not.toHaveBeenCalled();
  });
});

describe('ListEventsUseCase', () => {
  let useCase: ListEventsUseCase;

  beforeEach(() => {
    useCase = new ListEventsUseCase();
    jest.clearAllMocks();
  });

  it('should return paginated events with filters', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const paginatedResult = {
      data: [
        { id: 'event-1', eventType: 'feeding', babyId, userId },
        { id: 'event-2', eventType: 'sleep', babyId, userId },
      ],
      pagination: { page: 1, limit: 20, total: 2, totalPages: 1 },
    };

    mockedEventsRepo.findAllByBaby.mockResolvedValue(paginatedResult as any);

    const query = { type: undefined, page: 1, limit: 20 };

    const result = await useCase.execute(babyId, userId, query);

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedEventsRepo.findAllByBaby).toHaveBeenCalledWith(babyId, {
      type: undefined,
      startDate: undefined,
      endDate: undefined,
      page: 1,
      limit: 20,
    });
    expect(result.pagination.total).toBe(2);
  });

  it('should filter by type', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedEventsRepo.findAllByBaby.mockResolvedValue({
      data: [],
      pagination: { page: 1, limit: 20, total: 0, totalPages: 0 },
    });

    const query = { type: 'feeding' as const, page: 1, limit: 20 };

    await useCase.execute(babyId, userId, query);

    expect(mockedEventsRepo.findAllByBaby).toHaveBeenCalledWith(babyId, {
      type: 'feeding',
      startDate: undefined,
      endDate: undefined,
      page: 1,
      limit: 20,
    });
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    const query = { type: undefined, page: 1, limit: 20 };

    await expect(useCase.execute('baby-1', 'unauthorized', query))
      .rejects.toThrow('Access denied');
  });
});

describe('GetEventUseCase', () => {
  let useCase: GetEventUseCase;

  beforeEach(() => {
    useCase = new GetEventUseCase();
    jest.clearAllMocks();
  });

  it('should return event when user is caregiver', async () => {
    const babyId = 'baby-1';
    const eventId = 'event-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const event = {
      id: eventId,
      babyId,
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      scheduledAt: null,
      status: 'completed',
      details: {},
      notes: null,
      routineId: null,
      createdAt: new Date(),
      baby: { id: babyId, name: 'Baby Test' },
      user: { id: userId, name: 'User', email: 'user@example.com' },
    };

    mockedEventsRepo.findById.mockResolvedValue(event as any);

    const result = await useCase.execute(babyId, eventId, userId);

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedEventsRepo.findById).toHaveBeenCalledWith(eventId);
    expect(result.id).toBe(eventId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'event-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
  });

  it('should throw 404 when event not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedEventsRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1'))
      .rejects.toThrow('Event not found');
  });

  it('should throw 404 when event belongs to different baby', async () => {
    const userId = 'user-1';
    const wrongBabyId = 'baby-1';
    const eventId = 'event-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: wrongBabyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedEventsRepo.findById.mockResolvedValue({
      id: eventId,
      babyId: 'baby-2', // different baby
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      status: 'completed',
    } as any);

    await expect(useCase.execute(wrongBabyId, eventId, userId))
      .rejects.toThrow('Event not found');
  });
});

describe('UpdateEventUseCase', () => {
  let useCase: UpdateEventUseCase;

  beforeEach(() => {
    useCase = new UpdateEventUseCase();
    jest.clearAllMocks();
  });

  it('should update event details', async () => {
    const babyId = 'baby-1';
    const eventId = 'event-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedEventsRepo.findById.mockResolvedValue({
      id: eventId,
      babyId,
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      status: 'completed',
    } as any);

    const updatedEvent = {
      id: eventId,
      babyId,
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      status: 'completed',
      details: { feedingType: 'breast', amountMl: 150 },
      notes: 'Updated notes',
    };

    mockedEventsRepo.update.mockResolvedValue(updatedEvent as any);

    const result = await useCase.execute(babyId, eventId, userId, {
      notes: 'Updated notes',
    });

    expect(mockedEventsRepo.update).toHaveBeenCalledWith(eventId, { notes: 'Updated notes' });
    expect(result.notes).toBe('Updated notes');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'event-1', 'unauthorized', {}))
      .rejects.toThrow('Access denied');
  });

  it('should throw 404 when event not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedEventsRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1', { notes: 'test' }))
      .rejects.toThrow('Event not found');
  });
});

describe('DeleteEventUseCase', () => {
  let useCase: DeleteEventUseCase;

  beforeEach(() => {
    useCase = new DeleteEventUseCase();
    jest.clearAllMocks();
  });

  it('should delete event when user is caregiver', async () => {
    const babyId = 'baby-1';
    const eventId = 'event-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedEventsRepo.findById.mockResolvedValue({
      id: eventId,
      babyId,
      userId,
      eventType: 'feeding',
      occurredAt: new Date(),
      status: 'completed',
    } as any);

    mockedEventsRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, eventId, userId);

    expect(mockedEventsRepo.remove).toHaveBeenCalledWith(eventId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'event-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
    expect(mockedEventsRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 404 when event not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedEventsRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1'))
      .rejects.toThrow('Event not found');
    expect(mockedEventsRepo.remove).not.toHaveBeenCalled();
  });
});
