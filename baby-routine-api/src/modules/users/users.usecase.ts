import { AppError } from '../../shared/errors/AppError';
import * as usersRepository from './users.repository';

export class GetUserProfileUseCase {
  async execute(userId: string) {
    const user = await usersRepository.findById(userId);

    if (!user) {
      throw new AppError('User not found', 404, 'NOT_FOUND');
    }

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    };
  }
}
