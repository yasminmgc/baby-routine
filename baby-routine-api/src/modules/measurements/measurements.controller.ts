import { Request, Response, NextFunction } from 'express';
import {
  CreateMeasurementUseCase,
  ListMeasurementsUseCase,
  DeleteMeasurementUseCase,
} from './measurements.usecase';
import { CreateMeasurementInput } from './measurements.schemas';

const createMeasurementUseCase = new CreateMeasurementUseCase();
const listMeasurementsUseCase = new ListMeasurementsUseCase();
const deleteMeasurementUseCase = new DeleteMeasurementUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const input = req.body as CreateMeasurementInput;
    const result = await createMeasurementUseCase.execute(babyId, req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const result = await listMeasurementsUseCase.execute(babyId, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId, id } = req.params as { babyId: string; id: string };
    await deleteMeasurementUseCase.execute(babyId, id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
