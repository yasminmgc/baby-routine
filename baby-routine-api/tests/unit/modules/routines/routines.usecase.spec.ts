import {
  CreateRoutineUseCase,
  ListRoutinesUseCase,
  UpdateRoutineUseCase,
  DeleteRoutineUseCase,
  ToggleRoutineUseCase,
} from 'src/modules/routines/routines.usecase';
import * as routinesRepository from 'src/modules/routines/routines.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/routines/routines.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedRoutinesRepo = routinesRepository as jest.Mocked<typeof routinesRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateRoutineUseCase', () => {
  let useCase: CreateRoutineUseCase;

  beforeEach(() => {
    useCase = new CreateRoutineUseCase();
    jest.clearAllMocks();
  });

  it('should create a routine with activityType', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const createdRoutine = {
      id: 'routine-1',
      babyId,
      userId,
      activityType: 'feeding',
      intervalMinutes: null,
      defaultStartTime: null,
      active: true,
      createdAt: new Date(),
    };

    mockedRoutinesRepo.create.mockResolvedValue(createdRoutine as any);

    const result = await useCase.execute(babyId, userId, {
      activityType: 'feeding',
    });

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedRoutinesRepo.create).toHaveBeenCalledWith({
      babyId,
      userId,
      activityType: 'feeding',
      intervalMinutes: undefined,
      defaultStartTime: undefined,
    });
    expect(result.activityType).toBe('feeding');
    expect(result.active).toBe(true);
  });

  it('should create a routine with interval and start time', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const createdRoutine = {
      id: 'routine-2',
      babyId,
      userId,
      activityType: 'sleep',
      intervalMinutes: 120,
      defaultStartTime: '14:00',
      active: true,
      createdAt: new Date(),
    };

    mockedRoutinesRepo.create.mockResolvedValue(createdRoutine as any);

    const result = await useCase.execute(babyId, userId, {
      activityType: 'sleep',
      intervalMinutes: 120,
      defaultStartTime: '14:00',
    });

    expect(result.intervalMinutes).toBe(120);
    expect(result.defaultStartTime).toBe('14:00');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized', { activityType: 'feeding' })
    ).rejects.toThrow('Access denied');
    expect(mockedRoutinesRepo.create).not.toHaveBeenCalled();
  });
});

describe('ListRoutinesUseCase', () => {
  let useCase: ListRoutinesUseCase;

  beforeEach(() => {
    useCase = new ListRoutinesUseCase();
    jest.clearAllMocks();
  });

  it('should list all routines for a baby', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findByBaby.mockResolvedValue([
      { id: 'r-1', babyId, userId, activityType: 'feeding', intervalMinutes: null, defaultStartTime: null, active: true, createdAt: new Date() },
      { id: 'r-2', babyId, userId, activityType: 'sleep', intervalMinutes: 180, defaultStartTime: null, active: false, createdAt: new Date() },
    ] as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedRoutinesRepo.findByBaby).toHaveBeenCalledWith(babyId);
    expect(result).toHaveLength(2);
    expect(result[0].activityType).toBe('feeding');
    expect(result[1].active).toBe(false);
  });

  it('should return empty array when baby has no routines', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findByBaby.mockResolvedValue([]);

    const result = await useCase.execute(babyId, userId);

    expect(result).toHaveLength(0);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
  });
});

