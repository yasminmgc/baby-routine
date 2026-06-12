import { Request, Response, NextFunction } from 'express';
import { GetUserProfileUseCase } from './users.usecase';

const getUserProfileUseCase = new GetUserProfileUseCase();

export async function getUserProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    const result = await getUserProfileUseCase.execute(id);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
