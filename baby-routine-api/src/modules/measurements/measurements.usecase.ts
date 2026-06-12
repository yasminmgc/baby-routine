import { AppError } from '../../shared/errors/AppError';
import * as measurementsRepository from './measurements.repository';
import * as babiesRepository from '../babies/babies.repository';
import { CreateMeasurementInput } from './measurements.schemas';

export class CreateMeasurementUseCase {
  async execute(babyId: string, userId: string, input: CreateMeasurementInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const measurement = await measurementsRepository.create({
      babyId,
      userId,
      measuredAt: input.measuredAt,
      weightKg: input.weightKg,
      heightCm: input.heightCm,
      headCircumferenceCm: input.headCircumferenceCm,
      notes: input.notes,
    });

    return {
      id: measurement.id,
      babyId: measurement.babyId,
      userId: measurement.userId,
      measuredAt: measurement.measuredAt,
      weightKg: measurement.weightKg,
      heightCm: measurement.heightCm,
      headCircumferenceCm: measurement.headCircumferenceCm,
      notes: measurement.notes,
      createdAt: measurement.createdAt,
    };
  }
}

export class ListMeasurementsUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const measurements = await measurementsRepository.findByBaby(babyId);

    return measurements.map((m) => ({
      id: m.id,
      babyId: m.babyId,
      userId: m.userId,
      measuredAt: m.measuredAt,
      weightKg: m.weightKg,
      heightCm: m.heightCm,
      headCircumferenceCm: m.headCircumferenceCm,
      notes: m.notes,
      createdAt: m.createdAt,
    }));
  }
}

export class DeleteMeasurementUseCase {
  async execute(babyId: string, measurementId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const existing = await measurementsRepository.findById(measurementId);

    if (!existing) {
      throw new AppError('Measurement not found', 404, 'NOT_FOUND');
    }

    if (existing.babyId !== babyId) {
      throw new AppError('Measurement not found', 404, 'NOT_FOUND');
    }

    await measurementsRepository.remove(measurementId);
  }
}
