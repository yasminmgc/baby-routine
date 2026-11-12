import { Request, Response, NextFunction } from 'express';
import {
  CreateEventUseCase,
  ListEventsUseCase,
  GetEventUseCase,
  UpdateEventUseCase,
  DeleteEventUseCase,
} from './events.usecase';
import { CreateEventInput, UpdateEventInput } from './events.schemas';

const createEventUseCase = new CreateEventUseCase();
const listEventsUseCase = new ListEventsUseCase();
const getEventUseCase = new GetEventUseCase();
const updateEventUseCase = new UpdateEventUseCase();
const deleteEventUseCase = new DeleteEventUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const input = req.body as CreateEventInput;
    const result = await createEventUseCase.execute(babyId, req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const query = {
      type: req.query.type as 'feeding' | 'sleep' | 'diaper' | 'bath' | 'appointment' | 'vaccination' | 'medication' | undefined,
      startDate: req.query.startDate ? new Date(req.query.startDate as string) : undefined,
      endDate: req.query.endDate ? new Date(req.query.endDate as string) : undefined,
      page: req.query.page ? parseInt(req.query.page as string, 10) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string, 10) : 20,
    };
    const result = await listEventsUseCase.execute(babyId, req.userId!, query);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const result = await getEventUseCase.execute(babyId, id, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function update(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    const input = req.body as UpdateEventInput;
    const result = await updateEventUseCase.execute(babyId, id, req.userId!, input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    await deleteEventUseCase.execute(babyId, id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
