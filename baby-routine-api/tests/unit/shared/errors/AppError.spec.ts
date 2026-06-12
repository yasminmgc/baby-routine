import { AppError } from 'src/shared/errors/AppError';

describe('AppError', () => {
  it('should create an AppError with default statusCode and code', () => {
    const error = new AppError('Something went wrong');

    expect(error).toBeInstanceOf(Error);
    expect(error).toBeInstanceOf(AppError);
    expect(error.message).toBe('Something went wrong');
    expect(error.statusCode).toBe(400);
    expect(error.code).toBe('INTERNAL_ERROR');
  });

  it('should create an AppError with custom statusCode', () => {
    const error = new AppError('Not found', 404);

    expect(error.message).toBe('Not found');
    expect(error.statusCode).toBe(404);
  });

  it('should create an AppError with custom statusCode and code', () => {
    const error = new AppError('Unauthorized', 401, 'UNAUTHORIZED');

    expect(error.message).toBe('Unauthorized');
    expect(error.statusCode).toBe(401);
    expect(error.code).toBe('UNAUTHORIZED');
  });

  it('should create an AppError for conflict scenario', () => {
    const error = new AppError('Email already exists', 409, 'CONFLICT');

    expect(error.statusCode).toBe(409);
    expect(error.code).toBe('CONFLICT');
  });

  it('should create an AppError for forbidden scenario', () => {
    const error = new AppError('Access denied', 403, 'FORBIDDEN');

    expect(error.statusCode).toBe(403);
    expect(error.code).toBe('FORBIDDEN');
  });
});
