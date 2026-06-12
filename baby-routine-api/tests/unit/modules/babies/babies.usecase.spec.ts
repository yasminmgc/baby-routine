import {
  CreateBabyUseCase,
  ListBabiesUseCase,
  GetBabyUseCase,
  UpdateBabyUseCase,
  DeleteBabyUseCase,
} from 'src/modules/babies/babies.usecase';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/babies/babies.repository');

const mockedRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateBabyUseCase', () => {
  let useCase: CreateBabyUseCase;

  beforeEach(() => {
    useCase = new CreateBabyUseCase();
    jest.clearAllMocks();
  });

  it('should create baby and insert owner in baby_caregivers in one transaction', async () => {
    const userId = 'user-uuid-1';
    const input = {
      name: 'Baby Test',
      birthDate: new Date('2025-06-01'),
      gender: 'female' as const,
      initialWeightKg: 3.5,
      initialHeightCm: 50,
      allergies: 'None',
    };

    const createdBaby = {
      id: 'baby-uuid-1',
      name: 'Baby Test',
      birthDate: new Date('2025-06-01'),
      gender: 'female',
      initialWeightKg: 3.5,
      initialHeightCm: 50,
      allergies: 'None',
      createdAt: new Date('2025-06-12'),
    };

    // Mock transaction: creates baby, then inserts caregiver
    const mockTx = {
      baby: {
        create: jest.fn().mockResolvedValue(createdBaby),
      },
      babyCaregiver: {
        create: jest.fn().mockResolvedValue({}),
      },
    };

    const mockPrisma = {
      $transaction: jest.fn().mockImplementation(async (fn: any) => {
        return fn(mockTx);
      }),
    };

    mockedRepo.getClient.mockReturnValue(mockPrisma as any);

    const result = await useCase.execute(userId, input);

    expect(mockPrisma.$transaction).toHaveBeenCalled();
    expect(mockTx.baby.create).toHaveBeenCalledWith({
      data: {
        name: 'Baby Test',
        birthDate: input.birthDate,
        gender: 'female',
        initialWeightKg: 3.5,
        initialHeightCm: 50,
        allergies: 'None',
      },
    });
    expect(mockTx.babyCaregiver.create).toHaveBeenCalledWith({
      data: {
        babyId: 'baby-uuid-1',
        userId,
        role: 'owner',
      },
    });

    expect(result).toEqual({
      id: 'baby-uuid-1',
      name: 'Baby Test',
      birthDate: createdBaby.birthDate,
      gender: 'female',
      initialWeightKg: 3.5,
      initialHeightCm: 50,
      allergies: 'None',
      createdAt: createdBaby.createdAt,
      currentUserRole: 'owner',
    });
  });

  it('should handle optional fields as undefined', async () => {
    const userId = 'user-uuid-1';
    const input = {
      name: 'Minimal Baby',
      birthDate: new Date('2025-06-01'),
    };

    const createdBaby = {
      id: 'baby-uuid-2',
      name: 'Minimal Baby',
      birthDate: new Date('2025-06-01'),
      gender: null,
      initialWeightKg: null,
      initialHeightCm: null,
      allergies: null,
      createdAt: new Date('2025-06-12'),
    };

    const mockTx = {
      baby: { create: jest.fn().mockResolvedValue(createdBaby) },
      babyCaregiver: { create: jest.fn().mockResolvedValue({}) },
    };

    const mockPrisma = {
      $transaction: jest.fn().mockImplementation(async (fn: any) => fn(mockTx)),
    };

    mockedRepo.getClient.mockReturnValue(mockPrisma as any);

    const result = await useCase.execute(userId, input);

    expect(mockTx.baby.create).toHaveBeenCalledWith({
      data: {
        name: 'Minimal Baby',
        birthDate: input.birthDate,
        gender: undefined,
        initialWeightKg: undefined,
        initialHeightCm: undefined,
        allergies: undefined,
      },
    });
    expect(result.currentUserRole).toBe('owner');
  });
});

