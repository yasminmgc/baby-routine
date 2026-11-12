import { ListHealthRecordsUseCase } from 'src/modules/health/health.usecase';
import * as healthRepository from 'src/modules/health/health.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/health/health.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedHealthRepo = healthRepository as jest.Mocked<typeof healthRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('ListHealthRecordsUseCase', () => {
  let useCase: ListHealthRecordsUseCase;

  beforeEach(() => {
    useCase = new ListHealthRecordsUseCase();
    jest.clearAllMocks();
  });

  it('should list all health records for a baby', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedHealthRepo.findByBaby.mockResolvedValue([
      {
        id: 'hr-1',
        babyId,
        userId,
        recordType: 'vaccination',
        occurredAt: new Date('2025-06-01'),
        title: 'BCG Vaccine',
        description: 'First dose',
        createdAt: new Date(),
      },
      {
        id: 'hr-2',
        babyId,
        userId,
        recordType: 'appointment',
        occurredAt: new Date('2025-06-10'),
        title: 'Pediatrician visit',
        description: 'Monthly checkup',
        createdAt: new Date(),
      },
    ] as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedHealthRepo.findByBaby).toHaveBeenCalledWith(babyId, undefined);
    expect(result).toHaveLength(2);
    expect(result[0].recordType).toBe('vaccination');
    expect(result[1].recordType).toBe('appointment');
  });

  it('should filter health records by type', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedHealthRepo.findByBaby.mockResolvedValue([
      {
        id: 'hr-1',
        babyId,
        userId,
        recordType: 'vaccination',
        occurredAt: new Date('2025-06-01'),
        title: 'BCG Vaccine',
        description: null,
        createdAt: new Date(),
      },
    ] as any);

    const result = await useCase.execute(babyId, userId, 'vaccination');

    expect(mockedHealthRepo.findByBaby).toHaveBeenCalledWith(babyId, 'vaccination');
    expect(result).toHaveLength(1);
    expect(result[0].recordType).toBe('vaccination');
  });

  it('should return empty array when no health records exist', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedHealthRepo.findByBaby.mockResolvedValue([]);

    const result = await useCase.execute(babyId, userId);

    expect(result).toHaveLength(0);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized')
    ).rejects.toThrow('Access denied');

    expect(mockedHealthRepo.findByBaby).not.toHaveBeenCalled();
  });
});
