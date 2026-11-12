import { AppError } from '../../shared/errors/AppError';
import * as notesRepository from './notes.repository';
import * as babiesRepository from '../babies/babies.repository';
import { CreateNoteInput, UpdateNoteInput } from './notes.schemas';

export class CreateNoteUseCase {
  async execute(babyId: string, userId: string, input: CreateNoteInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const note = await notesRepository.create({
      babyId,
      userId,
      content: input.content,
    });

    return {
      id: note.id,
      babyId: note.babyId,
      userId: note.userId,
      content: note.content,
      createdAt: note.createdAt,
    };
  }
}

export class ListNotesUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const notes = await notesRepository.findByBaby(babyId);

    return notes.map((n) => ({
      id: n.id,
      babyId: n.babyId,
      userId: n.userId,
      content: n.content,
      createdAt: n.createdAt,
    }));
  }
}

export class UpdateNoteUseCase {
  async execute(babyId: string, noteId: string, userId: string, input: UpdateNoteInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await notesRepository.findById(noteId);

    if (!existing) {
      throw new AppError('Note not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Note not found', 404, 'NOT_FOUND');
    }

    const updated = await notesRepository.update(noteId, { content: input.content });

    return {
      id: updated.id,
      babyId: updated.babyId,
      userId: updated.userId,
      content: updated.content,
      createdAt: updated.createdAt,
    };
  }
}

export class DeleteNoteUseCase {
  async execute(babyId: string, noteId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await notesRepository.findById(noteId);

    if (!existing) {
      throw new AppError('Note not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Note not found', 404, 'NOT_FOUND');
    }

    await notesRepository.remove(noteId);
  }
}