describe('ListBabiesUseCase', () => {
  let useCase: ListBabiesUseCase;

  beforeEach(() => {
    useCase = new ListBabiesUseCase();
    jest.clearAllMocks();
  });

  it('should list babies where user is caregiver with currentUserRole', async () => {
    const userId = 'user-uuid-1';
    const fakeCaregivers = [
      {
        role: 'owner',
        baby: {
          id: 'baby-1',
          name: 'Baby One',
          birthDate: new Date('2025-01-01'),
          gender: 'male',
          initialWeightKg: 4.0,
          initialHeightCm: 52,
          allergies: null,
          createdAt: new Date('2025-01-01'),
        },
      },
      {
        role: 'caregiver',
        baby: {
          id: 'baby-2',
          name: 'Baby Two',
          birthDate: new Date('2025-03-01'),
          gender: null,
          initialWeightKg: null,
          initialHeightCm: null,
          allergies: 'Peanuts',
          createdAt: new Date('2025-03-01'),
        },
      },
    ];

    mockedRepo.findAllByUser.mockResolvedValue(fakeCaregivers as any);

    const result = await useCase.execute(userId);

    expect(mockedRepo.findAllByUser).toHaveBeenCalledWith(userId);
    expect(result).toHaveLength(2);
    expect(result[0].currentUserRole).toBe('owner');
    expect(result[1].currentUserRole).toBe('caregiver');
    expect(result[0].name).toBe('Baby One');
    expect(result[1].name).toBe('Baby Two');
  });

  it('should return empty array when user has no babies', async () => {
    mockedRepo.findAllByUser.mockResolvedValue([]);

    const result = await useCase.execute('user-without-babies');

    expect(result).toEqual([]);
  });
});

describe('GetBabyUseCase', () => {
  let useCase: GetBabyUseCase;

  beforeEach(() => {
    useCase = new GetBabyUseCase();
    jest.clearAllMocks();
  });

  it('should return baby when user is caregiver', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const fakeBaby = {
      id: babyId,
      name: 'Baby One',
      birthDate: new Date('2025-01-01'),
      gender: 'male',
      initialWeightKg: 4.0,
      initialHeightCm: 52,
      allergies: null,
      createdAt: new Date('2025-01-01'),
    };

    mockedRepo.findById.mockResolvedValue(fakeBaby as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(result).toEqual({
      id: babyId,
      name: 'Baby One',
      birthDate: fakeBaby.birthDate,
      gender: 'male',
      initialWeightKg: 4.0,
      initialHeightCm: 52,
      allergies: null,
      createdAt: fakeBaby.createdAt,
      currentUserRole: 'owner',
    });
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized-user'))
      .rejects.toThrow('Access denied');
    try {
      await useCase.execute('baby-1', 'unauthorized-user');
    } catch (error: any) {
      expect(error.statusCode).toBe(403);
      expect(error.code).toBe('FORBIDDEN');
    }
  });
});

describe('UpdateBabyUseCase', () => {
  let useCase: UpdateBabyUseCase;

  beforeEach(() => {
    useCase = new UpdateBabyUseCase();
    jest.clearAllMocks();
  });

  it('should update baby when user is caregiver', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    const updatedBaby = {
      id: babyId,
      name: 'Updated Baby',
      birthDate: new Date('2025-01-01'),
      gender: 'female',
      initialWeightKg: 4.2,
      initialHeightCm: 53,
      allergies: 'None',
      createdAt: new Date('2025-01-01'),
    };

    mockedRepo.update.mockResolvedValue(updatedBaby as any);

    const result = await useCase.execute(babyId, userId, { name: 'Updated Baby' });

    expect(mockedRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedRepo.update).toHaveBeenCalledWith(babyId, { name: 'Updated Baby' });
    expect(result.name).toBe('Updated Baby');
    expect(result.currentUserRole).toBe('caregiver');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized', { name: 'X' }))
      .rejects.toThrow('Access denied');
  });
});

describe('DeleteBabyUseCase', () => {
  let useCase: DeleteBabyUseCase;

  beforeEach(() => {
    useCase = new DeleteBabyUseCase();
    jest.clearAllMocks();
  });

  it('should delete baby when user is owner', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, userId);

    expect(mockedRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedRepo.remove).toHaveBeenCalledWith(babyId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
    expect(mockedRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 403 when user is caregiver but not owner', async () => {
    const babyId = 'baby-1';
    const userId = 'user-2';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-2',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    await expect(useCase.execute(babyId, userId))
      .rejects.toThrow('Only the owner can perform this action');
    try {
      await useCase.execute(babyId, userId);
    } catch (error: any) {
      expect(error.statusCode).toBe(403);
      expect(error.code).toBe('FORBIDDEN');
    }
    expect(mockedRepo.remove).not.toHaveBeenCalled();
  });
});
