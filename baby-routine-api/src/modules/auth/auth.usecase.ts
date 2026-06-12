import { AppError } from '../../shared/errors/AppError';
import { hashPassword, comparePassword } from '../../shared/utils/bcrypt';
import { signToken } from '../../shared/utils/jwt';
import * as authRepository from './auth.repository';
import { RegisterInput, LoginInput } from './auth.schemas';

export class RegisterUseCase {
  async execute(input: RegisterInput) {
    const existing = await authRepository.findByEmail(input.email);
    if (existing) {
      throw new AppError('Email already registered', 409, 'CONFLICT');
    }

    const passwordHash = await hashPassword(input.password);

    const user = await authRepository.createUser({
      name: input.name,
      email: input.email,
      passwordHash,
    });

    const token = signToken({ sub: user.id, email: user.email });

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      token,
    };
  }
}

export class LoginUseCase {
  async execute(input: LoginInput) {
    const user = await authRepository.findByEmail(input.email);
    if (!user) {
      throw new AppError('Invalid email or password', 400, 'INVALID_CREDENTIALS');
    }

    const isValid = await comparePassword(input.password, user.passwordHash);
    if (!isValid) {
      throw new AppError('Invalid email or password', 400, 'INVALID_CREDENTIALS');
    }

    const token = signToken({ sub: user.id, email: user.email });

    return {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt,
      },
    };
  }
}

export class UpdateFcmTokenUseCase {
  async execute(userId: string, fcmToken: string) {
    await authRepository.updateFcmToken(userId, fcmToken);
    return { message: 'FCM token updated' };
  }
}
