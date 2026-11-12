import { AppError } from '../../shared/errors/AppError';
import * as routinesRepository from './routines.repository';
import * as babiesRepository from '../babies/babies.repository';
import { CreateRoutineInput, UpdateRoutineInput } from './routines.schemas';

export class CreateRoutineUseCase {
  async execute(babyId: string, userId: string, input: CreateRoutineInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const routine = await routinesRepository.create({
      babyId,
      userId,
      activityType: input.activityType,
      intervalMinutes: input.intervalMinutes,
      defaultStartTime: input.defaultStartTime,
    });

    return {
      id: routine.id,
      babyId: routine.babyId,
      userId: routine.userId,
      activityType: routine.activityType,
      intervalMinutes: routine.intervalMinutes,
      defaultStartTime: routine.defaultStartTime,
      active: routine.active,
      createdAt: routine.createdAt,
    };
  }
}

export class ListRoutinesUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const routines = await routinesRepository.findByBaby(babyId);

    return routines.map((r) => ({
      id: r.id,
      babyId: r.babyId,
      userId: r.userId,
      activityType: r.activityType,
      intervalMinutes: r.intervalMinutes,
      defaultStartTime: r.defaultStartTime,
      active: r.active,
      createdAt: r.createdAt,
    }));
  }
}

export class UpdateRoutineUseCase {
  async execute(babyId: string, routineId: string, userId: string, input: UpdateRoutineInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await routinesRepository.findById(routineId);

    if (!existing) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    const updated = await routinesRepository.update(routineId, input);

    return {
      id: updated.id,
      babyId: updated.babyId,
      userId: updated.userId,
      activityType: updated.activityType,
      intervalMinutes: updated.intervalMinutes,
      defaultStartTime: updated.defaultStartTime,
      active: updated.active,
      createdAt: updated.createdAt,
    };
  }
}

export class DeleteRoutineUseCase {
  async execute(babyId: string, routineId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await routinesRepository.findById(routineId);

    if (!existing) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    await routinesRepository.remove(routineId);
  }
}

export class ToggleRoutineUseCase {
  async execute(babyId: string, routineId: string, userId: string, active: boolean) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await routinesRepository.findById(routineId);

    if (!existing) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Routine not found', 404, 'NOT_FOUND');
    }

    const updated = await routinesRepository.toggleActive(routineId, active);

    return {
      id: updated.id,
      babyId: updated.babyId,
      userId: updated.userId,
      activityType: updated.activityType,
      intervalMinutes: updated.intervalMinutes,
      defaultStartTime: updated.defaultStartTime,
      active: updated.active,
      createdAt: updated.createdAt,
    };
  }
}
