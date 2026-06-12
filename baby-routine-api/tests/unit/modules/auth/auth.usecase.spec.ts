import { RegisterUseCase, LoginUseCase, UpdateFcmTokenUseCase } from 'src/modules/auth/auth.usecase';
import * as authRepository from 'src/modules/auth/auth.repository';
import { hashPassword, comparePassword } from 'src/shared/utils/bcrypt';
import { signToken } from 'src/shared/utils/jwt';

jest.mock('src/modules/auth/auth.repository');
jest.mock('src/shared/utils/bcrypt');
jest.mock('src/shared/utils/jwt');

const mockedRepo = authRepository as jest.Mocked<typeof authRepository>;
const mockedBcrypt = { hashPassword, comparePassword } as jest.Mocked<{
  hashPassword: jest.Mock;
  comparePassword: jest.Mock;
}>;
const mockedJwt = { signToken } as jest.Mocked<{ signToken: jest.Mock }>;

describe('RegisterUseCase', () => {
  let useCase: RegisterUseCase;

  beforeEach(() => {
    useCase = new RegisterUseCase();
    jest.clearAllMocks();
  });

  it('should register a new user successfully', async () => {
    const input = { name: 'Test User', email: 'test@example.com', password: 'Password1' };
    const fakeUser = { id: 'uuid-1', name: 'Test User', email: 'test@example.com', passwordHash: 'hash', fcmToken: null, createdAt: new Date() };
    const fakeToken = 'jwt-token';

    mockedRepo.findByEmail.mockResolvedValue(null);
    (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
    mockedRepo.createUser.mockResolvedValue(fakeUser);
    (signToken as jest.Mock).mockReturnValue(fakeToken);

    const result = await useCase.execute(input);

    expect(mockedRepo.findByEmail).toHaveBeenCalledWith(input.email);
    expect(hashPassword).toHaveBeenCalledWith(input.password);
    expect(mockedRepo.createUser).toHaveBeenCalledWith({
      name: input.name,
      email: input.email,
      passwordHash: 'hashed-password',
    });
    expect(signToken).toHaveBeenCalledWith({ sub: fakeUser.id, email: fakeUser.email });
    expect(result).toEqual({
      id: fakeUser.id,
      name: fakeUser.name,
      email: fakeUser.email,
      token: fakeToken,
    });
  });

  it('should throw 409 CONFLICT when email already exists', async () => {
    const input = { name: 'Test User', email: 'duplicate@example.com', password: 'Password1' };
    const existingUser = { id: 'uuid-1', name: 'Existing', email: 'duplicate@example.com', passwordHash: 'hash', fcmToken: null, createdAt: new Date() };

    mockedRepo.findByEmail.mockResolvedValue(existingUser);

    await expect(useCase.execute(input)).rejects.toThrow('Email already registered');
    try {
      await useCase.execute(input);
    } catch (error: any) {
      expect(error.statusCode).toBe(409);
      expect(error.code).toBe('CONFLICT');
    }
    expect(mockedRepo.createUser).not.toHaveBeenCalled();
  });
});

describe('LoginUseCase', () => {
  let useCase: LoginUseCase;

  beforeEach(() => {
    useCase = new LoginUseCase();
    jest.clearAllMocks();
  });

  it('should login successfully with valid credentials', async () => {
    const input = { email: 'test@example.com', password: 'Password1' };
    const fakeUser = { id: 'uuid-1', name: 'Test User', email: 'test@example.com', passwordHash: 'hash', fcmToken: null, createdAt: new Date() };
    const fakeToken = 'jwt-token';

    mockedRepo.findByEmail.mockResolvedValue(fakeUser);
    (comparePassword as jest.Mock).mockResolvedValue(true);
    (signToken as jest.Mock).mockReturnValue(fakeToken);

    const result = await useCase.execute(input);

    expect(mockedRepo.findByEmail).toHaveBeenCalledWith(input.email);
    expect(comparePassword).toHaveBeenCalledWith(input.password, fakeUser.passwordHash);
    expect(signToken).toHaveBeenCalledWith({ sub: fakeUser.id, email: fakeUser.email });
    expect(result).toEqual({
      token: fakeToken,
      user: {
        id: fakeUser.id,
        name: fakeUser.name,
        email: fakeUser.email,
        createdAt: fakeUser.createdAt,
      },
    });
  });

  it('should throw error with wrong password', async () => {
    const input = { email: 'test@example.com', password: 'WrongPassword1' };
    const fakeUser = { id: 'uuid-1', name: 'Test User', email: 'test@example.com', passwordHash: 'hash', fcmToken: null, createdAt: new Date() };

    mockedRepo.findByEmail.mockResolvedValue(fakeUser);
    (comparePassword as jest.Mock).mockResolvedValue(false);

    await expect(useCase.execute(input)).rejects.toThrow('Invalid email or password');
    expect(signToken).not.toHaveBeenCalled();
  });

  it('should throw error with non-existent email', async () => {
    const input = { email: 'nonexistent@example.com', password: 'Password1' };

    mockedRepo.findByEmail.mockResolvedValue(null);

    await expect(useCase.execute(input)).rejects.toThrow('Invalid email or password');
    expect(signToken).not.toHaveBeenCalled();
  });
});

describe('UpdateFcmTokenUseCase', () => {
  let useCase: UpdateFcmTokenUseCase;

  beforeEach(() => {
    useCase = new UpdateFcmTokenUseCase();
    jest.clearAllMocks();
  });

  it('should update FCM token successfully', async () => {
    const userId = 'uuid-1';
    const fcmToken = 'fcm-token-string';
    const updatedUser = { id: userId, name: 'Test', email: 'test@example.com', passwordHash: 'hash', fcmToken, createdAt: new Date() };

    mockedRepo.updateFcmToken.mockResolvedValue(updatedUser);

    const result = await useCase.execute(userId, fcmToken);

    expect(mockedRepo.updateFcmToken).toHaveBeenCalledWith(userId, fcmToken);
    expect(result).toEqual({ message: 'FCM token updated' });
  });
});
