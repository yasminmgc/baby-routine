import { Request, Response, NextFunction } from 'express';
import { errorMiddleware } from 'src/shared/middlewares/error.middleware';
import { AppError } from 'src/shared/errors/AppError';

describe('Middleware - Error', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = {};
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
  });

  it('should handle AppError with correct status code and code', () => {
    const error = new AppError('Resource not found', 404, 'NOT_FOUND');

    errorMiddleware(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({
      status: 'error',
      message: 'Resource not found',
      code: 'NOT_FOUND',
    });
  });

  it('should handle AppError with default code', () => {
    const error = new AppError('Bad request');

    errorMiddleware(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      status: 'error',
      message: 'Bad request',
      code: 'INTERNAL_ERROR',
    });
  });

  it('should handle unknown errors as 500', () => {
    const error = new Error('Unexpected crash');

    errorMiddleware(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({
      status: 'error',
      message: 'Internal server error',
      code: 'INTERNAL_ERROR',
    });
  });

  it('should handle authentication errors', () => {
    const error = new AppError('Authentication required', 401, 'UNAUTHORIZED');

    errorMiddleware(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({
      status: 'error',
      message: 'Authentication required',
      code: 'UNAUTHORIZED',
    });
  });

  it('should handle validation errors', () => {
    const error = new AppError('name: Required', 400, 'VALIDATION_ERROR');

    errorMiddleware(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      status: 'error',
      message: 'name: Required',
      code: 'VALIDATION_ERROR',
    });
  });
});
