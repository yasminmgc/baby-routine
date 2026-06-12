import {
  CreateMeasurementUseCase,
  ListMeasurementsUseCase,
  DeleteMeasurementUseCase,
} from 'src/modules/measurements/measurements.usecase';
import * as measurementsRepository from 'src/modules/measurements/measurements.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/measurements/measurements.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedMeasurementsRepo = measurementsRepository as jest.Mocked<typeof measurementsRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateMeasurementUseCase', () => {
  let useCase: CreateMeasurementUseCase;

  beforeEach(() => {
    useCase = new CreateMeasurementUseCase();
    jest.clearAllMocks();
  });

  it('should create a measurement with measuredAt only', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';
    const measuredAt = new Date('2025-06-15');

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const created = {
      id: 'm-1',
      babyId,
      userId,
      measuredAt,
      weightKg: null,
      heightCm: null,
      headCircumferenceCm: null,
      notes: null,
      createdAt: new Date(),
    };

    mockedMeasurementsRepo.create.mockResolvedValue(created as any);

    const result = await useCase.execute(babyId, userId, { measuredAt });

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedMeasurementsRepo.create).toHaveBeenCalledWith({
      babyId,
      userId,
      measuredAt,
      weightKg: undefined,
      heightCm: undefined,
      headCircumferenceCm: undefined,
      notes: undefined,
    });
    expect(result.id).toBe('m-1');
    expect(result.measuredAt).toBe(measuredAt);
  });

  it('should create a measurement with all fields', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';
    const measuredAt = new Date('2025-06-15');

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const created = {
      id: 'm-2',
      babyId,
      userId,
      measuredAt,
      weightKg: 5.2 as any,
      heightCm: 58.5 as any,
      headCircumferenceCm: 38.0 as any,
      notes: 'Growing well',
      createdAt: new Date(),
    };

    mockedMeasurementsRepo.create.mockResolvedValue(created as any);

    const result = await useCase.execute(babyId, userId, {
      measuredAt,
      weightKg: 5.2,
      heightCm: 58.5,
      headCircumferenceCm: 38.0,
      notes: 'Growing well',
    });

    expect(result.weightKg).toBe(5.2);
    expect(result.heightCm).toBe(58.5);
    expect(result.headCircumferenceCm).toBe(38.0);
    expect(result.notes).toBe('Growing well');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized', { measuredAt: new Date() })
    ).rejects.toThrow('Access denied');

    expect(mockedMeasurementsRepo.create).not.toHaveBeenCalled();
  });
});

describe('ListMeasurementsUseCase', () => {
  let useCase: ListMeasurementsUseCase;

  beforeEach(() => {
    useCase = new ListMeasurementsUseCase();
    jest.clearAllMocks();
  });

  it('should list measurements ordered by measuredAt desc', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedMeasurementsRepo.findByBaby.mockResolvedValue([
      {
        id: 'm-2',
        babyId,
        userId,
        measuredAt: new Date('2025-06-20'),
        weightKg: 6.0 as any,
        heightCm: null as any,
        headCircumferenceCm: null as any,
        notes: null,
        createdAt: new Date(),
      },
      {
        id: 'm-1',
        babyId,
        userId,
        measuredAt: new Date('2025-06-10'),
        weightKg: null as any,
        heightCm: null as any,
        headCircumferenceCm: null as any,
        notes: null,
        createdAt: new Date(),
      },
    ] as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedMeasurementsRepo.findByBaby).toHaveBeenCalledWith(babyId);
    expect(result).toHaveLength(2);
    expect(result[0].id).toBe('m-2');
    expect(result[1].id).toBe('m-1');
  });

  it('should return empty array when baby has no measurements', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedMeasurementsRepo.findByBaby.mockResolvedValue([]);

    const result = await useCase.execute(babyId, userId);

    expect(result).toHaveLength(0);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized')
    ).rejects.toThrow('Access denied');
  });
});

describe('DeleteMeasurementUseCase', () => {
  let useCase: DeleteMeasurementUseCase;

  beforeEach(() => {
    useCase = new DeleteMeasurementUseCase();
    jest.clearAllMocks();
  });

  it('should delete measurement when user is caregiver', async () => {
    const babyId = 'baby-1';
    const measurementId = 'm-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedMeasurementsRepo.findById.mockResolvedValue({
      id: measurementId,
      babyId,
      userId,
      measuredAt: new Date(),
    } as any);

    mockedMeasurementsRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, measurementId, userId);

    expect(mockedMeasurementsRepo.remove).toHaveBeenCalledWith(measurementId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'm-1', 'unauthorized')
    ).rejects.toThrow('Access denied');

    expect(mockedMeasurementsRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 404 when measurement not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedMeasurementsRepo.findById.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'nonexistent', 'user-1')
    ).rejects.toThrow('Measurement not found');
  });

  it('should throw 404 when measurement belongs to different baby', async () => {
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedMeasurementsRepo.findById.mockResolvedValue({
      id: 'm-1',
      babyId: 'baby-2',
      userId,
      measuredAt: new Date(),
    } as any);

    await expect(
      useCase.execute('baby-1', 'm-1', userId)
    ).rejects.toThrow('Measurement not found');
  });
});
