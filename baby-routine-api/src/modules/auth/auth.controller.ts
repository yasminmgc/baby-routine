import { Request, Response, NextFunction } from 'express';
import { RegisterUseCase, LoginUseCase, UpdateFcmTokenUseCase } from './auth.usecase';
import { RegisterInput, LoginInput, FcmTokenInput } from './auth.schemas';

const registerUseCase = new RegisterUseCase();
const loginUseCase = new LoginUseCase();
const updateFcmTokenUseCase = new UpdateFcmTokenUseCase();

export async function register(req: Request, res: Response, next: NextFunction) {
  try {
    const input = req.body as RegisterInput;
    const result = await registerUseCase.execute(input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function login(req: Request, res: Response, next: NextFunction) {
  try {
    const input = req.body as LoginInput;
    const result = await loginUseCase.execute(input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function updateFcmToken(req: Request, res: Response, next: NextFunction) {
  try {
    const input = req.body as FcmTokenInput;
    const result = await updateFcmTokenUseCase.execute(req.userId!, input.fcmToken);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