describe('UpdateRoutineUseCase', () => {
  let useCase: UpdateRoutineUseCase;

  beforeEach(() => {
    useCase = new UpdateRoutineUseCase();
    jest.clearAllMocks();
  });

  it('should update routine configuration', async () => {
    const babyId = 'baby-1';
    const routineId = 'routine-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findById.mockResolvedValue({
      id: routineId,
      babyId,
      userId,
      activityType: 'feeding',
      intervalMinutes: null,
      defaultStartTime: null,
      active: true,
    } as any);

    const updatedRoutine = {
      id: routineId,
      babyId,
      userId,
      activityType: 'feeding',
      intervalMinutes: 60,
      defaultStartTime: '08:00',
      active: true,
      createdAt: new Date(),
    };

    mockedRoutinesRepo.update.mockResolvedValue(updatedRoutine as any);

    const result = await useCase.execute(babyId, routineId, userId, {
      intervalMinutes: 60,
      defaultStartTime: '08:00',
    });

    expect(mockedRoutinesRepo.update).toHaveBeenCalledWith(routineId, {
      intervalMinutes: 60,
      defaultStartTime: '08:00',
    });
    expect(result.intervalMinutes).toBe(60);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'routine-1', 'unauthorized', { activityType: 'feeding' })
    ).rejects.toThrow('Access denied');
  });

  it('should throw 404 when routine not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRoutinesRepo.findById.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'nonexistent', 'user-1', { activityType: 'feeding' })
    ).rejects.toThrow('Routine not found');
  });

  it('should throw 404 when routine belongs to different baby', async () => {
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findById.mockResolvedValue({
      id: 'routine-1',
      babyId: 'baby-2', // different baby
      userId,
      activityType: 'feeding',
      active: true,
    } as any);

    await expect(
      useCase.execute('baby-1', 'routine-1', userId, { activityType: 'feeding' })
    ).rejects.toThrow('Routine not found');
  });
});

describe('DeleteRoutineUseCase', () => {
  let useCase: DeleteRoutineUseCase;

  beforeEach(() => {
    useCase = new DeleteRoutineUseCase();
    jest.clearAllMocks();
  });

  it('should delete routine when user is caregiver', async () => {
    const babyId = 'baby-1';
    const routineId = 'routine-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findById.mockResolvedValue({
      id: routineId,
      babyId,
      userId,
      activityType: 'feeding',
      active: true,
    } as any);

    mockedRoutinesRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, routineId, userId);

    expect(mockedRoutinesRepo.remove).toHaveBeenCalledWith(routineId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'routine-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
    expect(mockedRoutinesRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 404 when routine not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRoutinesRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1'))
      .rejects.toThrow('Routine not found');
  });
});

describe('ToggleRoutineUseCase', () => {
  let useCase: ToggleRoutineUseCase;

  beforeEach(() => {
    useCase = new ToggleRoutineUseCase();
    jest.clearAllMocks();
  });

  it('should toggle routine active to false', async () => {
    const babyId = 'baby-1';
    const routineId = 'routine-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findById.mockResolvedValue({
      id: routineId,
      babyId,
      userId,
      activityType: 'feeding',
      active: true,
    } as any);

    const toggled = {
      id: routineId,
      babyId,
      userId,
      activityType: 'feeding',
      intervalMinutes: null,
      defaultStartTime: null,
      active: false,
      createdAt: new Date(),
    };

    mockedRoutinesRepo.toggleActive.mockResolvedValue(toggled as any);

    const result = await useCase.execute(babyId, routineId, userId, false);

    expect(mockedRoutinesRepo.toggleActive).toHaveBeenCalledWith(routineId, false);
    expect(result.active).toBe(false);
  });

  it('should toggle routine active to true', async () => {
    const babyId = 'baby-1';
    const routineId = 'routine-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRoutinesRepo.findById.mockResolvedValue({
      id: routineId,
      babyId,
      userId,
      activityType: 'sleep',
      active: false,
    } as any);

    const toggled = {
      id: routineId,
      babyId,
      userId,
      activityType: 'sleep',
      intervalMinutes: null,
      defaultStartTime: null,
      active: true,
      createdAt: new Date(),
    };

    mockedRoutinesRepo.toggleActive.mockResolvedValue(toggled as any);

    const result = await useCase.execute(babyId, routineId, userId, true);

    expect(mockedRoutinesRepo.toggleActive).toHaveBeenCalledWith(routineId, true);
    expect(result.active).toBe(true);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'routine-1', 'unauthorized', true))
      .rejects.toThrow('Access denied');
  });

  it('should throw 404 when routine not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRoutinesRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1', true))
      .rejects.toThrow('Routine not found');
  });
});
