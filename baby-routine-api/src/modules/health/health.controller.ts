import { Request, Response, NextFunction } from 'express';
import { ListHealthRecordsUseCase } from './health.usecase';

const listHealthRecordsUseCase = new ListHealthRecordsUseCase();

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const type = req.query.type as string | undefined;
    const result = await listHealthRecordsUseCase.execute(babyId, req.userId!, type);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
