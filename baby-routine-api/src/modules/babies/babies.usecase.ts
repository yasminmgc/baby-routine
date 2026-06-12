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

export class AddCaregiverUseCase {
  async execute(babyId: string, currentUserId: string, email: string) {
    const requesterCaregiver = await babiesRepository.findCaregiver(babyId, currentUserId);

    if (!requesterCaregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const targetUser = await babiesRepository.findUserByEmail(email);

    if (!targetUser) {
      throw new AppError('User not found with this email', 404, 'NOT_FOUND');
    }

    const existingCaregiver = await babiesRepository.findCaregiver(babyId, targetUser.id);

    if (existingCaregiver) {
      throw new AppError('User is already a caregiver for this baby', 409, 'CONFLICT');
    }

    await babiesRepository.addCaregiver(babyId, targetUser.id, 'caregiver');

    return { message: 'Caregiver added successfully.' };
  }
}

export class RemoveCaregiverUseCase {
  async execute(babyId: string, targetUserId: string, currentUserId: string) {
    const requesterCaregiver = await babiesRepository.findCaregiver(babyId, currentUserId);

    if (!requesterCaregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    if (requesterCaregiver.role !== 'owner') {
      throw new AppError('Only the owner can perform this action', 403, 'FORBIDDEN');
    }

    const targetCaregiver = await babiesRepository.findCaregiver(babyId, targetUserId);

    if (!targetCaregiver) {
      throw new AppError('Caregiver not found for this baby', 404, 'NOT_FOUND');
    }

    await babiesRepository.removeCaregiver(babyId, targetUserId);

    return { message: 'Caregiver removed successfully.' };
  }
}

export class ListCaregiversUseCase {
  async execute(babyId: string, userId: string) {
    const caregiver = await babiesRepository.findCaregiver(babyId, userId);

    if (!caregiver) {
      throw new AppError('Access denied', 403, 'FORBIDDEN');
    }

    const caregivers = await babiesRepository.listCaregivers(babyId);

    return caregivers.map((cg) => ({
      id: cg.id,
      userId: cg.user.id,
      name: cg.user.name,
      email: cg.user.email,
      role: cg.role,
      createdAt: cg.createdAt,
    }));
  }
}
