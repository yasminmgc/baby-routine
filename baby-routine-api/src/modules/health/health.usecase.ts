import { AppError } from '../../shared/errors/AppError';
import * as healthRepository from './health.repository';
import * as babiesRepository from '../babies/babies.repository';

export class ListHealthRecordsUseCase {
  async execute(babyId: string, userId: string, type?: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const records = await healthRepository.findByBaby(babyId, type);

    return records.map((r) => ({
      id: r.id,
      babyId: r.babyId,
      userId: r.userId,
      recordType: r.recordType,
      occurredAt: r.occurredAt,
      title: r.title,
      description: r.description,
      createdAt: r.createdAt,
    }));
  }
}
