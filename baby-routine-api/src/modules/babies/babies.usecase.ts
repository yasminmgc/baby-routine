import { AppError } from '../../shared/errors/AppError';
import * as babiesRepository from './babies.repository';
import { CreateBabyInput, UpdateBabyInput } from './babies.schemas';

export class CreateBabyUseCase {
  async execute(userId: string, input: CreateBabyInput) {
    const prisma = babiesRepository.getClient();

    const baby = await prisma.$transaction(async (tx) => {
      const created = await tx.baby.create({
        data: {
          name: input.name,
          birthDate: input.birthDate,
          gender: input.gender,
          initialWeightKg: input.initialWeightKg,
          initialHeightCm: input.initialHeightCm,
          allergies: input.allergies,
        },
      });

      await tx.babyCaregiver.create({
        data: {
          babyId: created.id,
          userId,
          role: 'owner',
        },
      });

      return created;
    });

    return {
      id: baby.id,
      name: baby.name,
      birthDate: baby.birthDate,
      gender: baby.gender,
      initialWeightKg: baby.initialWeightKg,
      initialHeightCm: baby.initialHeightCm,
      allergies: baby.allergies,
      createdAt: baby.createdAt,
      currentUserRole: 'owner',
    };
  }
}

export class ListBabiesUseCase {
  async execute(userId: string) {
    const caregivers = await babiesRepository.findAllByUser(userId);

    return caregivers.map((cg) => ({
      id: cg.baby.id,
      name: cg.baby.name,
      birthDate: cg.baby.birthDate,
      gender: cg.baby.gender,
      initialWeightKg: cg.baby.initialWeightKg,
      initialHeightCm: cg.baby.initialHeightCm,
      allergies: cg.baby.allergies,
      createdAt: cg.baby.createdAt,
      currentUserRole: cg.role,
    }));
  }
}

export class GetBabyUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const baby = await babiesRepository.findById(babyId);

    if (!baby) {
      throw new AppError('Baby not found', 404, 'NOT_FOUND');
    }

    return {
      id: baby.id,
      name: baby.name,
      birthDate: baby.birthDate,
      gender: baby.gender,
      initialWeightKg: baby.initialWeightKg,
      initialHeightCm: baby.initialHeightCm,
      allergies: baby.allergies,
      createdAt: baby.createdAt,
      currentUserRole: caregiver.role,
    };
  }
}

export class UpdateBabyUseCase {
  async execute(babyId: string, userId: string, input: UpdateBabyInput) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const baby = await babiesRepository.update(babyId, input);

    return {
      id: baby.id,
      name: baby.name,
      birthDate: baby.birthDate,
      gender: baby.gender,
      initialWeightKg: baby.initialWeightKg,
      initialHeightCm: baby.initialHeightCm,
      allergies: baby.allergies,
      createdAt: baby.createdAt,
      currentUserRole: caregiver.role,
    };
  }
}

export class DeleteBabyUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    if (caregiver.role !== 'owner') {
      throw new AppError('Only the owner can perform this action', 403, 'FORBIDDEN');
    }

    await babiesRepository.remove(babyId);
  }
}
