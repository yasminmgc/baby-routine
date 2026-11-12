import { Request, Response, NextFunction } from 'express';
import {
  CreateNoteUseCase,
  ListNotesUseCase,
  UpdateNoteUseCase,
  DeleteNoteUseCase,
} from './notes.usecase';
import { CreateNoteInput, UpdateNoteInput } from './notes.schemas';

const createNoteUseCase = new CreateNoteUseCase();
const listNotesUseCase = new ListNotesUseCase();
const updateNoteUseCase = new UpdateNoteUseCase();
const deleteNoteUseCase = new DeleteNoteUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const input = req.body as CreateNoteInput;
    const result = await createNoteUseCase.execute(babyId, req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const result = await listNotesUseCase.execute(babyId, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function update(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const input = req.body as UpdateNoteInput;
    const result = await updateNoteUseCase.execute(babyId, id, req.userId!, input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    await deleteNoteUseCase.execute(babyId, id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
