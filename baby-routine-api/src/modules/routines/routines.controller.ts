import { Request, Response, NextFunction } from 'express';
import {
  CreateRoutineUseCase,
  ListRoutinesUseCase,
  UpdateRoutineUseCase,
  DeleteRoutineUseCase,
  ToggleRoutineUseCase,
} from './routines.usecase';
import { CreateRoutineInput, UpdateRoutineInput, ToggleRoutineInput } from './routines.schemas';

const createRoutineUseCase = new CreateRoutineUseCase();
const listRoutinesUseCase = new ListRoutinesUseCase();
const updateRoutineUseCase = new UpdateRoutineUseCase();
const deleteRoutineUseCase = new DeleteRoutineUseCase();
const toggleRoutineUseCase = new ToggleRoutineUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const input = req.body as CreateRoutineInput;
    const result = await createRoutineUseCase.execute(babyId, req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const result = await listRoutinesUseCase.execute(babyId, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function update(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const input = req.body as UpdateRoutineInput;
    const result = await updateRoutineUseCase.execute(babyId, id, req.userId!, input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    await deleteRoutineUseCase.execute(babyId, id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}

export async function toggle(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const { active } = req.body as ToggleRoutineInput;
    const result = await toggleRoutineUseCase.execute(babyId, id, req.userId!, active);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
