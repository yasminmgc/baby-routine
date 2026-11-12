import { GetUserProfileUseCase } from 'src/modules/users/users.usecase';
import * as usersRepository from 'src/modules/users/users.repository';

jest.mock('src/modules/users/users.repository');

const mockedRepo = usersRepository as jest.Mocked<typeof usersRepository>;

describe('GetUserProfileUseCase', () => {
  let useCase: GetUserProfileUseCase;

  beforeEach(() => {
    useCase = new GetUserProfileUseCase();
    jest.clearAllMocks();
  });

  it('should return user profile without passwordHash', async () => {
    const fakeUser = {
      id: 'uuid-1',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: new Date('2025-01-01'),
    };

    mockedRepo.findById.mockResolvedValue(fakeUser);

    const result = await useCase.execute('uuid-1');

    expect(mockedRepo.findById).toHaveBeenCalledWith('uuid-1');
    expect(result).toEqual({
      id: 'uuid-1',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: fakeUser.createdAt,
    });
    // Ensure passwordHash is NOT in the response
    expect(result).not.toHaveProperty('passwordHash');
  });

  it('should throw 404 when user not found', async () => {
    mockedRepo.findById.mockResolvedValue(null);

    await expect(useCase.execute('nonexistent')).rejects.toThrow('User not found');
    try {
      await useCase.execute('nonexistent');
    } catch (error: any) {
      expect(error.statusCode).toBe(404);
      expect(error.code).toBe('NOT_FOUND');
    }
  });
});
