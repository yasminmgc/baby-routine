import { Request, Response, NextFunction } from 'express';
import {
  CreateBabyUseCase,
  ListBabiesUseCase,
  GetBabyUseCase,
  UpdateBabyUseCase,
  DeleteBabyUseCase,
  AddCaregiverUseCase,
  RemoveCaregiverUseCase,
  ListCaregiversUseCase,
} from './babies.usecase';
import { CreateBabyInput, UpdateBabyInput, AddCaregiverInput } from './babies.schemas';

const createBabyUseCase = new CreateBabyUseCase();
const listBabiesUseCase = new ListBabiesUseCase();
const getBabyUseCase = new GetBabyUseCase();
const updateBabyUseCase = new UpdateBabyUseCase();
const deleteBabyUseCase = new DeleteBabyUseCase();
const addCaregiverUseCase = new AddCaregiverUseCase();
const removeCaregiverUseCase = new RemoveCaregiverUseCase();
const listCaregiversUseCase = new ListCaregiversUseCase();

export async function create(req: Request, res: Response, next: NextFunction) {
  try {
    const input = req.body as CreateBabyInput;
    const result = await createBabyUseCase.execute(req.userId!, input);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

export async function list(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await listBabiesUseCase.execute(req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    const result = await getBabyUseCase.execute(id, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function update(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    const input = req.body as UpdateBabyInput;
    const result = await updateBabyUseCase.execute(id, req.userId!, input);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function remove(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    await deleteBabyUseCase.execute(id, req.userId!);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
}

export async function addCaregiver(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    const { email } = req.body as AddCaregiverInput;
    const result = await addCaregiverUseCase.execute(id, req.userId!, email);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function removeCaregiver(req: Request, res: Response, next: NextFunction) {
  try {
    const { id, userId } = req.params as { id: string; userId: string };
    const result = await removeCaregiverUseCase.execute(id, userId, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function listCaregivers(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params as { id: string };
    const result = await listCaregiversUseCase.execute(id, req.userId!);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
