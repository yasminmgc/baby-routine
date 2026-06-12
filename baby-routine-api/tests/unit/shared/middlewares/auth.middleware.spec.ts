import { Request, Response, NextFunction } from 'express';
import { authMiddleware } from 'src/shared/middlewares/auth.middleware';

// Mock jwt module
jest.mock('src/shared/utils/jwt', () => ({
  verifyToken: jest.fn(),
}));

describe('Middleware - Auth', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = {
      headers: {},
    };
    res = {};
    next = jest.fn();
    jest.clearAllMocks();
  });

  it('should throw 401 when no authorization header is present', () => {
    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Authentication required');
  });

  it('should throw 401 when authorization header is not Bearer', () => {
    req.headers = { authorization: 'Basic abc123' };

    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Invalid authorization format');
  });

  it('should throw 401 when authorization header has invalid format', () => {
    req.headers = { authorization: 'Bearer' }; // missing token

    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Invalid authorization format');
  });

  it('should throw 401 when authorization header has too many parts', () => {
    req.headers = { authorization: 'Bearer token extra' };

    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Invalid authorization format');
  });

  it('should call next() and set userId when token is valid', () => {
    const { verifyToken } = require('src/shared/utils/jwt');
    (verifyToken as jest.Mock).mockReturnValue({ sub: 'user-abc' });

    req.headers = { authorization: 'Bearer valid.jwt.token' };

    authMiddleware(req as Request, res as Response, next);

    expect(verifyToken).toHaveBeenCalledWith('valid.jwt.token');
    expect(req.userId).toBe('user-abc');
    expect(next).toHaveBeenCalled();
  });

  it('should throw 401 when token verification fails', () => {
    const { verifyToken } = require('src/shared/utils/jwt');
    (verifyToken as jest.Mock).mockImplementation(() => {
      throw new Error('jwt malformed');
    });

    req.headers = { authorization: 'Bearer invalid.jwt.token' };

    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Invalid or expired token');
  });

  it('should handle authorization header with extra whitespace', () => {
    const { verifyToken } = require('src/shared/utils/jwt');
    (verifyToken as jest.Mock).mockReturnValue({ sub: 'user-xyz' });

    req.headers = { authorization: 'Bearer   spaced.token.here' };

    expect(() =>
      authMiddleware(req as Request, res as Response, next)
    ).toThrow('Invalid authorization format');
  });
});
