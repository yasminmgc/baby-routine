import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { validate } from 'src/shared/middlewares/validate.middleware';
import { AppError } from 'src/shared/errors/AppError';

describe('Middleware - Validate', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = {
      body: {},
      query: {},
      params: {},
    };
    res = {};
    next = jest.fn();
  });

  it('should call next() when no schemas are provided', () => {
    const middleware = validate({});
    middleware(req as Request, res as Response, next);
    expect(next).toHaveBeenCalled();
  });

  it('should validate body with Zod schema and call next on success', () => {
    const schema = z.object({
      name: z.string(),
      age: z.number(),
    });

    req.body = { name: 'John', age: 30 };
    const middleware = validate({ body: schema });

    middleware(req as Request, res as Response, next);

    expect(next).toHaveBeenCalled();
    expect(req.body).toEqual({ name: 'John', age: 30 });
  });

  it('should throw VALIDATION_ERROR when body validation fails', () => {
    const schema = z.object({
      name: z.string(),
      email: z.string().email(),
    });

    req.body = { name: 'John', email: 'not-an-email' };
    const middleware = validate({ body: schema });

    expect(() =>
      middleware(req as Request, res as Response, next)
    ).toThrow(AppError);

    try {
      middleware(req as Request, res as Response, next);
    } catch (error) {
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });

  it('should validate query with Zod schema', () => {
    const schema = z.object({
      page: z.coerce.number().min(1),
    });

    req.query = { page: '5' };
    const middleware = validate({ query: schema });

    middleware(req as Request, res as Response, next);

    expect(next).toHaveBeenCalled();
    expect(req.query).toEqual({ page: 5 });
  });

  it('should throw VALIDATION_ERROR when query validation fails', () => {
    const schema = z.object({
      page: z.coerce.number().min(1),
    });

    req.query = { page: '0' };
    const middleware = validate({ query: schema });

    try {
      middleware(req as Request, res as Response, next);
      fail('Expected error to be thrown');
    } catch (error) {
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });

  it('should validate params with Zod schema', () => {
    const schema = z.object({
      babyId: z.string().uuid(),
    });

    req.params = { babyId: '550e8400-e29b-41d4-a716-446655440000' };
    const middleware = validate({ params: schema });

    middleware(req as Request, res as Response, next);

    expect(next).toHaveBeenCalled();
  });

  it('should throw when params contain invalid UUID', () => {
    const schema = z.object({
      babyId: z.string().uuid(),
    });

    req.params = { babyId: 'not-a-uuid' };
    const middleware = validate({ params: schema });

    try {
      middleware(req as Request, res as Response, next);
      fail('Expected error to be thrown');
    } catch (error) {
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });

  it('should validate body, query, and params together', () => {
    const bodySchema = z.object({ title: z.string() });
    const querySchema = z.object({ filter: z.string().optional() });
    const paramsSchema = z.object({ id: z.string() });

    req.body = { title: 'Test' };
    req.query = { filter: 'active' };
    req.params = { id: 'abc-123' };

    const middleware = validate({
      body: bodySchema,
      query: querySchema,
      params: paramsSchema,
    });

    middleware(req as Request, res as Response, next);

    expect(next).toHaveBeenCalled();
  });

  it('should throw when any of multiple schemas fail', () => {
    const bodySchema = z.object({ title: z.string() });
    const paramsSchema = z.object({ id: z.string().uuid() });

    req.body = { title: 'Test' };
    req.params = { id: 'invalid-uuid' };

    const middleware = validate({ body: bodySchema, params: paramsSchema });

    try {
      middleware(req as Request, res as Response, next);
      fail('Expected error to be thrown');
    } catch (error) {
      const appError = error as AppError;
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });
});
