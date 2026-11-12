import { Request, Response, NextFunction } from 'express';
import {
  CreateReminderUseCase,
  ListRemindersUseCase,
  UpdateReminderUseCase,
  DeleteReminderUseCase,
} from './reminders.usecase';
import { CreateReminderInput, UpdateReminderInput } from './reminders.schemas';

const createReminderUseCase = new CreateReminderUseCase();
const listRemindersUseCase = new ListRemindersUseCase();
const updateReminderUseCase = new UpdateReminderUseCase();
const deleteReminderUseCase = new DeleteReminderUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const input = req.body as CreateReminderInput;
    const result = await createReminderUseCase.execute(babyId, req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const result = await listRemindersUseCase.execute(babyId, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function update(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const input = req.body as UpdateReminderInput;
    const result = await updateReminderUseCase.execute(babyId, id, req.userId!, input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    await deleteReminderUseCase.execute(babyId, id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
