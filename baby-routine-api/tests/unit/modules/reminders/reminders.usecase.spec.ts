import {
  CreateReminderUseCase,
  ListRemindersUseCase,
  UpdateReminderUseCase,
  DeleteReminderUseCase,
} from 'src/modules/reminders/reminders.usecase';
import * as remindersRepository from 'src/modules/reminders/reminders.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/reminders/reminders.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedRemindersRepo = remindersRepository as jest.Mocked<typeof remindersRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateReminderUseCase', () => {
  let useCase: CreateReminderUseCase;

  beforeEach(() => {
    useCase = new CreateReminderUseCase();
    jest.clearAllMocks();
  });

  it('should create a reminder with triggerAt', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';
    const triggerAt = new Date('2026-05-10T08:00:00.000Z');

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const createdReminder = {
      id: 'reminder-1',
      babyId,
      userId,
      reminderType: 'feeding',
      description: 'Hora da mamadeira',
      triggerAt,
      recurrence: 'none',
      active: true,
      sent: false,
      routineId: null,
      createdAt: new Date(),
    };

    mockedRemindersRepo.create.mockResolvedValue(createdReminder as any);

    const result = await useCase.execute(babyId, userId, {
      reminderType: 'feeding',
      description: 'Hora da mamadeira',
      triggerAt,
    });

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedRemindersRepo.create).toHaveBeenCalledWith({
      babyId,
      userId,
      reminderType: 'feeding',
      description: 'Hora da mamadeira',
      triggerAt,
      recurrence: undefined,
      routineId: undefined,
    });
    expect(result.reminderType).toBe('feeding');
    expect(result.description).toBe('Hora da mamadeira');
  });

  it('should create a reminder with recurrence and routineId', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';
    const triggerAt = new Date('2026-05-10T14:00:00.000Z');

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const createdReminder = {
      id: 'reminder-2',
      babyId,
      userId,
      reminderType: 'sleep',
      description: 'Hora do soninho',
      triggerAt,
      recurrence: 'daily',
      active: true,
      sent: false,
      routineId: 'routine-1',
      createdAt: new Date(),
    };

    mockedRemindersRepo.create.mockResolvedValue(createdReminder as any);

    const result = await useCase.execute(babyId, userId, {
      reminderType: 'sleep',
      description: 'Hora do soninho',
      triggerAt,
      recurrence: 'daily',
      routineId: 'routine-1',
    });

    expect(result.recurrence).toBe('daily');
    expect(result.routineId).toBe('routine-1');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized', {
        reminderType: 'feeding',
        description: 'Test',
        triggerAt: new Date(),
      })
    ).rejects.toThrow('Access denied');
    expect(mockedRemindersRepo.create).not.toHaveBeenCalled();
  });
});

describe('ListRemindersUseCase', () => {
  let useCase: ListRemindersUseCase;

  beforeEach(() => {
    useCase = new ListRemindersUseCase();
    jest.clearAllMocks();
  });

  it('should list reminders for a baby', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRemindersRepo.findByBaby.mockResolvedValue([
      {
        id: 'r-1',
        babyId,
        userId,
        reminderType: 'feeding',
        description: 'Mamadeira',
        triggerAt: new Date(),
        recurrence: 'none',
        active: true,
        sent: false,
        routineId: null,
        routine: null,
        createdAt: new Date(),
      },
      {
        id: 'r-2',
        babyId,
        userId,
        reminderType: 'sleep',
        description: 'Soneca',
        triggerAt: new Date(),
        recurrence: 'daily',
        active: true,
        sent: false,
        routineId: null,
        routine: null,
        createdAt: new Date(),
      },
    ] as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedRemindersRepo.findByBaby).toHaveBeenCalledWith(babyId);
    expect(result).toHaveLength(2);
    expect(result[0].reminderType).toBe('feeding');
    expect(result[1].recurrence).toBe('daily');
  });

  it('should return empty array when no reminders', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRemindersRepo.findByBaby.mockResolvedValue([]);

    const result = await useCase.execute(babyId, userId);

    expect(result).toHaveLength(0);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
  });
});

describe('UpdateReminderUseCase', () => {
  let useCase: UpdateReminderUseCase;

  beforeEach(() => {
    useCase = new UpdateReminderUseCase();
    jest.clearAllMocks();
  });

  it('should update reminder description', async () => {
    const babyId = 'baby-1';
    const reminderId = 'reminder-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRemindersRepo.findById.mockResolvedValue({
      id: reminderId,
      babyId,
      userId,
      reminderType: 'feeding',
      description: 'Old description',
      triggerAt: new Date(),
      recurrence: 'none',
      active: true,
      sent: false,
      routineId: null,
    } as any);

    const updatedReminder = {
      id: reminderId,
      babyId,
      userId,
      reminderType: 'feeding',
      description: 'New description',
      triggerAt: new Date(),
      recurrence: 'daily',
      active: true,
      sent: false,
      routineId: null,
      createdAt: new Date(),
    };

    mockedRemindersRepo.update.mockResolvedValue(updatedReminder as any);

    const result = await useCase.execute(babyId, reminderId, userId, {
      description: 'New description',
      recurrence: 'daily',
    });

    expect(mockedRemindersRepo.update).toHaveBeenCalledWith(reminderId, {
      description: 'New description',
      recurrence: 'daily',
    });
    expect(result.description).toBe('New description');
    expect(result.recurrence).toBe('daily');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'reminder-1', 'unauthorized', { description: 'test' })
    ).rejects.toThrow('Access denied');
  });

  it('should throw 404 when reminder not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRemindersRepo.findById.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'nonexistent', 'user-1', { description: 'test' })
    ).rejects.toThrow('Reminder not found');
  });

  it('should throw 404 when reminder belongs to different baby', async () => {
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedRemindersRepo.findById.mockResolvedValue({
      id: 'reminder-1',
      babyId: 'baby-2', // different baby
      userId,
      reminderType: 'feeding',
      description: 'test',
      active: true,
    } as any);

    await expect(
      useCase.execute('baby-1', 'reminder-1', userId, { description: 'test' })
    ).rejects.toThrow('Reminder not found');
  });
});

describe('DeleteReminderUseCase', () => {
  let useCase: DeleteReminderUseCase;

  beforeEach(() => {
    useCase = new DeleteReminderUseCase();
    jest.clearAllMocks();
  });

  it('should delete reminder when user is caregiver', async () => {
    const babyId = 'baby-1';
    const reminderId = 'reminder-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedRemindersRepo.findById.mockResolvedValue({
      id: reminderId,
      babyId,
      userId,
      reminderType: 'feeding',
      description: 'test',
      active: true,
    } as any);

    mockedRemindersRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, reminderId, userId);

    expect(mockedRemindersRepo.remove).toHaveBeenCalledWith(reminderId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'reminder-1', 'unauthorized'))
      .rejects.toThrow('Access denied');
    expect(mockedRemindersRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 404 when reminder not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedRemindersRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('baby-1', 'nonexistent', 'user-1'))
      .rejects.toThrow('Reminder not found');
  });
});
