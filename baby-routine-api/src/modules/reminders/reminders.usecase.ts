import { AppError } from '../../shared/errors/AppError';
import * as remindersRepository from './reminders.repository';
import * as babiesRepository from '../babies/babies.repository';
import { CreateReminderInput, UpdateReminderInput } from './reminders.schemas';

export class CreateReminderUseCase {
  async execute(babyId: string, userId: string, input: CreateReminderInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const reminder = await remindersRepository.create({
      babyId,
      userId,
      reminderType: input.reminderType,
      description: input.description,
      triggerAt: input.triggerAt,
      recurrence: input.recurrence,
      routineId: input.routineId,
    });

    return {
      id: reminder.id,
      babyId: reminder.babyId,
      userId: reminder.userId,
      reminderType: reminder.reminderType,
      description: reminder.description,
      triggerAt: reminder.triggerAt,
      recurrence: reminder.recurrence,
      active: reminder.active,
      sent: reminder.sent,
      routineId: reminder.routineId,
      createdAt: reminder.createdAt,
    };
  }
}

export class ListRemindersUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const reminders = await remindersRepository.findByBaby(babyId);

    return reminders.map((r) => ({
      id: r.id,
      babyId: r.babyId,
      userId: r.userId,
      reminderType: r.reminderType,
      description: r.description,
      triggerAt: r.triggerAt,
      recurrence: r.recurrence,
      active: r.active,
      sent: r.sent,
      routineId: r.routineId,
      routine: r.routine,
      createdAt: r.createdAt,
    }));
  }
}

export class UpdateReminderUseCase {
  async execute(babyId: string, reminderId: string, userId: string, input: UpdateReminderInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await remindersRepository.findById(reminderId);

    if (!existing) {
      throw new AppError('Reminder not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Reminder not found', 404, 'NOT_FOUND');
    }

    const updated = await remindersRepository.update(reminderId, input);

    return {
      id: updated.id,
      babyId: updated.babyId,
      userId: updated.userId,
      reminderType: updated.reminderType,
      description: updated.description,
      triggerAt: updated.triggerAt,
      recurrence: updated.recurrence,
      active: updated.active,
      sent: updated.sent,
      routineId: updated.routineId,
      createdAt: updated.createdAt,
    };
  }
}

export class DeleteReminderUseCase {
  async execute(babyId: string, reminderId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await remindersRepository.findById(reminderId);

    if (!existing) {
      throw new AppError('Reminder not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Reminder not found', 404, 'NOT_FOUND');
    }

    await remindersRepository.remove(reminderId);
  }
}
