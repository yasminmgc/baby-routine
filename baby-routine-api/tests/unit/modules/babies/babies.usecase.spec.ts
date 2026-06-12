import {
  CreateBabyUseCase,
  ListBabiesUseCase,
  GetBabyUseCase,
  UpdateBabyUseCase,
  DeleteBabyUseCase,
  AddCaregiverUseCase,
  RemoveCaregiverUseCase,
  ListCaregiversUseCase,
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

describe('AddCaregiverUseCase', () => {
  let useCase: AddCaregiverUseCase;

  beforeEach(() => {
    useCase = new AddCaregiverUseCase();
    jest.clearAllMocks();
  });

  it('should add caregiver by email successfully', async () => {
    const babyId = 'baby-1';
    const currentUserId = 'user-1';
    const email = 'newcaregiver@example.com';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-req',
      babyId,
      userId: currentUserId,
      role: 'owner',
      createdAt: new Date(),
    });

    const targetUser = {
      id: 'user-2',
      name: 'New Caregiver',
      email,
      passwordHash: 'hash',
      fcmToken: null,
      createdAt: new Date(),
    };

    mockedRepo.findUserByEmail.mockResolvedValue(targetUser);
    mockedRepo.findCaregiver.mockResolvedValueOnce({
      id: 'cg-req',
      babyId,
      userId: currentUserId,
      role: 'owner',
      createdAt: new Date(),
    }).mockResolvedValueOnce(null); // second call: check if target already caregiver

    mockedRepo.addCaregiver.mockResolvedValue({
      id: 'cg-new',
      babyId,
      userId: 'user-2',
      role: 'caregiver',
      createdAt: new Date(),
      user: { id: 'user-2', name: 'New Caregiver', email },
    } as any);

    const result = await useCase.execute(babyId, currentUserId, email);

    expect(mockedRepo.findUserByEmail).toHaveBeenCalledWith(email);
    expect(mockedRepo.addCaregiver).toHaveBeenCalledWith(babyId, 'user-2', 'caregiver');
    expect(result).toEqual({ message: 'Caregiver added successfully.' });
  });

  it('should throw 403 when requester is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized', 'someone@example.com'))
      .rejects.toThrow('Access denied');
  });

  it('should throw 404 when target user not found', async () => {
    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-req',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRepo.findUserByEmail.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-1', 'nonexistent@example.com'))
      .rejects.toThrow('User not found with this email');
  });

  it('should throw 409 when user is already a caregiver', async () => {
    const babyId = 'baby-1';
    const currentUserId = 'user-1';
    const email = 'existing@example.com';

    mockedRepo.findCaregiver.mockResolvedValueOnce({
      id: 'cg-req',
      babyId,
      userId: currentUserId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRepo.findUserByEmail.mockResolvedValue({
      id: 'user-2',
      name: 'Existing',
      email,
      passwordHash: 'hash',
      fcmToken: null,
      createdAt: new Date(),
    });

    mockedRepo.findCaregiver.mockResolvedValueOnce({
      id: 'cg-existing',
      babyId,
      userId: 'user-2',
      role: 'caregiver',
      createdAt: new Date(),
    });

    await expect(useCase.execute(babyId, currentUserId, email))
      .rejects.toThrow('User is already a caregiver for this baby');
    try {
      await useCase.execute(babyId, currentUserId, email);
    } catch (error: any) {
      expect(error.statusCode).toBe(409);
      expect(error.code).toBe('CONFLICT');
    }
  });
});

describe('RemoveCaregiverUseCase', () => {
  let useCase: RemoveCaregiverUseCase;

  beforeEach(() => {
    useCase = new RemoveCaregiverUseCase();
    jest.clearAllMocks();
  });

  it('should remove caregiver when requester is owner', async () => {
    const babyId = 'baby-1';
    const targetUserId = 'user-2';
    const currentUserId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValueOnce({
      id: 'cg-req',
      babyId,
      userId: currentUserId,
      role: 'owner',
      createdAt: new Date(),
    }).mockResolvedValueOnce({
      id: 'cg-target',
      babyId,
      userId: targetUserId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedRepo.removeCaregiver.mockResolvedValue({} as any);

    const result = await useCase.execute(babyId, targetUserId, currentUserId);

    expect(mockedRepo.removeCaregiver).toHaveBeenCalledWith(babyId, targetUserId);
    expect(result).toEqual({ message: 'Caregiver removed successfully.' });
  });

  it('should throw 403 when requester is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'user-2', 'unauthorized'))
      .rejects.toThrow('Access denied');
  });

  it('should throw 403 when requester is caregiver but not owner', async () => {
    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-req',
      babyId: 'baby-1',
      userId: 'user-2',
      role: 'caregiver',
      createdAt: new Date(),
    });

    await expect(useCase.execute('baby-1', 'user-3', 'user-2'))
      .rejects.toThrow('Only the owner can perform this action');
  });

  it('should throw 404 when target caregiver not found', async () => {
    const babyId = 'baby-1';
    const currentUserId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValueOnce({
      id: 'cg-req',
      babyId,
      userId: currentUserId,
      role: 'owner',
      createdAt: new Date(),
    }).mockResolvedValueOnce(null); // target not found

    await expect(useCase.execute(babyId, 'nonexistent', currentUserId))
      .rejects.toThrow('Caregiver not found for this baby');
  });
});

describe('ListCaregiversUseCase', () => {
  let useCase: ListCaregiversUseCase;

  beforeEach(() => {
    useCase = new ListCaregiversUseCase();
    jest.clearAllMocks();
  });

  it('should list caregivers for a baby when user is caregiver', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedRepo.findCaregiver.mockResolvedValue({
      id: 'cg-req',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const fakeCaregivers = [
      {
        id: 'cg-1',
        babyId,
        userId: 'user-1',
        role: 'owner',
        createdAt: new Date('2025-01-01'),
        user: { id: 'user-1', name: 'Owner User', email: 'owner@example.com' },
      },
      {
        id: 'cg-2',
        babyId,
        userId: 'user-2',
        role: 'caregiver',
        createdAt: new Date('2025-02-01'),
        user: { id: 'user-2', name: 'Caregiver User', email: 'caregiver@example.com' },
      },
    ];

    mockedRepo.listCaregivers.mockResolvedValue(fakeCaregivers as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedRepo.listCaregivers).toHaveBeenCalledWith(babyId);
    expect(result).toHaveLength(2);
    expect(result[0]).toEqual({
      id: 'cg-1',
      userId: 'user-1',
      name: 'Owner User',
      email: 'owner@example.com',
      role: 'owner',
      createdAt: fakeCaregivers[0].createdAt,
    });
    expect(result[1].role).toBe('caregiver');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
  });
});
