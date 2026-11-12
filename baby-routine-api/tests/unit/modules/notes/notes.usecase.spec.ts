import {
  CreateNoteUseCase,
  ListNotesUseCase,
  UpdateNoteUseCase,
  DeleteNoteUseCase,
} from 'src/modules/notes/notes.usecase';
import * as notesRepository from 'src/modules/notes/notes.repository';
import * as babiesRepository from 'src/modules/babies/babies.repository';

jest.mock('src/modules/notes/notes.repository');
jest.mock('src/modules/babies/babies.repository');

const mockedNotesRepo = notesRepository as jest.Mocked<typeof notesRepository>;
const mockedBabiesRepo = babiesRepository as jest.Mocked<typeof babiesRepository>;

describe('CreateNoteUseCase', () => {
  let useCase: CreateNoteUseCase;

  beforeEach(() => {
    useCase = new CreateNoteUseCase();
    jest.clearAllMocks();
  });

  it('should create a note with content', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    const created = {
      id: 'note-1',
      babyId,
      userId,
      content: 'Baby slept through the night!',
      createdAt: new Date(),
    };

    mockedNotesRepo.create.mockResolvedValue(created as any);

    const result = await useCase.execute(babyId, userId, {
      content: 'Baby slept through the night!',
    });

    expect(mockedBabiesRepo.findCaregiver).toHaveBeenCalledWith(babyId, userId);
    expect(mockedNotesRepo.create).toHaveBeenCalledWith({
      babyId,
      userId,
      content: 'Baby slept through the night!',
    });
    expect(result.id).toBe('note-1');
    expect(result.content).toBe('Baby slept through the night!');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'unauthorized', { content: 'Some note' })
    ).rejects.toThrow('Access denied');

    expect(mockedNotesRepo.create).not.toHaveBeenCalled();
  });
});

describe('ListNotesUseCase', () => {
  let useCase: ListNotesUseCase;

  beforeEach(() => {
    useCase = new ListNotesUseCase();
    jest.clearAllMocks();
  });

  it('should list notes ordered by createdAt desc', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedNotesRepo.findByBaby.mockResolvedValue([
      {
        id: 'note-2',
        babyId,
        userId,
        content: 'Second note',
        createdAt: new Date('2025-06-20'),
      },
      {
        id: 'note-1',
        babyId,
        userId,
        content: 'First note',
        createdAt: new Date('2025-06-10'),
      },
    ] as any);

    const result = await useCase.execute(babyId, userId);

    expect(mockedNotesRepo.findByBaby).toHaveBeenCalledWith(babyId);
    expect(result).toHaveLength(2);
    expect(result[0].content).toBe('Second note');
    expect(result[1].content).toBe('First note');
  });

  it('should return empty array when baby has no notes', async () => {
    const babyId = 'baby-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedNotesRepo.findByBaby.mockResolvedValue([]);

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

describe('UpdateNoteUseCase', () => {
  let useCase: UpdateNoteUseCase;

  beforeEach(() => {
    useCase = new UpdateNoteUseCase();
    jest.clearAllMocks();
  });

  it('should update note content', async () => {
    const babyId = 'baby-1';
    const noteId = 'note-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedNotesRepo.findById.mockResolvedValue({
      id: noteId,
      babyId,
      userId,
      content: 'Old content',
    } as any);

    const updated = {
      id: noteId,
      babyId,
      userId,
      content: 'Updated content',
      createdAt: new Date(),
    };

    mockedNotesRepo.update.mockResolvedValue(updated as any);

    const result = await useCase.execute(babyId, noteId, userId, {
      content: 'Updated content',
    });

    expect(mockedNotesRepo.update).toHaveBeenCalledWith(noteId, { content: 'Updated content' });
    expect(result.content).toBe('Updated content');
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'note-1', 'unauthorized', { content: 'Updated' })
    ).rejects.toThrow('Access denied');
  });

  it('should throw 404 when note not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedNotesRepo.findById.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'nonexistent', 'user-1', { content: 'Updated' })
    ).rejects.toThrow('Note not found');
  });

  it('should throw 404 when note belongs to different baby', async () => {
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId,
      role: 'owner',
      createdAt: new Date(),
    });

    mockedNotesRepo.findById.mockResolvedValue({
      id: 'note-1',
      babyId: 'baby-2',
      userId,
      content: 'Some note',
    } as any);

    await expect(
      useCase.execute('baby-1', 'note-1', userId, { content: 'Updated' })
    ).rejects.toThrow('Note not found');
  });
});

describe('DeleteNoteUseCase', () => {
  let useCase: DeleteNoteUseCase;

  beforeEach(() => {
    useCase = new DeleteNoteUseCase();
    jest.clearAllMocks();
  });

  it('should delete note when user is caregiver', async () => {
    const babyId = 'baby-1';
    const noteId = 'note-1';
    const userId = 'user-1';

    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId,
      userId,
      role: 'caregiver',
      createdAt: new Date(),
    });

    mockedNotesRepo.findById.mockResolvedValue({
      id: noteId,
      babyId,
      userId,
      content: 'Some note',
    } as any);

    mockedNotesRepo.remove.mockResolvedValue({} as any);

    await useCase.execute(babyId, noteId, userId);

    expect(mockedNotesRepo.remove).toHaveBeenCalledWith(noteId);
  });

  it('should throw 403 when user is not a caregiver', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'note-1', 'unauthorized')
    ).rejects.toThrow('Access denied');

    expect(mockedNotesRepo.remove).not.toHaveBeenCalled();
  });

  it('should throw 404 when note not found', async () => {
    mockedBabiesRepo.findCaregiver.mockResolvedValue({
      id: 'cg-1',
      babyId: 'baby-1',
      userId: 'user-1',
      role: 'owner',
      createdAt: new Date(),
    });
    mockedNotesRepo.findById.mockResolvedValue(null);

    await expect(
      useCase.execute('baby-1', 'nonexistent', 'user-1')
    ).rejects.toThrow('Note not found');
  });
});
